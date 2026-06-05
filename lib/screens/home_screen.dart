import 'package:flutter/material.dart';
import '../widgets/banner_ad_widget.dart';

import '../data/grids.dart';
import '../data/themes.dart';
import '../models/game_config.dart';
import '../services/purchase_service.dart';
import '../services/store.dart';
import 'achievements_screen.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';
import 'play_setup_screen.dart';
import 'stats_screen.dart';
import 'themes_screen.dart';

const _purple = Color(0xFF7B1FA2);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _refresh() => setState(() {});

  void _showRemoveAdsDialog() {
    final ps = PurchaseService.instance;
    final price = ps.productFor(PurchaseService.noAdsId)?.price ?? '15 lei';
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Fără reclame',
            style: TextStyle(color: _purple, fontWeight: FontWeight.w900)),
        content: const Text(
          'Joacă fără bannere și fără reclame care te întrerup. O singură dată, pentru totdeauna.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ps.restore();
            },
            child: const Text('Restaurează',
                style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ps.buy(PurchaseService.noAdsId);
            },
            child: Text('Cumpără • $price',
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _openMode(GameMode mode) async {
    if (mode == GameMode.daily) {
      final n = DateTime.now();
      final seed = n.year * 10000 + n.month * 100 + n.day;
      // A fixed mid-size grid so the daily challenge is fair for everyone.
      const dailyGrid = GridSize('Avansat', 6, 4);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GameScreen(
            config: GameConfig(
              grid: dailyGrid,
              themeIndex: seed % kThemes.length,
              mode: GameMode.daily,
              seed: seed,
            ),
          ),
        ),
      );
      _refresh();
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlaySetupScreen(mode: mode)),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = kThemes[Store.themeIndex % kThemes.length];
    return Scaffold(
      bottomNavigationBar: const BannerAdWidget(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'PAIR MATCH\nCARDS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                    color: _purple,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Antrenează-ți memoria · joacă offline',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              _ModeCard(
                mode: GameMode.zen,
                onTap: () => _openMode(GameMode.zen),
              ),
              _ModeCard(
                mode: GameMode.timeAttack,
                onTap: () => _openMode(GameMode.timeAttack),
              ),
              _ModeCard(
                mode: GameMode.daily,
                trailing: Store.dailyDoneToday
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () => _openMode(GameMode.daily),
              ),
              _ModeCard(
                mode: GameMode.twoPlayer,
                onTap: () => _openMode(GameMode.twoPlayer),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _MiniButton(
                    icon: Icons.palette,
                    label: 'Teme',
                    badge: theme.preview,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ThemesScreen()),
                      );
                      _refresh();
                    },
                  ),
                  _MiniButton(
                    icon: Icons.bar_chart,
                    label: 'Statistici',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const StatsScreen())),
                  ),
                ],
              ),
              Row(
                children: [
                  _MiniButton(
                    icon: Icons.emoji_events,
                    label: 'Realizări',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const AchievementsScreen())),
                  ),
                  _MiniButton(
                    icon: Icons.leaderboard,
                    label: 'Clasament',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const LeaderboardScreen())),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: PurchaseService.instance.noAdsNotifier,
                builder: (context, noAds, _) {
                  if (noAds) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextButton.icon(
                      onPressed: _showRemoveAdsDialog,
                      icon: const Icon(Icons.block, color: _purple, size: 20),
                      label: const Text('Fără reclame',
                          style: TextStyle(
                              color: _purple, fontWeight: FontWeight.w600)),
                    ),
                  );
                },
              ),
              if (Store.streak > 1)
                Text('🔥 Serie: ${Store.streak} zile',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: _purple, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final GameMode mode;
  final VoidCallback onTap;
  final Widget? trailing;
  const _ModeCard({required this.mode, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Text(mode.emoji, style: const TextStyle(fontSize: 30)),
        title: Text(mode.label,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(mode.subtitle),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;
  const _MiniButton(
      {required this.icon,
      required this.label,
      this.badge,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: _purple,
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: _purple),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(badge ?? '', style: const TextStyle(fontSize: 18)),
              Icon(icon),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
