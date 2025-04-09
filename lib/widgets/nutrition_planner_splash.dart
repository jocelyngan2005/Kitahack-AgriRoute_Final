import 'package:flutter/material.dart';
import '../screens/nutrition_planner_screen.dart';

class NutritionPlannerSplashScreen extends StatefulWidget {
  const NutritionPlannerSplashScreen({super.key});

  @override
  State<NutritionPlannerSplashScreen> createState() => 
      _NutritionPlannerSplashScreenState();
}

class _NutritionPlannerSplashScreenState extends State<NutritionPlannerSplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PersonalizedNutritionPlannerScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfcf3dd),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Your Personalized',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5f8f58),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              const Text(
                'Nutrition Starts Here!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5f8f58),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Get customized meal plans based on your dietary preferences, allergies, and sustainability goals.',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF343434),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFFf2c763),
                ),
                strokeWidth: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}