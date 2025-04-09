import 'package:google_maps_flutter/google_maps_flutter.dart';

class FoodDonationCenters {
  static String predictSpoilage(String food, DateTime expiry) {
    final daysLeft = expiry.difference(DateTime.now()).inDays;
    if (daysLeft <= 0) return "🚨 EXPIRED";
    return daysLeft <= 2 ? "⚠️ EXPIRING ($daysLeft days)" : "✅ FRESH ($daysLeft days)";
  }

  static List<LatLng> getDonationCenters() {
    return const [
      LatLng(3.1457, 101.6980), // Central Market
      LatLng(3.1585, 101.7144), // KLCC
      LatLng(3.1545, 101.7122), // Kechara Soup Kitchen
      LatLng(3.1486, 101.6987), // Food Aid Foundation
      LatLng(3.1499, 101.7001), // New Center
    ];
  }
}