import 'package:shared_preferences/shared_preferences.dart';

/// Tracks the player's heart (life) balance. Hearts let a run continue
/// from the point of failure instead of starting over. Local only.
class HeartService {
  static const _heartsKey = 'stack_it_hearts';
  static const maxHearts = 5;
  static const price = 40;

  Future<int> loadHearts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_heartsKey) ?? 0;
  }

  Future<int> addHearts(int amount) async {
    if (amount <= 0) return loadHearts();
    final prefs = await SharedPreferences.getInstance();
    final updated = ((prefs.getInt(_heartsKey) ?? 0) + amount).clamp(0, maxHearts);
    await prefs.setInt(_heartsKey, updated);
    return updated;
  }

  /// Attempts to spend one heart. Returns true if a heart was available
  /// and spent.
  Future<bool> spendHeart() async {
    final prefs = await SharedPreferences.getInstance();
    final hearts = prefs.getInt(_heartsKey) ?? 0;
    if (hearts <= 0) return false;
    await prefs.setInt(_heartsKey, hearts - 1);
    return true;
  }
}
