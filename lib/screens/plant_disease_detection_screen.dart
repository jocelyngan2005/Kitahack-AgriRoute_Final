import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/plant_disease_detection_service.dart';
import '../services/pest_detection_service.dart';
import 'disease_info_screen.dart';
import 'pest_info_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class PlantDiseaseDetectionScreen extends StatefulWidget {
  @override
  _PlantDiseaseDetectionScreenState createState() => _PlantDiseaseDetectionScreenState();
}

class _PlantDiseaseDetectionScreenState extends State<PlantDiseaseDetectionScreen> {
  final PlantDiseaseService _diseaseService = PlantDiseaseService();
  final ImagePicker _picker = ImagePicker();
  final String geminiApiKey = "AIzaSyB_haRU_xiO1kHVeL4_U1YuGElZAOMGv8s"; // Replace with your actual API key
  
  XFile? _imageFile;
  bool _isLoading = false;
  bool _isLoadingAdvice = false;
  bool _isModelLoaded = false;
  PlantDiseaseResult? _result;
  PestDetectionResult? _pestResult;
  bool _isPestDetectionMode = false;
  String _pestAdvice = "";
  
  @override
  void initState() {
    super.initState();
    _loadModel();
  }
  
  Future<void> _loadModel() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _diseaseService.loadModel();
      setState(() {
        _isModelLoaded = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load disease detection model')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      _takePicture();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera permission is required')),
      );
    }
  }
  
  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxHeight: 1080,
        maxWidth: 1080,
        imageQuality: 85,
      );
      
      if (photo != null) {
        setState(() {
          _imageFile = photo;
          _result = null; // Clear previous result
          _pestResult = null; // Clear previous pest result
        });
        if (_isPestDetectionMode) {
          _detectPest(photo);
        } else {
          _detectDisease(photo);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to take picture: $e')),
      );
    }
  }
  
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 1080,
        maxWidth: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _imageFile = image;
          _result = null; // Clear previous result
          _pestResult = null; // Clear previous pest result
        });
        if (_isPestDetectionMode) {
          _detectPest(image);
        } else {
          _detectDisease(image);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }
  
  Future<void> _detectDisease(XFile imageFile) async {
    if (!_isModelLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Model is not loaded yet, please wait')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await _diseaseService.detectDisease(imageFile);
      setState(() {
        _result = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to detect disease: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _detectPest(XFile imageFile) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // This would use your PestDetectionService
      final result = await PestDetectionService.analyzeImage(File(imageFile.path));
      setState(() {
        // Create a PestDetectionResult from the service response
        _pestResult = PestDetectionResult(
          pest: result['diagnosis'],
        );
      });
      
      // Get advice for detected pest
      await _getGeminiAdvice(_pestResult!.pest);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to detect pest: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _getGeminiAdvice(String detectedIssue) async {
    setState(() {
      _isLoadingAdvice = true;
    });
    
    final url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=$geminiApiKey";

    final requestPayload = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": """Provide expert farming advice for the following detected pest: $detectedIssue.
              
    Format your response with these clear section headers and ensure no words are bolded:

    Pest Name: (Include only the name of the pest without including the name of target plants and attach name of family in brackets if applicable)

    Description:
    (Provide a paragraph describing the pest)

    Causes:
    - (List each cause as a bullet point)
    - (Another cause)

    Symptoms:
    - (List each visible symptom as a bullet point)
    - (Another symptom)

    Treatment:
    - (List each treatment method as a bullet point)
    - (Another treatment)

    Prevention:
    - (List each prevention method as a bullet point)
    - (Another prevention method)"""
            }
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestPayload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final adviceText = data["candidates"][0]["content"]["parts"][0]["text"] ?? "No advice available.";
        
        setState(() {
          _pestAdvice = adviceText;
          
          // Update the pest result with more detailed information from the API
          if (_pestResult != null) {
            // Parse the advice text to extract structured information
            final lines = adviceText.split('\n');
            String description = "", currentSection = "", pestName = "";
            List<String> causes = [], symptoms = [], treatment = [], prevention = [];
              
            // Process multi-line sections
            for (int i = 0; i < lines.length; i++) {
              String line = lines[i].trim();
              
              // Skip empty lines
              if (line.isEmpty) continue;

              // Detect pest name
              if (line.toLowerCase().contains("pest name:")) {
                // Extract the pest name
                pestName = line.replaceAll(RegExp(r'pest name:?', caseSensitive: false), '').trim();
                continue; // Skip to next line
              }
              
              // Detect section headers
              if (line.toLowerCase().contains("description:")) {
                currentSection = "description";
                // Remove the header text
                line = line.replaceAll(RegExp(r'description:?', caseSensitive: false), '').trim();
              } else if (line.toLowerCase().contains("causes:")) {
                currentSection = "causes";
                // Remove the header text
                line = line.replaceAll(RegExp(r'causes:?', caseSensitive: false), '').trim();
                continue; // Skip to next line to begin collecting bullet points
              } else if (line.toLowerCase().contains("symptoms:")) {
                currentSection = "symptoms";
                // Remove the header text
                line = line.replaceAll(RegExp(r'symptoms:?', caseSensitive: false), '').trim();
                continue; // Skip to next line to begin collecting bullet points
              } else if (line.toLowerCase().contains("treatment:")) {
                currentSection = "treatment";
                // Remove the header text
                line = line.replaceAll(RegExp(r'treatment:?', caseSensitive: false), '').trim();
                continue; // Skip to next line to begin collecting bullet points
              } else if (line.toLowerCase().contains("prevention:")) {
                currentSection = "prevention";
                // Remove the header text
                line = line.replaceAll(RegExp(r'prevention:?', caseSensitive: false), '').trim();
                continue; // Skip to next line to begin collecting bullet points
              }
              
              // Add content to the current section
              if (currentSection == "description") {
                if (description.isNotEmpty) description += " "; // Add space between lines
                description += line;
              } else if (currentSection == "causes" && line.isNotEmpty) {
                // Handle bullet points or regular text lines
                if (line.startsWith('•') || line.startsWith('-')) {
                  causes.add(line.substring(1).trim());
                } else {
                  causes.add(line);
                }
              } else if (currentSection == "symptoms" && line.isNotEmpty) {
                if (line.startsWith('•') || line.startsWith('-')) {
                  symptoms.add(line.substring(1).trim());
                } else {
                  symptoms.add(line);
                }
              } else if (currentSection == "treatment" && line.isNotEmpty) {
                if (line.startsWith('•') || line.startsWith('-')) {
                  treatment.add(line.substring(1).trim());
                } else {
                  treatment.add(line);
                }
              } else if (currentSection == "prevention" && line.isNotEmpty) {
                if (line.startsWith('•') || line.startsWith('-')) {
                  prevention.add(line.substring(1).trim());
                } else {
                  prevention.add(line);
                }
              }
            }

          

            // Update the pest result with more detailed information
            _pestResult = PestDetectionResult(
              pest: pestName,
              description: description,
              causes: causes,
              symptoms: symptoms,
              treatment: treatment,
              prevention: prevention,
            );
          }
        });
      } else {
        setState(() {
          _pestAdvice = "Error fetching advice: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _pestAdvice = "Error fetching advice: $e";
      });
    } finally {
      setState(() {
        _isLoadingAdvice = false;
      });
    }
  }
  
  void _navigateToDiseaseInfoScreen() {
    if (_result != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DiseaseInfoScreen(
            disease: _result!.disease,
            confidence: _result!.confidence,
            description: _result!.description,
            causes: _result!.causes,
            symptoms: _result!.symptoms,
            treatment: _result!.treatment,
            prevention: _result!.prevention,
            imagePath: _imageFile?.path,
          ),
        ),
      );
    }
  }
  
  void _navigateToPestInfoScreen() {
    if (_pestResult != null && _imageFile != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PestInfoScreen(
            pest: _pestResult!.pest,
            description: _pestResult!.description,
            causes: _pestResult!.causes,
            symptoms: _pestResult!.symptoms,
            treatment: _pestResult!.treatment,
            prevention: _pestResult!.prevention,
            imagePath: _imageFile!.path,
            advice: _pestAdvice,
          ),
        ),
      );
    }
  }
  
  void _navigateBack() {
    Navigator.of(context).pop();
  }
  
  void _toggleDetectionMode(bool value) {
    setState(() {
      _isPestDetectionMode = value;
      // Reset results when switching modes
      _result = null;
      _pestResult = null;
      _imageFile = null;
      _pestAdvice = "";
    });
  }
  
  // Build method for plant disease detection UI
  Widget _buildPlantDiseaseUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and instructions
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plant Disease Detection',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 32,
                  color: Colors.black,
                  letterSpacing: 1.2
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Take or upload a clear photo of a plant leaf to identify possible diseases.',
                style: GoogleFonts.dmSans(fontSize: 14),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
      
        // Horizontal line
        Container(
          height: 1,
          color: Color(0xFF5F8F58),
          margin: EdgeInsets.symmetric(vertical: 16),
        ),
      
        // Image selection buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _checkCameraPermission,
                icon: Icon(
                  Icons.camera_alt,
                  color: Color(0xFF3D7238),
                  size: 15,
                ),
                label: Text(
                  'TAKE PHOTO',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Color(0xFF5F8F58)
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickImage,
                icon: Icon(
                  Icons.photo_library,
                  color: Color(0xFF3D7238),
                  size: 15,
                ),
                label: Text(
                  'GALLERY',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Color(0xFF5F8F58)
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        // Image preview area (gray placeholder or actual image)
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _imageFile != null ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_imageFile!.path),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ) : Center(
              child: _isLoading ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF5F8F58),
                  ),
                  SizedBox(height: 16),
                  Text(_isModelLoaded 
                    ? 'Analyzing image...' 
                    : 'Loading detection model...'
                  ),
                ],
              ) : null,
            ),
          ),
        ),
        SizedBox(height: 16),
      
        // Results section (white card)
        if (_result != null)
          InkWell(
            onTap: _navigateToDiseaseInfoScreen,
            child: Card(
              color: Colors.white,
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.health_and_safety,
                              color: Color(0xFF5F8F58),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'DIAGNOSIS RESULT',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                wordSpacing: 1.1
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Color(0xFF5F8F58),
                        ),
                      ],
                    ),
                    Divider(color: Color(0xFF5F8F58)),
                    SizedBox(height: 8),
                    
                    // Disease name and confidence
                    Text(
                      'DETECTED DISEASE:',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        letterSpacing: 1.1
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _result!.disease,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 40,
                        color: Color(0xFF5F8F58),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'CONFIDENCE: ${(_result!.confidence).toStringAsFixed(1)}%',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Build method for pest detection UI
  Widget _buildPestDetectionUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and instructions
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pest Detection',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 32,
                  color: Colors.black,
                  letterSpacing: 1.2
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Take or upload a clear photo of pests or infested plants for identification.',
                style: GoogleFonts.dmSans(fontSize: 14),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
      
        // Horizontal line
        Container(
          height: 1,
          color: Color(0xFF5F8F58),
          margin: EdgeInsets.symmetric(vertical: 16),
        ),
      
        // Image selection buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _checkCameraPermission,
                icon: Icon(
                  Icons.camera_alt,
                  color: Color(0xFF3D7238),
                  size: 15,
                ),
                label: Text(
                  'TAKE PHOTO',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Color(0xFF5F8F58)
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickImage,
                icon: Icon(
                  Icons.photo_library,
                  color: Color(0xFF3D7238),
                  size: 15,
                ),
                label: Text(
                  'GALLERY',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Color(0xFF5F8F58)
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        // Image preview area (gray placeholder or actual image)
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _imageFile != null ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_imageFile!.path),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ) : Center(
              child: _isLoading ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF5F8F58),
                  ),
                  SizedBox(height: 16),
                  Text(_isLoadingAdvice 
                    ? 'Fetching expert advice...' 
                    : 'Analyzing image...'
                  ),
                ],
              ) : null,
            ),
          ),
        ),
        SizedBox(height: 16),
      
        // Results section (white card)
        if (_pestResult != null)
          InkWell(
            onTap: _navigateToPestInfoScreen,
            child: Card(
              color: Colors.white,
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.bug_report,
                              color: Color(0xFF5F8F58),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'PEST DETECTION RESULT',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                wordSpacing: 1.1
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Color(0xFF5F8F58),
                        ),
                      ],
                    ),
                    Divider(color: Color(0xFF5F8F58)),
                    SizedBox(height: 8),
                    
                    // Pest name and confidence
                    Text(
                      'DETECTED PEST:',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        letterSpacing: 1.1
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _pestResult!.pest,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 25,
                        color: Color(0xFF5F8F58),
                      ),
                    ),
                    SizedBox(height: 8),
                    
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
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
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top navigation bar with back arrow and toggle switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back arrow button
                    InkWell(
                      onTap: _navigateBack,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Color(0xFF5F8F58),
                          size: 24,
                        ),
                      ),
                    ),
                    
                    // Custom toggle switch
                    Container(
                      height: 40,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Color(0xFFB5D0B2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          // Background track
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            width: 80,
                            height: 32,
                          ),
                          
                          // Sliding indicator
                          AnimatedPositioned(
                            duration: Duration(milliseconds: 300),
                            left: _isPestDetectionMode ? 40 : 0,
                            child: GestureDetector(
                              onHorizontalDragEnd: (details) {
                                if (details.primaryVelocity! < 0) {
                                  // Swiped left to right
                                  _toggleDetectionMode(true);
                                } else {
                                  // Swiped right to left
                                  _toggleDetectionMode(false);
                                }
                              },
                              child: Container(
                                width: 40,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          
                          // Icons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Shield icon (disease detection)
                              GestureDetector(
                                onTap: () => _toggleDetectionMode(false),
                                child: Container(
                                  width: 40,
                                  height: 32,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.shield_outlined,
                                    color: _isPestDetectionMode ? Colors.white : Color(0xFF5F8F58),
                                    size: 20,
                                  ),
                                ),
                              ),
                              
                              // Bug icon (pest detection)
                              GestureDetector(
                                onTap: () => _toggleDetectionMode(true),
                                child: Container(
                                  width: 40,
                                  height: 32,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.bug_report,
                                    color: _isPestDetectionMode ? Color(0xFF5F8F58) : Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                // Content based on selected mode
                Expanded(
                  child: _isPestDetectionMode ? _buildPestDetectionUI() : _buildPlantDiseaseUI(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _diseaseService.dispose();
    super.dispose();
  }
}

// Add this class for pest detection results


