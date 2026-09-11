import 'package:flutter/material.dart';

import 'controllers/app_controllers.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const BciManagementApp());
}

class BciManagementApp extends StatefulWidget {
  const BciManagementApp({super.key});

  @override
  State<BciManagementApp> createState() => _BciManagementAppState();
}

class _BciManagementAppState extends State<BciManagementApp> {
  final AppControllers _controllers = AppControllers();

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BCI Management System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF173B63)),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
        ),
      ),
      // Only the auth controller decides which top-level screen is shown,
      // so that is all this needs to listen to.
      home: AnimatedBuilder(
        animation: _controllers.auth,
        builder: (BuildContext context, Widget? child) {
          return _controllers.auth.currentUser == null
              ? LoginScreen(auth: _controllers.auth)
              : HomeShell(controllers: _controllers);
        },
      ),
    );
  }
}
