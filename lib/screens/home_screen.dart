import 'package:flutter/material.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'MEMORY\nMATCH',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF7B1FA2),
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Găsește perechile de cărți',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              const Spacer(),
              _DifficultyButton(label: 'Ușor (4×3)', cols: 4, rows: 3, color: Colors.green),
              const SizedBox(height: 12),
              _DifficultyButton(label: 'Mediu (4×4)', cols: 4, rows: 4, color: Colors.orange),
              const SizedBox(height: 12),
              _DifficultyButton(label: 'Greu (4×5)', cols: 4, rows: 5, color: Colors.red),
              const SizedBox(height: 12),
              _DifficultyButton(label: 'Expert (4×6)', cols: 4, rows: 6, color: Color(0xFF7B1FA2)),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final String label;
  final int cols;
  final int rows;
  final Color color;
  const _DifficultyButton({required this.label, required this.cols, required this.rows, required this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GameScreen(cols: cols, rows: rows)),
      ),
      child: Text(label),
    );
  }
}
