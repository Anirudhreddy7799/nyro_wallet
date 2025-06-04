import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'app_router.dart';
import 'screens/get_started_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_card_screen.dart';
import 'screens/cards_screen.dart';
import 'screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  runApp(const NyroWalletApp());
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show a loading indicator while waiting for auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // If the snapshot has a user, they are signed in
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        // Otherwise, show the GetStarted screen
        return const GetStartedScreen();
      },
    );
  }
}

class NyroWalletApp extends StatelessWidget {
  const NyroWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NyroWallet',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: const ColorScheme.dark(primary: Color(0xFFE5C100)),
        fontFamily: 'Poppins',
      ),
      home: const AuthGate(),
      routes: {
        GetStartedScreen.routeName: (_) => const GetStartedScreen(),
        SignupScreen.routeName: (_) => const SignupScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
        CardsScreen.routeName: (_) => const CardsScreen(),
        AddCardScreen.routeName: (_) => const AddCardScreen(),
      },
    );
  }
}
