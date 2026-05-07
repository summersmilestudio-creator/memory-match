import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameScreen extends StatefulWidget {
  final int cols;
  final int rows;
  const GameScreen({super.key, required this.cols, required this.rows});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _Card {
  final int symbol;
  bool flipped;
  bool matched;
  _Card(this.symbol, {this.flipped = false, this.matched = false});
}

const _icons = [
  Icons.favorite, Icons.star, Icons.bolt, Icons.cake, Icons.pets,
  Icons.local_florist, Icons.wb_sunny, Icons.beach_access,
  Icons.music_note, Icons.sports_soccer, Icons.coffee, Icons.local_pizza,
  Icons.directions_car, Icons.flight_takeoff, Icons.train, Icons.casino,
];

const _colors = [
  Color(0xFFE91E63), Color(0xFFFFC107), Color(0xFF03A9F4),
  Color(0xFF8BC34A), Color(0xFFFF5722), Color(0xFF9C27B0),
  Color(0xFF00BCD4), Color(0xFFFF9800), Color(0xFF673AB7),
  Color(0xFF4CAF50), Color(0xFF795548), Color(0xFFEC407A),
  Color(0xFF5C6BC0), Color(0xFF26A69A), Color(0xFF66BB6A),
  Color(0xFFEF5350),
];

class _GameScreenState extends State<GameScreen> {
  late List<_Card> _cards;
  int? _firstIdx;
  bool _busy = false;
  int _moves = 0;
  int _matches = 0;
  int _seconds = 0;
  Timer? _timer;
  bool _won = false;

  @override
  void initState() {
    super.initState();
    _setup();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_won && mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setup() {
    final total = widget.cols * widget.rows;
    final pairs = total ~/ 2;
    final symbols = List.generate(pairs, (i) => i);
    final all = [...symbols, ...symbols]..shuffle(Random());
    _cards = all.map((s) => _Card(s)).toList();
  }

  void _onTap(int idx) async {
    if (_busy || _cards[idx].flipped || _cards[idx].matched) return;
    setState(() => _cards[idx].flipped = true);
    HapticFeedback.lightImpact();
    if (_firstIdx == null) {
      _firstIdx = idx;
      return;
    }
    _moves++;
    final firstIdx = _firstIdx!;
    _firstIdx = null;

    if (_cards[firstIdx].symbol == _cards[idx].symbol) {
      setState(() {
        _cards[firstIdx].matched = true;
        _cards[idx].matched = true;
        _matches++;
      });
      HapticFeedback.mediumImpact();
      if (_matches == _cards.length ~/ 2) {
        _won = true;
        _timer?.cancel();
        Future.microtask(() {
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (c) => AlertDialog(
              title: const Text('🎉 Câștigat!'),
              content: Text(
                  'Toate perechile găsite!\nTimp: ${_fmtTime(_seconds)}\nMutări: $_moves'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(c);
                      Navigator.pop(context);
                    },
                    child: const Text('Înapoi')),
                TextButton(
                    onPressed: () {
                      Navigator.pop(c);
                      setState(() {
                        _setup();
                        _moves = 0;
                        _matches = 0;
                        _seconds = 0;
                        _won = false;
                      });
                      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
                        if (!_won && mounted) setState(() => _seconds++);
                      });
                    },
                    child: const Text('Din nou')),
              ],
            ),
          );
        });
      }
    } else {
      _busy = true;
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() {
        _cards[firstIdx].flipped = false;
        _cards[idx].flipped = false;
        _busy = false;
      });
    }
  }

  String _fmtTime(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cols}×${widget.rows}'),
        backgroundColor: const Color(0xFF7B1FA2),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat('Timp', _fmtTime(_seconds)),
                  _stat('Mutări', '$_moves'),
                  _stat('Perechi', '$_matches/${_cards.length ~/ 2}'),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: widget.cols,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (ctx, i) {
                    final card = _cards[i];
                    return _CardWidget(
                      card: card,
                      onTap: () => _onTap(i),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF7B1FA2))),
      ],
    );
  }
}

class _CardWidget extends StatelessWidget {
  final _Card card;
  final VoidCallback onTap;
  const _CardWidget({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _colors[card.symbol % _colors.length];
    final icon = _icons[card.symbol % _icons.length];
    final showing = card.flipped || card.matched;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: showing ? color : const Color(0xFF7B1FA2),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Center(
          child: showing
              ? Icon(icon, color: Colors.white, size: 38)
              : const Icon(Icons.help_outline, color: Colors.white24, size: 32),
        ),
      ),
    );
  }
}
