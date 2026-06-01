import 'package:flutter/material.dart';

import '../data/grids.dart';
import '../data/themes.dart';
import '../models/game_config.dart';
import '../services/store.dart';
import 'game_screen.dart';
import 'themes_screen.dart';

const _purple = Color(0xFF7B1FA2);

class PlaySetupScreen extends StatefulWidget {
  final GameMode mode;
  const PlaySetupScreen({super.key, required this.mode});

  @override
  State<PlaySetupScreen> createState() => _PlaySetupScreenState();
}

class _PlaySetupScreenState extends State<PlaySetupScreen> {
  int _gridIndex = 1;

  @override
  Widget build(BuildContext context) {
    final theme = kThemes[Store.themeIndex % kThemes.length];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode.label),
        backgroundColor: _purple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: Text(theme.preview,
                    style: const TextStyle(fontSize: 30)),
                title: const Text('Temă cărți'),
                subtitle: Text(theme.name),
                trailing: TextButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ThemesScreen()),
                    );
                    setState(() {});
                  },
                  child: const Text('Schimbă'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Mărime grilă',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...List.generate(kGrids.length, (i) {
              final g = kGrids[i];
              final selected = i == _gridIndex;
              return Card(
                color: selected ? _purple : null,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text('${g.label}  ·  $g',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: selected ? Colors.white : null)),
                  subtitle: Text('${g.pairs} perechi',
                      style: TextStyle(
                          color:
                              selected ? Colors.white70 : Colors.black54)),
                  trailing: Builder(builder: (_) {
                    final best = Store.bestTime(g.key);
                    if (best == null) return const SizedBox.shrink();
                    final m = (best ~/ 60).toString().padLeft(2, '0');
                    final s = (best % 60).toString().padLeft(2, '0');
                    return Text('🏅 $m:$s',
                        style: TextStyle(
                            color: selected
                                ? Colors.white
                                : _purple,
                            fontWeight: FontWeight.bold));
                  }),
                  onTap: () => setState(() => _gridIndex = i),
                ),
              );
            }),
            const SizedBox(height: 22),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _purple,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen(
                      config: GameConfig(
                        grid: kGrids[_gridIndex],
                        themeIndex: Store.themeIndex,
                        mode: widget.mode,
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Începe jocul',
                  style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
