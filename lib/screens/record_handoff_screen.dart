import 'package:flutter/material.dart';
import '../services/blockchain_service.dart';
import '../models/handoff_model.dart';
import 'package:google_fonts/google_fonts.dart';

class RecordHandoffScreen extends StatefulWidget {
  @override
  _RecordHandoffScreenState createState() => _RecordHandoffScreenState();
}

class _RecordHandoffScreenState extends State<RecordHandoffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _blockchainService = BlockchainService();

  String _productId = '';
  String _senderId = '';
  String _receiverId = '';
  String _location = '';
  String _notes = '';

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Create a Handoff object
        final handoff = Handoff(
          productId: _productId,
          senderId: _senderId,
          receiverId: _receiverId,
          location: _location,
          notes: _notes,
        );

        // Pass the Handoff object as an argument
        final result = await _blockchainService.recordHandoff(handoff.toJson());
        print('Full API Response: $result');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Handoff recorded successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form after successful submission
        _formKey.currentState!.reset();
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Record Handoff',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 32,
                  height: 1.2,
                  letterSpacing: 1.2
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Please fill in the details below to record the handoff of a product.',
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
                    labelText: 'SENDER ID',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    labelStyle: GoogleFonts.dmSans(
                      color: Colors.grey,
                      fontSize: 12,
                      letterSpacing: 1.2
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter Sender ID' : null,
                  onSaved: (value) => _senderId = value!,
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
                    labelText: 'RECEIVER ID',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    labelStyle: GoogleFonts.dmSans(
                      color: Colors.grey,
                      fontSize: 12,
                      letterSpacing: 1.2
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter Receiver ID' : null,
                  onSaved: (value) => _receiverId = value!,
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
                  onSaved: (value) => _location = value!,
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
                    labelText: 'NOTES (OPTIONAL)',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    labelStyle: GoogleFonts.dmSans(
                      color: Colors.grey,
                      fontSize: 12,
                      letterSpacing: 1.2
                    ),
                  ),
                  onSaved: (value) => _notes = value ?? '',
                ),
              ),
              
              SizedBox(height: 30),
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
    );
  }
}
