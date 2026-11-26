import 'package:geolocator/geolocator.dart';
import '../core/constants/app_constants.dart';

class LocationService {
  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  Future<Position?> getCurrentPosition() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (pos.accuracy > AppConstants.maxGpsAccuracyMeters) return null;
      return pos;
    } catch (_) {
      return null;
    }
  }

  Stream<Position> positionStream({
    int distanceFilterMeters = 5,
  }) {
    final locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
      intervalDuration: const Duration(seconds: 2),
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationTitle: 'Fitness — Rutina activa',
        notificationText: 'Registrando tu recorrido y actividad en curso',
        enableWakeLock: true,
      ),
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings)
        .where((pos) => pos.accuracy <= AppConstants.maxGpsAccuracyMeters);
  }

  double distanceBetweenMeters({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}