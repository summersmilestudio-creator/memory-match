import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/banner_ad_widget.dart';
import '../services/ads_service.dart';
import 'package:flutter/services.dart';

import '../data/grids.dart';
import '../data/themes.dart';
import '../models/game_config.dart';
import '../services/achievements.dart';
import '../services/store.dart';

const _purple = Color(0xFF7B1FA2);

class _Card {
  final int symbol;
  bool flipped = false;
  bool matched = false;
  _Card(this.symbol);
}

class GameScreen extends StatefulWidget {
  final GameConfig config;
  const GameScreen({super.key, required this.config});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<_Card> _cards;
  late List<String> _faces;
  int? _firstIdx;
  bool _busy = false;
  bool _finished = false;

  int _moves = 0;
  int _matches = 0;
  int _mismatches = 0;
  int _seconds = 0; // elapsed
  int _remaining = 0; // for time attack
  Timer? _timer;

  // two-player state
  int _current = 0;
  final List<int> _pScore = [0, 0];

  GameConfig get cfg => widget.config;
  GridSize get grid => cfg.grid;
  bool get _isTimeAttack => cfg.mode == GameMode.timeAttack;
  bool get _isTwoPlayer => cfg.mode == GameMode.twoPlayer;

  @override
  void initState() {
    super.initState();
    _setup();
    _remaining = cfg.timeBudget;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_finished || !mounted) return;
      setState(() {
        _seconds++;
        if (_isTimeAttack) {
          _remaining--;
          if (_remaining <= 0) _lose();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setup() {
    final rng = cfg.seed != null ? Random(cfg.seed) : Random();
    final theme = kThemes[cfg.themeIndex % kThemes.length];
    final pool = List<String>.from(theme.symbols)..shuffle(rng);
    _faces = pool.take(grid.pairs).toList();
    final ids = List.generate(grid.pairs, (i) => i);
    final all = [...ids, ...ids]..shuffle(rng);
    _cards = all.map((s) => _Card(s)).toList();
  }

  void _restart() {
    setState(() {
      _setup();
      _firstIdx = null;
      _busy = false;
      _finished = false;
      _moves = 0;
      _matches = 0;
      _mismatches = 0;
      _seconds = 0;
      _remaining = cfg.timeBudget;
      _current = 0;
      _pScore[0] = 0;
      _pScore[1] = 0;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_finished || !mounted) return;
      setState(() {
        _seconds++;
        if (_isTimeAttack) {
          _remaining--;
          if (_remaining <= 0) _lose();
        }
      });
    });
  }

  Future<void> _onTap(int idx) async {
    if (_busy || _finished) return;
    if (_cards[idx].flipped || _cards[idx].matched) return;
    setState(() => _cards[idx].flipped = true);
    HapticFeedback.lightImpact();

    if (_firstIdx == null) {
      _firstIdx = idx;
      return;
    }
    final first = _firstIdx!;
    _firstIdx = null;
    _moves++;

    if (_cards[first].symbol == _cards[idx].symbol) {
      setState(() {
        _cards[first].matched = true;
        _cards[idx].matched = true;
        _matches++;
        if (_isTwoPlayer) _pScore[_current]++;
      });
      HapticFeedback.mediumImpact();
      if (_matches == grid.pairs) {
        await _win();
      }
      // matched: same player keeps the turn
    } else {
      _mismatches++;
      _busy = true;
      await Future.delayed(const Duration(milliseconds: 750));
      if (!mounted) return;
      setState(() {
        _cards[first].flipped = false;
        _cards[idx].flipped = false;
        _busy = false;
        if (_isTwoPlayer) _current = 1 - _current;
      });
    }
  }

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  int _computeScore() {
    final base = grid.pairs * 100;
    final timeBonus = max(0, grid.pairs * 10 - _seconds) * 2;
    final penalty = _mismatches * 4;
    return max(grid.pairs * 10, base + timeBonus - penalty);
  }

  Future<void> _lose() async {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();
    await Store.incGamesPlayed();
    if (_matches > 0) await Store.addMatches(_matches);
    if (!mounted) return;
    AdsService.instance.maybeShowInterstitial();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: const Text('⏰ Timpul a expirat'),
        content: Text(
            'Ai găsit $_matches din ${grid.pairs} perechi.\nMai încearcă!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pop(context);
            },
            child: const Text('Înapoi'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(c);
              _restart();
            },
            child: const Text('Din nou'),
          ),
        ],
      ),
    );
  }

  Future<void> _win() async {
    _finished = true;
    _timer?.cancel();
    HapticFeedback.heavyImpact();
    AdsService.instance.maybeShowInterstitial();

    await Store.addMatches(_matches);
    await Store.incGamesPlayed();
    await Store.incGamesWon();

    if (_isTwoPlayer) {
      _showTwoPlayerResult();
      return;
    }

    final streak = await Store.touchStreak();
    final newRecord = await Store.recordTime(grid.key, _seconds);
    final score = _computeScore();

    int rank = 0;
    if (cfg.mode == GameMode.daily) {
      await Store.recordDaily(score);
      rank = await Store.addScore(
          LeaderEntry(score, 'Zilnic', grid.toString(), _today()));
    } else {
      rank = await Store.addScore(
          LeaderEntry(score, cfg.mode.label, grid.toString(), _today()));
    }

    final newly = await evaluateAchievements(
      seconds: _seconds,
      mismatches: _mismatches,
      isHardest: grid.cols == kHardestGrid.cols && grid.rows == kHardestGrid.rows,
      streak: streak,
    );

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: const Text('🎉 Felicitări!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Timp', _fmt(_seconds)),
            _row('Mutări', '$_moves'),
            _row('Greșeli', '$_mismatches'),
            _row('Scor', '$score'),
            if (rank > 0) _row('Clasament', 'locul #$rank'),
            if (newRecord)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('🏅 Record nou pentru această grilă!',
                    style: TextStyle(
                        color: _purple, fontWeight: FontWeight.bold)),
              ),
            if (newly.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text('Realizări deblocate:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              for (final a in newly) Text('${a.icon}  ${a.name}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pop(context);
            },
            child: const Text('Înapoi'),
          ),
          if (cfg.mode != GameMode.daily)
            FilledButton(
              onPressed: () {
                Navigator.pop(c);
                _restart();
              },
              child: const Text('Din nou'),
            ),
        ],
      ),
    );
  }

  void _showTwoPlayerResult() {
    final p1 = _pScore[0], p2 = _pScore[1];
    final msg = p1 == p2
        ? 'Egalitate! $p1 – $p2'
        : (p1 > p2
            ? 'Jucătorul 1 câștigă! $p1 – $p2'
            : 'Jucătorul 2 câștigă! $p2 – $p1');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: const Text('🏆 Final'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pop(context);
            },
            child: const Text('Înapoi'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(c);
              _restart();
            },
            child: const Text('Din nou'),
          ),
        ],
      ),
    );
  }

  String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: const TextStyle(color: Colors.black54)),
            Text(v, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BannerAdWidget(),
      appBar: AppBar(
        title: Text('${cfg.mode.label} · $grid'),
        backgroundColor: _purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Reîncepe',
            onPressed: _restart,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: const Color(0xFFF3E5F5),
              child: _isTwoPlayer ? _twoPlayerBar() : _statsBar(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: grid.cols,
                    childAspectRatio: 0.78,
                    crossAxisSpacing: 7,
                    mainAxisSpacing: 7,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (ctx, i) => _CardWidget(
                    card: _cards[i],
                    face: _faces[_cards[i].symbol],
                    onTap: () => _onTap(i),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _stat(_isTimeAttack ? 'Rămas' : 'Timp',
            _fmt(_isTimeAttack ? _remaining.clamp(0, 9999) : _seconds)),
        _stat('Mutări', '$_moves'),
        _stat('Perechi', '$_matches/${grid.pairs}'),
      ],
    );
  }

  Widget _twoPlayerBar() {
    Widget p(int i) {
      final active = _current == i;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? _purple : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text('Jucător ${i + 1}',
                style: TextStyle(
                    color: active ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.bold)),
            Text('${_pScore[i]}',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: active ? Colors.white : _purple)),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [p(0), _stat('Perechi', '$_matches/${grid.pairs}'), p(1)],
    );
  }

  Widget _stat(String label, String value) => Column(
        children: [
          Text(label,
              style: const TextStyle(color: Colors.black54, fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w900, color: _purple)),
        ],
      );
}

class _CardWidget extends StatelessWidget {
  final _Card card;
  final String face;
  final VoidCallback onTap;
  const _CardWidget(
      {required this.card, required this.face, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final showing = card.flipped || card.matched;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: showing
              ? (card.matched ? const Color(0xFFE1BEE7) : Colors.white)
              : _purple,
          borderRadius: BorderRadius.circular(10),
          border: card.matched
              ? Border.all(color: _purple, width: 2)
              : null,
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2))
          ],
        ),
        child: Center(
          child: showing
              ? FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(face, style: const TextStyle(fontSize: 34)),
                  ),
                )
              : const Icon(Icons.help_outline,
                  color: Colors.white24, size: 30),
        ),
      ),
    );
  }
}
