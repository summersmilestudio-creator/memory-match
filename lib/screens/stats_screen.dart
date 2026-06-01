import 'package:flutter/material.dart';

import '../data/grids.dart';
import '../services/store.dart';

const _purple = Color(0xFF7B1FA2);

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistici'),
        backgroundColor: _purple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _tile('Jocuri jucate', '${Store.gamesPlayed}'),
            _tile('Jocuri câștigate', '${Store.gamesWon}'),
            _tile('Perechi găsite (total)', '${Store.totalMatches}'),
            _tile('Serie curentă', '${Store.streak} zile'),
            const SizedBox(height: 18),
            const Text('Cel mai bun timp pe grilă',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...kGrids.map((g) {
              final best = Store.bestTime(g.key);
              return _tile('${g.label} · $g',
                  best == null ? '—' : _fmt(best));
            }),
          ],
        ),
      ),
    );
  }

  Widget _tile(String k, String v) => Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          title: Text(k),
          trailing: Text(v,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _purple)),
        ),
      );
}
