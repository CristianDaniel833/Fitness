import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'profile_provider.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    AuthService? authService,
    DatabaseService? databaseService,
  })  : _authService = authService ?? AuthService(),
        _databaseService = databaseService ?? DatabaseService.instance;

  final AuthService _authService;
  final DatabaseService _databaseService;

  bool _isAuthenticated = false;
  bool _hasFingerprintSensor = false;
  bool _hasPinConfigured = false;
  bool _isBusy = false;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get hasFingerprintSensor => _hasFingerprintSensor;
  bool get hasPinConfigured => _hasPinConfigured;
  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();

    _hasFingerprintSensor = await _authService.isFingerprintAvailable();
    _hasPinConfigured = await _authService.hasPinConfigured();

    _isBusy = false;
    notifyListeners();
  }

  Future<bool> authenticateWithFingerprint(
      ProfileProvider profileProvider) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();

    final ok = await _authService.authenticateWithFingerprint();
    if (ok) {
      profileProvider.resetSessionSkipFlag();
      _isAuthenticated = true;
    } else {
      _errorMessage = 'No se pudo validar la huella.';
    }

    _isBusy = false;
    notifyListeners();
    return ok;
  }

  Future<bool> createPin(String pin, ProfileProvider profileProvider) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();

    await _authService.savePin(pin);
    _hasPinConfigured = true;
    profileProvider.resetSessionSkipFlag();
    _isAuthenticated = true;

    _isBusy = false;
    notifyListeners();
    return true;
  }

  Future<bool> verifyPin(String pin, ProfileProvider profileProvider) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();

    final valid = await _authService.verifyPin(pin);
    if (valid) {
      profileProvider.resetSessionSkipFlag();
      _isAuthenticated = true;
    } else {
      _errorMessage = 'El PIN ingresado no es correcto.';
    }

    _isBusy = false;
    notifyListeners();
    return valid;
  }

  /// Elimina PIN, historial de rutinas/rutas en SQLite y datos de perfil,
  /// dejando la aplicación como nueva para crear otro PIN.
  Future<void> resetAllDataAfterForgotPin(
      ProfileProvider profileProvider) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();

    await _authService.clearPin();
    await _databaseService.clearAllWorkoutData();
    await profileProvider.clearProfileData();

    _hasPinConfigured = false;
    _isAuthenticated = false;
    _isBusy = false;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}