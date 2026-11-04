import 'package:flutter/material.dart';

import 'data/item_repository.dart';
import 'screens/home_screen.dart';
import 'state/item_controller.dart';

void main() {
  runApp(const LostAndFoundApp());
}

class LostAndFoundApp extends StatefulWidget {
  const LostAndFoundApp({super.key});

  @override
  State<LostAndFoundApp> createState() => _LostAndFoundAppState();
}

class _LostAndFoundAppState extends State<LostAndFoundApp> {
  late final ItemController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ItemController(ItemRepository());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Achados e Perdidos',
    
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF183153),
        surface: const Color(0xFFF5F7FA),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Color(0xFFF5F7FA),
        foregroundColor: Color(0xFF183153),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDCE3ED)),
        ),
      ),
    ),
    home: HomeScreen(controller: _controller),
  );
}
