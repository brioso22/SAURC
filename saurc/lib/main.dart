import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importación vital para la persistencia
import 'firebase_options.dart';
import 'screens/splash_dark_screen.dart';
import 'login_dark_screen.dart'; // Asegúrate de tener estas importaciones
import 'home_dark_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

      // TEMA OSCURO (Principal para SAURC)
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF002868),
          brightness: Brightness.dark,
          surface: const Color(0xFF011638),
        ),
      ),

      themeMode: ThemeMode.system, // Hereda el modo del sistema

      // PERSISTENCIA DE SESIÓN:
      // El StreamBuilder escucha a Firebase y decide qué pantalla mostrar
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Firebase avisa automáticamente si el usuario ya está logeado
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Mientras se comprueba la conexión, mostramos el Splash
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashDarkScreen();
        }

        // 2. Si hay datos (un usuario activo), va directo al Home persistente
        if (snapshot.hasData) {
          return const HomeDarkScreen();
        }

        // 3. Si no hay usuario, va al Login
        return const LoginDarkScreen();
      },
    );
  }
}