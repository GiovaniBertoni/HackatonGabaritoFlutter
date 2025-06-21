import 'package:flutter/material.dart';
import 'screens/auth_check_screen.dart'; // <<< MUDANÇA
import 'utils/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Corretor de Gabaritos',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthCheckScreen(), // Novo ecrã inicial
    );
  }
}