import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/route_point.dart';
import '../models/workout_session.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  static const String _dbName = 'fitness_local.db';
  static const int _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final fullPath = join(dbPath, _dbName);

    return openDatabase(
      fullPath,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE workouts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            start_time INTEGER NOT NULL,
            end_time INTEGER NOT NULL,
            duration_seconds INTEGER NOT NULL,
            steps INTEGER NOT NULL,
            distance_meters REAL NOT NULL,
            calories_kcal REAL NOT NULL,
            avg_speed_kmh REAL NOT NULL,
            predominant_activity TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE route_points (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            workout_id INTEGER NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            timestamp INTEGER NOT NULL,
            FOREIGN KEY (workout_id) REFERENCES workouts (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  Future<int> insertWorkout(WorkoutSession session) async {
    final db = await database;
    return db.transaction((txn) async {
      final workoutId = await txn.insert('workouts', session.toMap());
      for (final point in session.routePoints) {
        await txn.insert(
          'route_points',
          point.toMap(parentWorkoutId: workoutId),
        );
      }
      return workoutId;
    });
  }

  Future<int> deleteWorkout(int workoutId) async {
    final db = await database;
    return await db.transaction((txn) async {
      await txn.delete(
        'route_points',
        where: 'workout_id = ?',
        whereArgs: [workoutId],
      );
      return await txn.delete(
        'workouts',
        where: 'id = ?',
        whereArgs: [workoutId],
      );
    });
  }

  Future<List<WorkoutSession>> getAllWorkouts() async {
    final db = await database;
    final rows = await db.query(
      'workouts',
      orderBy: 'start_time DESC',
    );
    return rows.map((row) => WorkoutSession.fromMap(row)).toList();
  }

  Future<WorkoutSession?> getWorkoutWithRoute(int workoutId) async {
    final db = await database;
    final workoutRows = await db.query(
      'workouts',
      where: 'id = ?',
      whereArgs: [workoutId],
      limit: 1,
    );
    if (workoutRows.isEmpty) return null;

    final pointRows = await db.query(
      'route_points',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
      orderBy: 'timestamp ASC',
    );

    final points = pointRows.map((p) => RoutePoint.fromMap(p)).toList();
    return WorkoutSession.fromMap(workoutRows.first, points: points);
  }

  /// Borra todo el historial y puntos de ruta guardados (reset por "Olvidé mi PIN").
  Future<void> clearAllWorkoutData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('route_points');
      await txn.delete('workouts');
    });
  }
}