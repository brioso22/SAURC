import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

class PostCreateDarkScreen extends StatefulWidget {
  const PostCreateDarkScreen({super.key});

  @override
  State<PostCreateDarkScreen> createState() => _PostCreateDarkScreenState();
}

class _PostCreateDarkScreenState extends State<PostCreateDarkScreen> {
  final _descriptionController = TextEditingController();
  final _otherCategoryController = TextEditingController();
  final _picker = ImagePicker();
  
  File? _imageFile;
  String? _selectedCategory;
  bool _isLoading = false;
  String _locationStatus = "Ubicación no capturada";
  GeoPoint? _currentGeoPoint;
  String _userName = "Usuario Anónimo";

  final List<String> _categories = [
    'Tendido Eléctrico/Alumbrado',
    'Inundación/Fuga de Agua',
    'Baches/Carretera Deteriorada',
    'Basura/Contaminación',
    'Otros'
  ];

  @override
  void initState() {
    super.initState();
    _getUserData();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _otherCategoryController.dispose();
    super.dispose();
  }

  Future<void> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userData = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
        if (mounted) {
          setState(() {
            _userName = userData.data()?['nombres'] ?? user.displayName ?? user.email?.split('@')[0] ?? "Usuario";
          });
        }
      } catch (e) {
        debugPrint("Error al obtener nombre: $e");
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    var status = await Permission.location.request();
    if (!status.isGranted) {
      if (mounted) setState(() => _locationStatus = "Permiso de GPS denegado");
      return;
    }

    if (mounted) setState(() => _locationStatus = "Obteniendo GPS...");

    try {
      loc.Location location = loc.Location();
      final locData = await location.getLocation().timeout(const Duration(seconds: 10));
      
      if (mounted) {
        setState(() {
          _currentGeoPoint = GeoPoint(locData.latitude!, locData.longitude!);
          _locationStatus = "GPS Capturado: (${locData.latitude!.toStringAsFixed(4)}, ${locData.longitude!.toStringAsFixed(4)})";
        });
      }
    } catch (e) {
      if (mounted) setState(() => _locationStatus = "Error al capturar GPS");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 40,
        maxWidth: 800,    
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final bytes = await file.length();
        if (bytes > 600000) { 
          _showErrorSnackBar("Imagen demasiado grande.");
          return;
        }
        if (mounted) setState(() => _imageFile = file);
      }
    } catch (e) {
      _showErrorSnackBar("Error al seleccionar imagen.");
    }
  }

  Future<void> _submitDenuncia() async {
    if (_imageFile == null) { _showErrorSnackBar("Sube una foto de la evidencia."); return; }
    if (_selectedCategory == null) { _showErrorSnackBar("Selecciona una categoría."); return; }
    if (_currentGeoPoint == null) { _showErrorSnackBar("Captura el GPS antes de enviar."); return; }

    FocusScope.of(context).unfocus();
    if (mounted) setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Inicia sesión primero.");

      final bytes = await _imageFile!.readAsBytes();
      String base64Image = base64Encode(bytes);

      final finalCategory = (_selectedCategory == 'Otros') 
          ? "Otros: ${_otherCategoryController.text.trim()}" 
          : _selectedCategory;

      await FirebaseFirestore.instance.collection('denuncias').add({
        'uid_usuario': user.uid,
        'nombre_usuario': _userName,
        'categoria': finalCategory,
        'descripcion': _descriptionController.text.trim(),
        'coordenadas': _currentGeoPoint,
        'url_imagen': base64Image, 
        'fecha_creacion': FieldValue.serverTimestamp(),
        'estado': 'Pendiente',
        'likes': [],
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Reporte enviado exitosamente!"), backgroundColor: Colors.green),
        );
        _resetForm();
      }
    } catch (e) {
      _showErrorSnackBar("Error al enviar: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    setState(() {
      _imageFile = null;
      _selectedCategory = null;
      _descriptionController.clear();
      _otherCategoryController.clear();
      _getCurrentLocation();
    });
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: colors.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // CARD DE INFO DE USUARIO Y GPS
            Card(
              color: colors.surfaceContainerLow,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: colors.outlineVariant.withOpacity(0.2))
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_circle, color: colors.primary),
                        const SizedBox(width: 10),
                        Expanded(child: Text("Reportando como: $_userName", 
                          style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    Divider(color: colors.outlineVariant.withOpacity(0.3)),
                    Row(
                      children: [
                        Icon(Icons.location_on, 
                          color: _currentGeoPoint != null ? Colors.green : colors.error, size: 20),
                        const SizedBox(width: 10),
                        Expanded(child: Text(_locationStatus, 
                          style: TextStyle(color: _currentGeoPoint != null ? Colors.green : colors.error, fontSize: 12))),
                        IconButton(icon: Icon(Icons.refresh, color: colors.primary, size: 20), onPressed: _getCurrentLocation)
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text("1. Foto de la Evidencia", 
              style: textTheme.titleSmall?.copyWith(color: colors.onSurfaceVariant)),
            const SizedBox(height: 10),
            
            if (_imageFile != null)
              Container(
                height: 200,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => setState(() => _imageFile = null),
                  ),
                ),
              ),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Cámara"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primaryContainer, 
                        foregroundColor: colors.onPrimaryContainer, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Galería"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primaryContainer, 
                        foregroundColor: colors.onPrimaryContainer, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            Text("2. Clasificación de la Denuncia", 
              style: textTheme.titleSmall?.copyWith(color: colors.onSurfaceVariant)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: Text("Seleccionar tipo", style: TextStyle(color: colors.onSurfaceVariant)),
              dropdownColor: colors.surfaceContainerHigh,
              style: TextStyle(color: colors.onSurface),
              decoration: _buildInputDecoration(Icons.category, colors),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(value: category, child: Text(category));
              }).toList(),
              onChanged: (String? newValue) => setState(() => _selectedCategory = newValue),
            ),
            if (_selectedCategory == 'Otros')
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: TextField(
                  controller: _otherCategoryController,
                  style: TextStyle(color: colors.onSurface),
                  decoration: _buildInputDecoration(Icons.edit_note, colors).copyWith(hintText: "Especifique el tipo de problema"),
                ),
              ),
            const SizedBox(height: 25),

            Text("3. Descripción Detallada (Opcional)", 
              style: textTheme.titleSmall?.copyWith(color: colors.onSurfaceVariant)),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              maxLength: 300,
              style: TextStyle(color: colors.onSurface),
              decoration: _buildInputDecoration(Icons.description, colors).copyWith(hintText: "Explique brevemente el problema"),
            ),
            const SizedBox(height: 40),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitDenuncia,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("ENVIAR DENUNCIA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(IconData icon, ColorScheme colors) {
    return InputDecoration(
      filled: true,
      fillColor: colors.surfaceContainerLow,
      prefixIcon: Icon(icon, color: colors.primary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      hintStyle: TextStyle(color: colors.onSurfaceVariant.withOpacity(0.5)),
    );
  }
}