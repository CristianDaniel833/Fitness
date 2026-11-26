import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/workout_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/onboarding/initial_profile_screen.dart';
import 'screens/workout/workout_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FitnessApp());
}

class FitnessApp extends StatefulWidget {
  const FitnessApp({super.key});

  @override
  State<FitnessApp> createState() => _FitnessAppState();
}

class _FitnessAppState extends State<FitnessApp> with WidgetsBindingObserver {
  late final SettingsProvider _settingsProvider;
  late final ProfileProvider _profileProvider;
  late final AuthProvider _authProvider;
  late final WorkoutProvider _workoutProvider;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _settingsProvider = SettingsProvider();
    _profileProvider = ProfileProvider();
    _authProvider = AuthProvider();
    _workoutProvider = WorkoutProvider();

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      _settingsProvider.init(),
      _profileProvider.loadProfile(),
      _authProvider.init(),
    ]);
    _workoutProvider.updateProfile(_profileProvider.profile);
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _workoutProvider.handleAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _workoutProvider.dispose();
    _authProvider.dispose();
    _profileProvider.dispose();
    _settingsProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _settingsProvider),
        ChangeNotifierProvider.value(value: _profileProvider),
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _workoutProvider),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Fitness',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
            settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: _initialized
                ? const _RootRouter()
                : const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        },
      ),
    );
  }
}

class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = context.watch<ProfileProvider>();

    if (!auth.isAuthenticated) {
      return const AuthScreen();
    }

    if (profile.shouldShowInitialProfilePrompt) {
      return const InitialProfileScreen();
    }

    return const WorkoutScreen();
  }
}