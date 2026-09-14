import 'package:flutter/material.dart';

import '../models/daily_reward.dart';

/// Shows the 7-day reward track and lets the player claim today's gift.
/// [pendingDay] is null when today's reward has already been claimed.
class DailyRewardDialog extends StatelessWidget {
  const DailyRewardDialog({
    super.key,
    required this.pendingDay,
    required this.streak,
    required this.onClaim,
  });

  final int? pendingDay;
  final int streak;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final claimedCount = pendingDay == null ? streak : pendingDay! - 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        decoration: BoxDecoration(
          color: const Color(0xFF232752),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'DAILY REWARDS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              pendingDay != null
                  ? 'Come back every day for bigger gifts!'
                  : "Claimed! See you tomorrow for day ${(streak % kDailyRewards.length) + 1}.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < kDailyRewards.length; i++)
                  _DayBadge(
                    day: i + 1,
                    reward: kDailyRewards[i],
                    claimed: i < claimedCount,
                    isToday: pendingDay == i + 1,
                  ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: pendingDay != null ? onClaim : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  disabledBackgroundColor: Colors.white24,
                  disabledForegroundColor: Colors.white54,
                  foregroundColor: const Color(0xFF232752),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  pendingDay != null
                      ? pendingDay == kDailyRewards.length
                          ? 'CLAIM +${kDailyRewards[pendingDay! - 1]} 🪙 +1 ❤️'
                          : 'CLAIM +${kDailyRewards[pendingDay! - 1]} 🪙'
                      : 'COME BACK TOMORROW',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayBadge extends StatelessWidget {
  const _DayBadge({
    required this.day,
    required this.reward,
    required this.claimed,
    required this.isToday,
  });

  final int day;
  final int reward;
  final bool claimed;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final isBonusDay = day == kDailyRewards.length;
    final color = claimed
        ? Colors.greenAccent
        : isToday
            ? Colors.amberAccent
            : Colors.white38;

    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: isToday ? Colors.amberAccent.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday ? Colors.amberAccent : Colors.white12,
          width: isToday ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'DAY $day',
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 6),
          Icon(
            claimed ? Icons.check_circle : (isBonusDay ? Icons.card_giftcard : Icons.monetization_on),
            color: color,
            size: 22,
          ),
          const SizedBox(height: 6),
          Text('$reward', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          if (isBonusDay) Text('+1 ❤️', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
