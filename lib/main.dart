import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'utils/app_theme.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Supabase
    await Supabase.initialize(
        url: 'https://nibwouetnychcxujjamz.supabase.co',
        publishableKey: 'sb_publishable_JKIb2h8V6a5AHWqnad4SEQ_UntXh4hg',
    );

    runApp(const FoodMealPlannerApp());
}

class FoodMealPlannerApp extends StatelessWidget {
    const FoodMealPlannerApp({super.key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Food & Meal Planner',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const AuthGate(),
        );
    }
}

class AuthGate extends StatelessWidget {
    const AuthGate({super.key});

    @override
    Widget build(BuildContext context) {
        return StreamBuilder<firebase_auth.User?>(
            stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
                // Firebase is checking the current login state
                if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                        body: Center(
                            child: CircularProgressIndicator(),
                        ),
                    );
                }

                // User is already logged in
                if (snapshot.hasData) {
                    return const HomeScreen();
                }

                // User is not logged in
                return const LoginScreen();
            },
        );
    }
}