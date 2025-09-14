import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart' as qr_scanner;
import 'dart:io';
import 'qr_result_screen.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanned = false;
  final TextEditingController _manualController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    cameraController.dispose();
    _manualController.dispose();
    super.dispose();
  }

  // Handle QR code detection
  void _onDetect(BarcodeCapture capture) {
    // Prevent multiple scans
    if (_isScanned) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? qrValue = barcode.rawValue;
      
      if (qrValue != null && qrValue.isNotEmpty) {
        _processQRData(qrValue);
        break;
      }
    }
  }

  // Process QR data and navigate
  void _processQRData(String qrData) {
    setState(() => _isScanned = true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QRResultScreen(qrData: qrData),
      ),
    );
  }

  // Pick image from gallery and scan QR
  Future<void> _pickImageAndScan() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // For now, just show manual entry as fallback
        _showManualEntryDialog();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  // Show manual entry dialog
  void _showManualEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Part ID'),
        content: TextField(
          controller: _manualController,
          decoration: InputDecoration(
            hintText: 'e.g., P-001',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final partId = _manualController.text.trim();
              if (partId.isNotEmpty) {
                Navigator.pop(context);
                _processQRData(partId);
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Camera preview with QR scanner
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          
          // Overlay with scanning frame
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          
          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Text(
              'Position QR code within the frame',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // Action buttons
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Manual entry
                FloatingActionButton(
                  mini: true,
                  heroTag: 'manual',
                  onPressed: _showManualEntryDialog,
                  child: Icon(Icons.keyboard),
                ),
                // Gallery picker
                FloatingActionButton(
                  mini: true,
                  heroTag: 'gallery',
                  onPressed: _pickImageAndScan,
                  child: Icon(Icons.photo_library),
                ),
                // Flash toggle
                FloatingActionButton(
                  mini: true,
                  heroTag: 'flash',
                  onPressed: () => cameraController.toggleTorch(),
                  child: Icon(Icons.flash_on),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}