import 'package:go_router/go_router.dart';
import 'package:mute/screens/camera_screen.dart';
import 'package:mute/screens/history_screen.dart';
import 'package:mute/screens/home_screen.dart';
import 'package:mute/screens/learning_screen.dart';
import 'package:mute/screens/reverse_mode_screen.dart';
import 'package:mute/screens/settings_screen.dart';
import 'package:mute/screens/splash_screen.dart';
import 'package:mute/screens/practice_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/camera',
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: '/reverse-mode',
        builder: (context, state) => const ReverseModeScreen(),
      ),
      GoRoute(
        path: '/learning',
        builder: (context, state) => const LearningScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/practice/:gesture',
        builder: (context, state) {
          final gesture = state.pathParameters['gesture']!;
          return PracticeScreen(gesture: gesture);
        },
      ),
    ],
  );
}
