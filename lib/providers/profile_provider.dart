import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/user_profile.dart';

class ProfileProvider extends ChangeNotifier {
  static const String _ageKey = 'fitness_profile_age_v1';
  static const String _weightKey = 'fitness_profile_weight_v1';
  static const String _heightKey = 'fitness_profile_height_v1';
  static const String _completedKey = 'fitness_profile_completed_v1';

  UserProfile _profile = const UserProfile();
  bool _skippedThisSession = false;

  UserProfile get profile => _profile;
  bool get isProfileCompleted => _profile.isProfileCompleted;

  /// Debe mostrarse la pantalla intermedia de perfil inicial tras autenticar
  /// si aún no se ha guardado el perfil y no se ha omitido en esta sesión.
  bool get shouldShowInitialProfilePrompt =>
      !_profile.isProfileCompleted && !_skippedThisSession;

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final age = prefs.getInt(_ageKey) ?? AppConstants.defaultAgeYears;
    final weight = prefs.getInt(_weightKey) ?? AppConstants.defaultWeightKg;
    final height = prefs.getInt(_heightKey) ?? AppConstants.defaultHeightCm;
    final completed = prefs.getBool(_completedKey) ?? false;

    _profile = UserProfile(
      ageYears: age,
      weightKg: weight,
      heightCm: height,
      isProfileCompleted: completed,
    );
    _skippedThisSession = false;
    notifyListeners();
  }

  Future<void> saveProfile({
    required int ageYears,
    required int weightKg,
    required int heightCm,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_ageKey, ageYears);
    await prefs.setInt(_weightKey, weightKg);
    await prefs.setInt(_heightKey, heightCm);
    await prefs.setBool(_completedKey, true);

    _profile = UserProfile(
      ageYears: ageYears,
      weightKg: weightKg,
      heightCm: heightCm,
      isProfileCompleted: true,
    );
    _skippedThisSession = false;
    notifyListeners();
  }

  void skipInitialProfileForNow() {
    _skippedThisSession = true;
    notifyListeners();
  }

  void resetSessionSkipFlag() {
    _skippedThisSession = false;
  }

  Future<void> clearProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ageKey);
    await prefs.remove(_weightKey);
    await prefs.remove(_heightKey);
    await prefs.remove(_completedKey);

    _profile = const UserProfile();
    _skippedThisSession = false;
    notifyListeners();
  }
}