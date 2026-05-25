import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/store.dart';
import 'services/ads_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Store.init();
  await AdsService.instance.initialize();
  runApp(const MemoryApp());
}

class MemoryApp extends StatelessWidget {
  const MemoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Match Cards',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7B1FA2)),
        scaffoldBackgroundColor: const Color(0xFFF3E5F5),
      ),
      home: const HomeScreen(),
    );
  }
}
