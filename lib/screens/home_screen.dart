import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AuthService authService;
  Stream<DocumentSnapshot>? userStream;

  @override
  void initState() {
    super.initState();
    // We'll setup the stream in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get auth service reference safely
    authService = Provider.of<AuthService>(context, listen: false);
    
    // Setup the user stream if logged in
    if (authService.isLoggedIn && authService.user != null) {
      userStream = FirebaseFirestore.instance
          .collection('users')
          .doc(authService.user!.uid)
          .snapshots();
    } else {
      userStream = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE5F0E7), // top
              Color(0xFFEDF2E5), // middle
              Color.fromARGB(255, 246, 246, 226) // bottom
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome back and Sign Out button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Welcome Back,',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: Color(0xFF333333),
                        letterSpacing: 2.0
                      ),
                    ),
                    // Sign out button
                    IconButton(
                      icon: Icon(Icons.logout, color: Color(0xFF5F8F58)),
                      onPressed: () async {
                        await authService.signOut();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      tooltip: 'Sign Out',
                    ),
                  ],
                ),
                SizedBox(height: 4),
                
                // User info
                StreamBuilder<DocumentSnapshot>(
                  stream: userStream,
                  builder: (context, snapshot) {
                    String userName = "User";
                    
                    if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                      final userData = snapshot.data!.data() as Map<String, dynamic>;
                      userName = userData['name'] ?? authService.user?.displayName ?? "User";
                    } else if (authService.user?.displayName != null && authService.user!.displayName!.isNotEmpty) {
                      userName = authService.user!.displayName!;
                    }
                    
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          userName,
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 36,
                            letterSpacing: 1.5,
                            color: Color(0xFF111111),
                          ),
                        ),
                        Icon(
                          Icons.account_circle,
                          size: 40,
                        ),
                      ],
                    );
                  },
                ),
                
                Divider(
                  color: Color(0xFF5F8F58),
                  thickness: 1,
                  height: 40,
                ),
                
                // Feature cards based on user role
                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: userStream,
                    builder: (context, snapshot) {
                      String userRole = "hobbyist"; // Default role
                      
                      if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                        final userData = snapshot.data!.data() as Map<String, dynamic>;
                        userRole = userData['role'] ?? "hobbyist";
                      }
                      
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            // Common feature for both roles
                            _buildFeatureCard(
                              title: 'Find Farming Techniques',
                              description: 'Discover the best farming techniques for your crops.',
                              icon: Icons.search,
                              onTap: () {
                                Navigator.pushNamed(context, '/search');
                              },
                            ),
                            
                            // Farmer-only feature
                            if (userRole == "farmer")
                              _buildFeatureCard(
                                title: 'Predict Crop Yield',
                                description: 'Estimate the yield of your crops based on various factors.',
                                icon: Icons.trending_up,
                                onTap: () {
                                  Navigator.pushNamed(context, '/crop_yield');
                                },
                              ),
                            
                            // Common feature for both roles
                            _buildFeatureCard(
                              title: 'Plant Disease Detection',
                              description: 'Upload an image of your plant to detect diseases & get treatment advice.',
                              icon: Icons.bug_report,
                              onTap: () {
                                Navigator.pushNamed(context, '/disease_detection');
                              },
                            ),
                            
                            // Hobbyist-only feature
                            if (userRole == "hobbyist")
                              _buildFeatureCard(
                                title: 'Personalized Nutrition Planning',
                                description: 'Get personalized nutrition plans based on your dietary needs.',
                                icon: Icons.menu_book,
                                onTap: () {
                                  Navigator.pushNamed(context, '/nutrition_planner');
                                },
                              ),
                            
                            // Common feature for both roles
                            _buildFeatureCard(
                              title: 'Food Supply Chain Transparency',
                              description: 'Track the journey of your food from farm to table.',
                              icon: Icons.local_shipping,
                              onTap: () {
                                Navigator.pushNamed(context, '/supply_chain');
                              },
                            ),
                            
                            // Common feature for both roles
                            _buildFeatureCard(
                              title: 'Food Waste Reduction',
                              description: 'Predicts food surplus before waste occurs and suggests donation spots.',
                              icon: Icons.food_bank,
                              onTap: () {
                                Navigator.pushNamed(context, '/waste_prediction');
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFE5F0E7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Color(0xFF5F8F58),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.dmSans(),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}