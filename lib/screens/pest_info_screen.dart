import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PestInfoScreen extends StatelessWidget {
  final String pest;
  final String? description;
  final List<String>? causes;
  final List<String>? symptoms;
  final List<String>? treatment;
  final List<String>? prevention;
  final String? imagePath;
  final String? advice;

  const PestInfoScreen({
    Key? key,
    required this.pest,
    this.description,
    this.causes,
    this.symptoms,
    this.treatment,
    this.prevention,
    this.imagePath,
    this.advice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE5F0E7),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0), // Zero height app bar
        child: AppBar(
          backgroundColor: Color(0xFFEAF1E9),
          elevation: 0,
          toolbarHeight: 0,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button, pest title 
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Color(0xFF5F8F58)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pest,
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 30,
                          color: Colors.black,
                          letterSpacing: 2.0
                        ),
                      ),
                      SizedBox(height: 4),
                      
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // White card with content
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Scrollable content including image
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image (now inside the scrollable area)
                          if (imagePath != null)
                            Container(
                              height: 210,
                              width: double.infinity,
                              margin: EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(imagePath!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),                        

                          // Description section
                          if (description != null && description!.isNotEmpty)
                            _buildSection('DESCRIPTION', description!),

                          // Causes section
                          if (causes != null && causes!.isNotEmpty)
                            _buildBulletSection('CAUSES', causes!),

                          // Symptoms section
                          if (symptoms != null && symptoms!.isNotEmpty)
                            _buildBulletSection('SYMPTOMS', symptoms!),

                          // Treatment section
                          if (treatment != null && treatment!.isNotEmpty)
                            _buildBulletSection('TREATMENT', treatment!),

                          // Prevention section
                          if (prevention != null && prevention!.isNotEmpty)
                            _buildBulletSection('PREVENTION', prevention!),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Save button
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pest diagnosis saved to records')),
                );
              },
              icon: Icon(Icons.save_outlined),
              label: Text(
                'SAVE',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5F8F58),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattedText(String text) {
    // Split the text by asterisks
    final parts = text.split('*');
    final List<TextSpan> textSpans = [];
    
    // Build text spans with alternating styles
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      
      // Odd indices are between asterisks (bold)
      if (i % 2 == 1) {
        textSpans.add(
          TextSpan(
            text: parts[i],
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );
      } 
      // Even indices are normal text
      else {
        textSpans.add(
          TextSpan(
            text: parts[i],
            style: GoogleFonts.dmSans(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        );
      }
    }
    
    return RichText(
      text: TextSpan(
        style: GoogleFonts.dmSans(
          fontSize: 16,
          height: 1.5,
          color: Colors.black, // Default text color
        ),
        children: textSpans,
      ),
    );
  }
  
  Widget _buildSection(String title, String content) {
    // Check if content includes bullet points
    bool hasBulletPoints = content.contains('•') || content.contains('-');
    
    if (hasBulletPoints) {
      // Convert the content to a list based on bullet points
      List<String> items = [];
      
      // Split by line breaks first
      List<String> lines = content.split('\n');
      
      for (String line in lines) {
        line = line.trim();
        if (line.startsWith('•') || line.startsWith('-')) {
          // Remove the bullet point character and trim
          items.add(line.substring(1).trim());
        } else if (line.isNotEmpty) {
          items.add(line);
        }
      }
      
      return _buildBulletSection(title, items);
    } else {
      // Regular text section
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.dmSerifDisplay(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF5F8F58),
              letterSpacing: 1.2,          
            ),
          ),
          Divider(
            color: Color(0xFF5F8F58),
            thickness: 1.5,
          ),
          SizedBox(height: 5),
          _buildFormattedText(content),
        ],
      );
    }
  }
  
  Widget _buildBulletSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          title,
          style: GoogleFonts.dmSerifDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF5F8F58),
            letterSpacing: 1.2,
          ),
        ),
        Divider(
          color: Color(0xFF5F8F58),
          thickness: 1.5,
        ),
        SizedBox(height: 5),
        ...items.map((item) => _buildBulletItem(item)),
      ],
    );
  }
  
  Widget _buildBulletItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🐞',  // Bug emoji instead of plant emoji for pests
            style: GoogleFonts.dmSans(fontSize: 14),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _buildFormattedText(text),
          ),
        ],
      ),
    );
  }
}