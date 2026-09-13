import 'package:shared_preferences/shared_preferences.dart';

/// Persists the best score locally. No backend — just device storage.
class ScoreService {
  static const _bestScoreKey = 'stack_it_best_score';

  Future<int> loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestScoreKey) ?? 0;
  }

  Future<void> saveBestScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bestScoreKey, score);
  }
}
