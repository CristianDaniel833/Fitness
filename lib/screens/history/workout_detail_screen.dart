import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/workout_session.dart';
import '../../services/database_service.dart';

class WorkoutDetailScreen extends StatefulWidget {
  const WorkoutDetailScreen({super.key, required this.workoutId});

  final int workoutId;

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  late Future<WorkoutSession?> _sessionFuture;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _sessionFuture = DatabaseService.instance.getWorkoutWithRoute(widget.workoutId);
  }

  String _formatDuration(int totalSeconds) {
    final d = Duration(seconds: totalSeconds);
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Future<void> _confirmAndDeleteWorkout() async {
    if (_isDeleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar rutina'),
        content: const Text(
          '¿Seguro que deseas borrar este registro de rutina y su ruta guardada? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await DatabaseService.instance.deleteWorkout(widget.workoutId);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar la rutina.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy · HH:mm');
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de rutina'),
        actions: [
          IconButton(
            tooltip: 'Eliminar rutina',
            onPressed: _isDeleting ? null : _confirmAndDeleteWorkout,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: FutureBuilder<WorkoutSession?>(
        future: _sessionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final session = snapshot.data;
          if (session == null) {
            return const Center(child: Text('No se encontró la rutina.'));
          }

          final points = session.routePoints;
          final startCoord = points.isNotEmpty
              ? '${points.first.latitude.toStringAsFixed(5)}, '
              '${points.first.longitude.toStringAsFixed(5)}'
              : 'Sin registro';
          final endCoord = points.isNotEmpty
              ? '${points.last.latitude.toStringAsFixed(5)}, '
              '${points.last.longitude.toStringAsFixed(5)}'
              : 'Sin registro';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.predominantActivity,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(dateFmt.format(session.startTime)),
                        const Divider(height: 24),
                        _DetailRow(
                          label: 'Calorías quemadas',
                          value:
                          '${session.caloriesKcal.toStringAsFixed(1)} kcal',
                        ),
                        _DetailRow(
                          label: 'Duración',
                          value: _formatDuration(session.durationSeconds),
                        ),
                        _DetailRow(
                          label: 'Pasos',
                          value: '${session.steps}',
                        ),
                        _DetailRow(
                          label: 'Distancia',
                          value:
                          '${session.distanceKm.toStringAsFixed(2)} km',
                        ),
                        _DetailRow(
                          label: 'Velocidad promedio',
                          value:
                          '${session.avgSpeedKmh.toStringAsFixed(1)} km/h',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Registro de coordenadas GPS',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text('Puntos guardados: ${points.length}'),
                        const SizedBox(height: 4),
                        Text('Inicio: $startCoord'),
                        const SizedBox(height: 4),
                        Text('Fin: $endCoord'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                  ),
                  onPressed: _isDeleting ? null : _confirmAndDeleteWorkout,
                  icon: _isDeleting
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.delete_outline),
                  label: Text(
                    _isDeleting ? 'Eliminando...' : 'Eliminar rutina',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}