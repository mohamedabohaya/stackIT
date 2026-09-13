/// Coin rewards for a repeating 7-day login streak, indexed by day-1.
/// Day 7 is a big bonus; the cycle restarts at day 1 after that.
const List<int> kDailyRewards = [10, 15, 20, 30, 40, 55, 100];
