import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../core/utils/fitness_calculator.dart';
import '../models/route_point.dart';
import '../models/sensor_metrics.dart';
import '../models/user_profile.dart';
import '../models/workout_session.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../services/motion_sensor_service.dart';

enum WorkoutStatus { idle, running, paused }

class WorkoutProvider extends ChangeNotifier {
  WorkoutProvider({
    MotionSensorService? motionService,
    LocationService? locationService,
    DatabaseService? databaseService,
  })  : _motionService = motionService ?? MotionSensorService(),
        _locationService = locationService ?? LocationService(),
        _databaseService = databaseService ?? DatabaseService.instance;

  final MotionSensorService _motionService;
  final LocationService _locationService;
  final DatabaseService _databaseService;

  WorkoutStatus _status = WorkoutStatus.idle;
  DateTime? _startTime;
  Duration _elapsed = Duration.zero;
  int _steps = 0;
  int? _initialStepSensorValue;
  int _lastStepSensorValue = 0;
  double _distanceMeters = 0.0;
  double _caloriesKcal = 0.0;
  SensorMetrics _metrics = const SensorMetrics();
  final List<RoutePoint> _routePoints = [];
  final Map<String, int> _activitySecondsCount = {};

  UserProfile _currentProfile = const UserProfile();
  Timer? _ticker;
  StreamSubscription<StepCount>? _stepSub;
  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  StreamSubscription<Position>? _posSub;

  WorkoutStatus get status => _status;
  Duration get elapsed => _elapsed;
  int get steps => _steps;
  double get distanceMeters => _distanceMeters;
  double get distanceKm => _distanceMeters / 1000.0;
  double get caloriesKcal => _caloriesKcal;
  SensorMetrics get metrics => _metrics;
  List<RoutePoint> get routePoints => List.unmodifiable(_routePoints);
  bool get isActiveOrPaused => _status != WorkoutStatus.idle;

  void updateProfile(UserProfile profile) {
    _currentProfile = profile;
    // Recalcular distancia con zancada automática si ya hay pasos registrados
    if (_steps > 0 && _routePoints.length < 2) {
      _distanceMeters = _steps * _currentProfile.calculatedStrideMeters;
    }
    notifyListeners();
  }

  Future<void> startWorkout({UserProfile? profile}) async {
    if (profile != null) {
      _currentProfile = profile;
    }

    if (_status == WorkoutStatus.idle) {
      _startTime = DateTime.now();
      _elapsed = Duration.zero;
      _steps = 0;
      _initialStepSensorValue = null;
      _distanceMeters = 0.0;
      _caloriesKcal = 0.0;
      _routePoints.clear();
      _activitySecondsCount.clear();
      _metrics = const SensorMetrics();
    }

    _status = WorkoutStatus.running;
    _startStreams();
    notifyListeners();
  }

  void pauseWorkout() {
    if (_status != WorkoutStatus.running) return;
    _status = WorkoutStatus.paused;
    _stopStreams();
    notifyListeners();
  }

  /// Pausa automáticamente cuando el usuario navega a otra pantalla.
  void pauseForNavigation() {
    if (_status == WorkoutStatus.running) {
      pauseWorkout();
    }
  }

  /// Maneja el ciclo de vida de Android:
  /// - Continúa si solo se bloquea/oscurece la pantalla (`inactive` / `hidden`).
  /// - Pausa si la app pasa a segundo plano o se cierra (`paused` / `detached`).
  void handleAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (_status == WorkoutStatus.running) {
        pauseWorkout();
      }
    }
  }

  Future<WorkoutSession?> finishAndSaveWorkout() async {
    if (_status == WorkoutStatus.idle) return null;

    _status = WorkoutStatus.idle;
    _stopStreams();

    final endTime = DateTime.now();
    final actualStart =
        _startTime ?? endTime.subtract(_elapsed);
    final avgSpeedKmh = _elapsed.inSeconds > 0
        ? (distanceKm / (_elapsed.inSeconds / 3600.0))
        : 0.0;

    String predominant = 'Caminando';
    int maxSec = -1;
    _activitySecondsCount.forEach((label, sec) {
      if (sec > maxSec) {
        maxSec = sec;
        predominant = label;
      }
    });

    final session = WorkoutSession(
      startTime: actualStart,
      endTime: endTime,
      durationSeconds: _elapsed.inSeconds,
      steps: _steps,
      distanceMeters: _distanceMeters,
      caloriesKcal: _caloriesKcal,
      avgSpeedKmh: avgSpeedKmh,
      predominantActivity: predominant,
      routePoints: List<RoutePoint>.from(_routePoints),
    );

    final savedId = await _databaseService.insertWorkout(session);
    _resetSessionState();
    notifyListeners();

    return session.copyWith(id: savedId);
  }

  void discardCurrentWorkout() {
    _stopStreams();
    _resetSessionState();
    notifyListeners();
  }

  void _resetSessionState() {
    _status = WorkoutStatus.idle;
    _startTime = null;
    _elapsed = Duration.zero;
    _steps = 0;
    _initialStepSensorValue = null;
    _distanceMeters = 0.0;
    _caloriesKcal = 0.0;
    _routePoints.clear();
    _activitySecondsCount.clear();
    _metrics = const SensorMetrics();
  }

  void _startStreams() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_status != WorkoutStatus.running) return;
      _elapsed += const Duration(seconds: 1);

      final speed = _metrics.currentSpeedKmh;
      final activity = FitnessCalculator.classifyActivity(speed);
      _activitySecondsCount[activity] =
          (_activitySecondsCount[activity] ?? 0) + 1;

      _caloriesKcal = FitnessCalculator.calculateCaloriesKcal(
        weightKg: _currentProfile.weightKg.toDouble(),
        duration: _elapsed,
        speedKmh: speed > 0.5 ? speed : (_steps > 0 ? 4.5 : 0.0),
      );

      notifyListeners();
    });

    _stepSub?.cancel();
    _stepSub = _motionService.stepCountStream().listen(
          (event) {
        if (_status != WorkoutStatus.running) return;
        _initialStepSensorValue ??= event.steps;
        final deltaFromStart =
        max(0, event.steps - _initialStepSensorValue!);
        if (deltaFromStart > _steps) {
          _steps = deltaFromStart;
          _lastStepSensorValue = event.steps;
          // Si aún no hay suficientes puntos GPS, estimar distancia con zancada
          if (_routePoints.length < 2) {
            _distanceMeters =
                _steps * _currentProfile.calculatedStrideMeters;
          }
          notifyListeners();
        } else {
          _lastStepSensorValue = event.steps;
        }
      },
      onError: (_) {},
    );

    _accelSub?.cancel();
    _accelSub = _motionService.accelerometerStream().listen(
          (event) {
        if (_status != WorkoutStatus.running) return;
        final mag = sqrt(
          event.x * event.x + event.y * event.y + event.z * event.z,
        );
        // Estimación de apoyo si no hay velocidad GPS activa
        double speedEstimate = _metrics.currentSpeedKmh;
        if (_routePoints.length < 2) {
          final dynamicAccel = (mag - 9.81).abs();
          if (dynamicAccel < 0.8) {
            speedEstimate = 0.0;
          } else if (dynamicAccel < 3.5) {
            speedEstimate = 4.5;
          } else if (dynamicAccel < 7.0) {
            speedEstimate = 7.8;
          } else {
            speedEstimate = 11.2;
          }
        }

        _metrics = _metrics.copyWith(
          currentSpeedKmh: speedEstimate,
          activityLabel: FitnessCalculator.classifyActivity(speedEstimate),
        );
      },
      onError: (_) {},
    );

    _gyroSub?.cancel();
    _gyroSub = _motionService.gyroscopeStream().listen(
          (event) {
        if (_status != WorkoutStatus.running) return;
        _metrics = _metrics.copyWith(
          gyroX: event.x,
          gyroY: event.y,
          gyroZ: event.z,
        );
      },
      onError: (_) {},
    );

    _posSub?.cancel();
    _posSub = _locationService.positionStream().listen(
          (pos) {
        if (_status != WorkoutStatus.running) return;
        final newPoint = RoutePoint(
          latitude: pos.latitude,
          longitude: pos.longitude,
          timestamp: DateTime.now(),
        );

        if (_routePoints.isNotEmpty) {
          final prev = _routePoints.last;
          final segMeters = _locationService.distanceBetweenMeters(
            startLat: prev.latitude,
            startLng: prev.longitude,
            endLat: newPoint.latitude,
            endLng: newPoint.longitude,
          );
          if (segMeters >= 1.0) {
            _distanceMeters += segMeters;
          }
        }

        _routePoints.add(newPoint);

        final gpsSpeedKmh = pos.speed > 0 ? pos.speed * 3.6 : 0.0;
        _metrics = _metrics.copyWith(
          currentSpeedKmh: gpsSpeedKmh,
          activityLabel: FitnessCalculator.classifyActivity(gpsSpeedKmh),
        );
        notifyListeners();
      },
      onError: (_) {},
    );
  }

  void _stopStreams() {
    _ticker?.cancel();
    _ticker = null;
    _stepSub?.cancel();
    _stepSub = null;
    _accelSub?.cancel();
    _accelSub = null;
    _gyroSub?.cancel();
    _gyroSub = null;
    _posSub?.cancel();
    _posSub = null;
  }

  @override
  void dispose() {
    _stopStreams();
    super.dispose();
  }
}