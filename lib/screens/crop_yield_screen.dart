import 'package:flutter/material.dart';
import '../services/crop_yield_service.dart';
import 'dart:convert';
import '../screens/expert_advice_screen.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';


class CropYieldScreen extends StatefulWidget {
  @override
  _CropYieldScreenState createState() => _CropYieldScreenState();
}

class _CropYieldScreenState extends State<CropYieldScreen> {
  final _formKey = GlobalKey<FormState>();

  // Service for API calls
  final CropYieldService _yieldService = CropYieldService();
  
  // Dropdown lists
  final List<String> _areaList = [
    'Albania', 'Algeria', 'Angola', 'Argentina', 'Armenia',
    'Australia', 'Austria', 'Azerbaijan', 'Bahamas', 'Bahrain',
    'Bangladesh', 'Belarus', 'Belgium', 'Botswana', 'Brazil',
    'Bulgaria', 'Burkina Faso', 'Burundi', 'Cameroon', 'Canada',
    'Central African Republic', 'Chile', 'Colombia', 'Croatia',
    'Denmark', 'Dominican Republic', 'Ecuador', 'Egypt', 'El Salvador',
    'Eritrea', 'Estonia', 'Finland', 'France', 'Germany', 'Ghana',
    'Greece', 'Guatemala', 'Guinea', 'Guyana', 'Haiti', 'Honduras',
    'Hungary', 'India', 'Indonesia', 'Iraq', 'Ireland', 'Italy',
    'Jamaica', 'Japan', 'Kazakhstan', 'Kenya', 'Latvia', 'Lebanon',
    'Lesotho', 'Libya', 'Lithuania', 'Madagascar', 'Malawi',
    'Malaysia', 'Mali', 'Mauritania', 'Mauritius', 'Mexico',
    'Montenegro', 'Morocco', 'Mozambique', 'Namibia', 'Nepal',
    'Netherlands', 'New Zealand', 'Nicaragua', 'Niger', 'Norway',
    'Pakistan', 'Papua New Guinea', 'Peru', 'Poland', 'Portugal',
    'Qatar', 'Romania', 'Rwanda', 'Saudi Arabia', 'Senegal',
    'Slovenia', 'South Africa', 'Spain', 'Sri Lanka', 'Sudan',
    'Suriname', 'Sweden', 'Switzerland', 'Tajikistan', 'Thailand',
    'Tunisia', 'Turkey', 'Uganda', 'Ukraine', 'United Kingdom',
    'Uruguay', 'Zambia', 'Zimbabwe'
  ];

  final List<String> _itemList = [
    'Maize', 'Potatoes', 'Rice, paddy', 'Sorghum', 'Soybeans', 'Wheat',
    'Cassava', 'Sweet potatoes', 'Plantains and others', 'Yams'
  ];

  // Dropdown selected values
  String? _selectedArea;
  String? _selectedItem;
  
  // Other controllers
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _rainfallController = TextEditingController();
  final TextEditingController _pesticideController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();

  // Prediction result and loading state
  double? _predictedYield;
  bool _isLoading = false;
  String? _errorMessage;
  String? _advice = null;

  @override
  void initState() {
    super.initState();
    // Check API health on init
    _checkApiHealth();
  }

  Future<void> _checkApiHealth() async {
    final isHealthy = await _yieldService.checkApiHealth();
    if (!isHealthy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backend service is unavailable'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _predictCropYield() async {
    // Validate inputs
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Set loading state
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _predictedYield = null;
      _advice = null;
    });

    try {
      // Call prediction service
      final prediction = await _yieldService.predictCropYield(
        area: _selectedArea!,
        item: _selectedItem!,
        year: int.parse(_yearController.text),
        rainfall: double.parse(_rainfallController.text),
        pesticides: double.parse(_pesticideController.text),
        avgTemp: double.parse(_temperatureController.text),
      );

      // Generate advice in background
      _getGeminiAdvice(
        area: _selectedArea!,
        item: _selectedItem!,
        year: _yearController.text,
        rainfall: _rainfallController.text,
        pesticides: _pesticideController.text,
        avgTemp: _temperatureController.text,
        predictedYield: prediction.cropYield.toStringAsFixed(2),
      );

      // Update UI with prediction
      setState(() {
        _predictedYield = prediction.cropYield;
        _isLoading = false;
      });

    } catch (e) {
      // Handle errors
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage ?? 'Prediction failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _getGeminiAdvice({
    required String area,
    required String item,
    required String year,
    required String rainfall,
    required String pesticides,
    required String avgTemp,
    required String predictedYield,
  }) async {
    final String geminiApiKey = "AIzaSyB_haRU_xiO1kHVeL4_U1YuGElZAOMGv8s";
    final url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=$geminiApiKey";

    final requestPayload = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": "Provide expert farming advice for the following inputs:\nArea: $area\nCrop: $item\nYear: $year\nAverage Rainfall: $rainfall mm/year\nPesticides: $pesticides tonnes\nAverage Temperature: $avgTemp °C\nPredicted Yield: $predictedYield hg/ha"}
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
        setState(() {
          _advice = data["candidates"][0]["content"]["parts"][0]["text"] ?? "No advice available.";
        });
      } else {
        setState(() {
          _advice = "Error fetching advice: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _advice = "Error fetching advice.";
      });
    }
  }

  void _navigateToAdviceScreen() {
    if (_predictedYield != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExpertAdviceScreen(
            area: _selectedArea ?? '',
            item: _selectedItem ?? '',
            year: _yearController.text,
            rainfall: _rainfallController.text,
            pesticides: _pesticideController.text,
            temperature: _temperatureController.text,
            predictedYield: _predictedYield?.toStringAsFixed(2) ?? '',
            advice: _advice,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE5F0E7), // top
            Color(0xFFEDF2E5), // middle
            Color.fromARGB(255, 246, 246, 226) // bottom
          ],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF5F8F58)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          
          backgroundColor: const Color(0xFFF2F7ED),
          elevation: 0,
        ),
        body: Container(
          color: const Color(0xFFF2F7ED),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Crop Yield Prediction', 
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 32, 
                        letterSpacing: 1.2
                      )
                    ),
                    Text(
                      'Fill in the required information to predict crop yield!',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFF5F8F58), thickness: 1),
                    const SizedBox(height: 16),
                    
                    // Area Dropdown
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'COUNTRY / AREA',
                          labelStyle: GoogleFonts.dmSans(
                            color: Colors.grey,
                            fontSize: 14,
                            letterSpacing: 1.2
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        value: _selectedArea,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: _areaList.map((area) => DropdownMenuItem(
                          value: area,
                          child: Text(
                            area,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedArea = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a country';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Item Dropdown
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'CROP TYPE',
                          labelStyle: GoogleFonts.dmSans(
                            color: Colors.grey,
                            fontSize: 14,
                            letterSpacing: 1.2
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        value: _selectedItem,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: _itemList.map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedItem = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a crop type';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Year and Pesticides Row
                    Row(
                      children: [
                        // Year Input
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: TextFormField(
                              controller: _yearController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'YEAR',
                                labelStyle: GoogleFonts.dmSans(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  letterSpacing: 1.2
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                int? year = int.tryParse(value);
                                if (year == null || year < 2000 || year > DateTime.now().year) {
                                  return 'Invalid year';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Pesticide Input
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: TextFormField(
                              controller: _pesticideController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'PESTICIDES (TONNES)',
                                labelStyle: GoogleFonts.dmSans(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  letterSpacing: 1.2
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Rainfall Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextFormField(
                        controller: _rainfallController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'AVERAGE RAINFALL (MM / YEAR)',
                          labelStyle: GoogleFonts.dmSans(
                            color: Colors.grey,
                            fontSize: 14,
                            letterSpacing: 1.2
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter average rainfall';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Temperature Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextFormField(
                        controller: _temperatureController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'AVERAGE TEMPERATURE (°C)',
                          labelStyle: GoogleFonts.dmSans(
                            color: Colors.grey,
                            fontSize: 14,
                            letterSpacing: 1.2
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter average temperature';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Prediction Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _predictCropYield,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5F8F58),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.white))
                          : Text(
                              'PREDICT CROP YIELD',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Results Display
                    if (_predictedYield != null)
                      InkWell(
                        onTap: _navigateToAdviceScreen,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: const Color(0xFF5F8F58),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'PREDICTION RESULT',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      wordSpacing: 1.1
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF5F8F58),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Divider(color: Color(0xFF5F8F58),),
                              const SizedBox(height: 4),
                              Text(
                                'PREDICTED YIELD:',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  letterSpacing: 1.1
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_predictedYield!.toStringAsFixed(2)} hg/ha',
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 32,
                                  color: Color(0xFF5F8F58),
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
        ),
      ),
    );
  }
}