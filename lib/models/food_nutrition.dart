class FoodItem {
  final String name;
  final String dietaryTags;
  final double sustainabilityScore;
  final int calories;
  final String? imageUrl;

  FoodItem({
    required this.name,
    required this.dietaryTags,
    required this.sustainabilityScore,
    required this.calories,
    this.imageUrl,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['Food Name'] ?? 'Unknown',
      dietaryTags: json['Dietary Tags'] ?? '',
      sustainabilityScore: json['Sustainability Score']?.toDouble() ?? 0.0,
      calories: json['Calories'] ?? 0,
      imageUrl: json['imageUrl'],
    );
  }
}