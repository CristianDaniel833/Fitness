import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> isLocationGranted() async {
    final status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  Future<bool> isActivityRecognitionGranted() async {
    final status = await Permission.activityRecognition.status;
    return status.isGranted;
  }

  Future<bool> requestActivityRecognitionPermission() async {
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  Future<bool> openSystemAppSettings() async {
    return openAppSettings();
  }
}