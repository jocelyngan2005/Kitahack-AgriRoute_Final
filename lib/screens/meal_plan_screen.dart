import 'package:flutter/material.dart';
import '../models/meal_plan.dart';
import '../services/nutrition_planner_service.dart';
import 'recipe_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class MealPlanPage extends StatefulWidget {
  final String dietaryPreference;
  final List<String> allergies;
  final String duration;
  final int maxCalories;
  final double minSustainabilityScore;
  final ApiService apiService;

  const MealPlanPage({
    super.key,
    required this.dietaryPreference,
    required this.allergies,
    required this.duration,
    required this.maxCalories,
    required this.minSustainabilityScore,
    required this.apiService,
  });

  @override
  State<MealPlanPage> createState() => _MealPlanPageState();
}

class _MealPlanPageState extends State<MealPlanPage> {
  late Future<MealPlan> _mealPlanFuture;
  bool _isLoading = false;
  final List<String> _mealOrder = ['breakfast', 'lunch', 'dinner'];

  @override
  void initState() {
    super.initState();
    _loadMealPlan();
  }

  void _loadMealPlan() {
    setState(() {
      _isLoading = true;
    });
    
    _mealPlanFuture = widget.apiService.generateMealPlan(
      dietaryPreference: widget.dietaryPreference,
      allergies: widget.allergies,
      duration: widget.duration,
      maxCalories: widget.maxCalories,
      minSustainabilityScore: widget.minSustainabilityScore,
    ).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
  }

  List<MapEntry<String, String>> _sortMeals(Map<String, String> meals) {
    final entries = meals.entries.toList();
    
    entries.sort((a, b) {
      final aIndex = _mealOrder.indexOf(a.key.toLowerCase());
      final bIndex = _mealOrder.indexOf(b.key.toLowerCase());
      
      if (aIndex == -1) return 1;
      if (bIndex == -1) return -1;
      
      return aIndex.compareTo(bIndex);
    });
    
    return entries;
  }

  String _getPlanTitle() {
    final durationLower = widget.duration.toLowerCase();
    
    if (durationLower == 'daily' || durationLower == 'day') {
      return "Today's Meal Plan";
    } else if (durationLower == 'weekly' || durationLower == 'week') {
      return "This Week's Meal Plan";
    } else {
      return "Your Meal Plan";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove backgroundColor property as we're using a gradient background in the body
      extendBodyBehindAppBar: true, // This allows the gradient to extend behind the AppBar
      appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  leading: Padding(
    padding: const EdgeInsets.all(20), // Padding around back icon
    child: IconButton(
      icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF5f8f58)),
      onPressed: () => Navigator.of(context).pop(),
    ),
  ),
  actions: [
    Padding(
      padding: const EdgeInsets.all(20), // Padding around refresh icon
      child: IconButton(
        icon: const Icon(Icons.refresh, color: Color(0xFF5f8f58)),
        onPressed: _isLoading ? null : _loadMealPlan,
      ),
    ),
  ],
),

      body: Container(
        // Add gradient decoration
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF5F8F58)))
            : FutureBuilder<MealPlan>(
                future: _mealPlanFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadMealPlan,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: Text('No meal plan available'));
                  }

                  final mealPlan = snapshot.data!;

                  return RefreshIndicator(
                    color: const Color(0xFF5f8f58),
                    onRefresh: () async {
                      _loadMealPlan();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 24, 
                        right: 24,
                        // Add top padding to account for status bar and app bar
                        top: MediaQuery.of(context).padding.top + 30
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getPlanTitle(),
                              style: GoogleFonts.dmSerifDisplay(
                                fontSize: 32,
                                height: 1.2,
                                letterSpacing: 1.2
                              ),
                            ),
                            const SizedBox(height: 15),
                            Container(
                              height: 2,
                              color: const Color(0xFF5f8f58),
                            ),
                            const SizedBox(height: 24),
                            ...mealPlan.plan.entries.map((entry) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDayHeader(entry.key),
                                  const SizedBox(height: 10),
                                  ..._sortMeals((entry.value).cast<String, String>()).map((meal) {
                                    return _buildMealCard(
                                      mealType: meal.key,
                                      foodName: meal.value,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => RecipePage(
                                              foodName: meal.value,
                                              mealType: meal.key,
                                              apiService: widget.apiService,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }),
                                  const SizedBox(height: 16),
                                ],
                              );
                            }),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
  
  Widget _buildDayHeader(String day) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          day.toUpperCase(),
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        
      ],
    );
  }
  
  Widget _buildMealCard({
    required String mealType, 
    required String foodName, 
    required VoidCallback onTap
  }) {
    IconData mealIcon;
    
    switch(mealType.toLowerCase()) {
      case 'breakfast':
        mealIcon = Icons.wb_sunny_outlined;
        break;
      case 'lunch':
        mealIcon = Icons.restaurant_outlined;
        break;
      case 'dinner':
        mealIcon = Icons.nightlight_outlined;
        break;
      default:
        mealIcon = Icons.restaurant_outlined;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: const Offset(-1, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      mealIcon,
                      size: 20,
                      color: const Color(0xFF5f8f58),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      mealType.toUpperCase(),
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Color(0xFF5f8f58),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 1,
                  color: Colors.grey.withOpacity(0.2),
                ),
                Text(
                  foodName,
                  style: GoogleFonts.dmSerifDisplay (
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF598453),
                    letterSpacing: 1.5
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}