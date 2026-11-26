import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  String? _localError;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _handleFingerprint() async {
    setState(() => _localError = null);
    final auth = context.read<AuthProvider>();
    final profile = context.read<ProfileProvider>();
    await auth.authenticateWithFingerprint(profile);
  }

  Future<void> _handleCreatePin() async {
    setState(() => _localError = null);
    final pin = _pinController.text.trim();
    final confirm = _confirmPinController.text.trim();

    if (pin.length < AppConstants.pinMinLength ||
        pin.length > AppConstants.pinMaxLength) {
      setState(() {
        _localError =
        'El PIN debe tener entre ${AppConstants.pinMinLength} y ${AppConstants.pinMaxLength} dígitos.';
      });
      return;
    }

    if (pin != confirm) {
      setState(() => _localError = 'Los PIN ingresados no coinciden.');
      return;
    }

    final auth = context.read<AuthProvider>();
    final profile = context.read<ProfileProvider>();
    await auth.createPin(pin, profile);
    _pinController.clear();
    _confirmPinController.clear();
  }

  Future<void> _handleVerifyPin() async {
    setState(() => _localError = null);
    final pin = _pinController.text.trim();

    if (pin.length < AppConstants.pinMinLength) {
      setState(() {
        _localError =
        'Ingresa tu PIN de ${AppConstants.pinMinLength} a ${AppConstants.pinMaxLength} dígitos.';
      });
      return;
    }

    final auth = context.read<AuthProvider>();
    final profile = context.read<ProfileProvider>();
    await auth.verifyPin(pin, profile);
    _pinController.clear();
  }

  Future<void> _showForgotPinDialog() async {
    final auth = context.read<AuthProvider>();
    final profile = context.read<ProfileProvider>();

    final shouldReset = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Olvidaste tu PIN?'),
        content: const Text(
          'Restablecer el PIN eliminará por completo todo tu historial de rutinas, '
              'rutas guardadas y datos de perfil. La aplicación volverá a quedar como '
              'si nunca se hubiera usado para que crees un nuevo PIN.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Borrar y crear nuevo PIN'),
          ),
        ],
      ),
    );

    if (shouldReset == true && mounted) {
      _pinController.clear();
      _confirmPinController.clear();
      setState(() => _localError = null);
      await auth.resetAllDataAfterForgotPin(profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final errorText = _localError ?? auth.errorMessage;

    return Scaffold(
      appBar: AppBar(title: const Text('Fitness · Acceso')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.fingerprint,
                        size: 52,
                        color: auth.hasFingerprintSensor
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        auth.hasFingerprintSensor
                            ? 'Sensor de huella listo y verificado'
                            : 'Huella no disponible o sin huella registrada',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        auth.hasFingerprintSensor
                            ? 'Usa tu huella o reintenta la lectura biométrica para entrar.'
                            : 'Puedes continuar utilizando tu PIN alternativo.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      if (auth.hasFingerprintSensor) ...[
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: auth.isBusy ? null : _handleFingerprint,
                          icon: const Icon(Icons.fingerprint),
                          label: const Text('Ingresar o reintentar huella'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: auth.hasPinConfigured
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Acceso con PIN',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _pinController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: AppConstants.pinMaxLength,
                        decoration: const InputDecoration(
                          labelText: 'Ingresa tu PIN',
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: auth.isBusy ? null : _handleVerifyPin,
                        child: const Text('Entrar con PIN'),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: auth.isBusy
                              ? null
                              : _showForgotPinDialog,
                          child: const Text('Olvidé mi PIN'),
                        ),
                      ),
                    ],
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Crear PIN de seguridad',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Configura un PIN numérico de ${AppConstants.pinMinLength} a ${AppConstants.pinMaxLength} dígitos para tu primera vez.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _pinController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: AppConstants.pinMaxLength,
                        decoration: const InputDecoration(
                          labelText: 'Nuevo PIN',
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _confirmPinController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: AppConstants.pinMaxLength,
                        decoration: const InputDecoration(
                          labelText: 'Confirmar PIN',
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: auth.isBusy ? null : _handleCreatePin,
                        child: const Text('Crear PIN'),
                      ),
                    ],
                  ),
                ),
              ),
              if (errorText != null) ...[
                const SizedBox(height: 14),
                Text(
                  errorText,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}