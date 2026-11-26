class RoutePoint {
  final int? id;
  final int? workoutId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const RoutePoint({
    this.id,
    this.workoutId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  Map<String, dynamic> toMap({int? parentWorkoutId}) {
    return {
      if (id != null) 'id': id,
      'workout_id': parentWorkoutId ?? workoutId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory RoutePoint.fromMap(Map<String, dynamic> map) {
    return RoutePoint(
      id: map['id'] as int?,
      workoutId: map['workout_id'] as int?,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }
}