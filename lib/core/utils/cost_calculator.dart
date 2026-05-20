class CostCalculator {
  CostCalculator._();

  /// Money spent based on COMPLETED packs (every 20 cigarettes = 1 pack bought).
  static double moneySpent({
    required int cigaretteCount,
    required int packSize,
    required double packPrice,
  }) {
    final packsConsumed = cigaretteCount ~/ packSize;
    return packsConsumed * packPrice;
  }

  /// Progress in the current (unfinished) pack: 0.0 - 1.0
  static double currentPackProgress({
    required int cigaretteCount,
    required int packSize,
  }) {
    return (cigaretteCount % packSize) / packSize;
  }

  /// Cigarettes smoked in the current pack
  static int cigarettesInCurrentPack({
    required int cigaretteCount,
    required int packSize,
  }) {
    return cigaretteCount % packSize;
  }
}
