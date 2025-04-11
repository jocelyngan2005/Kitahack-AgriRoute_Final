import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExpertAdviceScreen extends StatefulWidget {
  final String area;
  final String item;
  final String year;
  final String rainfall;
  final String pesticides;
  final String temperature;
  final String predictedYield;
  final String? advice;

  const ExpertAdviceScreen({
    Key? key,
    required this.area,
    required this.item,
    required this.year,
    required this.rainfall,
    required this.pesticides,
    required this.temperature,
    required this.predictedYield,
    this.advice,
  }) : super(key: key);

  @override
  _AdviceScreenState createState() => _AdviceScreenState();
}

class _AdviceScreenState extends State<ExpertAdviceScreen> {
  bool _isLoading = false;
  String? _advice;
  
  // Add missing class member variables
  String _title = "Expert Farming Advice";
  String _description = "";
  List<String> _challenges = [];
  List<String> _recommendations = [];
  String _conclusion = "";
  String _sectionTitle = "EXPERT ADVICE";

  @override
  void initState() {
    super.initState();
    _advice = widget.advice;
    if (_advice == null) {
      _loadAdvice();
    } else {
      // Parse existing advice if provided
      final parsedSections = _parseAdviceResponse(_advice!);
      _title = parsedSections['title'] ?? "Farming Advice";
      _description = parsedSections['description'] ?? "";
      _challenges = parsedSections['challenges'] ?? [];
      _recommendations = parsedSections['recommendations'] ?? [];
      _conclusion = parsedSections['conclusion'] ?? "";
    }
  }

  Future<void> _loadAdvice() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String geminiApiKey = "YOUR_API_KEY"; 
      final url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=$geminiApiKey";

      final requestPayload = {
        "contents": [
          {
            "role": "user",
            "parts": [
              {"text": """Area: ${widget.area}
                Crop: ${widget.item}
                Year: ${widget.year}
                Average Rainfall: ${widget.rainfall} mm/year
                Pesticides: ${widget.pesticides} tonnes
                Average Temperature: ${widget.temperature} °C
                Predicted Yield: ${widget.predictedYield} hg/ha

                Format your response using EXACTLY these section headings and formatting:

                # [Title about ${widget.item} farming in ${widget.area}]

                **Description:**
                [Write 1 paragraph about the crop, conditions, and general outlook]

                **Challenges:**
                🌾 [Challenge 1]
                🌾 [Challenge 2]
                🌾 [Challenge 3]
                🌾 [Challenge 4]

                **Recommendations:**
                🌾 [Recommendation 1]
                🌾 [Recommendation 2]
                🌾 [Recommendation 3]
                🌾 [Recommendation 4]
                🌾 [Recommendation 5]

                **Conclusion:**
                [Write a short paragraph analyzing the predicted yield of ${widget.predictedYield} hg/ha and final thoughts]

                Important: Use exactly these section headings with the exact formatting shown above. Each challenge and recommendation must start with "🌾 " exactly as shown.
              """}
            ]
          }
        ]
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestPayload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawText = data["candidates"][0]["content"]["parts"][0]["text"] ?? "No advice available.";
        
        // Parse the response into sections
        final parsedSections = _parseAdviceResponse(rawText);
        
        setState(() {
          _advice = rawText; // Keep original text for fallback
          _title = parsedSections['title'] ?? "Farming Advice";
          _description = parsedSections['description'] ?? "";
          _challenges = parsedSections['challenges'] ?? [];
          _recommendations = parsedSections['recommendations'] ?? [];
          _conclusion = parsedSections['conclusion'] ?? "";
          _isLoading = false;
        });
      } else {
        setState(() {
          _advice = "Error fetching advice: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _advice = "Error fetching advice: $e";
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _parseAdviceResponse(String text) {
    // Initialize result map
    Map<String, dynamic> result = {
      'title': '',
      'description': '',
      'challenges': <String>[],
      'recommendations': <String>[],
      'conclusion': ''
    };
    
    try {
      // Extract title (usually in the first line, often with markdown formatting)
      final titleMatch = RegExp(r'^#+\s*(.+?)$', multiLine: true).firstMatch(text);
      if (titleMatch != null) {
        result['title'] = titleMatch.group(1)?.trim() ?? '';
      }
      
      // Extract description section
      final descriptionMatch = RegExp(r'\*\*Description:\*\*\s*\n([\s\S]*?)(?=\*\*Challenges:\*\*|\*\*Recommendations:\*\*|$)', 
        caseSensitive: true).firstMatch(text);
      if (descriptionMatch != null) {
        result['description'] = descriptionMatch.group(1)?.trim() ?? '';
      }
      
      // Extract challenges section
      final challengesPattern = RegExp(r'\*\*Challenges:\*\*\s*\n([\s\S]*?)(?=\*\*Recommendations:\*\*|\*\*.*?\*\*|$)', 
        caseSensitive: true);
      final challengesMatch = challengesPattern.firstMatch(text);
      if (challengesMatch != null) {
        final challengesText = challengesMatch.group(1) ?? '';
        // Find all bullet points starting with 🌾
        final bulletPoints = RegExp(r'🌾\s*([^\n]+)').allMatches(challengesText);
        result['challenges'] = bulletPoints.map((m) => m.group(1)?.trim() ?? '').toList();
      }
      
      // Extract recommendations section
      final recommendationsPattern = RegExp(r'\*\*Recommendations:\*\*\s*\n([\s\S]*?)(?=\*\*.*?\*\*|$)', 
        caseSensitive: true);
      final recommendationsMatch = recommendationsPattern.firstMatch(text);
      if (recommendationsMatch != null) {
        final recommendationsText = recommendationsMatch.group(1) ?? '';
        // Find all bullet points starting with 🌾
        final bulletPoints = RegExp(r'🌾\s*([^\n]+)').allMatches(recommendationsText);
        result['recommendations'] = bulletPoints.map((m) => m.group(1)?.trim() ?? '').toList();
      }
      
      // Extract conclusion/yield analysis
      final conclusionPatterns = [
        RegExp(r'\*\*(?:Conclusive Analysis|Conclusion|Yield Analysis):\*\*\s*\n([\s\S]*?)(?=\*\*.*?\*\*|$)', caseSensitive: true),
        RegExp(r'\*\*(?:Predicted Yield Analysis):\*\*\s*\n([\s\S]*?)(?=\*\*.*?\*\*|$)', caseSensitive: true)
      ];
      
      for (var pattern in conclusionPatterns) {
        final match = pattern.firstMatch(text);
        if (match != null && match.group(1) != null) {
          result['conclusion'] = match.group(1)!.trim();
          break;
        }
      }
      
      // If conclusion not found using patterns, try to find the last section
      if (result['conclusion'].isEmpty) {
        final sections = text.split(RegExp(r'\*\*.*?\*\*\s*\n'));
        if (sections.length > 1) {
          result['conclusion'] = sections.last.trim();
        }
      }
      
    } catch (e) {
      print('Error parsing advice: $e');
    }
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5F0E7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF5F8F58)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Column(
        children: [
          // Title Section
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _title,
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 32,
                  color: Colors.black87,
                  letterSpacing: 1.2
                ),
              ),
            ),
          ),
          
          // Main Content with curved white background
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF5F8F58),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Prediction Summary Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F7ED),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.shield_outlined,
                                    color: const Color(0xFF5F8F58),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'PREDICTION SUMMARY',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      letterSpacing: 1.2
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Divider(thickness: 1, color: Colors.black12),
                              const SizedBox(height: 4),
                              _buildSummaryItem('Country/Area', widget.area),
                              _buildSummaryItem('Crop Type', widget.item),
                              _buildSummaryItem('Year', widget.year),
                              _buildSummaryItem('Rainfall', '${widget.rainfall} mm/year'),
                              _buildSummaryItem('Pesticides', '${widget.pesticides} tonnes'),
                              _buildSummaryItem('Temperature', '${widget.temperature} °C'),
                              _buildSummaryItem('Predicted Yield', '${widget.predictedYield} hg/ha', highlight: true),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                                                
                        
                        
                        // Description section
                        if (_description.isNotEmpty) 
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Text(
                              _description,
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                height: 1.6,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        

                        
                        // Challenges section
                        if (_challenges.isNotEmpty) ...[
                          Row(
                            children: [
                              Text(
                                'CHALLENGES',
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5F8F58),
                                  letterSpacing: 1.2
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: const Color(0xFF5F8F58),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(
                            _challenges.length,
                            (index) => _buildListItem(_challenges[index]),
                          ),
                          const SizedBox(height: 20),
                        ],
                        
                        // Recommendations section
                        if (_recommendations.isNotEmpty) ...[
                          Row(
                            children: [
                              Text(
                                'RECOMMENDATIONS',
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5F8F58),
                                  letterSpacing: 1.2
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: const Color(0xFF5F8F58),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(
                            _recommendations.length,
                            (index) => _buildListItem(_recommendations[index]),
                          ),
                          const SizedBox(height: 20),
                        ],
                        
                        // Conclusion section
                        if (_conclusion.isNotEmpty) ...[
                          Row(
                            children: [
                              Text(
                                'CONCLUSION',
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5F8F58),
                                  letterSpacing: 1.2
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: const Color(0xFF5F8F58),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _conclusion,
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: ElevatedButton(
            onPressed: () {
              // Save functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5F8F58),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  'SAVE', 
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSummaryItem(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: highlight ? const Color(0xFF5F8F58) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildListItem(String item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "🌾", 
            style: GoogleFonts.dmSans(
              fontSize: 16,
              color: Color(0xFF5F8F58),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}