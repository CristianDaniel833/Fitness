import '../constants/app_constants.dart';

class FitnessCalculator {
  FitnessCalculator._();

  /// Calcula la longitud de zancada estimada en metros según estatura (cm),
  /// edad y peso (kg).
  static double calculateStrideLengthMeters({
    required int heightCm,
    required int ageYears,
    required int weightKg,
  }) {
    final heightMeters = heightCm / 100.0;

    // Factor base proporcional a la estatura (~0.415 al caminar/trotar ligero)
    double factor = 0.415;

    // Ajuste sutil por edad (ligera reducción en adultos mayores)
    if (ageYears >= 60) {
      factor -= 0.025;
    } else if (ageYears >= 45) {
      factor -= 0.010;
    }

    // Ajuste sutil por masa corporal relativa
    final bmi = calculateBmi(weightKg: weightKg, heightCm: heightCm);
    if (bmi >= 30) {
      factor -= 0.015;
    }

    final stride = heightMeters * factor;
    return stride.clamp(0.40, 1.35);
  }

  /// Calcula el Índice de Masa Corporal (IMC).
  static double calculateBmi({
    required int weightKg,
    required int heightCm,
  }) {
    final heightMeters = heightCm / 100.0;
    if (heightMeters <= 0) return 0;
    return weightKg / (heightMeters * heightMeters);
  }

  /// Estima calorías quemadas usando MET según velocidad promedio (km/h),
  /// peso (kg) y duración en segundos.
  static double calculateCaloriesKcal({
    required double weightKg,
    required Duration duration,
    required double speedKmh,
  }) {
    final hours = duration.inSeconds / 3600.0;
    if (hours <= 0 || speedKmh <= 0.4) return 0;

    double met;
    if (speedKmh < AppConstants.walkingMaxSpeedKmh) {
      met = speedKmh < 4.0 ? 2.8 : 3.5; // Caminata
    } else if (speedKmh < AppConstants.joggingMaxSpeedKmh) {
      met = 6.5; // Trote
    } else {
      met = 9.0; // Carrera
    }

    // Calorías (kcal) ≈ MET * peso (kg) * tiempo (horas)
    return met * weightKg * hours;
  }

  /// Clasifica el estado de movimiento según velocidad (km/h).
  static String classifyActivity(double speedKmh) {
    if (speedKmh <= 0.5) return 'En reposo';
    if (speedKmh < AppConstants.walkingMaxSpeedKmh) return 'Caminando';
    if (speedKmh < AppConstants.joggingMaxSpeedKmh) return 'Trotando';
    return 'Corriendo';
  }
}