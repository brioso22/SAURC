import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

// Importaciones de tus archivos
import 'post_create_dark_screen.dart'; 
import 'help_dark_screen.dart';        
import 'settings_dark_screen.dart';    
import 'maps_dark_screen.dart'; // <--- Nueva importación

class HomeDarkScreen extends StatefulWidget {
  const HomeDarkScreen({super.key});

  @override
  State<HomeDarkScreen> createState() => _HomeDarkScreenState();
}

class _HomeDarkScreenState extends State<HomeDarkScreen> {
  int _selectedIndex = 0;

  // Lista de pantallas actualizada
  final List<Widget> _screens = [
    const GlobalPostsScreen(),           
    const MapsDarkScreen(), // <--- Añadida la pantalla del mapa
    const PostCreateDarkScreen(),        
    const HelpDarkScreen(),              
    const SettingsDarkScreen(),          
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text("SAURC", 
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: colors.primary)
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: colors.primary.withOpacity(0.1), 
            child: Icon(Icons.person, color: colors.primary, size: 20)
          ),
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: colors.surface,
        indicatorColor: colors.primary.withOpacity(0.2),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.forum_outlined), label: 'Posts'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Mapa'), // <--- Nuevo botón
          NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Denunciar'),
          NavigationDestination(icon: Icon(Icons.help_outline), label: 'Ayuda'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Config'),
        ],
      ),
    );
  }
}

// --- PANTALLA DE POSTS GLOBALES ---

class GlobalPostsScreen extends StatelessWidget {
  const GlobalPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('denuncias').orderBy('fecha_creacion', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("Error de conexión", style: TextStyle(color: colors.error)));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return Center(child: Text("No hay denuncias activas", style: TextStyle(color: colors.onSurface.withOpacity(0.3))));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            return PostWidget(docId: docs[index].id, data: docs[index].data() as Map<String, dynamic>);
          },
        );
      },
    );
  }
}

// --- WIDGET DE POST INDIVIDUAL ---

class PostWidget extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  const PostWidget({super.key, required this.docId, required this.data});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final List likes = data['likes'] ?? [];
    final bool isLiked = user != null && likes.contains(user.uid);
    final colors = Theme.of(context).colorScheme;

    void toggleLike() {
      if (user == null) return;
      DocumentReference postRef = FirebaseFirestore.instance.collection('denuncias').doc(docId);
      isLiked 
        ? postRef.update({'likes': FieldValue.arrayRemove([user.uid])})
        : postRef.update({'likes': FieldValue.arrayUnion([user.uid])});
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: colors.primary.withOpacity(0.1),
              child: Icon(Icons.person_outline, color: colors.primary),
            ),
            title: Text(data['categoria'] ?? "General", 
              style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface)),
            subtitle: Text("${data['nombre_usuario'] ?? 'Anónimo'} • SAURC", 
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _buildImage(data['url_imagen'], colors),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(data['descripcion'] ?? "", 
              style: TextStyle(color: colors.onSurface.withOpacity(0.8), fontSize: 14)),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 10, right: 10), 
            child: Row(
              children: [
                IconButton(
                  icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : colors.onSurfaceVariant),
                  onPressed: toggleLike,
                ),
                Text("${likes.length}", style: TextStyle(color: colors.onSurfaceVariant)),
                const SizedBox(width: 15),
                IconButton(
                  icon: Icon(Icons.chat_bubble_outline, color: colors.onSurfaceVariant),
                  onPressed: () => _showComments(context, docId, colors),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.share_outlined, color: colors.onSurfaceVariant),
                  onPressed: () => Share.share("Alerta SAURC: ${data['categoria']} en tu zona."),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String? input, ColorScheme colors) {
    if (input == null || input.isEmpty) {
      return Container(
        height: 200, width: double.infinity, color: colors.surfaceContainer,
        child: Icon(Icons.image_not_supported, color: colors.onSurface.withOpacity(0.1)),
      );
    }
    try {
      return Image.memory(base64Decode(input), width: double.infinity, height: 250, fit: BoxFit.cover);
    } catch (e) {
      return Container(
        height: 200, width: double.infinity, color: colors.surfaceContainer,
        child: Icon(Icons.broken_image, color: colors.onSurface.withOpacity(0.1)),
      );
    }
  }

  void _showComments(BuildContext context, String postId, ColorScheme colors) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => _CommentsSection(postId: postId, colors: colors),
    );
  }
}

// --- SECCIÓN DE COMENTARIOS ---

class _CommentsSection extends StatefulWidget {
  final String postId;
  final ColorScheme colors;
  const _CommentsSection({required this.postId, required this.colors});

  @override
  State<_CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<_CommentsSection> {
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: widget.colors.outlineVariant, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 15),
          Text("Comentarios", style: TextStyle(color: widget.colors.onSurface, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('denuncias').doc(widget.postId).collection('comentarios').orderBy('fecha', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final comments = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final c = comments[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(c['texto'] ?? "", style: TextStyle(color: widget.colors.onSurface)),
                      subtitle: Text("Anónimo", style: TextStyle(color: widget.colors.onSurfaceVariant, fontSize: 10)),
                    );
                  },
                );
              },
            ),
          ),
          TextField(
            controller: _commentController,
            style: TextStyle(color: widget.colors.onSurface),
            decoration: InputDecoration(
              hintText: "Escribe un comentario...",
              hintStyle: TextStyle(color: widget.colors.onSurfaceVariant),
              suffixIcon: IconButton(
                icon: Icon(Icons.send, color: widget.colors.primary), 
                onPressed: () async {
                  if (_commentController.text.isEmpty) return;
                  await FirebaseFirestore.instance.collection('denuncias').doc(widget.postId).collection('comentarios').add({
                    'texto': _commentController.text,
                    'fecha': FieldValue.serverTimestamp(),
                    'usuario': 'Anónimo',
                  });
                  _commentController.clear();
                }
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}