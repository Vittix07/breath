import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_profile.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  return UserProfileNotifier(ref.watch(sharedPreferencesProvider));
});

final onboardingCompleteProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider) != null;
});

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  final SharedPreferences _prefs;
  static const _key = 'user_profile';

  UserProfileNotifier(this._prefs) : super(null) {
    _load();
  }

  void _load() {
    final json = _prefs.getString(_key);
    if (json != null) {
      state = UserProfile.fromJson(jsonDecode(json) as Map<String, dynamic>);
    }
  }

  Future<void> save(UserProfile profile) async {
    state = profile;
    await _prefs.setString(_key, jsonEncode(profile.toJson()));
  }

  Future<void> update(UserProfile profile) async {
    await save(profile);
  }
}
