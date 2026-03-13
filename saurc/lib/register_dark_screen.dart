import 'package:flutter/material.dart';

class RegisterDarkScreen extends StatelessWidget {
  const RegisterDarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surface,
      // AppBar sencillo para poder regresar al Login
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Crear Cuenta",
              style: textTheme.headlineMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Únete a la auditoría urbana de SAURC",
              style: TextStyle(color: colors.onSurface.withOpacity(0.6)),
            ),
            const SizedBox(height: 35),
            
            // Campo: Nombres
            _buildTextField(context, "Nombres", Icons.person_outline),
            const SizedBox(height: 15),
            
            // Campo: Apellidos
            _buildTextField(context, "Apellidos", Icons.person_outline),
            const SizedBox(height: 15),
            
            // Campo: Teléfono
            _buildTextField(context, "Número de teléfono", Icons.phone_android, keyboardType: TextInputType.phone),
            const SizedBox(height: 15),
            
            // Campo: Contraseña
            _buildTextField(context, "Contraseña", Icons.lock_outline, obscureText: true),
            const SizedBox(height: 15),
            
            // Campo: Repetir Contraseña
            _buildTextField(context, "Repetir contraseña", Icons.lock_reset, obscureText: true),
            
            const SizedBox(height: 40),
            
            // Botón de Registro
            ElevatedButton(
              onPressed: () {
                print("Datos listos para validación de registro");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: const Text(
                "REGISTRARSE",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper para no repetir código de diseño en cada TextField
  Widget _buildTextField(BuildContext context, String hint, IconData icon, {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    final colors = Theme.of(context).colorScheme;
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: colors.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colors.onSurface.withOpacity(0.5)),
        filled: true,
        fillColor: colors.onSurface.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: colors.primary, size: 22),
      ),
    );
  }
}