import 'package:flutter/material.dart';

class FoodCard extends StatelessWidget {
  final String foodName;
  final String mealType;
  final VoidCallback onTap;

  const FoodCard({
    super.key,
    required this.foodName,
    required this.mealType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 15),
      elevation: 2,
      color: const Color(0xFF5f8f58),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getMealIcon(),
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    mealType,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                foodName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Chip(
                    label: const Text('View Recipe'),
                    backgroundColor: Colors.white,
                  ),
                  Spacer(),
                  Icon(Icons.chevron_right,
                    color: Colors.white
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMealIcon() {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.breakfast_dining;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }
}