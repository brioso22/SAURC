import 'package:flutter/material.dart';
import 'dart:async';
import 'package:saurc/login_dark_screen.dart'; 

class SplashDarkScreen extends StatefulWidget {
  const SplashDarkScreen({super.key});

  @override
  State<SplashDarkScreen> createState() => _SplashDarkScreenState();
}

class _SplashDarkScreenState extends State<SplashDarkScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginDarkScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el esquema de colores actual (Light o Dark según el sistema)
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      // HERENCIA: Usa el color de fondo definido en el tema (surface)
      backgroundColor: colors.surface, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_city_rounded, 
              size: 100,
              // HERENCIA: Usa el color de contraste sobre el fondo (primary)
              color: colors.primary,
            ),
            const SizedBox(height: 20),
            Text(
              "SAURC",
              style: TextStyle(
                // HERENCIA: El color de texto principal del tema
                color: colors.onSurface,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                // HERENCIA: El color de acción definido como primario
                color: colors.primary, 
                backgroundColor: colors.primary.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Iniciando auditoría urbana...",
              style: TextStyle(
                // HERENCIA: Texto con menor énfasis
                color: colors.onSurface.withOpacity(0.7), 
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}