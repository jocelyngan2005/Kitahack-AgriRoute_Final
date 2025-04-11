import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class HobbyistTrackingScreen extends StatefulWidget {
  @override
  _HobbyistTrackingScreenState createState() => _HobbyistTrackingScreenState();
}

class _HobbyistTrackingScreenState extends State<HobbyistTrackingScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanningActive = false;
  File? selectedImage;
  bool isProcessingImage = false;


  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        controller.pauseCamera();
        // Process QR code data to show food route
        _showFoodRouteDialog(scanData.code!);
      }
    });
  }

  void _showFoodRouteDialog(String qrData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Food Route Information'),
        content: Text('QR Code data: $qrData'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (controller != null) {
                controller?.resumeCamera();
              } else {
                setState(() {
                  isScanningActive = false;
                  isProcessingImage = false;
                  selectedImage = null;
                });
              }
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _takePhoto() {
    setState(() {
      isScanningActive = true;
    });
  }

  Future<void> _openGallery() async {
    final ImagePicker picker = ImagePicker();
    
    setState(() {
      isProcessingImage = true;
    });

    try {
      final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedImage != null) {
        setState(() {
          selectedImage = File(pickedImage.path);
        });
        
        // Process the image for QR code
        await _scanQRFromImage(pickedImage.path);
      } else {
        // User canceled the picker
        setState(() {
          isProcessingImage = false;
        });
      }
    } catch (e) {
      setState(() {
        isProcessingImage = false;
      });
      _showErrorDialog('Failed to process image: ${e.toString()}');
    }
  }

  Future<void> _scanQRFromImage(String imagePath) async {
    try {
      // Create a MobileScannerController for processing static images
      final controller = MobileScannerController();
      
      // Process the image
      final result = await controller.analyzeImage(imagePath);
      
      if (result != null && result.barcodes.isNotEmpty) {
        final barcode = result.barcodes.first;
        if (barcode.rawValue != null) {
          _showFoodRouteDialog(barcode.rawValue!);
        } else {
          _showErrorDialog('No QR code data found in the image.');
        }
      } else {
        _showErrorDialog('No QR code found in the image.');
      }
    } catch (e) {
      _showErrorDialog('Error scanning QR code: ${e.toString()}');
    } finally {
      setState(() {
        isProcessingImage = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.green),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Color(0xFFE5F0E7),
        elevation: 0,
      ),
      body: Container(
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
        child: isProcessingImage
            ? _buildProcessingView()
            : isScanningActive
                ? _buildQRScanner()
                : _buildInitialView(),
      ),
    );
  }

  Widget _buildInitialView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Supply Chain Tracker',
            style: GoogleFonts.dmSerifDisplay(
                fontSize: 32, color: Colors.black, letterSpacing: 1.2),
          ),
          SizedBox(height: 16),
          Text(
            'Take or upload a clear photo of a QR code to view the food route',
            style: GoogleFonts.dmSans(fontSize: 14),
          ),
          SizedBox(height: 20),
          Divider(color: Color(0xFF5F8F58)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _takePhoto,
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
                        fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Color(0xFF5F8F58)),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openGallery,
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
                        fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Color(0xFF5F8F58)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQRScanner() {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.green,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 300,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isScanningActive = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: Text('Cancel Scanning'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (selectedImage != null)
            Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  selectedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          SizedBox(height: 24),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5F8F58)),
          ),
          SizedBox(height: 16),
          Text(
            'Scanning QR Code...',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isProcessingImage = false;
                selectedImage = null;
              });
            },
            child: Text('Cancel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}