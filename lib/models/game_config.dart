import '../data/grids.dart';

enum GameMode { zen, timeAttack, daily, twoPlayer }

extension GameModeInfo on GameMode {
  String get label {
    switch (this) {
      case GameMode.zen:
        return 'Zen';
      case GameMode.timeAttack:
        return 'Contra cronometru';
      case GameMode.daily:
        return 'Provocarea zilei';
      case GameMode.twoPlayer:
        return 'Doi jucători';
    }
  }

  String get subtitle {
    switch (this) {
      case GameMode.zen:
        return 'Relaxat, fără presiune. Timpul curge în sus.';
      case GameMode.timeAttack:
        return 'Termină înainte să expire timpul.';
      case GameMode.daily:
        return 'O grilă nouă în fiecare zi, cu clasament local.';
      case GameMode.twoPlayer:
        return 'Pe rând, pe același telefon (pass-and-play).';
    }
  }

  String get emoji {
    switch (this) {
      case GameMode.zen:
        return '🧘';
      case GameMode.timeAttack:
        return '⏱️';
      case GameMode.daily:
        return '📅';
      case GameMode.twoPlayer:
        return '👥';
    }
  }
}

class GameConfig {
  final GridSize grid;
  final int themeIndex;
  final GameMode mode;

  /// When set, the deck is generated deterministically from this seed
  /// (used by the daily challenge so everyone gets the same board).
  final int? seed;

  const GameConfig({
    required this.grid,
    required this.themeIndex,
    required this.mode,
    this.seed,
  });

  /// Countdown budget in seconds for time-attack (≈ 7s per pair).
  int get timeBudget => grid.pairs * 7;
}
