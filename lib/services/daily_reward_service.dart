import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_reward.dart';

/// Tracks the player's daily login streak locally. Missing a day resets
/// the streak back to day 1; claiming on consecutive days advances it
/// through the 7-day reward cycle.
class DailyRewardService {
  static const _lastClaimKey = 'stack_it_daily_last_claim';
  static const _streakKey = 'stack_it_daily_streak';

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  Future<DateTime?> _loadLastClaimDate() async {
    final prefs = await SharedPreferences.getInstance();
    final iso = prefs.getString(_lastClaimKey);
    return iso == null ? null : DateTime.tryParse(iso);
  }

  Future<int> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  /// The streak day (1-based, cycling through [kDailyRewards]) claimable
  /// right now, or null if today's reward was already claimed.
  Future<int?> pendingStreakDay() async {
    final last = await _loadLastClaimDate();
    if (last == null) return 1;

    final today = _dateOnly(DateTime.now());
    final diff = today.difference(_dateOnly(last)).inDays;

    if (diff <= 0) return null;
    if (diff == 1) {
      final streak = await loadStreak();
      return (streak % kDailyRewards.length) + 1;
    }
    return 1;
  }

  /// Claims today's reward, persisting the new streak day. Returns the
  /// streak day that was claimed (1-based).
  Future<int> claim() async {
    final day = await pendingStreakDay() ?? await loadStreak();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastClaimKey, _dateOnly(DateTime.now()).toIso8601String());
    await prefs.setInt(_streakKey, day);
    return day;
  }
}
