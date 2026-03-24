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
        scaffoldBackgroundColor: const Color(0xFFEFEFEF), // Fondo EFEFEF

        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0047AB),      // Azul Institucional
          surface: Color(0xFFFFFFFF),      // Fondo de Tarjetas Blanco
          onSurface: Colors.black87,
          outline: Color(0xFFD5D5D5),      // Iconos inactivos
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0047AB),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),

        navigationBarTheme: NavigationBarThemeData(
  backgroundColor: const Color(0xFFF1FAFC), // El color claro de tu Figma
  indicatorColor: Colors.transparent, 
  
  // Forzamos el color de las etiquetas (textos)
  labelTextStyle: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return const TextStyle(color: Color(0xFF0047AB), fontWeight: FontWeight.bold);
    }
    return const TextStyle(color: Color(0xFF94A3B8)); // Gris para los no seleccionados
  }),

  // Forzamos el color de los iconos
  iconTheme: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return const IconThemeData(color: Color(0xFF0047AB), size: 28);
    }
    return const IconThemeData(color: Color(0xFF94A3B8)); // Color de las "pelotitas"
  }),
),

        cardTheme: const CardThemeData(
          color: Color(0xFFFFFFFF),
          elevation: 1,
        ),
      ),
      // TEMA OSCURO
      darkTheme: ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212), // Tu fondo oscuro de Figma

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF4A90E2),      // Azul más brillante para modo oscuro
      surface: Color(0xFF1E1E1E),      // Fondo de tarjetas oscuro
      onSurface: Colors.white,
      outline: Color(0xFF94A3B8),      // Gris de iconos
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF121212),
      indicatorColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: Color(0xFF4A90E2), fontWeight: FontWeight.bold);
        }
        return const TextStyle(color: Color(0xFF94A3B8));
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Color(0xFF4A90E2), size: 28);
        }
        return const IconThemeData(color: Color(0xFF94A3B8));
      }),
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