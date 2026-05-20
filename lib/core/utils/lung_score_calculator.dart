import 'dart:ui';

import '../constants/medical_constants.dart';

class LungScoreCalculator {
  LungScoreCalculator._();

  static double packYears(double cigarettesPerDay, int smokingYears) {
    return (cigarettesPerDay / MedicalConstants.cigarettesPerPack) * smokingYears;
  }

  /// Predicted FEV1 in liters for a healthy non-smoker.
  /// Simplified linear approximation of GLI-2012 for Caucasian adults 18-60.
  static double predictedFEV1(String sex, int age, int heightCm) {
    if (sex == 'male') {
      return (-0.0244 * age) + (0.0436 * heightCm) - 3.84;
    }
    return (-0.0210 * age) + (0.0342 * heightCm) - 2.79;
  }

  /// Lifestyle/profile modifier factor (0.6 - 1.6).
  /// Higher = faster lung damage, Lower = slower.
  static double computeModifierFactor({
    required int exerciseLevel,
    required int ageFirstCigarette,
    required String productType,
    required int fagerstromScore,
    required int baselineCough,
    required int baselineBreathlessness,
  }) {
    double factor = 1.0;

    switch (exerciseLevel) {
      case 0:
        factor += 0.10;
      case 1:
        factor += 0.0;
      case 2:
        factor -= 0.08;
      case 3:
        factor -= 0.15;
    }

    if (ageFirstCigarette < 16) {
      factor += 0.12;
    } else if (ageFirstCigarette < 18) {
      factor += 0.06;
    }

    switch (productType) {
      case 'cigarette':
        factor += 0.0;
      case 'rolled':
        factor += 0.08;
      case 'iqos':
        factor -= 0.25;
      case 'mixed':
        factor += 0.04;
    }

    if (fagerstromScore >= 7) factor += 0.05;
    if (baselineCough >= 4) factor += 0.06;
    if (baselineBreathlessness >= 4) factor += 0.08;

    return factor.clamp(0.6, 1.6);
  }

  static int calculate({
    required int age,
    required String sex,
    required int heightCm,
    required int smokingYears,
    required double cigarettesPerDay,
    required double modifierFactor,
  }) {
    final baseDecline = sex == 'male'
        ? MedicalConstants.baseDeclineMale
        : MedicalConstants.baseDeclineFemale;

    final peakFEV1ml =
        predictedFEV1(sex, MedicalConstants.peakAge, heightCm) * 1000;

    final declineYears =
        (age - MedicalConstants.declineStartAge).clamp(0, 100);
    final naturalDecline = baseDecline * declineYears;

    final smokingDeclineAnnual =
        (cigarettesPerDay * MedicalConstants.declinePerCigarette)
            .clamp(0, MedicalConstants.maxSmokingDecline);
    final smokingDeclineTotal =
        smokingDeclineAnnual * smokingYears * modifierFactor;

    final expectedFEV1 = peakFEV1ml - naturalDecline;
    final currentFEV1 = peakFEV1ml - naturalDecline - smokingDeclineTotal;

    final score = (currentFEV1 / expectedFEV1) * 100;
    return score.round().clamp(0, 100);
  }

  static (String label, String colorKey) scoreLabel(int score) {
    if (score >= 90) return ('Ottimo', 'success');
    if (score >= 75) return ('Buono', 'success');
    if (score >= 60) return ('Discreto', 'warning');
    if (score >= 40) return ('Attenzione', 'warning');
    return ('Critico', 'danger');
  }

  static ProjectionData computeProjection({
    required int age,
    required String sex,
    required int heightCm,
    required int smokingYears,
    required double cigarettesPerDay,
    required double modifierFactor,
  }) {
    final baseDecline = sex == 'male'
        ? MedicalConstants.baseDeclineMale
        : MedicalConstants.baseDeclineFemale;

    final peakFEV1ml =
        predictedFEV1(sex, MedicalConstants.peakAge, heightCm) * 1000;

    final smokingDeclineAnnual =
        (cigarettesPerDay * MedicalConstants.declinePerCigarette)
                .clamp(0, MedicalConstants.maxSmokingDecline) *
            modifierFactor;

    final declineYears =
        (age - MedicalConstants.declineStartAge).clamp(0, 100);
    final naturalDecline = baseDecline * declineYears;
    final smokingDeclineTotal =
        (cigarettesPerDay * MedicalConstants.declinePerCigarette)
                .clamp(0, MedicalConstants.maxSmokingDecline) *
            smokingYears *
            modifierFactor;

    double fev1Continue = peakFEV1ml - naturalDecline - smokingDeclineTotal;
    double fev1Quit = fev1Continue;

    final nonSmoker = <Offset>[];
    final ifContinue = <Offset>[];
    final ifQuitNow = <Offset>[];

    for (int futureAge = age; futureAge <= age + 40; futureAge++) {
      final dy =
          (futureAge - MedicalConstants.declineStartAge).clamp(0, 100);

      final nonSmokerFEV1 = peakFEV1ml - (baseDecline * dy);
      nonSmoker.add(Offset(
        futureAge.toDouble(),
        ((nonSmokerFEV1 / peakFEV1ml) * 100).clamp(0, 100),
      ));

      ifContinue.add(Offset(
        futureAge.toDouble(),
        ((fev1Continue / peakFEV1ml) * 100).clamp(0, 100),
      ));

      ifQuitNow.add(Offset(
        futureAge.toDouble(),
        ((fev1Quit / peakFEV1ml) * 100).clamp(0, 100),
      ));

      if (futureAge >= MedicalConstants.declineStartAge) {
        fev1Continue -= (baseDecline + smokingDeclineAnnual);
        fev1Quit -= MedicalConstants.exSmokerDecline;
      }
    }

    return ProjectionData(nonSmoker, ifContinue, ifQuitNow);
  }
}

class ProjectionData {
  final List<Offset> nonSmoker;
  final List<Offset> ifContinue;
  final List<Offset> ifQuitNow;

  const ProjectionData(this.nonSmoker, this.ifContinue, this.ifQuitNow);
}
