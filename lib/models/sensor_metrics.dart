class SensorMetrics {
  final double currentSpeedKmh;
  final String activityLabel;
  final double gyroX;
  final double gyroY;
  final double gyroZ;

  const SensorMetrics({
    this.currentSpeedKmh = 0.0,
    this.activityLabel = 'En reposo',
    this.gyroX = 0.0,
    this.gyroY = 0.0,
    this.gyroZ = 0.0,
  });

  SensorMetrics copyWith({
    double? currentSpeedKmh,
    String? activityLabel,
    double? gyroX,
    double? gyroY,
    double? gyroZ,
  }) {
    return SensorMetrics(
      currentSpeedKmh: currentSpeedKmh ?? this.currentSpeedKmh,
      activityLabel: activityLabel ?? this.activityLabel,
      gyroX: gyroX ?? this.gyroX,
      gyroY: gyroY ?? this.gyroY,
      gyroZ: gyroZ ?? this.gyroZ,
    );
  }
}