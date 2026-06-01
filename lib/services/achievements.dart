import 'store.dart';

/// The 8 achievements advertised on the store listing. IDs match
/// play_metadata.json so the same set is meaningful on every platform.
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  const Achievement(this.id, this.name, this.description, this.icon);

  bool get unlocked => Store.isUnlocked(id);
}

const List<Achievement> kAchievements = [
  Achievement('first_match', 'Prima pereche',
      'Găsește prima ta pereche.', '🎯'),
  Achievement('matches_50', '50 de perechi',
      'Găsește 50 de perechi în total.', '✋'),
  Achievement('matches_200', '200 de perechi',
      'Găsește 200 de perechi în total.', '💪'),
  Achievement('matches_500', '500 de perechi',
      'Găsește 500 de perechi în total.', '🏆'),
  Achievement('fast_match', 'Viteză',
      'Termină un nivel în mai puțin de 60 de secunde.', '⚡'),
  Achievement('no_mistakes', 'Impecabil',
      'Termină un nivel fără nicio greșeală.', '✨'),
  Achievement('streak_7', '7 zile la rând',
      'Joacă Memory Match 7 zile consecutiv.', '🔥'),
  Achievement('memory_master', 'Maestru al memoriei',
      'Termină cel mai greu nivel (8×6).', '👑'),
];

/// Evaluates all achievements after a finished game and returns the list of
/// newly unlocked ones (so the UI can celebrate them).
Future<List<Achievement>> evaluateAchievements({
  required int seconds,
  required int mismatches,
  required bool isHardest,
  required int streak,
}) async {
  final newly = <Achievement>[];

  Future<void> tryUnlock(String id) async {
    if (await Store.unlock(id)) {
      newly.add(kAchievements.firstWhere((a) => a.id == id));
    }
  }

  final total = Store.totalMatches;
  if (total >= 1) await tryUnlock('first_match');
  if (total >= 50) await tryUnlock('matches_50');
  if (total >= 200) await tryUnlock('matches_200');
  if (total >= 500) await tryUnlock('matches_500');
  if (seconds > 0 && seconds < 60) await tryUnlock('fast_match');
  if (mismatches == 0) await tryUnlock('no_mistakes');
  if (streak >= 7) await tryUnlock('streak_7');
  if (isHardest) await tryUnlock('memory_master');

  return newly;
}
