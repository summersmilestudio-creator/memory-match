import 'package:flutter/material.dart';

import '../services/store.dart';

const _purple = Color(0xFF7B1FA2);

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = Store.leaderboard();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clasament local'),
        backgroundColor: _purple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: entries.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Încă nu ai niciun scor.\nJoacă un nivel ca să intri în clasament!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: entries.length,
                itemBuilder: (ctx, i) {
                  final e = entries[i];
                  final medal = i == 0
                      ? '🥇'
                      : i == 1
                          ? '🥈'
                          : i == 2
                              ? '🥉'
                              : '#${i + 1}';
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Text(medal,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      title: Text('${e.score} puncte',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      subtitle: Text('${e.mode} · ${e.grid} · ${e.date}'),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
