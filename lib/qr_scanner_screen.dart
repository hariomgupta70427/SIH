import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'qr_result_screen.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanned = false;
  bool _hasPermission = false;
  final TextEditingController _manualController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _hasPermission = status == PermissionStatus.granted;
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    _manualController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
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

  void _processQRData(String qrData) {
    setState(() => _isScanned = true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('QR Code detected: $qrData'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QRResultScreen(qrData: qrData),
      ),
    );
  }

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
      body: _hasPermission ? Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          
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
              ),
            ),
          ),
          
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
          
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: 'manual',
                  onPressed: _showManualEntryDialog,
                  child: Icon(Icons.keyboard),
                ),
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
      ) : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Camera permission required'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await openAppSettings();
              },
              child: Text('Open Settings'),
            ),
            SizedBox(height: 8),
            TextButton(
              onPressed: _showManualEntryDialog,
              child: Text('Enter Part ID Manually'),
            ),
          ],
        ),
      ),
    );
  }
}