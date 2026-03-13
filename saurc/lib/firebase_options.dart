// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] para el proyecto SAURC.
/// Este archivo fue corregido manualmente basándose en tu google-services.json.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web no configurada');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Plataforma no soportada');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDIQnzBFrlcKXJ_nAgM0IAZJYs9Aw68Dcc',
    appId: '1:836945471405:android:50d4b2fecefa52dc8e2324',
    messagingSenderId: '836945471405',
    projectId: 'saurc-42a13',
    storageBucket: 'saurc-42a13.firebasestorage.app',
  );
}