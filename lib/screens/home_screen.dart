import 'package:flutter/material.dart';

import '../models/daily_reward.dart';
import '../models/game_level.dart';
import '../models/game_theme.dart';
import '../services/daily_reward_service.dart';
import '../services/level_service.dart';
import '../services/score_service.dart';
import '../services/store_service.dart';
import '../widgets/daily_reward_dialog.dart';
import '../widgets/stack_logo.dart';
import 'game_screen.dart';
import 'levels_screen.dart';
import 'store_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scoreService = ScoreService();
  final _storeService = StoreService();
  final _levelService = LevelService();
  final _dailyRewardService = DailyRewardService();

  int _bestScore = 0;
  int _coins = 0;
  int _claimableLevels = 0;
  int? _pendingRewardDay;
  int _streak = 0;
  bool _dailyDialogAutoShown = false;
  GameTheme _selectedTheme = kClassicTheme;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final best = await _scoreService.loadBestScore();
    final coins = await _storeService.loadCoins();
    final selectedId = await _storeService.loadSelectedThemeId();
    final claimedIds = await _levelService.loadClaimedLevelIds();
    final pendingRewardDay = await _dailyRewardService.pendingStreakDay();
    final streak = await _dailyRewardService.loadStreak();
    if (!mounted) return;
    setState(() {
      _bestScore = best;
      _coins = coins;
      _selectedTheme = themeById(selectedId);
      _claimableLevels = kGameLevels
          .where((l) => best >= l.targetScore && !claimedIds.contains(l.id))
          .length;
      _pendingRewardDay = pendingRewardDay;
      _streak = streak;
    });

    if (!_dailyDialogAutoShown && pendingRewardDay != null) {
      _dailyDialogAutoShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _showDailyRewardDialog());
    }
  }

  Future<void> _showDailyRewardDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => DailyRewardDialog(
        pendingDay: _pendingRewardDay,
        streak: _streak,
        onClaim: _claimDailyReward,
      ),
    );
  }

  Future<void> _claimDailyReward() async {
    final day = await _dailyRewardService.claim();
    final newCoins = await _storeService.addCoins(kDailyRewards[day - 1]);
    if (!mounted) return;
    Navigator.of(context).pop();
    setState(() {
      _coins = newCoins;
      _streak = day;
      _pendingRewardDay = null;
    });
  }

  Future<void> _play() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameScreen(theme: _selectedTheme)),
    );
    _loadData();
  }

  Future<void> _openStore() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StoreScreen()),
    );
    _loadData();
  }

  Future<void> _openLevels() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LevelsScreen()),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1F3B),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 8,
              right: 8,
              child: _GiftButton(
                hasReward: _pendingRewardDay != null,
                onTap: _showDailyRewardDialog,
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              const StackLogo(scale: 1.2),
              const SizedBox(height: 24),
              const Text(
                'STACK IT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Best: $_bestScore',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '🪙 $_coins',
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: _play,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amberAccent,
                    foregroundColor: const Color(0xFF232752),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'PLAY',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: 220,
                child: Row(
                  children: [
                    Expanded(
                      child: _MenuButton(
                        icon: Icons.storefront_rounded,
                        label: 'STORE',
                        onTap: _openStore,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MenuButton(
                        icon: Icons.emoji_events_rounded,
                        label: 'LEVELS',
                        onTap: _openLevels,
                        badgeCount: _claimableLevels,
                      ),
                    ),
                  ],
                ),
              ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A secondary home-screen action button (Store / Levels). Both share this
/// widget so they always match in size, padding, and shape.
class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              constraints: const BoxConstraints(minWidth: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1B1F3B), width: 2),
              ),
              child: Text(
                '$badgeCount',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}

/// Top-right icon that opens the daily reward dialog anytime, with a
/// small dot when a gift is waiting to be claimed.
class _GiftButton extends StatelessWidget {
  const _GiftButton({required this.hasReward, required this.onTap});

  final bool hasReward;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          icon: const Icon(Icons.card_giftcard, color: Colors.white70),
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: 0.25),
            shape: const CircleBorder(),
          ),
        ),
        if (hasReward)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1B1F3B), width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
