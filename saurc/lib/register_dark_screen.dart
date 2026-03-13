import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_dark_screen.dart'; // Importación necesaria para la redirección

class RegisterDarkScreen extends StatefulWidget {
  const RegisterDarkScreen({super.key});

  @override
  State<RegisterDarkScreen> createState() => _RegisterDarkScreenState();
}

class _RegisterDarkScreenState extends State<RegisterDarkScreen> {
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _acceptTerms = false; // Estado del checkbox

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Validación de seguridad de contraseña
  bool _isPasswordSecure(String pass) {
    // Mínimo 8 caracteres, una letra y un número
    final RegExp passwordRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return passwordRegExp.hasMatch(pass);
  }

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();

    // VALIDACIONES
    if (!_acceptTerms) {
      _showError("Debes aceptar los términos y condiciones");
      return;
    }

    if (!_isPasswordSecure(_passwordController.text)) {
      _showError("La contraseña debe tener al menos 8 caracteres, incluyendo letras y números");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError("Las contraseñas no coinciden");
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Guardar en Firestore
      await FirebaseFirestore.instance.collection('usuarios').doc(userCredential.user!.uid).set({
        'nombres': _nameController.text.trim(),
        'apellidos': _lastNameController.text.trim(),
        'telefono': _phoneController.text.trim(),
        'correo': _emailController.text.trim(),
        'rol': 'auditor',
        'fecha_registro': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Registro exitoso!")),
        );
        // REDIRECCIÓN DIRECTA AL HOME (reemplaza la pantalla actual)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeDarkScreen()),
          (route) => false,
        );
      }

    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Error de autenticación");
    } catch (e) {
      _showError("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const Text("Crear Cuenta", 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)
            ),
            const SizedBox(height: 30),
            
            _buildTextField("Nombres", Icons.person, controller: _nameController),
            _buildTextField("Apellidos", Icons.person, controller: _lastNameController),
            _buildTextField("Correo electrónico", Icons.email, controller: _emailController, type: TextInputType.emailAddress),
            _buildTextField("Número de teléfono", Icons.phone, controller: _phoneController, type: TextInputType.phone),
            _buildTextField("Contraseña", Icons.lock, controller: _passwordController, isPass: true),
            _buildTextField("Repetir contraseña", Icons.lock_reset, controller: _confirmPasswordController, isPass: true),
            
            const SizedBox(height: 10),

            // SECCIÓN TÉRMINOS Y CONDICIONES
            Row(
              children: [
                Checkbox(
                  value: _acceptTerms,
                  onChanged: (val) => setState(() => _acceptTerms = val!),
                  checkColor: Colors.white,
                  activeColor: colors.primary,
                  side: const BorderSide(color: Colors.white54),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: "Acepto los ",
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                      children: [
                        TextSpan(
                          text: "términos y condiciones",
                          style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              final url = Uri.parse('https://www.ejemplo.com');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              }
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            
            _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("REGISTRARSE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon, {required TextEditingController controller, bool isPass = false, TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}