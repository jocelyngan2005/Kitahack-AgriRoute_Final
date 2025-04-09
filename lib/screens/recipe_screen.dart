import 'package:flutter/material.dart';
import '../services/nutrition_planner_service.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipePage extends StatefulWidget {
  final String foodName;
  final String mealType;
  final ApiService apiService;

  const RecipePage({
    super.key,
    required this.foodName,
    required this.mealType,
    required this.apiService,
  });

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  late Future<String> _recipeFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  void _loadRecipe() {
    setState(() {
      _isLoading = true;
    });
    
    _recipeFuture = widget.apiService
        .suggestRecipe(widget.foodName, widget.mealType)
        .whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
  }

  // Parse recipe text and extract sections
  Map<String, dynamic> _parseRecipe(String rawRecipe) {
    Map<String, dynamic> result = {
      'recipeName': '',
      'description': '',
      'sustainabilityScore': '',
      'calories': '',
      'ingredients': <String>[],
      'instructions': <String>[]
    };
    
    List<String> lines = rawRecipe.split('\n');
    
    // First extract the recipe name
    if (lines.isNotEmpty) {
      result['recipeName'] = lines[0].trim();
    }
    
    // Find section indices
    int ingredientsIndex = -1;
    int instructionsIndex = -1;
    
    for (int i = 0; i < lines.length; i++) {
      String lowercaseLine = lines[i].toLowerCase();
      
      // Detect sustainability score
      if (lowercaseLine.contains("sustainability") || lowercaseLine.contains("sustainable")) {
        result['sustainabilityScore'] = lines[i].trim();
      }
      
      // Detect calories specifically
      if (lowercaseLine.contains("calories per serving") || 
          lowercaseLine.contains("cal/serving") || 
          lowercaseLine.contains("calories:") ||
          (lowercaseLine.contains("calories") && lowercaseLine.contains("serving"))) {
        result['calories'] = lines[i].trim();
      }
      
      // Find ingredients section
      if (lowercaseLine.contains("ingredient") && ingredientsIndex == -1) {
        ingredientsIndex = i;
      }
      
      // Find instructions section
      if ((lowercaseLine.contains("instruction") || 
           lowercaseLine.contains("direction") || 
           lowercaseLine.contains("method")) && instructionsIndex == -1) {
        instructionsIndex = i;
      }
    }
    
    // Extract ingredients
    if (ingredientsIndex != -1) {
      int endIndex = instructionsIndex != -1 ? instructionsIndex : lines.length;
      
      for (int i = ingredientsIndex + 1; i < endIndex; i++) {
        String line = lines[i].trim();
        
        // Skip empty lines, section headers, and calorie/sustainability information
        if (line.isEmpty || 
            line.toLowerCase().contains("ingredient") ||
            line.toLowerCase().contains("calories") || 
            line.toLowerCase().contains("sustainability")) {
          continue;
        }
        
        result['ingredients'].add(line);
      }
    }
    
    // Extract instructions
    if (instructionsIndex != -1) {
      for (int i = instructionsIndex + 1; i < lines.length; i++) {
        String line = lines[i].trim();
        
        // Skip empty lines, section headers, and other metadata
        if (line.isEmpty || 
            line.toLowerCase().contains("ingredient") ||
            line.toLowerCase().contains("instruction") ||
            line.toLowerCase().contains("direction") ||
            line.toLowerCase().contains("calories") || 
            line.toLowerCase().contains("sustainability")) {
          continue;
        }
        
        result['instructions'].add(line);
      }
    }
    
    // Extract description (text between recipe name and first section)
    int firstSectionIndex = lines.length;
    for (int i = 1; i < lines.length; i++) {
      String lowercaseLine = lines[i].toLowerCase();
      if (lowercaseLine.contains("ingredient") || 
          lowercaseLine.contains("instruction") || 
          lowercaseLine.contains("direction") ||
          lowercaseLine.contains("sustainable") ||
          lowercaseLine.contains("calories")) {
        firstSectionIndex = i;
        break;
      }
    }
    
    if (firstSectionIndex > 1) {
      List<String> descriptionLines = [];
      for (int i = 1; i < firstSectionIndex; i++) {
        String line = lines[i].trim();
        if (line.isNotEmpty) {
          descriptionLines.add(line);
        }
      }
      result['description'] = descriptionLines.join('\n');
    }
    
    return result;
  }

  // Process text to bold words between asterisks
  Widget _formatText(String text) {
    // Process text to bold words between asterisks
    List<InlineSpan> spans = [];
    
    // Split by double asterisks
    List<String> parts = text.split('**');
    
    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        // Regular text
        spans.add(TextSpan(
          text: parts[i],
          style: GoogleFonts.dmSans(fontSize: 16, height: 1.5),
        ));
      } else {
        // Bolded text (text between asterisks)
        spans.add(TextSpan(
          text: parts[i],
          style: GoogleFonts.dmSans(
            fontSize: 16, 
            height: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ));
      }
    }
    
    return RichText(text: TextSpan(children: spans, style: GoogleFonts.dmSans(color: Colors.black)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF5f8f58)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.mealType.toUpperCase(),
          style: GoogleFonts.dmSans(
            color: Color(0xFF5f8f58),
            fontWeight: FontWeight.w500,
            fontSize: 18,
            letterSpacing: 1.8
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF5f8f58)),
            onPressed: _isLoading ? null : _loadRecipe,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE5F0E7),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5f8f58)))
          : FutureBuilder<String>(
              future: _recipeFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadRecipe,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5f8f58),
                          ),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text('No recipe available'));
                }

                final recipe = snapshot.data!;
                final parsedRecipe = _parseRecipe(recipe);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food name header outside the card
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: Text(
                        parsedRecipe['recipeName'],
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 28,
                          letterSpacing: 1.4
                        ),
                      ),
                    ),
                    
                    // Card with curved top and shadow containing all other content
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
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Full recipe name
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                
                              ),
                              
                              // Description section
                              if (parsedRecipe['description'].isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "DESCRIPTION",
                                        style: GoogleFonts.dmSerifDisplay(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF5F8F58),
                                          letterSpacing: 1.2,          
                                        ),
                                      ),
                                      const Divider(color: Color(0xFF5f8f58), thickness: 1),
                                      _formatText(parsedRecipe['description']),
                                    ],
                                  ),
                                ),
                              
                              // Sustainability and calories
                              if (parsedRecipe['sustainabilityScore'].isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "INFO",
                                        style: TextStyle(
                                          color: Color(0xFF5f8f58),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Divider(color: Color(0xFF5f8f58), thickness: 1),
                                      _formatText(parsedRecipe['sustainabilityScore']),
                                      if (parsedRecipe['calories'].isNotEmpty)
                                        _formatText(parsedRecipe['calories']),
                                    ],
                                  ),
                                ),
                              
                              // Ingredients section
                              if (parsedRecipe['ingredients'].isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "INGREDIENTS",
                                        style: TextStyle(
                                          color: Color(0xFF5f8f58),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Divider(color: Color(0xFF5f8f58), thickness: 1),
                                      const SizedBox(height: 10),
                                      ...parsedRecipe['ingredients'].map<Widget>((ingredient) {
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(width: 8),
                                              Expanded(child: _formatText(ingredient)),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              
                              // Instructions section
                              if (parsedRecipe['instructions'].isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "INSTRUCTIONS",
                                        style: TextStyle(
                                          color: Color(0xFF5f8f58),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Divider(color: Color(0xFF5f8f58), thickness: 1),
                                      const SizedBox(height: 10),
                                      ...parsedRecipe['instructions'].map<Widget>((instruction) {
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(width: 8),
                                              Expanded(child: _formatText(instruction)),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              
                              // Save button
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Implement save functionality
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Recipe saved!'))
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5f8f58),
                                    minimumSize: const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.save_alt, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        'SAVE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}