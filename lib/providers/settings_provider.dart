import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/permission_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({PermissionService? permissionService})
      : _permissionService = permissionService ?? PermissionService();

  final PermissionService _permissionService;

  static const String _darkModeKey = 'fitness_dark_mode_v1';

  bool _isDarkMode = false;
  bool _locationGranted = false;
  bool _activityGranted = false;

  bool get isDarkMode => _isDarkMode;
  bool get locationGranted => _locationGranted;
  bool get activityGranted => _activityGranted;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    await refreshPermissionsStatus();
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
    notifyListeners();
  }

  Future<void> refreshPermissionsStatus() async {
    _locationGranted = await _permissionService.isLocationGranted();
    _activityGranted = await _permissionService.isActivityRecognitionGranted();
    notifyListeners();
  }

  Future<bool> requestLocation() async {
    final granted = await _permissionService.requestLocationPermission();
    await refreshPermissionsStatus();
    return granted;
  }

  Future<bool> requestActivityRecognition() async {
    final granted =
    await _permissionService.requestActivityRecognitionPermission();
    await refreshPermissionsStatus();
    return granted;
  }

  Future<void> openAppSettings() async {
    await _permissionService.openSystemAppSettings();
  }
}