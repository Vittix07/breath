import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
enum InsightCategory { temporal, correlation, economic, health, behavioral }

class Insight {
  final String id;
  final String text;
  final IconData icon;
  final Color color;
  final InsightCategory category;

  const Insight({
    required this.id,
    required this.text,
    required this.icon,
    required this.color,
    required this.category,
  });
}

class UserStats {
  final int dataDays;
  final double cigarettesPerDay;
  final int smokingYears;
  final double packYears;
  final double pricePerPack;
  final double nicotinePerUnit;
  final double tarPerUnit;
  final String productType;
  final int todayCount;
  final int yesterdayCount;
  final int monthCount;
  final Map<int, int> weekData; // 0=Mon..6=Sun -> count
  final Map<String, int> contextDistribution;
  final Map<int, int> hourlyDistribution; // hour -> count
  final int totalLogged;
  final List<int> dailyCounts; // last N days, most recent first
  final int? peakDayCount;
  final DateTime? peakDayDate;

  const UserStats({
    required this.dataDays,
    required this.cigarettesPerDay,
    required this.smokingYears,
    required this.packYears,
    required this.pricePerPack,
    required this.nicotinePerUnit,
    required this.tarPerUnit,
    required this.productType,
    required this.todayCount,
    required this.yesterdayCount,
    required this.monthCount,
    required this.weekData,
    required this.contextDistribution,
    required this.hourlyDistribution,
    required this.totalLogged,
    required this.dailyCounts,
    this.peakDayCount,
    this.peakDayDate,
  });
}

// --- Category colors ---
const _categoryColors = {
  InsightCategory.temporal: Color(0xFF0EA5E9),    // sky
  InsightCategory.correlation: Color(0xFF7C3AED), // violet
  InsightCategory.economic: Color(0xFFF97316),     // orange
  InsightCategory.health: Color(0xFFE11D48),       // rose
  InsightCategory.behavioral: Color(0xFF14B8A6),   // teal
};

const _categoryIcons = {
  InsightCategory.temporal: LucideIcons.calendarDays,
  InsightCategory.correlation: LucideIcons.gitBranch,
  InsightCategory.economic: LucideIcons.coins,
  InsightCategory.health: LucideIcons.heartPulse,
  InsightCategory.behavioral: LucideIcons.target,
};

// --- All insight generators ---

abstract class _InsightGen {
  String get id;
  InsightCategory get category;
  int get minDataDays;
  bool hasEnoughData(UserStats s);
  Insight? generate(UserStats s);
  double relevance(UserStats s) => 0.5;
}

// ────── TEMPORAL ──────

class _WorstDayInsight extends _InsightGen {
  @override String get id => 'worst_day';
  @override InsightCategory get category => InsightCategory.temporal;
  @override int get minDataDays => 7;
  @override bool hasEnoughData(UserStats s) => s.weekData.values.any((v) => v > 0);
  @override Insight? generate(UserStats s) {
    int maxDay = 0, maxCount = 0;
    s.weekData.forEach((day, count) {
      if (count > maxCount) { maxCount = count; maxDay = day; }
    });
    if (maxCount == 0) return null;
    const names = ['lunedi', 'martedi', 'mercoledi', 'giovedi', 'venerdi', 'sabato', 'domenica'];
    return Insight(id: id, text: 'Il ${names[maxDay]} fumi di piu (media: $maxCount)', icon: LucideIcons.calendarDays, color: _categoryColors[category]!, category: category);
  }
  @override double relevance(UserStats s) => 0.7;
}

class _BestDayInsight extends _InsightGen {
  @override String get id => 'best_day';
  @override InsightCategory get category => InsightCategory.temporal;
  @override int get minDataDays => 7;
  @override bool hasEnoughData(UserStats s) => s.weekData.values.any((v) => v > 0);
  @override Insight? generate(UserStats s) {
    int minDay = 0, minCount = 999;
    s.weekData.forEach((day, count) {
      if (count < minCount && count >= 0) { minCount = count; minDay = day; }
    });
    const names = ['lunedi', 'martedi', 'mercoledi', 'giovedi', 'venerdi', 'sabato', 'domenica'];
    return Insight(id: id, text: 'Il ${names[minDay]} e il tuo giorno migliore (media: $minCount)', icon: LucideIcons.calendarCheck, color: _categoryColors[category]!, category: category);
  }
  @override double relevance(UserStats s) => 0.6;
}

class _PeakHourInsight extends _InsightGen {
  @override String get id => 'peak_hour';
  @override InsightCategory get category => InsightCategory.temporal;
  @override int get minDataDays => 3;
  @override bool hasEnoughData(UserStats s) => s.hourlyDistribution.isNotEmpty;
  @override Insight? generate(UserStats s) {
    if (s.hourlyDistribution.isEmpty) return null;
    final total = s.hourlyDistribution.values.fold(0, (a, b) => a + b);
    if (total == 0) return null;
    int afterEight = 0;
    s.hourlyDistribution.forEach((h, c) { if (h >= 20) afterEight += c; });
    final pct = ((afterEight / total) * 100).round();
    if (pct < 10) return null;
    return Insight(id: id, text: 'Il $pct% delle tue sigarette e dopo le 20:00', icon: LucideIcons.clock, color: _categoryColors[category]!, category: category);
  }
  @override double relevance(UserStats s) => 0.6;
}

class _WeekdayWeekendInsight extends _InsightGen {
  @override String get id => 'weekday_weekend';
  @override InsightCategory get category => InsightCategory.temporal;
  @override int get minDataDays => 7;
  @override bool hasEnoughData(UserStats s) => s.weekData.values.any((v) => v > 0);
  @override Insight? generate(UserStats s) {
    final wdTotal = (s.weekData[0] ?? 0) + (s.weekData[1] ?? 0) + (s.weekData[2] ?? 0) + (s.weekData[3] ?? 0) + (s.weekData[4] ?? 0);
    final weTotal = (s.weekData[5] ?? 0) + (s.weekData[6] ?? 0);
    final wdAvg = wdTotal / 5; final weAvg = weTotal / 2;
    if (wdAvg == 0 && weAvg == 0) return null;
    if (wdAvg > weAvg && weAvg > 0) {
      final pct = (((wdAvg - weAvg) / weAvg) * 100).round();
      return Insight(id: id, text: 'Fumi il $pct% in piu nei giorni feriali', icon: LucideIcons.briefcase, color: _categoryColors[category]!, category: category);
    } else if (weAvg > wdAvg && wdAvg > 0) {
      final pct = (((weAvg - wdAvg) / wdAvg) * 100).round();
      return Insight(id: id, text: 'Fumi il $pct% in piu nel weekend', icon: LucideIcons.palmtree, color: _categoryColors[category]!, category: category);
    }
    return null;
  }
  @override double relevance(UserStats s) => 0.65;
}

class _WeeklyTrendInsight extends _InsightGen {
  @override String get id => 'weekly_trend';
  @override InsightCategory get category => InsightCategory.temporal;
  @override int get minDataDays => 14;
  @override bool hasEnoughData(UserStats s) => s.dailyCounts.length >= 14;
  @override Insight? generate(UserStats s) {
    if (s.dailyCounts.length < 14) return null;
    final thisWeek = s.dailyCounts.take(7).fold(0, (a, b) => a + b);
    final lastWeek = s.dailyCounts.skip(7).take(7).fold(0, (a, b) => a + b);
    if (lastWeek == 0) return null;
    final pctChange = (((thisWeek - lastWeek) / lastWeek) * 100).round();
    final direction = pctChange >= 0 ? '+$pctChange' : '$pctChange';
    return Insight(id: id, text: 'Questa settimana $direction% rispetto alla scorsa', icon: LucideIcons.trendingUp, color: _categoryColors[category]!, category: category);
  }
  @override double relevance(UserStats s) => 0.7;
}

class _MonthlyAvgInsight extends _InsightGen {
  @override String get id => 'monthly_avg';
  @override InsightCategory get category => InsightCategory.temporal;
  @override int get minDataDays => 14;
  @override bool hasEnoughData(UserStats s) => s.monthCount > 0;
  @override Insight? generate(UserStats s) {
    final daysInMonth = DateTime.now().day;
    if (daysInMonth == 0) return null;
    final avg = (s.monthCount / daysInMonth).toStringAsFixed(1);
    return Insight(id: id, text: 'Questo mese fumi in media $avg/giorno', icon: LucideIcons.barChart3, color: _categoryColors[category]!, category: category);
  }
  @override double relevance(UserStats s) => 0.5;
}

// ────── CORRELATION ──────

class _StressConsumptionInsight extends _InsightGen {
  @override String get id => 'stress_consumption';
  @override InsightCategory get category => InsightCategory.correlation;
  @override int get minDataDays => 10;
  @override bool hasEnoughData(UserStats s) => s.contextDistribution.containsKey('stress');
  @override Insight? generate(UserStats s) {
    final stressCount = s.contextDistribution['stress'] ?? 0;
    if (stressCount == 0) return null;
    final total = s.contextDistribution.values.fold(0, (a, b) => a + b);
    if (total == 0) return null;
    final pct = ((stressCount / total) * 100).round();
    return Insight(id: id, text: 'Il $pct% delle sigarette e legato allo stress', icon: LucideIcons.zap, color: _categoryColors[category]!, category: category);
  }
  @override double relevance(UserStats s) => 0.75;
}

class _ExerciseConsumptionInsight extends _InsightGen {
  @override String get id => 'exercise_consumption';
  @override InsightCategory get category => InsightCategory.correlation;
  @override int get minDataDays => 10;
  @override bool hasEnoughData(UserStats s) => s.dataDays >= 10;
  @override Insight? generate(UserStats s) {
    return Insight(id: id, text: 'Nei giorni attivi tendi a fumare meno', icon: LucideIcons.dumbbell, color: _categoryColors[category]!, category: category);
  }
  @override double relevance(UserStats s) => 0.4;
}

class _WellbeingConsumptionInsight extends _InsightGen {
  @override String get id => 'wellbeing_consumption';
  @override InsightCategory get category => InsightCategory.correlation;
  @override int get minDataDays => 10;
  @override bool hasEnoughData(UserStats s) => s.dataDays >= 10;
  @override Insight? generate(UserStats s) {
    return Insight(id: id, text: 'Ti senti meglio nei giorni in cui fumi meno', icon: LucideIcons.smile, color: _categoryColors[category]!, category: category);
  }
  @override double relevance(UserStats s) => 0.4;
}

class _CravingHabitInsight extends _InsightGen {
  @override String get id => 'craving_habit';
  @override InsightCategory get category => InsightCategory.correlation;
  @override int get minDataDays => 10;
  @override bool hasEnoughData(UserStats s) {
    final boredom = s.contextDistribution['boredom'] ?? 0;
    return boredom > 0;
  }
  @override Insight? generate(UserStats s) {
    final boredom = s.contextDistribution['boredom'] ?? 0;
    final total = s.contextDistribution.values.fold(0, (a, b) => a + b);
    if (total == 0) return null;
    final pct = ((boredom / total) * 100).round();
    if (pct < 5) return null;
    return Insight(id: id, text: 'Il $pct% delle volte fumi per abitudine/noia', icon: LucideIcons.repeat, color: _categoryColors[category]!, category: category);
  }
  @override double relevance(UserStats s) => 0.6;
}

class _DominantContextInsight extends _InsightGen {
  @override String get id => 'dominant_context';
  @override InsightCategory get category => InsightCategory.correlation;
  @override int get minDataDays => 7;
  @override bool hasEnoughData(UserStats s) => s.contextDistribution.isNotEmpty;
  @override Insight? generate(UserStats s) {
    if (s.contextDistribution.isEmpty) return null;
    final sorted = s.contextDistribution.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first;
    if (top.key == 'none' || top.key == 'other') return null;
    final total = s.contextDistribution.values.fold(0, (a, b) => a + b);
    if (total == 0) return null;
    final pct = ((top.value / total) * 100).round();
    const labels = {'stress': 'stress', 'social': 'socialita', 'boredom': 'noia', 'after_coffee': 'caffe', 'after_meal': 'dopo pasto'};
    return Insight(id: id, text: 'Il $pct% delle sigarette in contesto: ${labels[top.key] ?? top.key}', icon: LucideIcons.pieChart, color: _categoryColors[category]!, category: category);
  }
  @override double relevance(UserStats s) => 0.7;
}

class _SleepConsumptionInsight extends _InsightGen {
  @override String get id => 'sleep_consumption';
  @override InsightCategory get category => InsightCategory.correlation;
  @override int get minDataDays => 10;
  @override bool hasEnoughData(UserStats s) => s.dataDays >= 10;
  @override Insight? generate(UserStats s) {
    return Insight(id: id, text: 'Dormi meglio nei giorni con meno sigarette', icon: LucideIcons.moon, color: _categoryColors[category]!, category: category);
  }
  @override double relevance(UserStats s) => 0.35;
}

// ────── ECONOMIC ──────

class _WeeklySpendInsight extends _InsightGen {
  @override String get id => 'weekly_spend';
  @override InsightCategory get category => InsightCategory.economic;
  @override int get minDataDays => 7;
  @override bool hasEnoughData(UserStats s) => s.dailyCounts.length >= 7;
  @override Insight? generate(UserStats s) {
    final weekCount = s.dailyCounts.take(7).fold(0, (a, b) => a + b);
    final packs = weekCount ~/ 20;
    final spent = packs * s.pricePerPack;
    if (spent == 0) return null;
    return Insight(id: id, text: 'Questa settimana hai speso ${spent.toStringAsFixed(0)}€ in sigarette', icon: LucideIcons.wallet, color: _categoryColors[category]!, category: category);
  }
  @override double relevance(UserStats s) => 0.65;
}

class _ProjectedAnnualSpendInsight extends _InsightGen {
  @override String get id => 'projected_annual';
  @override InsightCategory get category => InsightCategory.economic;
  @override int get minDataDays => 3;
  @override bool hasEnoughData(UserStats s) => s.cigarettesPerDay > 0;
  @override Insight? generate(UserStats s) {
    final dailyPacks = s.cigarettesPerDay / 20;
    final annual = dailyPacks * 365 * s.pricePerPack;
    return Insight(id: id, text: 'A questo ritmo spenderai ${annual.toStringAsFixed(0)}€ quest\'anno', icon: LucideIcons.trendingUp, color: _categoryColors[category]!, category: category);
  }
  @override double relevance(UserStats s) => 0.8;
}

class _SpendEquivalenceInsight extends _InsightGen {
  @override String get id => 'spend_equivalence';
  @override InsightCategory get category => InsightCategory.economic;
  @override int get minDataDays => 7;
  @override bool hasEnoughData(UserStats s) => s.monthCount > 0;
  @override Insight? generate(UserStats s) {
    final packs = s.monthCount ~/ 20;
    final spent = packs * s.pricePerPack;
    if (spent < 5) return null;
    final equivalences = [
      (10.99, 'un abbonamento Spotify'),
      (8.0, 'una pizza al ristorante'),
      (15.0, 'un libro'),
      (4.0, 'un caffe e cornetto'),
      (35.0, 'una cena fuori'),
      (50.0, 'un paio di scarpe da corsa'),
    ];
    final affordable = equivalences.where((e) => spent >= e.$1).toList();
    if (affordable.isEmpty) return null;
    final pick = affordable[DateTime.now().day % affordable.length];
    return Insight(id: id, text: 'Con la spesa di questo mese potresti comprare ${pick.$2}', icon: LucideIcons.shoppingBag, color: _categoryColors[category]!, category: category);
  }
  @override double relevance(UserStats s) => 0.7;
}

class _PacksConsumedInsight extends _InsightGen {
  @override String get id => 'packs_consumed';
  @override InsightCategory get category => InsightCategory.economic;
  @override int get minDataDays => 3;
  @override bool hasEnoughData(UserStats s) => s.monthCount > 0;
  @override Insight? generate(UserStats s) {
    final packs = s.monthCount ~/ 20;
    final remaining = s.monthCount % 20;
    if (packs == 0 && remaining == 0) return null;
    return Insight(id: id, text: 'Hai consumato $packs pacchetti questo mese ($remaining nel corrente)', icon: LucideIcons.packageOpen, color: _categoryColors[category]!, category: category);
  }
  @override double relevance(UserStats s) => 0.5;
}

// ────── HEALTH ──────

class _WeeklyNicotineInsight extends _InsightGen {
  @override String get id => 'weekly_nicotine';
  @override InsightCategory get category => InsightCategory.health;
  @override int get minDataDays => 3;
  @override bool hasEnoughData(UserStats s) => s.dailyCounts.isNotEmpty;
  @override Insight? generate(UserStats s) {
    final weekCount = s.dailyCounts.take(7).fold(0, (a, b) => a + b);
    final mg = (weekCount * s.nicotinePerUnit).round();
    if (mg == 0) return null;
    return Insight(id: id, text: 'Questa settimana hai assunto ~$mg mg di nicotina', icon: LucideIcons.flaskConical, color: _categoryColors[category]!, category: category);
  }
  @override double relevance(UserStats s) => 0.6;
}

class _MonthlyTarInsight extends _InsightGen {
  @override String get id => 'monthly_tar';
  @override InsightCategory get category => InsightCategory.health;
  @override int get minDataDays => 7;
  @override bool hasEnoughData(UserStats s) => s.monthCount > 0 && s.tarPerUnit > 0;
  @override Insight? generate(UserStats s) {
    if (s.tarPerUnit <= 0) return null;
    final grams = (s.monthCount * s.tarPerUnit) / 1000;
    return Insight(id: id, text: 'Questo mese hai inalato ~${grams.toStringAsFixed(2)} g di catrame', icon: LucideIcons.droplets, color: _categoryColors[category]!, category: category);
  }
  @override double relevance(UserStats s) => 0.65;
}

class _SymptomChangeInsight extends _InsightGen {
  @override String get id => 'symptom_change';
  @override InsightCategory get category => InsightCategory.health;
  @override int get minDataDays => 14;
  @override bool hasEnoughData(UserStats s) => s.dataDays >= 14;
  @override Insight? generate(UserStats s) {
    return Insight(id: id, text: 'Completa i check-in settimanali per tracciare i sintomi', icon: LucideIcons.clipboardList, color: _categoryColors[category]!, category: category);
  }
  @override double relevance(UserStats s) => 0.3;
}

class _PackYearsMilestoneInsight extends _InsightGen {
  @override String get id => 'pack_years_milestone';
  @override InsightCategory get category => InsightCategory.health;
  @override int get minDataDays => 1;
  @override bool hasEnoughData(UserStats s) => true;
  @override Insight? generate(UserStats s) {
    final py = s.packYears;
    return Insight(id: id, text: 'Hai raggiunto ${py.toStringAsFixed(1)} pack-years', icon: LucideIcons.activity, color: _categoryColors[category]!, category: category);
  }
  @override double relevance(UserStats s) => 0.55;
}

class _LungScoreTrendInsight extends _InsightGen {
  @override String get id => 'lung_score_trend';
  @override InsightCategory get category => InsightCategory.health;
  @override int get minDataDays => 30;
  @override bool hasEnoughData(UserStats s) => s.dataDays >= 30;
  @override Insight? generate(UserStats s) {
    return Insight(id: id, text: 'Il tuo Lung Score e stabile questo mese', icon: LucideIcons.heartPulse, color: _categoryColors[category]!, category: category);
  }
  @override double relevance(UserStats s) => 0.5;
}

// ────── BEHAVIORAL ──────

class _TrackingStreakInsight extends _InsightGen {
  @override String get id => 'tracking_streak';
  @override InsightCategory get category => InsightCategory.behavioral;
  @override int get minDataDays => 3;
  @override bool hasEnoughData(UserStats s) => s.dataDays >= 3;
  @override Insight? generate(UserStats s) {
    int streak = 0;
    for (final count in s.dailyCounts) {
      if (count > 0) { streak++; } else { break; }
    }
    if (streak < 2) return null;
    return Insight(id: id, text: 'Hai loggato per $streak giorni di fila', icon: LucideIcons.flame, color: _categoryColors[category]!, category: category);
  }
  @override double relevance(UserStats s) => 0.6;
}

class _ReductionVsBaselineInsight extends _InsightGen {
  @override String get id => 'reduction_baseline';
  @override InsightCategory get category => InsightCategory.behavioral;
  @override int get minDataDays => 14;
  @override bool hasEnoughData(UserStats s) => s.dailyCounts.length >= 14;
  @override Insight? generate(UserStats s) {
    if (s.dailyCounts.length < 14) return null;
    final recent = s.dailyCounts.take(7).fold(0, (a, b) => a + b) / 7;
    final baseline = s.cigarettesPerDay;
    if (baseline <= 0) return null;
    final diff = baseline - recent;
    if (diff <= 0) return null;
    return Insight(id: id, text: 'Fumi ${diff.toStringAsFixed(1)} in meno rispetto a quando hai iniziato', icon: LucideIcons.arrowDown, color: _categoryColors[category]!, category: category);
  }
  @override double relevance(UserStats s) => 0.75;
}

class _AbsolutePeakInsight extends _InsightGen {
  @override String get id => 'absolute_peak';
  @override InsightCategory get category => InsightCategory.behavioral;
  @override int get minDataDays => 7;
  @override bool hasEnoughData(UserStats s) => s.peakDayCount != null && s.peakDayCount! > 0;
  @override Insight? generate(UserStats s) {
    if (s.peakDayCount == null || s.peakDayCount == 0) return null;
    final dateStr = s.peakDayDate != null ? '${s.peakDayDate!.day}/${s.peakDayDate!.month}' : '';
    return Insight(id: id, text: 'Il tuo record giornaliero: ${s.peakDayCount} sigarette${dateStr.isNotEmpty ? ' il $dateStr' : ''}', icon: LucideIcons.trophy, color: _categoryColors[category]!, category: category);
  }
  @override double relevance(UserStats s) => 0.5;
}

class _MovingAverageInsight extends _InsightGen {
  @override String get id => 'moving_average';
  @override InsightCategory get category => InsightCategory.behavioral;
  @override int get minDataDays => 21;
  @override bool hasEnoughData(UserStats s) => s.dailyCounts.length >= 21;
  @override Insight? generate(UserStats s) {
    if (s.dailyCounts.length < 21) return null;
    final w1 = s.dailyCounts.take(7).fold(0, (a, b) => a + b) / 7;
    final w2 = s.dailyCounts.skip(7).take(7).fold(0, (a, b) => a + b) / 7;
    final w3 = s.dailyCounts.skip(14).take(7).fold(0, (a, b) => a + b) / 7;
    if (w1 < w2 && w2 < w3) {
      return Insight(id: id, text: 'La tua media sta scendendo da 3 settimane', icon: LucideIcons.trendingDown, color: _categoryColors[category]!, category: category);
    } else if (w1 > w2 && w2 > w3) {
      return Insight(id: id, text: 'La tua media sta salendo da 3 settimane', icon: LucideIcons.trendingUp, color: _categoryColors[category]!, category: category);
    }
    return Insight(id: id, text: 'La tua media e stabile da 3 settimane', icon: LucideIcons.minus, color: _categoryColors[category]!, category: category);
  }
  @override double relevance(UserStats s) => 0.55;
}

// --- All generators ---

final List<_InsightGen> _allGenerators = [
  _WorstDayInsight(),
  _BestDayInsight(),
  _PeakHourInsight(),
  _WeekdayWeekendInsight(),
  _WeeklyTrendInsight(),
  _MonthlyAvgInsight(),
  _StressConsumptionInsight(),
  _ExerciseConsumptionInsight(),
  _WellbeingConsumptionInsight(),
  _CravingHabitInsight(),
  _DominantContextInsight(),
  _SleepConsumptionInsight(),
  _WeeklySpendInsight(),
  _ProjectedAnnualSpendInsight(),
  _SpendEquivalenceInsight(),
  _PacksConsumedInsight(),
  _WeeklyNicotineInsight(),
  _MonthlyTarInsight(),
  _SymptomChangeInsight(),
  _PackYearsMilestoneInsight(),
  _LungScoreTrendInsight(),
  _TrackingStreakInsight(),
  _ReductionVsBaselineInsight(),
  _AbsolutePeakInsight(),
  _MovingAverageInsight(),
];

// --- Daily selection algorithm ---

List<Insight> selectDailyInsights(UserStats stats, DateTime date) {
  final available = <(Insight, double)>[];
  for (final gen in _allGenerators) {
    if (stats.dataDays >= gen.minDataDays && gen.hasEnoughData(stats)) {
      final insight = gen.generate(stats);
      if (insight != null) {
        available.add((insight, gen.relevance(stats)));
      }
    }
  }

  final seed = date.year * 10000 + date.month * 100 + date.day;
  final rng = Random(seed);

  available.sort((a, b) {
    final aScore = rng.nextDouble() * 0.4 + a.$2;
    final bScore = rng.nextDouble() * 0.4 + b.$2;
    return bScore.compareTo(aScore);
  });

  final selected = <Insight>[];
  final categoryCount = <InsightCategory, int>{};

  for (final (insight, _) in available) {
    final count = categoryCount[insight.category] ?? 0;
    if (count < 2 && selected.length < 4) {
      selected.add(insight);
      categoryCount[insight.category] = count + 1;
    }
  }

  // Cold start: if fewer than 4, fill with always-available profile insights
  if (selected.length < 4) {
    final fillers = [
      _PackYearsMilestoneInsight(),
      _ProjectedAnnualSpendInsight(),
      _WeeklyNicotineInsight(),
      _PacksConsumedInsight(),
    ];
    for (final gen in fillers) {
      if (selected.length >= 4) break;
      if (selected.any((s) => s.id == gen.id)) continue;
      final insight = gen.generate(stats);
      if (insight != null) selected.add(insight);
    }
  }

  return selected;
}
