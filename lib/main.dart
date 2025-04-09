import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/search_screen.dart';
import 'screens/plant_disease_detection_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/food_waste_screen.dart';
import 'screens/nutrition_planner_screen.dart';
import 'screens/crop_yield_screen.dart';
import 'screens/supply_chain_screen.dart';
import 'services/auth_service.dart';
import 'services/nutrition_planner_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signOut();
  runApp(
    MultiProvider( // Change to MultiProvider to support multiple providers
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ApiService()), // Add ApiService provider
      ],
      child: const ClimateSmartFarmingApp(),
    ),
  );
}

class ClimateSmartFarmingApp extends StatelessWidget {
  const ClimateSmartFarmingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Climate Smart Farming',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green.shade700,
          secondary: Colors.teal,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: AuthWrapper(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/search': (context) => SearchScreen(),
        '/disease_detection': (context) => PlantDiseaseDetectionScreen(),
        '/waste_prediction': (context) => FoodWasteScreen(),
        '/nutrition_planner': (context) => NutritionPlannerSplashScreen(),
        '/crop_yield': (context) => CropYieldScreen(),
        '/supply_chain': (context) => SupplyChainScreen(),
      },
    );
  }
}

// AuthWrapper will check authentication state and redirect accordingly
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    // Listen to auth state changes and redirect accordingly
    return authService.isLoggedIn ? const HomeScreen() : LoginScreen();
  }
}