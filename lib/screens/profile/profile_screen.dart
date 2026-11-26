import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/fitness_calculator.dart';
import '../../providers/profile_provider.dart';
import '../../providers/workout_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late int _age;
  late int _weight;
  late int _height;

  @override
  void initState() {
    super.initState();
    final p = context.read<ProfileProvider>().profile;
    _age = p.ageYears;
    _weight = p.weightKg;
    _height = p.heightCm;
  }

  List<int> _rangeList(int min, int max) =>
      List<int>.generate(max - min + 1, (i) => min + i);

  Future<void> _saveChanges() async {
    final profileProvider = context.read<ProfileProvider>();
    await profileProvider.saveProfile(
      ageYears: _age,
      weightKg: _weight,
      heightCm: _height,
    );
    if (!mounted) return;
    context.read<WorkoutProvider>().updateProfile(profileProvider.profile);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ages = _rangeList(AppConstants.minAgeYears, AppConstants.maxAgeYears);
    final weights =
    _rangeList(AppConstants.minWeightKg, AppConstants.maxWeightKg);
    final heights =
    _rangeList(AppConstants.minHeightCm, AppConstants.maxHeightCm);

    final calculatedStride = FitnessCalculator.calculateStrideLengthMeters(
      heightCm: _height,
      ageYears: _age,
      weightKg: _weight,
    );
    final bmi = FitnessCalculator.calculateBmi(
      weightKg: _weight,
      heightCm: _height,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: _age,
                      decoration: const InputDecoration(
                        labelText: 'Edad (años)',
                        border: OutlineInputBorder(),
                      ),
                      items: ages
                          .map(
                            (v) => DropdownMenuItem<int>(
                          value: v,
                          child: Text('$v años'),
                        ),
                      )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _age = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: _weight,
                      decoration: const InputDecoration(
                        labelText: 'Peso (kg)',
                        border: OutlineInputBorder(),
                      ),
                      items: weights
                          .map(
                            (v) => DropdownMenuItem<int>(
                          value: v,
                          child: Text('$v kg'),
                        ),
                      )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _weight = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: _height,
                      decoration: const InputDecoration(
                        labelText: 'Estatura (cm)',
                        border: OutlineInputBorder(),
                      ),
                      items: heights
                          .map(
                            (v) => DropdownMenuItem<int>(
                          value: v,
                          child: Text('$v cm'),
                        ),
                      )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _height = val);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cálculo automático del sistema',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Longitud de zancada estimada: '
                          '${calculatedStride.toStringAsFixed(2)} m',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text('IMC estimado: ${bmi.toStringAsFixed(1)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}