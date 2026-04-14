import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_dark_screen.dart';
import 'home_dark_screen.dart'; // Asegúrate de que este archivo exista

class LoginDarkScreen extends StatefulWidget {
  const LoginDarkScreen({super.key});

  @override
  State<LoginDarkScreen> createState() => _LoginDarkScreenState();
}

class _LoginDarkScreenState extends State<LoginDarkScreen> {
  // Controladores para capturar el texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      // Intento de login con Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Si tiene éxito, vamos al Home y limpiamos la pila de navegación
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeDarkScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Ocurrió un error";
      if (e.code == 'user-not-found') {
        message = "Usuario no encontrado";
      } else if (e.code == 'wrong-password') message = "Contraseña incorrecta";
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView( // Evita errores de overflow con el teclado
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.location_city_rounded, size: 80, color: colors.primary),
                const SizedBox(height: 10),
                Text(
                  "SAURC",
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Campo Correo
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: colors.onSurface),
                  decoration: _buildInputDecoration("Correo electrónico", Icons.email_outlined, colors),
                ),
                const SizedBox(height: 20),
                
                // Campo Contraseña
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: colors.onSurface),
                  decoration: _buildInputDecoration("Contraseña", Icons.lock_outline, colors),
                ),
                const SizedBox(height: 30),
                
                // Botón Ingresar
                ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("INGRESAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("¿No tienes cuenta?", style: TextStyle(color: colors.onSurface.withOpacity(0.6))),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterDarkScreen())),
                      child: Text("Regístrate", style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon, ColorScheme colors) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colors.onSurface.withOpacity(0.5)),
      filled: true,
      fillColor: colors.onSurface.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      prefixIcon: Icon(icon, color: colors.primary),
    );
  }
}