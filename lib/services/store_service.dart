import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_theme.dart';

/// Persists the player's coin balance and their theme unlocks/selection
/// locally. No backend, no real money — coins are earned by playing.
class StoreService {
  static const _coinsKey = 'stack_it_coins';
  static const _unlockedKey = 'stack_it_unlocked_themes';
  static const _selectedKey = 'stack_it_selected_theme';

  Future<int> loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinsKey) ?? 0;
  }

  Future<int> addCoins(int amount) async {
    if (amount <= 0) return loadCoins();
    final prefs = await SharedPreferences.getInstance();
    final updated = (prefs.getInt(_coinsKey) ?? 0) + amount;
    await prefs.setInt(_coinsKey, updated);
    return updated;
  }

  Future<Set<String>> loadUnlockedThemeIds() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_unlockedKey) ?? const [];
    return {kClassicTheme.id, ...stored};
  }

  Future<String> loadSelectedThemeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedKey) ?? kClassicTheme.id;
  }

  Future<void> selectTheme(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedKey, id);
  }

  /// Attempts to buy [theme], deducting its price from the wallet.
  /// Returns true if the purchase succeeded (enough coins available).
  Future<bool> unlockTheme(GameTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    final coins = prefs.getInt(_coinsKey) ?? 0;
    if (coins < theme.price) return false;

    final unlocked = <String>{kClassicTheme.id, ...?prefs.getStringList(_unlockedKey)};
    unlocked.add(theme.id);

    await prefs.setInt(_coinsKey, coins - theme.price);
    await prefs.setStringList(_unlockedKey, unlocked.toList());
    return true;
  }
}
