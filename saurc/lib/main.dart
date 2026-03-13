import 'package:flutter/material.dart';
import 'screens/splash_dark_screen.dart';

void main() {
  runApp(const SAURCApp());
}

class SAURCApp extends StatelessWidget {
  const SAURCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAURC',
      debugShowCheckedModeBanner: false,
      
      // TEMA CLARO
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF002868),
          brightness: Brightness.light,
        ),
      ),

      // TEMA OSCURO (El que definimos para SAURC)
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF002868),
          brightness: Brightness.dark,
          surface: const Color(0xFF011638), // Fondo oscuro personalizado
        ),
      ),

      // Esto hace que herede el modo del sistema automáticamente
      themeMode: ThemeMode.system, 

      home: const SplashDarkScreen(),
    );
  }
}