import 'package:flutter/material.dart';

class HelpDarkScreen extends StatelessWidget {
  const HelpDarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Centro de Ayuda SAURC", 
        style: TextStyle(color: Colors.white, fontSize: 18)),
    );
  }
}