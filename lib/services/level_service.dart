import 'package:shared_preferences/shared_preferences.dart';

/// Tracks which level gifts the player has already claimed. Local only.
class LevelService {
  static const _claimedKey = 'stack_it_claimed_levels';

  Future<Set<int>> loadClaimedLevelIds() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_claimedKey) ?? const [];
    return stored.map(int.parse).toSet();
  }

  Future<void> markClaimed(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    final claimed = <String>{...(prefs.getStringList(_claimedKey) ?? const [])};
    claimed.add(levelId.toString());
    await prefs.setStringList(_claimedKey, claimed.toList());
  }
}
