import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/cigarette_log.dart';
import 'user_provider.dart';

final cigaretteLogsProvider =
    StateNotifierProvider<CigaretteLogsNotifier, List<CigaretteLog>>((ref) {
  return CigaretteLogsNotifier(ref.watch(sharedPreferencesProvider));
});

final todayLogsProvider = Provider<List<CigaretteLog>>((ref) {
  final logs = ref.watch(cigaretteLogsProvider);
  final now = DateTime.now();
  return logs
      .where((l) =>
          l.smokedAt.year == now.year &&
          l.smokedAt.month == now.month &&
          l.smokedAt.day == now.day)
      .toList();
});

final yesterdayLogsProvider = Provider<List<CigaretteLog>>((ref) {
  final logs = ref.watch(cigaretteLogsProvider);
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  return logs
      .where((l) =>
          l.smokedAt.year == yesterday.year &&
          l.smokedAt.month == yesterday.month &&
          l.smokedAt.day == yesterday.day)
      .toList();
});

final weekLogsProvider = Provider<Map<int, int>>((ref) {
  final logs = ref.watch(cigaretteLogsProvider);
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final result = <int, int>{};
  for (var i = 0; i < 7; i++) {
    final day = weekStart.add(Duration(days: i));
    result[i] = logs
        .where((l) =>
            l.smokedAt.year == day.year &&
            l.smokedAt.month == day.month &&
            l.smokedAt.day == day.day)
        .length;
  }
  return result;
});

final monthLogsProvider = Provider<List<CigaretteLog>>((ref) {
  final logs = ref.watch(cigaretteLogsProvider);
  final now = DateTime.now();
  return logs
      .where((l) => l.smokedAt.year == now.year && l.smokedAt.month == now.month)
      .toList();
});

final contextDistributionProvider = Provider<Map<String, int>>((ref) {
  final logs = ref.watch(monthLogsProvider);
  final result = <String, int>{};
  for (final log in logs) {
    final ctx = log.context ?? 'none';
    result[ctx] = (result[ctx] ?? 0) + 1;
  }
  return result;
});

/// Daily counts for the last 30 days (most recent first).
final dailyCountsProvider = Provider<List<int>>((ref) {
  final logs = ref.watch(cigaretteLogsProvider);
  final now = DateTime.now();
  final counts = <int>[];
  for (var i = 0; i < 30; i++) {
    final day = now.subtract(Duration(days: i));
    final count = logs
        .where((l) =>
            l.smokedAt.year == day.year &&
            l.smokedAt.month == day.month &&
            l.smokedAt.day == day.day)
        .length;
    counts.add(count);
  }
  return counts;
});

/// Hourly distribution of all logs this month.
final hourlyDistributionProvider = Provider<Map<int, int>>((ref) {
  final logs = ref.watch(monthLogsProvider);
  final result = <int, int>{};
  for (final log in logs) {
    final hour = log.smokedAt.hour;
    result[hour] = (result[hour] ?? 0) + 1;
  }
  return result;
});

/// Number of distinct days with at least one log.
final dataDaysProvider = Provider<int>((ref) {
  final logs = ref.watch(cigaretteLogsProvider);
  final days = <String>{};
  for (final log in logs) {
    days.add('${log.smokedAt.year}-${log.smokedAt.month}-${log.smokedAt.day}');
  }
  return days.length;
});

/// Peak day (highest count) from all logged data.
final peakDayProvider = Provider<(int, DateTime?)>((ref) {
  final logs = ref.watch(cigaretteLogsProvider);
  final dayCounts = <String, int>{};
  final dayDates = <String, DateTime>{};
  for (final log in logs) {
    final key = '${log.smokedAt.year}-${log.smokedAt.month}-${log.smokedAt.day}';
    dayCounts[key] = (dayCounts[key] ?? 0) + 1;
    dayDates[key] = DateTime(log.smokedAt.year, log.smokedAt.month, log.smokedAt.day);
  }
  if (dayCounts.isEmpty) return (0, null);
  final maxEntry = dayCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
  return (maxEntry.value, dayDates[maxEntry.key]);
});

class CigaretteLogsNotifier extends StateNotifier<List<CigaretteLog>> {
  final SharedPreferences _prefs;
  static const _key = 'cigarette_logs';

  CigaretteLogsNotifier(this._prefs) : super([]) {
    _load();
  }

  void _load() {
    final json = _prefs.getString(_key);
    if (json != null) {
      final list = jsonDecode(json) as List;
      state = list
          .map((e) => CigaretteLog.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> addLog({String? context}) async {
    final log = CigaretteLog(
      id: state.length,
      smokedAt: DateTime.now(),
      context: context,
    );
    state = [...state, log];
    await _save();
  }

  Future<void> _save() async {
    await _prefs.setString(
        _key, jsonEncode(state.map((e) => e.toJson()).toList()));
  }
}
