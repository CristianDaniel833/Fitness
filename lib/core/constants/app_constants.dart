class AppConstants {
  AppConstants._();

  // Rangos realistas para menús desplegables (sin texto de rango en la interfaz)
  static const int minWeightKg = 30;
  static const int maxWeightKg = 250;
  static const int defaultWeightKg = 70;

  static const int minHeightCm = 100;
  static const int maxHeightCm = 230;
  static const int defaultHeightCm = 170;

  static const int minAgeYears = 10;
  static const int maxAgeYears = 100;
  static const int defaultAgeYears = 25;

  // Longitud mínima y máxima del PIN alternativo
  static const int pinMinLength = 4;
  static const int pinMaxLength = 6;

  // Umbrales de velocidad (en km/h) para clasificar actividad
  static const double walkingMaxSpeedKmh = 6.5;
  static const double joggingMaxSpeedKmh = 9.5;

  // Precisión GPS máxima aceptada en metros para evitar saltos bruscos
  static const double maxGpsAccuracyMeters = 25.0;
}