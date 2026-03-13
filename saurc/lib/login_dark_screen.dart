import 'package:flutter/material.dart';

class LoginDarkScreen extends StatelessWidget {
  const LoginDarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Extraemos el esquema de colores y el estilo de texto del tema actual
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // HERENCIA: Usa el fondo definido en el tema
      backgroundColor: colors.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.location_city_rounded,
              size: 80,
              // HERENCIA: Color primario del tema
              color: colors.primary,
            ),
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
            
            // Campo de Usuario
            TextField(
              style: TextStyle(color: colors.onSurface),
              decoration: InputDecoration(
                hintText: "Usuario",
                hintStyle: TextStyle(color: colors.onSurface.withOpacity(0.5)),
                filled: true,
                // HERENCIA: Un ligero contraste sobre el fondo
                fillColor: colors.onSurface.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.person, color: colors.primary),
              ),
            ),
            const SizedBox(height: 20),
            
            // Campo de Contraseña
            TextField(
              obscureText: true,
              style: TextStyle(color: colors.onSurface),
              decoration: InputDecoration(
                hintText: "Contraseña",
                hintStyle: TextStyle(color: colors.onSurface.withOpacity(0.5)),
                filled: true,
                fillColor: colors.onSurface.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.lock, color: colors.primary),
              ),
            ),
            const SizedBox(height: 30),
            
            // Botón de Ingreso
            ElevatedButton(
              onPressed: () {
                print("Intento de login en SAURC");
              },
              style: ElevatedButton.styleFrom(
                // HERENCIA: Usamos el color primario para el botón
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: const Text(
                "INGRESAR",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {},
              child: Text(
                "¿Olvidaste tu contraseña?",
                style: TextStyle(color: colors.onSurface.withOpacity(0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}