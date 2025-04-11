import 'package:flutter/material.dart';
import '../services/blockchain_service.dart';
import '../models/product_model.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterProductScreen extends StatefulWidget {
  @override
  _RegisterProductScreenState createState() => _RegisterProductScreenState();
}

class _RegisterProductScreenState extends State<RegisterProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _blockchainService = BlockchainService();

  String _productId = '';
  String _productName = '';
  String _producerName = '';
  String _location = '';
  DateTime _harvestDate = DateTime.now();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print('Submitting: $_productId, $_productName, $_producerName');

      Product product = Product(
        productId: _productId,
        name: _productName,
        producerName: _producerName,
        location: _location,
        harvestDate: _harvestDate,
      );

      try {
        final result = await _blockchainService.registerProduct(product);


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product registered successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE5F0E7), // top
              Color(0xFFEDF2E5), // middle
              Color.fromARGB(255, 246, 246, 226) // bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Register Product',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 32,
                      height: 1.2,
                      letterSpacing: 1.2
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Please fill in the details below to register your product.',
                    style: GoogleFonts.dmSans(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 10),
                  Divider(color: Color(0xFF5F8F58)),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'PRODUCT ID',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        labelStyle: GoogleFonts.dmSans(
                          color: Colors.grey,
                          fontSize: 12,
                          letterSpacing: 1.2
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Please enter Product ID' : null,
                      onSaved: (value) => _productId = value!,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'PRODUCT NAME',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        labelStyle: GoogleFonts.dmSans(
                          color: Colors.grey,
                          fontSize: 12,
                          letterSpacing: 1.2
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Please enter Product Name' : null,
                      onSaved: (value) => _productName = value!,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'PRODUCER NAME',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        labelStyle: GoogleFonts.dmSans(
                          color: Colors.grey,
                          fontSize: 12,
                          letterSpacing: 1.2
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Please enter Producer Name' : null,
                      onSaved: (value) => _producerName = value!,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'LOCATION',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        labelStyle: GoogleFonts.dmSans(
                          color: Colors.grey,
                          fontSize: 12,
                          letterSpacing: 1.2
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Please enter Location' : null,
                      onSaved: (value) => _location = value ?? '',
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: TextEditingController(
                      text: "${_harvestDate.day}/${_harvestDate.month}/${_harvestDate.year}",
                    ),
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: "HARVEST DATE",
                      labelStyle: GoogleFonts.dmSans(
                          color: Colors.grey,
                          fontSize: 12,
                          letterSpacing: 1.2
                        ),
                      hintText: "Select a date",
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      border: InputBorder.none,
                      
                    ),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                        
                      );
                      
                      if (picked != null && picked != _harvestDate) {
                        setState(() {
                          _harvestDate = picked;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5F8F58),
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'REGISTER PRODUCT',
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
          ),
        ),
      ),
    );
  }
}
