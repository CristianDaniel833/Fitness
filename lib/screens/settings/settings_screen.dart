import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsProvider>().refreshPermissionsStatus();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Modo oscuro'),
              subtitle: const Text('Cambia la apariencia de la aplicación'),
              value: settings.isDarkMode,
              onChanged: (val) => settings.setDarkMode(val),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Seguridad de acceso'),
                  subtitle: Text(
                    'Huella: ${auth.hasFingerprintSensor ? 'Disponible' : 'No disponible'} · '
                        'PIN: ${auth.hasPinConfigured ? 'Configurado' : 'Pendiente'}',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('Permiso de ubicación (GPS)'),
                  subtitle: Text(
                    settings.locationGranted ? 'Concedido' : 'No concedido',
                  ),
                  trailing: TextButton(
                    onPressed: () => settings.requestLocation(),
                    child: const Text('Solicitar'),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.directions_walk),
                  title: const Text('Permiso de actividad física'),
                  subtitle: Text(
                    settings.activityGranted ? 'Concedido' : 'No concedido',
                  ),
                  trailing: TextButton(
                    onPressed: () => settings.requestActivityRecognition(),
                    child: const Text('Solicitar'),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_applications_outlined),
                  title: const Text('Ajustes del sistema Android'),
                  subtitle: const Text(
                    'Administrar permisos manualmente si fueron bloqueados',
                  ),
                  onTap: () => settings.openAppSettings(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}