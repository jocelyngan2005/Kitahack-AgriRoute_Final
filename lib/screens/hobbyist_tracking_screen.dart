import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

class HobbyistTrackingScreen extends StatefulWidget {
  @override
  _HobbyistTrackingScreenState createState() => _HobbyistTrackingScreenState();
}

class _HobbyistTrackingScreenState extends State<HobbyistTrackingScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanningActive = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

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
        content: Text('QR Code data: $qrData\n\nFetching supply chain details...'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller?.resumeCamera();
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

  void _openGallery() async {
    // Implement gallery image picking and QR scanning
    // This would use image_picker package and then process the image
    // for QR codes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.green),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE9F3E8), Color(0xFFF6F7E7)],
          ),
        ),
        child: isScanningActive 
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
                  fontSize: 32,
                  color: Colors.black,
                  letterSpacing: 1.2
                ),
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
                controller?.dispose();
              },
              child: Text('Cancel Scanning'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
