import 'package:flutter/material.dart';
import '../services/blockchain_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

class ProductHistoryScreen extends StatefulWidget {
  @override
  _ProductHistoryScreenState createState() => _ProductHistoryScreenState();
}

class _ProductHistoryScreenState extends State<ProductHistoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _blockchainService = BlockchainService();

  String _productId = '';
  List<dynamic> _productHistory = [];
  bool _isLoading = false;

  void _fetchProductHistory() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
        _productHistory = [];
      });

      try {
        final history = await _blockchainService.getProductHistory(_productId);
        
        setState(() {
          _productHistory = history;
          _isLoading = false;
        });

        if (_productHistory.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No history found for this product.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildHistoryItem(dynamic block) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timestamp: ${DateTime.parse(block['timestamp']).toLocal()}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Type: ${block['data']['type']}'),
            if (block['data']['type'] == 'PRODUCT_REGISTRATION') ...[
              Text('Product Name: ${block['data']['name']}'),
              Text('Producer: ${block['data']['producerName']}'),
              Text('Location: ${block['data']['location'] ?? 'N/A'}'),
            ],
            if (block['data']['type'] == 'PRODUCT_HANDOFF') ...[
              Text('From: ${block['data']['senderId']}'),
              Text('To: ${block['data']['receiverId']}'),
              Text('Location: ${block['data']['location'] ?? 'N/A'}'),
              Text('Notes: ${block['data']['notes'] ?? 'N/A'}'),
            ],
            SizedBox(height: 8),
            Text(
              'Block Hash: ${block['hash']}',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
  
  void _generateQrCode() {
  if (_productHistory.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No product history to generate QR code from.'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }
  
  // Start with very basic information to avoid serialization issues
  String qrData = "Product ID: $_productId\n";
  qrData += "Supply Chain Events: ${_productHistory.length}\n";
  
  // Manually add simple text data instead of trying to JSON encode everything
  try {
    for (var block in _productHistory) {
      qrData += "\n- ${block['data']['type']} (${DateTime.parse(block['timestamp']).toLocal()})\n";
      
      if (block['data']['type'] == 'PRODUCT_REGISTRATION') {
        qrData += "  Name: ${block['data']['name']}\n";
        qrData += "  Producer: ${block['data']['producerName']}\n";
      } else if (block['data']['type'] == 'PRODUCT_HANDOFF') {
        qrData += "  From: ${block['data']['senderId']}\n";
        qrData += "  To: ${block['data']['receiverId']}\n";
      }
    }
  } catch (e) {
    print("Error generating QR data: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error generating QR data: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  
  // Make the dialog scrollable and sized appropriately
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Product Supply Chain QR Code', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text('Product ID: $_productId', 
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Product ID',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: _fetchProductHistory,
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter Product ID' : null,
                onSaved: (value) => _productId = value!,
              ),
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      if (_productHistory.isNotEmpty)
                        ElevatedButton.icon(
                          icon: Icon(Icons.qr_code),
                          label: Text('Generate Supply Chain QR Code'),
                          onPressed: _generateQrCode,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      SizedBox(height: 16),
                      Expanded(
                        child: _productHistory.isNotEmpty
                            ? ListView.builder(
                                itemCount: _productHistory.length,
                                itemBuilder: (context, index) {
                                  return _buildHistoryItem(_productHistory[index]);
                                },
                              )
                            : Center(
                                child: Text(
                                  'Enter a Product ID to view its history',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}