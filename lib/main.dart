import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'state/bci_store.dart';

void main() {
  runApp(const BciManagementApp());
}

class BciManagementApp extends StatefulWidget {
  const BciManagementApp({super.key});

  @override
  State<BciManagementApp> createState() => _BciManagementAppState();
}

class _BciManagementAppState extends State<BciManagementApp> {
  final BciStore _store = BciStore();

  @override
  void dispose() {
    _store.dispose();
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
      home: AnimatedBuilder(
        animation: _store,
        builder: (BuildContext context, Widget? child) {
          return _store.currentUser == null
              ? LoginScreen(store: _store)
              : HomeShell(store: _store);
        },
      ),
    );
  }
}
