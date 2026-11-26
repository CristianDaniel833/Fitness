import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:sensors_plus/sensors_plus.dart';

class MotionSensorService {
  Stream<StepCount> stepCountStream() {
    return Pedometer.stepCountStream;
  }

  Stream<AccelerometerEvent> accelerometerStream() {
    return accelerometerEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    );
  }

  Stream<GyroscopeEvent> gyroscopeStream() {
    return gyroscopeEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    );
  }
}