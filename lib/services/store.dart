import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// One entry on the local leaderboard.
class LeaderEntry {
  final int score;
  final String mode;
  final String grid;
  final String date; // yyyy-mm-dd

  LeaderEntry(this.score, this.mode, this.grid, this.date);

  Map<String, dynamic> toJson() =>
      {'s': score, 'm': mode, 'g': grid, 'd': date};

  factory LeaderEntry.fromJson(Map<String, dynamic> j) => LeaderEntry(
        j['s'] as int,
        j['m'] as String? ?? '',
        j['g'] as String? ?? '',
        j['d'] as String? ?? '',
      );
}

/// Persistent storage backed by SharedPreferences. Fully offline.
class Store {
  static late SharedPreferences _p;

  static Future<void> init() async {
    _p = await SharedPreferences.getInstance();
  }

  // ---- Selected theme ----
  static int get themeIndex => _p.getInt('theme_index') ?? 0;
  static Future<void> setThemeIndex(int i) => _p.setInt('theme_index', i);

  // ---- Best time per grid size (seconds) ----
  static int? bestTime(String gridKey) => _p.getInt('best_$gridKey');

  static Future<bool> recordTime(String gridKey, int seconds) async {
    final cur = bestTime(gridKey);
    if (cur == null || seconds < cur) {
      await _p.setInt('best_$gridKey', seconds);
      return true; // new record
    }
    return false;
  }

  // ---- Aggregate stats ----
  static int get totalMatches => _p.getInt('total_matches') ?? 0;
  static int get gamesWon => _p.getInt('games_won') ?? 0;
  static int get gamesPlayed => _p.getInt('games_played') ?? 0;

  static Future<void> addMatches(int n) =>
      _p.setInt('total_matches', totalMatches + n);
  static Future<void> incGamesPlayed() =>
      _p.setInt('games_played', gamesPlayed + 1);
  static Future<void> incGamesWon() =>
      _p.setInt('games_won', gamesWon + 1);

  // ---- Daily streak ----
  static int get streak => _p.getInt('streak') ?? 0;
  static String get _lastPlayDay => _p.getString('last_play_day') ?? '';

  /// Call once when a game is completed. Returns the updated streak.
  static Future<int> touchStreak() async {
    final now = DateTime.now();
    final today = _dayKey(now);
    final yesterday = _dayKey(now.subtract(const Duration(days: 1)));
    final last = _lastPlayDay;
    if (last == today) return streak;
    int next;
    if (last == yesterday) {
      next = streak + 1;
    } else {
      next = 1;
    }
    await _p.setInt('streak', next);
    await _p.setString('last_play_day', today);
    return next;
  }

  static String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ---- Achievements ----
  static bool isUnlocked(String id) => _p.getBool('ach_$id') ?? false;

  /// Returns true if this call newly unlocked the achievement.
  static Future<bool> unlock(String id) async {
    if (isUnlocked(id)) return false;
    await _p.setBool('ach_$id', true);
    return true;
  }

  // ---- Daily challenge ----
  static String get _todayKey {
    final n = DateTime.now();
    return _dayKey(n);
  }

  static bool get dailyDoneToday =>
      _p.getString('daily_done') == _todayKey;
  static int get dailyBestToday =>
      dailyDoneToday ? (_p.getInt('daily_best') ?? 0) : 0;

  static Future<void> recordDaily(int score) async {
    final best = dailyBestToday;
    await _p.setString('daily_done', _todayKey);
    if (score > best) await _p.setInt('daily_best', score);
  }

  // ---- Local leaderboard (top 20) ----
  static List<LeaderEntry> leaderboard() {
    final raw = _p.getString('leaderboard');
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List)
        .map((e) => LeaderEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => b.score.compareTo(a.score));
    return list;
  }

  static Future<int> addScore(LeaderEntry e) async {
    final list = leaderboard()..add(e);
    list.sort((a, b) => b.score.compareTo(a.score));
    final top = list.take(20).toList();
    await _p.setString(
        'leaderboard', jsonEncode(top.map((x) => x.toJson()).toList()));
    return top.indexWhere((x) => identical(x, e)) + 1; // 1-based rank, 0 if off
  }
}
