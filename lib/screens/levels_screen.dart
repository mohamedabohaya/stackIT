import 'package:flutter/material.dart';

import '../models/game_level.dart';
import '../services/level_service.dart';
import '../services/score_service.dart';
import '../services/store_service.dart';

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({super.key});

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  final _levelService = LevelService();
  final _scoreService = ScoreService();
  final _storeService = StoreService();

  int _bestScore = 0;
  int _coins = 0;
  Set<int> _claimedIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final best = await _scoreService.loadBestScore();
    final coins = await _storeService.loadCoins();
    final claimed = await _levelService.loadClaimedLevelIds();
    if (!mounted) return;
    setState(() {
      _bestScore = best;
      _coins = coins;
      _claimedIds = claimed;
      _loading = false;
    });
  }

  Future<void> _claim(GameLevel level) async {
    if (_claimedIds.contains(level.id) || _bestScore < level.targetScore) return;

    final newCoins = await _storeService.addCoins(level.reward);
    await _levelService.markClaimed(level.id);
    if (!mounted) return;
    setState(() {
      _coins = newCoins;
      _claimedIds = {..._claimedIds, level.id};
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Claimed ${level.reward} 🪙 for Level ${level.id}!'),
        duration: const Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final claimableCount = kGameLevels
        .where((l) => _bestScore >= l.targetScore && !_claimedIds.contains(l.id))
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFF1B1F3B),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 20, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'LEVELS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '🪙 $_coins',
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!_loading)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    claimableCount > 0
                        ? '$claimableCount gift${claimableCount == 1 ? '' : 's'} ready to claim!'
                        : 'Best score: $_bestScore',
                    style: TextStyle(
                      color: claimableCount > 0 ? Colors.greenAccent : Colors.white60,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Colors.amberAccent))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: kGameLevels.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final level = kGameLevels[index];
                        return _LevelCard(
                          level: level,
                          claimed: _claimedIds.contains(level.id),
                          unlocked: _bestScore >= level.targetScore,
                          bestScore: _bestScore,
                          onClaim: () => _claim(level),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.claimed,
    required this.unlocked,
    required this.bestScore,
    required this.onClaim,
  });

  final GameLevel level;
  final bool claimed;
  final bool unlocked;
  final int bestScore;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final claimable = unlocked && !claimed;
    final badgeColor = claimed
        ? Colors.greenAccent
        : claimable
            ? Colors.amberAccent
            : Colors.white38;

    return InkWell(
      onTap: claimable ? onClaim : null,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF232752),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: claimable ? Colors.amberAccent : Colors.white12,
            width: claimable ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${level.id}',
                    style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reach ${level.targetScore}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        claimed
                            ? 'Claimed'
                            : claimable
                                ? 'Ready to claim!'
                                : '$bestScore / ${level.targetScore}',
                        style: TextStyle(
                          color: badgeColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '🎁 ${level.reward} 🪙',
                      style: TextStyle(
                        color: claimed ? Colors.white38 : Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (claimed)
                      const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20)
                    else if (!unlocked)
                      const Icon(Icons.lock_outline, color: Colors.white38, size: 20),
                  ],
                ),
              ],
            ),
            if (!claimed && !unlocked) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (bestScore / level.targetScore).clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  valueColor: const AlwaysStoppedAnimation(Colors.amberAccent),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
