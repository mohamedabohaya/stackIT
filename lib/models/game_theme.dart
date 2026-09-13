import 'package:flutter/material.dart';

/// A purchasable cosmetic bundle: a background color plus the palette
/// the stacked blocks cycle through.
class GameTheme {
  const GameTheme({
    required this.id,
    required this.name,
    required this.price,
    required this.backgroundColor,
    required this.blockColors,
  });

  final String id;
  final String name;
  final int price;
  final Color backgroundColor;
  final List<Color> blockColors;

  Color get groundColor => Color.lerp(backgroundColor, Colors.black, 0.35)!;
}

const kClassicTheme = GameTheme(
  id: 'classic',
  name: 'Classic Rainbow',
  price: 0,
  backgroundColor: Color(0xFF1B1F3B),
  blockColors: [
    Color(0xFFEF476F),
    Color(0xFFFFA630),
    Color(0xFFC6E85A),
    Color(0xFF4ECDC4),
    Color(0xFF6C63FF),
  ],
);

const kNeonTheme = GameTheme(
  id: 'neon',
  name: 'Neon Nights',
  price: 20,
  backgroundColor: Color(0xFF0B0B14),
  blockColors: [
    Color(0xFFFF2E92),
    Color(0xFF00E5FF),
    Color(0xFFFFEE00),
    Color(0xFF7C4DFF),
    Color(0xFF00FFA3),
  ],
);

const kSunsetTheme = GameTheme(
  id: 'sunset',
  name: 'Sunset',
  price: 30,
  backgroundColor: Color(0xFF2B1030),
  blockColors: [
    Color(0xFFFF6B35),
    Color(0xFFFFD23F),
    Color(0xFFEE4266),
    Color(0xFFF6AE2D),
    Color(0xFFD7263D),
  ],
);

const kOceanTheme = GameTheme(
  id: 'ocean',
  name: 'Ocean Breeze',
  price: 40,
  backgroundColor: Color(0xFF08202C),
  blockColors: [
    Color(0xFF2EC4B6),
    Color(0xFF5BC0EB),
    Color(0xFF9BF6FF),
    Color(0xFFFFD166),
    Color(0xFF1B98E0),
  ],
);

const kPastelTheme = GameTheme(
  id: 'pastel',
  name: 'Pastel Dream',
  price: 50,
  backgroundColor: Color(0xFF2E2A3A),
  blockColors: [
    Color(0xFFFFB5C0),
    Color(0xFFFFE0AC),
    Color(0xFFC9F2C7),
    Color(0xFFB8E1FF),
    Color(0xFFD9C5FF),
  ],
);

const List<GameTheme> kStoreThemes = [
  kClassicTheme,
  kNeonTheme,
  kSunsetTheme,
  kOceanTheme,
  kPastelTheme,
];

GameTheme themeById(String id) {
  for (final theme in kStoreThemes) {
    if (theme.id == id) return theme;
  }
  return kClassicTheme;
}
