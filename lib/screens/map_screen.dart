import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'food_donation_centers.dart'; 
import 'package:google_fonts/google_fonts.dart';

class MapPage extends StatelessWidget {
  final String prediction;
  const MapPage({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DONATION CENTERS: $prediction',
          style: GoogleFonts.dmSans(
            fontSize: 20,
            color: Colors.black,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF5F8F58)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Color(0xFFE5F0E7),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(3.1390, 101.6869),  // Kuala Lumpur coordinates
          zoom: 13,
        ),
        markers: {
          for (final center in FoodDonationCenters.getDonationCenters())
            Marker(
              markerId: MarkerId(center.toString()),
              position: center,
              infoWindow: InfoWindow(
                title: 'Donation Center',
                snippet: getLocationName(center),
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                prediction.contains('EXPIRED') 
                  ? BitmapDescriptor.hueRed
                  : BitmapDescriptor.hueGreen,
              ),
            )
        },
      ),
    );
  }
  
  // Helper method to get location names based on coordinates
  String getLocationName(LatLng location) {
    const locations = {
      '3.1457, 101.6980': 'Central Market',
      '3.1585, 101.7144': 'KLCC',
      '3.1545, 101.7122': 'Kechara Soup Kitchen',
      '3.1486, 101.6987': 'Food Aid Foundation',
      '3.1499, 101.7001': 'New Center',
    };
    
    final key = '${location.latitude}, ${location.longitude}';
    return locations[key] ?? 'Donation Location';
  }
}