class NicotineCalculator {
  NicotineCalculator._();

  /// Nicotine absorbed in mg over a cigarette count, based on product.
  static double nicotineMg(int cigaretteCount, double nicotinePerUnit) {
    return cigaretteCount * nicotinePerUnit;
  }

  /// Tar inhaled in grams.
  static double tarInhaledGrams(int cigaretteCount, double tarMgPerUnit) {
    return (cigaretteCount * tarMgPerUnit) / 1000.0;
  }
}
