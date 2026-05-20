class MedicalConstants {
  MedicalConstants._();

  // FEV1 annual decline for non-smokers (ml/year)
  static const double baseDeclineMale = 31.0;
  static const double baseDeclineFemale = 27.0;

  // Extra decline per cigarette/day (ml/year per cigarette)
  // Derived from Fletcher-Peto: ~15 cig brings 31 to ~64 ml/year
  static const double declinePerCigarette = 2.2;

  // Max extra annual decline from smoking (ml/year)
  static const double maxSmokingDecline = 54.0;

  // Age of peak lung capacity
  static const int peakAge = 22;

  // Age when natural decline begins
  static const int declineStartAge = 25;

  // Ex-smoker decline (ml/year) — used in "if you quit" projection
  static const double exSmokerDecline = 35.0;

  static const double cigarettesPerPack = 20;

  // Default product values when no product is selected
  static const double defaultTarMg = 10.0;
  static const double defaultNicotineMg = 1.2;
  static const double defaultPackPrice = 6.00;

  static const String disclaimer =
      'Questo non e un parere medico. E un modello statistico basato su '
      'dati epidemiologici. Per una valutazione clinica, consulta il tuo medico.';
}
