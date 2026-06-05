import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'services/notification_service.dart';
import 'services/review_service.dart';

import 'screens/home_screen.dart';
import 'services/store.dart';
import 'services/ads_service.dart';
import 'services/purchase_service.dart';
import 'widgets/remove_ads_offer.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PurchaseService.instance.initialize();
  await Store.init();
  await AdsService.instance.initialize();
  ReviewService.instance.registerLaunch();
  NotificationService.instance.scheduleEvery6Hours(title: 'Pair Match Cards', body: 'Ține minte cărțile și câștigă! 🧠');
  runApp(const MemoryApp());
}

class MemoryApp extends StatefulWidget {
  const MemoryApp({super.key});

  @override
  State<MemoryApp> createState() => _MemoryAppState();
}

class _MemoryAppState extends State<MemoryApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Show the upsell right after a full-screen ad (App Open / interstitial) closes.
    AdsService.instance.adClosedTick.addListener(_onAdClosed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AdsService.instance.adClosedTick.removeListener(_onAdClosed);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AdsService.instance.showAppOpenIfReady();
    }
  }

  void _onAdClosed() {
    final ctx = navigatorKey.currentContext;
    if (ctx != null) RemoveAdsOffer.maybeShow(ctx);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pair Match Cards',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7B1FA2)),
        scaffoldBackgroundColor: const Color(0xFFF3E5F5),
      ),
      home: UpgradeAlert(child: const HomeScreen()),
    );
  }
}
