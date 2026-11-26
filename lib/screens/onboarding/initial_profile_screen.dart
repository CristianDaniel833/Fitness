import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/profile_provider.dart';

class InitialProfileScreen extends StatefulWidget {
  const InitialProfileScreen({super.key});

  @override
  State<InitialProfileScreen> createState() => _InitialProfileScreenState();
}

class _InitialProfileScreenState extends State<InitialProfileScreen> {
  late int _selectedAge;
  late int _selectedWeight;
  late int _selectedHeight;

  @override
  void initState() {
    super.initState();
    final current = context.read<ProfileProvider>().profile;
    _selectedAge = current.ageYears;
    _selectedWeight = current.weightKg;
    _selectedHeight = current.heightCm;
  }

  List<int> _rangeList(int min, int max) =>
      List<int>.generate(max - min + 1, (i) => min + i);

  Future<void> _saveAndContinue() async {
    await context.read<ProfileProvider>().saveProfile(
      ageYears: _selectedAge,
      weightKg: _selectedWeight,
      heightCm: _selectedHeight,
    );
  }

  void _skipForNow() {
    context.read<ProfileProvider>().skipInitialProfileForNow();
  }

  @override
  Widget build(BuildContext context) {
    final ages = _rangeList(AppConstants.minAgeYears, AppConstants.maxAgeYears);
    final weights =
    _rangeList(AppConstants.minWeightKg, AppConstants.maxWeightKg);
    final heights =
    _rangeList(AppConstants.minHeightCm, AppConstants.maxHeightCm);

    return Scaffold(
      appBar: AppBar(title: const Text('Fitness · Perfil inicial')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Configura tu perfil corporal',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Estos datos ayudan a calcular automáticamente tu longitud de zancada y calorías.',
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      DropdownButtonFormField<int>(
                        initialValue: _selectedAge,
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
                          if (val != null) setState(() => _selectedAge = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedWeight,
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
                          if (val != null) setState(() => _selectedWeight = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedHeight,
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
                          if (val != null) setState(() => _selectedHeight = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveAndContinue,
                child: const Text('Guardar y continuar'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: _skipForNow,
                child: const Text('Omitir'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}