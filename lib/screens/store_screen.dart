import 'package:flutter/material.dart';

import '../models/game_theme.dart';
import '../services/heart_service.dart';
import '../services/store_service.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final _storeService = StoreService();
  final _heartService = HeartService();

  int _coins = 0;
  int _hearts = 0;
  Set<String> _unlockedIds = {kClassicTheme.id};
  String _selectedId = kClassicTheme.id;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final coins = await _storeService.loadCoins();
    final hearts = await _heartService.loadHearts();
    final unlocked = await _storeService.loadUnlockedThemeIds();
    final selected = await _storeService.loadSelectedThemeId();
    if (!mounted) return;
    setState(() {
      _coins = coins;
      _hearts = hearts;
      _unlockedIds = unlocked;
      _selectedId = selected;
      _loading = false;
    });
  }

  Future<void> _buyHeart() async {
    if (_hearts >= HeartService.maxHearts) {
      _showMessage('Hearts are already full ($_hearts/${HeartService.maxHearts})');
      return;
    }
    if (_coins < HeartService.price) {
      _showMessage('Need ${HeartService.price - _coins} more 🪙 for a heart');
      return;
    }

    final success = await _storeService.spendCoins(HeartService.price);
    if (!success) {
      _showMessage('Need ${HeartService.price - _coins} more 🪙 for a heart');
      return;
    }
    final newHearts = await _heartService.addHearts(1);
    final newCoins = await _storeService.loadCoins();
    if (!mounted) return;
    setState(() {
      _hearts = newHearts;
      _coins = newCoins;
    });
    _showMessage('Bought a heart! ❤️ $newHearts/${HeartService.maxHearts}');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }

  Future<void> _onTapTheme(GameTheme theme) async {
    if (theme.id == _selectedId) return;

    if (_unlockedIds.contains(theme.id)) {
      await _storeService.selectTheme(theme.id);
      if (!mounted) return;
      setState(() => _selectedId = theme.id);
      return;
    }

    if (_coins < theme.price) {
      _showMessage('Need ${theme.price - _coins} more 🪙 to unlock ${theme.name}');
      return;
    }

    final success = await _storeService.unlockTheme(theme);
    if (!success) {
      _showMessage('Need ${theme.price - _coins} more 🪙 to unlock ${theme.name}');
      return;
    }
    await _storeService.selectTheme(theme.id);
    final newCoins = await _storeService.loadCoins();
    if (!mounted) return;
    setState(() {
      _unlockedIds = {..._unlockedIds, theme.id};
      _selectedId = theme.id;
      _coins = newCoins;
    });
    _showMessage('Unlocked ${theme.name}!');
  }

  @override
  Widget build(BuildContext context) {
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
                      'STORE',
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '🪙 $_coins',
                          style: const TextStyle(
                            color: Colors.amberAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '❤️ $_hearts',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Colors.amberAccent))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: kStoreThemes.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _HeartShopCard(
                            hearts: _hearts,
                            onBuy: _buyHeart,
                          );
                        }
                        final theme = kStoreThemes[index - 1];
                        final owned = _unlockedIds.contains(theme.id);
                        final selected = theme.id == _selectedId;
                        return _ThemeCard(
                          theme: theme,
                          owned: owned,
                          selected: selected,
                          onTap: () => _onTapTheme(theme),
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

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.theme,
    required this.owned,
    required this.selected,
    required this.onTap,
  });

  final GameTheme theme;
  final bool owned;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF232752),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? Colors.amberAccent : Colors.white12,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            _ThemePreview(theme: theme),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selected
                        ? 'Selected'
                        : owned
                            ? 'Unlocked — tap to use'
                            : theme.price == 0
                                ? 'Free'
                                : '${theme.price} 🪙',
                    style: TextStyle(
                      color: selected ? Colors.amberAccent : Colors.white60,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: Colors.amberAccent)
            else if (!owned)
              const Icon(Icons.lock_outline, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

class _HeartShopCard extends StatelessWidget {
  const _HeartShopCard({required this.hearts, required this.onBuy});

  final int hearts;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final isFull = hearts >= HeartService.maxHearts;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF232752),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.favorite, color: Colors.redAccent, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hearts',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Continue a run after a game over. $hearts/${HeartService.maxHearts}',
                  style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: isFull ? null : onBuy,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              disabledBackgroundColor: Colors.white24,
              disabledForegroundColor: Colors.white54,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              isFull ? 'FULL' : '+1 ${HeartService.price}🪙',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.theme});

  final GameTheme theme;

  @override
  Widget build(BuildContext context) {
    final colors = theme.blockColors.take(3).toList();
    final widths = [30.0, 42.0, 54.0];
    return Container(
      width: 72,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < colors.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.5),
              child: Container(
                width: widths[i],
                height: 9,
                decoration: BoxDecoration(
                  color: colors[i],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
