import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_dark_screen.dart'; 

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
  bool _acceptTerms = false;

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

  bool _isPasswordSecure(String pass) {
    final RegExp passwordRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return passwordRegExp.hasMatch(pass);
  }

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();

    if (!_acceptTerms) {
      _showError("Debes aceptar los términos y condiciones");
      return;
    }

    if (!_isPasswordSecure(_passwordController.text)) {
      _showError("La contraseña debe tener al menos 8 caracteres, letras y números");
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

      await FirebaseFirestore.instance.collection('usuarios').doc(userCredential.user!.uid).set({
        'nombres': _nameController.text.trim(),
        'apellidos': _lastNameController.text.trim(),
        'telefono': _phoneController.text.trim(),
        'correo': _emailController.text.trim(),
        'rol': 'auditor',
        'fecha_registro': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Registro exitoso!")));
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
      backgroundColor: colors.surface, // Hereda el fondo oscuro del sistema
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            Text("Crear Cuenta", 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colors.onSurface)
            ),
            const SizedBox(height: 30),
            
            _buildTextField("Nombres", Icons.person, controller: _nameController, colors: colors),
            _buildTextField("Apellidos", Icons.person, controller: _lastNameController, colors: colors),
            _buildTextField("Correo electrónico", Icons.email, controller: _emailController, type: TextInputType.emailAddress, colors: colors),
            _buildTextField("Número de teléfono", Icons.phone, controller: _phoneController, type: TextInputType.phone, colors: colors),
            _buildTextField("Contraseña", Icons.lock, controller: _passwordController, isPass: true, colors: colors),
            _buildTextField("Repetir contraseña", Icons.lock_reset, controller: _confirmPasswordController, isPass: true, colors: colors),
            
            const SizedBox(height: 10),

            Row(
              children: [
                Checkbox(
                  value: _acceptTerms,
                  onChanged: (val) => setState(() => _acceptTerms = val!),
                  checkColor: colors.onPrimary,
                  activeColor: colors.primary,
                  side: BorderSide(color: colors.onSurface.withOpacity(0.5)),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: "Acepto los ",
                      style: TextStyle(color: colors.onSurface.withOpacity(0.7), fontSize: 13),
                      children: [
                        TextSpan(
                          text: "términos y condiciones",
                          style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              final url = Uri.parse('https://www.google.com'); // Cambia por tu URL real
                              if (await canLaunchUrl(url)) await launchUrl(url);
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
              ? CircularProgressIndicator(color: colors.primary)
              : ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
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

  Widget _buildTextField(String hint, IconData icon, {
    required TextEditingController controller, 
    required ColorScheme colors,
    bool isPass = false, 
    TextInputType type = TextInputType.text
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        keyboardType: type,
        style: TextStyle(color: colors.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: colors.onSurface.withOpacity(0.4)),
          prefixIcon: Icon(icon, color: colors.primary),
          filled: true,
          fillColor: colors.onSurface.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}