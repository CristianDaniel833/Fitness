import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../models/route_point.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/workout_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/open_street_map_widget.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final LocationService _locationService = LocationService();
  LatLng? _currentPositionLatLng;
  bool _fetchingLocation = false;

  @override
  void initState() {
    super.initState();
    _refreshCurrentLocation();
  }

  Future<void> _refreshCurrentLocation() async {
    setState(() => _fetchingLocation = true);
    final pos = await _locationService.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _fetchingLocation = false;
      if (pos != null) {
        _currentPositionLatLng = LatLng(pos.latitude, pos.longitude);
      }
    });
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final mins = (d.inMinutes % 60).toString().padLeft(2, '0');
    final secs = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$mins:$secs';
  }

  Future<void> _openScreen(Widget destination) async {
    context.read<WorkoutProvider>().pauseForNavigation();
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  Future<void> _finishWorkout() async {
    final workout = context.read<WorkoutProvider>();
    final saved = await workout.finishAndSaveWorkout();
    if (!mounted) return;
    if (saved != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Rutina guardada · ${saved.caloriesKcal.toStringAsFixed(1)} kcal',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutProvider>();
    final profile = context.watch<ProfileProvider>().profile;
    final theme = Theme.of(context);

    // Si aún no inicia la rutina pero ya obtuvimos la posición inicial,
    // pasamos ese punto para que el marcador y el mapa arranquen ahí.
    final List<RoutePoint> displayPoints = workout.routePoints.isNotEmpty
        ? workout.routePoints
        : (_currentPositionLatLng != null
        ? [
      RoutePoint(
        latitude: _currentPositionLatLng!.latitude,
        longitude: _currentPositionLatLng!.longitude,
        timestamp: DateTime.now(),
      ),
    ]
        : const []);

    final coordsText = displayPoints.isNotEmpty
        ? '${displayPoints.last.latitude.toStringAsFixed(5)}, '
        '${displayPoints.last.longitude.toStringAsFixed(5)}'
        : 'Sin ubicación aún';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness'),
        actions: [
          IconButton(
            tooltip: 'Historial',
            icon: const Icon(Icons.history),
            onPressed: () => _openScreen(const HistoryScreen()),
          ),
          IconButton(
            tooltip: 'Mi Perfil',
            icon: const Icon(Icons.person_outline),
            onPressed: () => _openScreen(const ProfileScreen()),
          ),
          IconButton(
            tooltip: 'Ajustes',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _openScreen(const SettingsScreen()),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () {
              workout.pauseForNavigation();
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OpenStreetMapWidget(
                routePoints: displayPoints,
                fallbackCenter:
                _currentPositionLatLng ?? const LatLng(19.4326, -99.1332),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GPS: $coordsText',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              'Puntos de ruta grabados: ${workout.routePoints.length}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Actualizar ubicación',
                        onPressed:
                        _fetchingLocation ? null : _refreshCurrentLocation,
                        icon: _fetchingLocation
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(label: Text(workout.metrics.activityLabel)),
                  Text(
                    _formatDuration(workout.elapsed),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.85,
                children: [
                  _MetricTile(
                    label: 'Pasos',
                    value: '${workout.steps}',
                  ),
                  _MetricTile(
                    label: 'Distancia',
                    value: '${workout.distanceKm.toStringAsFixed(2)} km',
                  ),
                  _MetricTile(
                    label: 'Velocidad',
                    value:
                    '${workout.metrics.currentSpeedKmh.toStringAsFixed(1)} km/h',
                  ),
                  _MetricTile(
                    label: 'Calorías',
                    value: '${workout.caloriesKcal.toStringAsFixed(1)} kcal',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Giroscopio: X ${workout.metrics.gyroX.toStringAsFixed(2)} · '
                        'Y ${workout.metrics.gyroY.toStringAsFixed(2)} · '
                        'Z ${workout.metrics.gyroZ.toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (workout.status == WorkoutStatus.idle)
                ElevatedButton.icon(
                  onPressed: () => workout.startWorkout(profile: profile),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar rutina'),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: workout.status == WorkoutStatus.running
                            ? workout.pauseWorkout
                            : () => workout.startWorkout(profile: profile),
                        icon: Icon(
                          workout.status == WorkoutStatus.running
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        label: Text(
                          workout.status == WorkoutStatus.running
                              ? 'Pausar'
                              : 'Reanudar',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _finishWorkout,
                        icon: const Icon(Icons.stop),
                        label: const Text('Finalizar'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}