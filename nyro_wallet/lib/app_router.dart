import 'package:flutter/material.dart';
import 'screens/get_started_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

class AppRouter {
  /// Call this in MaterialApp’s `onGenerateRoute`
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const GetStartedScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        // Fallback if someone tries to navigate to an undefined route
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('404 – Page Not Found'))),
        );
    }
  }
}
