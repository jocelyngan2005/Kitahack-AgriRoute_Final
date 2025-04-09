import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'meal_plan_screen.dart';
import 'package:provider/provider.dart';
import '../services/nutrition_planner_service.dart';
import 'package:google_fonts/google_fonts.dart';

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
    // Navigate immediately to the main screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    return const Scaffold(
      backgroundColor: Color(0xFFfcf3dd),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Personalized Nutrition Planner',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5f8f58),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Text(
                'Get customized meal plans based on your dietary preferences, allergies, and sustainability goals.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF5f8f58),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PersonalizedNutritionPlannerScreen extends StatefulWidget {
  const PersonalizedNutritionPlannerScreen({super.key});

  @override
  State<PersonalizedNutritionPlannerScreen> createState() => _PersonalizedNutritionPlannerState();
}

class _PersonalizedNutritionPlannerState extends State<PersonalizedNutritionPlannerScreen> {
  String? dietaryPreference;
  final List<String> allergies = [];
  String? duration;
  int maxCalories = 2000;
  double minSustainabilityScore = 5.0;

  final TextEditingController _allergyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // All steps visible at once, matching the design
  bool get allInputsValid => 
      dietaryPreference != null && 
      duration != null;

  @override
  void dispose() {
    _allergyController.dispose();
    super.dispose();
  }

  void _addAllergy() {
    if (_allergyController.text.isNotEmpty) {
      setState(() {
        allergies.add(_allergyController.text.trim());
        _allergyController.clear();
      });
    }
  }

  void _removeAllergy(String allergy) {
    setState(() {
      allergies.remove(allergy);
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    
    // Green color used throughout the app
    const Color primaryGreen = Color(0xFF5F8F58);

    return Scaffold(
      // Replace the solid background with a gradient
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE5F0E7), // top
              Color(0xFFEDF2E5), // middle
              Color.fromARGB(255, 246, 246, 226) // bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 20), // adjust as needed
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: primaryGreen),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                title: null
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            'Personalized Meal Planning',
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 32,
                              height: 1.2,
                              letterSpacing: 1.2
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Fill in the required information to obtain personalised nutritious meals!',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 1,
                            color: primaryGreen,
                          ),
                          const SizedBox(height: 24),

                          // Dietary Preference
                          _buildInputField(
                            title: "DIETARY PREFERENCE",
                            child: DropdownButtonFormField<String>(
                              value: dietaryPreference,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                              hint: Text(
                                "Select dietary preference",
                                style: GoogleFonts.dmSans(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600
                                )
                              ),
                              items: ["Vegan", "Vegetarian", "Gluten-Free", "Pescatarian", "None"]
                                  .map((option) => DropdownMenuItem(
                                        value: option,
                                        child: Text(
                                          option,
                                          style: GoogleFonts.dmSans(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w600
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  dietaryPreference = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Allergies
                          _buildInputField(
                            title: "ALLERGY(IES)",
                            trailing: GestureDetector(
                              onTap: _addAllergy,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            child: TextField(
                              controller: _allergyController,
                              decoration: InputDecoration(
                                hintText: "Enter allergies",
                                hintStyle: GoogleFonts.dmSans(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (allergies.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: allergies.map((allergy) {
                                return Chip(
                                  backgroundColor: Color(0xFFB4C7A6),
                                  label: Text(
                                    allergy,
                                    style: GoogleFonts.dmSans(
                                      color: Colors.black87,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600
                                    ),
                                  ),
                                  deleteIcon: const Icon(Icons.close, size: 14),
                                  onDeleted: () => _removeAllergy(allergy),
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: 16),

                          // Duration
                          _buildInputField(
                            title: "DURATION",
                            child: DropdownButtonFormField<String>(
                              value: duration,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                              hint: Text(
                                "Select duration",
                                style: GoogleFonts.dmSans(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600
                                )
                              ),
                              items: ["daily", "weekly"]
                                  .map((option) => DropdownMenuItem(
                                        value: option,
                                        child: Text(
                                          option,
                                          style: GoogleFonts.dmSans(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w600
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  duration = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Max Calories
                          Text(
                            "MAX DAILY CALORIES",
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              letterSpacing: 1.2
                            ),
                          ),
                          const SizedBox(height: 16),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: primaryGreen,
                              inactiveTrackColor: Colors.black12,
                              thumbColor: primaryGreen,
                              trackHeight: 4.0,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                            ),
                            child: Slider(
                              value: maxCalories.toDouble(),
                              min: 500,
                              max: 5000,
                              divisions: 25,
                              onChanged: (value) {
                                setState(() {
                                  maxCalories = value.round();
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Min Sustainability Score
                          Text(
                            "MIN SUSTAINABILITY SCORE (1 - 10)",
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              letterSpacing: 1.2
                            ),
                          ),
                          const SizedBox(height: 16),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: primaryGreen,
                              inactiveTrackColor: Colors.black12,
                              thumbColor: primaryGreen,
                              trackHeight: 4.0,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                            ),
                            child: Slider(
                              value: minSustainabilityScore,
                              min: 0,
                              max: 10,
                              divisions: 10,
                              onChanged: (value) {
                                setState(() {
                                  minSustainabilityScore = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 36),

                          // Generate Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 0,
                              ),
                              onPressed: allInputsValid ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MealPlanPage(
                                      dietaryPreference: dietaryPreference ?? "None",
                                      allergies: allergies,
                                      duration: duration ?? "daily",
                                      maxCalories: maxCalories,
                                      minSustainabilityScore: minSustainabilityScore,
                                      apiService: apiService,
                                    ),
                                  ),
                                );
                              } : null,
                              child: Text(
                                "GENERATE MEAL PLAN",
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    IconData? icon,
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.black),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                child,
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}