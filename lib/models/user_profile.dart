import '../core/constants/app_constants.dart';
import '../core/utils/fitness_calculator.dart';

class UserProfile {
  final int ageYears;
  final int weightKg;
  final int heightCm;
  final bool isProfileCompleted;

  const UserProfile({
    this.ageYears = AppConstants.defaultAgeYears,
    this.weightKg = AppConstants.defaultWeightKg,
    this.heightCm = AppConstants.defaultHeightCm,
    this.isProfileCompleted = false,
  });

  /// Longitud de zancada calculada automáticamente por el sistema (en metros).
  double get calculatedStrideMeters {
    return FitnessCalculator.calculateStrideLengthMeters(
      heightCm: heightCm,
      ageYears: ageYears,
      weightKg: weightKg,
    );
  }

  /// Índice de Masa Corporal (IMC) calculado con peso y estatura actuales.
  double get bmi {
    return FitnessCalculator.calculateBmi(
      weightKg: weightKg,
      heightCm: heightCm,
    );
  }

  UserProfile copyWith({
    int? ageYears,
    int? weightKg,
    int? heightCm,
    bool? isProfileCompleted,
  }) {
    return UserProfile(
      ageYears: ageYears ?? this.ageYears,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
    );
  }
}