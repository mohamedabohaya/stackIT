/// A best-score milestone. Reaching [targetScore] in any run makes the
/// level's coin gift claimable from the Levels screen.
class GameLevel {
  const GameLevel({
    required this.id,
    required this.targetScore,
    required this.reward,
  });

  final int id;
  final int targetScore;
  final int reward;
}

const List<GameLevel> kGameLevels = [
  GameLevel(id: 1, targetScore: 5, reward: 10),
  GameLevel(id: 2, targetScore: 10, reward: 15),
  GameLevel(id: 3, targetScore: 15, reward: 20),
  GameLevel(id: 4, targetScore: 20, reward: 25),
  GameLevel(id: 5, targetScore: 30, reward: 35),
  GameLevel(id: 6, targetScore: 40, reward: 45),
  GameLevel(id: 7, targetScore: 50, reward: 60),
  GameLevel(id: 8, targetScore: 65, reward: 75),
  GameLevel(id: 9, targetScore: 80, reward: 90),
  GameLevel(id: 10, targetScore: 100, reward: 120),
  GameLevel(id: 11, targetScore: 125, reward: 150),
  GameLevel(id: 12, targetScore: 150, reward: 175),
  GameLevel(id: 13, targetScore: 175, reward: 200),
  GameLevel(id: 14, targetScore: 200, reward: 250),
  GameLevel(id: 15, targetScore: 250, reward: 300),
  GameLevel(id: 16, targetScore: 300, reward: 350),
  GameLevel(id: 17, targetScore: 350, reward: 400),
  GameLevel(id: 18, targetScore: 400, reward: 450),
  GameLevel(id: 19, targetScore: 450, reward: 500),
  GameLevel(id: 20, targetScore: 500, reward: 600),
];
