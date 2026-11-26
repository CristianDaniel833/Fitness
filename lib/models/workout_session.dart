import 'route_point.dart';

class WorkoutSession {
  final int? id;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;
  final int steps;
  final double distanceMeters;
  final double caloriesKcal;
  final double avgSpeedKmh;
  final String predominantActivity;
  final List<RoutePoint> routePoints;

  const WorkoutSession({
    this.id,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    required this.steps,
    required this.distanceMeters,
    required this.caloriesKcal,
    required this.avgSpeedKmh,
    required this.predominantActivity,
    this.routePoints = const [],
  });

  double get distanceKm => distanceMeters / 1000.0;

  WorkoutSession copyWith({
    int? id,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    int? steps,
    double? distanceMeters,
    double? caloriesKcal,
    double? avgSpeedKmh,
    String? predominantActivity,
    List<RoutePoint>? routePoints,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      steps: steps ?? this.steps,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      caloriesKcal: caloriesKcal ?? this.caloriesKcal,
      avgSpeedKmh: avgSpeedKmh ?? this.avgSpeedKmh,
      predominantActivity: predominantActivity ?? this.predominantActivity,
      routePoints: routePoints ?? this.routePoints,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime.millisecondsSinceEpoch,
      'duration_seconds': durationSeconds,
      'steps': steps,
      'distance_meters': distanceMeters,
      'calories_kcal': caloriesKcal,
      'avg_speed_kmh': avgSpeedKmh,
      'predominant_activity': predominantActivity,
    };
  }

  factory WorkoutSession.fromMap(
      Map<String, dynamic> map, {
        List<RoutePoint> points = const [],
      }) {
    return WorkoutSession(
      id: map['id'] as int?,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['end_time'] as int),
      durationSeconds: map['duration_seconds'] as int,
      steps: map['steps'] as int,
      distanceMeters: (map['distance_meters'] as num).toDouble(),
      caloriesKcal: (map['calories_kcal'] as num).toDouble(),
      avgSpeedKmh: (map['avg_speed_kmh'] as num).toDouble(),
      predominantActivity: map['predominant_activity'] as String,
      routePoints: points,
    );
  }
}