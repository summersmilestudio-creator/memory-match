import 'package:flutter/material.dart';

import '../services/achievements.dart';

const _purple = Color(0xFF7B1FA2);

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unlocked = kAchievements.where((a) => a.unlocked).length;
    return Scaffold(
      appBar: AppBar(
        title: Text('Realizări ($unlocked/${kAchievements.length})'),
        backgroundColor: _purple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: kAchievements.length,
          itemBuilder: (ctx, i) {
            final a = kAchievements[i];
            final got = a.unlocked;
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Opacity(
                  opacity: got ? 1 : 0.3,
                  child: Text(a.icon,
                      style: const TextStyle(fontSize: 30)),
                ),
                title: Text(a.name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: got ? Colors.black : Colors.black54)),
                subtitle: Text(a.description),
                trailing: Icon(
                  got ? Icons.check_circle : Icons.lock_outline,
                  color: got ? Colors.green : Colors.black26,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
