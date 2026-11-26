import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/workout_session.dart';
import '../../providers/workout_provider.dart';
import '../../services/database_service.dart';
import 'workout_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<WorkoutSession>> _workoutsFuture;
  bool _wasPausedOnEnter = false;

  @override
  void initState() {
    super.initState();
    _wasPausedOnEnter = context.read<WorkoutProvider>().isActiveOrPaused;
    _workoutsFuture = DatabaseService.instance.getAllWorkouts();
  }

  String _formatDuration(int totalSeconds) {
    final d = Duration(seconds: totalSeconds);
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy · HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de rutinas')),
      body: Column(
        children: [
          if (_wasPausedOnEnter)
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: const Text(
                'Tu rutina activa se pausó automáticamente al abrir el historial.',
              ),
            ),
          Expanded(
            child: FutureBuilder<List<WorkoutSession>>(
              future: _workoutsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Center(
                    child: Text('Aún no tienes rutinas guardadas.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.predominantActivity,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${item.caloriesKcal.toStringAsFixed(1)} kcal',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dateFmt.format(item.startTime)),
                              const SizedBox(height: 4),
                              Text(
                                'Duración: ${_formatDuration(item.durationSeconds)} · '
                                    'Pasos: ${item.steps} · '
                                    'Distancia: ${item.distanceKm.toStringAsFixed(2)} km',
                              ),
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          if (item.id == null) return;
                          final messenger = ScaffoldMessenger.of(context);
                          final deleted = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => WorkoutDetailScreen(workoutId: item.id!),
                            ),
                          );
                          if (deleted == true && mounted) {
                            setState(() {
                              _workoutsFuture = DatabaseService.instance.getAllWorkouts();
                            });
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Rutina eliminada del historial.'),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}