import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
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
            home: const LoginScreen(),
        );
    }
}