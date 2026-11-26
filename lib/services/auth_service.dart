import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  AuthService({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;

  static const String _pinHashKey = 'fitness_pin_hash_v1';

  String _hashPin(String pin) {
    return sha256.convert(utf8.encode(pin.trim())).toString();
  }

  /// Verifica si el dispositivo tiene hardware biométrico y al menos una huella enrollada.
  Future<bool> isFingerprintAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      if (!canCheck || !isSupported) return false;

      final biometrics = await _localAuth.getAvailableBiometrics();
      return biometrics.contains(BiometricType.fingerprint) ||
          biometrics.contains(BiometricType.strong) ||
          biometrics.contains(BiometricType.weak);
    } on PlatformException {
      return false;
    }
  }

  /// Lanza el diálogo biométrico nativo de Android.
  Future<bool> authenticateWithFingerprint() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Autentícate con tu huella para acceder a Fitness',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  /// Indica si ya existe un PIN configurado en el dispositivo.
  Future<bool> hasPinConfigured() async {
    final storedHash = await _secureStorage.read(key: _pinHashKey);
    return storedHash != null && storedHash.isNotEmpty;
  }

  /// Guarda un nuevo PIN cifrado (primera vez o tras restablecer).
  Future<void> savePin(String pin) async {
    await _secureStorage.write(key: _pinHashKey, value: _hashPin(pin));
  }

  /// Valida un PIN ingresado contra el hash guardado.
  Future<bool> verifyPin(String pin) async {
    final storedHash = await _secureStorage.read(key: _pinHashKey);
    if (storedHash == null || storedHash.isEmpty) return false;
    return _hashPin(pin) == storedHash;
  }

  /// Elimina el PIN guardado (usado en el flujo "Olvidé mi PIN").
  Future<void> clearPin() async {
    await _secureStorage.delete(key: _pinHashKey);
  }
}