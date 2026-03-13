import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'post_create_dark_screen.dart';
import 'help_dark_screen.dart';
import 'settings_dark_screen.dart';

// Importaciones de tus archivos según el 'dir' que pasaste
import 'post_create_dark_screen.dart'; // Denunciar
import 'settings_dark_screen.dart';    // Configuraciones
import 'help_dark_screen.dart';        // Ayuda

class HomeDarkScreen extends StatefulWidget {
  const HomeDarkScreen({super.key});

  @override
  State<HomeDarkScreen> createState() => _HomeDarkScreenState();
}

class _HomeDarkScreenState extends State<HomeDarkScreen> {
  int _selectedIndex = 0;

  // Lista de pantallas vinculadas a tu estructura de archivos
  final List<Widget> _screens = [
    const GlobalPostsPlaceholder(),      // 0: Feed de denuncias globales
    const PostCreateDarkScreen(),        // 1: Realizar denuncia (Anónimo)
    const HelpDarkScreen(),              // 2: Ayuda
    const SettingsDarkScreen(),          // 3: Configuraciones (Logout)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Herencia automática del tema definido en main.dart
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text("SAURC", 
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Pequeño indicador del usuario actual
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: colors.primary.withOpacity(0.2),
            child: Icon(Icons.person, color: colors.primary, size: 20),
          ),
        ),
      ),
      
      // El IndexedStack mantiene el estado de las pantallas para que no se recarguen al cambiar de pestaña
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      // Menú de navegación inferior estilo Material 3
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: colors.surface,
        indicatorColor: colors.primary.withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'Posts',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Denunciar',
          ),
          NavigationDestination(
            icon: Icon(Icons.help_outline),
            selectedIcon: Icon(Icons.help),
            label: 'Ayuda',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Config',
          ),
        ],
      ),
    );
  }
}

// Placeholder para el Feed de denuncias (Mientras conectamos la BD global)
class GlobalPostsPlaceholder extends StatelessWidget {
  const GlobalPostsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.public, size: 80, color: Colors.white10),
          SizedBox(height: 10),
          Text("Denuncias Globales", style: TextStyle(color: Colors.white70, fontSize: 18)),
          Text("Próximamente: Feed en tiempo real", style: TextStyle(color: Colors.white30)),
        ],
      ),
    );
  }
}