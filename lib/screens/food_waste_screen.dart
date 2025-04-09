import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'map_screen.dart';
import '../models/food_item.dart';
import 'package:google_fonts/google_fonts.dart';

class FoodWasteScreen extends StatefulWidget {
  const FoodWasteScreen({super.key});

  @override
  State<FoodWasteScreen> createState() => _FoodWasteScreenState();
}

class _FoodWasteScreenState extends State<FoodWasteScreen> {
  final _foodController = TextEditingController();
  final _expiryController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  
  // Firebase instances
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _foodItemsStream;
  
  @override
  void initState() {
    super.initState();
    // Set up stream to listen to current user's food items
    _setupFoodItemsStream();
  }
  
  void _setupFoodItemsStream() {
    if (_auth.currentUser != null) {
      _foodItemsStream = _firestore
          .collection('foodItems')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .snapshots();
    }
  }

  void _saveItem() {
    if (_foodController.text.isEmpty || _auth.currentUser == null) return;

    // Create new food item
    final newItem = FoodItem(
      name: _foodController.text,
      expiryDate: _selectedDate,
      userId: _auth.currentUser!.uid,
    );
    
    // Add to Firestore
    _firestore.collection('foodItems').add(newItem.toMap()).then((_) {
      // Clear input fields
      _foodController.clear();
      _expiryController.clear();
      _selectedDate = DateTime.now().add(const Duration(days: 7)); // Reset to default
    }).catchError((error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save item: $error')),
      );
    });
  }

  void _deleteItem(String docId) {
    _firestore.collection('foodItems').doc(docId).delete().catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete item: $error')),
      );
    });
  }

  void _navigateToMapScreen(FoodItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPage(prediction: item.getStatus()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF5F8F58)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              Color(0xFFE5F0E7),
              Color(0xFFEDF2E5),
              Color.fromARGB(255, 246, 246, 226) // Transition to the original background color
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top section with gradient background
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Food Waste Prediction',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 32,
                        letterSpacing: 1.2
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Fill in the required information to track expiry dates and donate surplus food!',
                      style: GoogleFonts.dmSans(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(color: Color(0xFF5F8F58)),
                  ],
                ),
              ),
            ),

            // Form fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextFormField(
                      controller: _foodController,
                      decoration: InputDecoration(
                        labelText: 'FOOD ITEM',
                        border: InputBorder.none,                
                        prefixIcon: Icon(
                          Icons.food_bank_outlined, 
                          color: Color(0xFF5F8F58),
                          size: 32,
                        ),
                        labelStyle: GoogleFonts.dmSans(
                            color: Colors.grey,
                            fontSize: 12,
                            letterSpacing: 1.2
                          ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: InputDecoration(
                        labelText: 'EXPIRY DATE',
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.calendar_today, 
                          color: Color(0xFF5F8F58)
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        labelStyle: GoogleFonts.dmSans(
                          color: Colors.grey,
                          fontSize: 12,
                          letterSpacing: 1.2
                        ),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                            _expiryController.text = DateFormat('yyyy-MM-dd').format(date);
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  ElevatedButton(
                    onPressed: _saveItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5F8F58),
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'SAVE ITEM',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 30),
            
            // Food Inventory Section with Firebase integration
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 10.0),
                      child: Text(
                        'Food Inventory',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 28,
                          letterSpacing: 1.2
                        ),
                      ),
                    ),
                    
                    // StreamBuilder to display real-time Firebase data
                    Expanded(
                      child: _auth.currentUser == null
                      ? Center(child: Text('Please log in to view your food inventory'))
                      : StreamBuilder<QuerySnapshot>(
                          stream: _foodItemsStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(child: Text('Error loading data'));
                            }
                            
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            
                            if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                              return Center(child: Text('No food items added yet'));
                            }
                            
                            return ListView.separated(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              itemCount: snapshot.data!.docs.length,
                              separatorBuilder: (context, index) => Divider(color: Colors.grey.withOpacity(0.3)),
                              itemBuilder: (context, index) {
                                // Convert Firestore document to FoodItem
                                final doc = snapshot.data!.docs[index];
                                final item = FoodItem.fromMap(
                                  doc.data() as Map<String, dynamic>, 
                                  doc.id
                                );
                                
                                final isExpired = item.getStatus() == 'ROTTEN';
                                
                                return InkWell(
                                  onTap: () => _navigateToMapScreen(item),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                style: GoogleFonts.dmSans(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                  color: isExpired ? Colors.red : Colors.black,
                                                ),
                                              ),
                                              Text(
                                                item.getStatusLine(),
                                                style: GoogleFonts.dmSans(
                                                  color: isExpired ? Colors.red.withOpacity(0.7) : Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete_outline, color: Color(0xFF5F8F58)),
                                          onPressed: () => _deleteItem(item.id!),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}