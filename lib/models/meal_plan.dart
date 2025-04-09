class MealPlan {
  final Map<String, Map<String, dynamic>> plan; 
  final String duration;

  MealPlan({required this.plan, required this.duration});

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      plan: Map<String, Map<String, dynamic>>.from(json['data']),
      duration: json['duration'] ?? 'daily',
    );
  }
}