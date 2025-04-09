import 'package:flutter/material.dart';
import '../services/farming_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _regionController = TextEditingController();
  final _cropController = TextEditingController();
  final _climateController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final FarmingService _farmingService = FarmingService();
  bool _isLoading = false;
  Map<String, dynamic>? _searchResults;
  bool _hasSearched = false;
  bool _isFullScreen = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _regionController.dispose();
    _cropController.dispose();
    _climateController.dispose();
    super.dispose();
  }
  
  void _scrollListener() {
    if (_scrollController.offset > 100 && !_isFullScreen) {
      setState(() {
        _isFullScreen = true;
      });
    } else if (_scrollController.offset <= 100 && _isFullScreen) {
      setState(() {
        _isFullScreen = false;
      });
    }
  }
  
  Future<bool> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      print("Location permission granted");
      return true;
    } else {
      print("Location permission denied");
      return false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    extendBodyBehindAppBar: true, // This lets the gradient go behind the app bar
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
              Color(0xFFE5F0E7), // top
              Color(0xFFEDF2E5), // middle
              Color.fromARGB(255, 246, 246, 226) // bottom
            ], // Adjust colors as needed
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: EdgeInsets.all(20),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios, 
                  color: Color(0xFF5F8F58),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          SizedBox(height: 20), 
          // Title section - static part
          if (!_isFullScreen)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Climate Farming Advisor',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 32,
                    height: 1.2,
                    letterSpacing: 1.2
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Fill in the required information to obtain personalised farming advice!',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  height: 1,
                  color: Color(0xFF5F8F58),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          
          // Input form section
          if (!_isFullScreen)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Location field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextFormField(
                      controller: _regionController,
                      decoration: InputDecoration(
                        labelText: 'LOCATION',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        prefixIcon: Icon(
                          Icons.location_on, 
                          color: Color(0xFF5F8F58)
                        ),
                        labelStyle: GoogleFonts.dmSans(
                          color: Colors.grey,
                          fontSize: 12,
                          letterSpacing: 1.2
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Crop field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextFormField(
                      controller: _cropController,
                      decoration: InputDecoration(
                        labelText: 'CROP TYPE / NAME',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        prefixIcon: Icon(
                          Icons.grass, 
                          color: Color(0xFF5F8F58)
                        ),
                        labelStyle: GoogleFonts.dmSans(
                          color: Colors.grey,
                          fontSize: 12,
                          letterSpacing: 1.2
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a crop type';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Weather condition field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextFormField(
                      controller: _climateController,
                      decoration: InputDecoration(
                        labelText: 'WEATHER CONDITION (OPTIONAL)',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        prefixIcon: Icon(
                          Icons.cloud, 
                          color: Color(0xFF5F8F58)
                        ),
                        labelStyle: GoogleFonts.dmSans(
                          color: Colors.grey,
                          fontSize: 12,
                          letterSpacing: 1.2
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _searchRecommendations,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF5C8D5B), // Dark green
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'GET FARMING TIPS',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF5C8D5B), // Dark green
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _isLoading ? null : _getCurrentLocationRecommendations,
                          icon: Icon(Icons.my_location, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded result section with scroll effect
          Expanded(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.only(
                top: _isFullScreen ? 0 : 24,
                left: _isFullScreen ? 0 : 24,
                right: _isFullScreen ? 0 : 24,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(_isFullScreen ? 0 : 16),
                  topRight: Radius.circular(_isFullScreen ? 0 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Color(0xFF5C8D5B)))
                : !_hasSearched
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.eco,
                            size: 64,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Enter details to get\nfarming recommendations!',
                            style: GoogleFonts.dmSans(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : _searchResults == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sentiment_dissatisfied,
                              size: 64,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No recommendations found\nfor your search criteria',
                              style: GoogleFonts.dmSans(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : _buildRecommendationsView(),
            ),
          ),
        ],
      ),
      ),
    ),
    );
  }

  Widget _buildRecommendationsView() {
    if (_searchResults == null) return Container();
    
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header information
          Text(
            'Recommendations for ${_searchResults!['crop']} in ${_searchResults!['region']}',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          
          // Climate conditions
          if (_searchResults!.containsKey('climate_conditions') && 
              _searchResults!['climate_conditions'] is List &&
              (_searchResults!['climate_conditions'] as List).isNotEmpty)
            _buildSection(
              title: 'CLIMATE CONDITIONS',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (_searchResults!['climate_conditions'] as List)
                    .map<Widget>((condition) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('⛅ ',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16,
                                  )),
                              Expanded(
                                child: Text(
                                  condition.toString(),
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          
          // Adaptation strategies
          if (_searchResults!.containsKey('adaptation_strategies') && 
              _searchResults!['adaptation_strategies'] is List &&
              (_searchResults!['adaptation_strategies'] as List).isNotEmpty)
            _buildSection(
              title: 'ADAPTATION STRATEGIES',
              content: Column(
                children: (_searchResults!['adaptation_strategies'] as List)
                    .map((strategy) => _buildStrategyCard(strategy))
                    .toList(),
              ),
            ),
          
          // Mitigation strategies
          if (_searchResults!.containsKey('mitigation_strategies') && 
              _searchResults!['mitigation_strategies'] is List &&
              (_searchResults!['mitigation_strategies'] as List).isNotEmpty)
            _buildSection(
              title: 'MITIGATION STRATEGIES',
              content: Column(
                children: (_searchResults!['mitigation_strategies'] as List)
                    .map((strategy) => _buildStrategyCard(strategy))
                    .toList(),
              ),
            ),
          
          // Water management
          if (_searchResults!.containsKey('water_management') && 
              _searchResults!['water_management'] is List &&
              (_searchResults!['water_management'] as List).isNotEmpty)
            _buildSection(
              title: 'WATER MANAGEMENT',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (_searchResults!['water_management'] as List)
                    .map((technique) => Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.water_drop, color: Colors.blue, size: 18),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  technique.toString(),
                                  style: GoogleFonts.dmSans(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          
          // Soil conservation
          if (_searchResults!.containsKey('soil_conservation') && 
              _searchResults!['soil_conservation'] is List &&
              (_searchResults!['soil_conservation'] as List).isNotEmpty)
            _buildSection(
              title: 'SOIL CONSERVATION',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (_searchResults!['soil_conservation'] as List)
                    .map((technique) => Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.landscape, color: Colors.brown, size: 18),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  technique.toString(),
                                  style: GoogleFonts.dmSans(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildSection({required String title, required Widget content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            title,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5F8F58),
              letterSpacing: 1.5
            ),
          ),
        ),
        Divider(
          color: Color(0xFF5F8F58),
          thickness: 1.5,
        ),
        content,
        SizedBox(height: 20),],
    );
  }
  
  Widget _buildStrategyCard(Map<String, dynamic> strategy) {
    return Container(
    margin: EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black26, width: 1),
    ),
    child: Padding(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  strategy['name'] ?? 'Unnamed Strategy',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  // Future implementation to save this technique
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Technique saved to your farming plan')),
                  );
                },
                icon: Icon(Icons.bookmark, color: Color(0xFF5F8F58)),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                splashRadius: 24,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            strategy['description'] ?? '',
            style: GoogleFonts.dmSans(fontSize: 16),
          ),
          SizedBox(height: 16),
          
          // Display benefits if available
          if (strategy.containsKey('benefits') && 
              strategy['benefits'] is List &&
              (strategy['benefits'] as List).isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BENEFITS:',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black54,
                    letterSpacing: 1.3,
                  ),
                ),
                SizedBox(height: 4),
                ...((strategy['benefits'] as List).map((benefit) => Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: GoogleFonts.dmSans(color: Color(0xFF5C8D5B))),
                          Expanded(child: Text(
                            benefit.toString(),
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                            )
                          )),
                        ],
                      ),
                    ))),
              ],
            ),
          
          SizedBox(height: 12),
          
          // Display implementation difficulty and effectiveness if available
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (strategy.containsKey('implementation_difficulty'))
                Chip(
                  label: Text(
                    'Difficulty: ${strategy['implementation_difficulty']}',
                    style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: _getDifficultyColor(strategy['implementation_difficulty']),
                  labelStyle: GoogleFonts.dmSans(color: Colors.white),
                  padding: EdgeInsets.all(5),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              if (strategy.containsKey('effectiveness'))
                Chip(
                  label: Text(
                    'Effectiveness: ${strategy['effectiveness']}',
                    style: GoogleFonts.dmSans(fontSize: 16),
                  ),
                  backgroundColor: _getEffectivenessColor(strategy['effectiveness']),
                  labelStyle: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w600),
                  padding: EdgeInsets.all(5),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
  
  Color _getDifficultyColor(String? difficulty) {
    if (difficulty == null) return Colors.grey;
    
    switch (difficulty.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  Color _getEffectivenessColor(String? effectiveness) {
    if (effectiveness == null) return Colors.grey;
    
    switch (effectiveness.toLowerCase()) {
      case 'low':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  Future<void> _searchRecommendations() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final region = _regionController.text;
        final cropType = _cropController.text;
        final climateChallenge = _climateController.text.isNotEmpty
            ? _climateController.text
            : null;
        
        final results = await _farmingService.getClimateSmartRecommendations(
          location: region,
          cropType: cropType,
          climateChallenge: climateChallenge,
        );
        
        setState(() {
          _searchResults = results;
          _hasSearched = true;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _searchResults = null;
          _hasSearched = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
  
  Future<void> _getCurrentLocationRecommendations() async {
    if (_cropController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a crop type')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Request location permission before proceeding
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        throw Exception("Location permission is required to use this feature");
      }
      
      final cropType = _cropController.text;
      final climateChallenge = _climateController.text.isNotEmpty
          ? _climateController.text
          : null;
      
      final results = await _farmingService.getRecommendationsForCurrentLocation(
        cropType: cropType,
        climateChallenge: climateChallenge,
      );
      
      setState(() {
        _searchResults = results;
        _hasSearched = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = null;
        _hasSearched = true;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}