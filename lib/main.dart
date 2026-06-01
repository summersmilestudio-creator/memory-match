import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'services/notification_service.dart';
import 'services/review_service.dart';

import 'screens/home_screen.dart';
import 'services/store.dart';
import 'services/ads_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Store.init();
  await AdsService.instance.initialize();
  ReviewService.instance.registerLaunch();
  NotificationService.instance.scheduleEvery6Hours(title: 'Memory Match Cards', body: 'Ține minte cărțile și câștigă! 🧠');
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
      home: UpgradeAlert(child: const HomeScreen()),
    );
  }
}
