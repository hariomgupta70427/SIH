import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'models/part_model.dart';
import 'models/scan_history_model.dart';
import 'services/firebase_service.dart';
import 'qr_result_screen.dart';

class QRScannerScreen extends StatefulWidget {
  final String inspectorId;
  
  const QRScannerScreen({Key? key, required this.inspectorId}) : super(key: key);
  
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isProcessing = false;
  final TextEditingController _manualController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Scanner', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue[600]!, Colors.blue[800]!]),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Scanner Icon
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.blue[100]!, Colors.blue[200]!]),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)],
                  ),
                  child: Icon(Icons.qr_code_scanner, size: 100, color: Colors.blue[600]),
                ),
                
                SizedBox(height: 32),
                
                Text(
                  'QR Code Scanner',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                ),
                
                SizedBox(height: 16),
                
                Text(
                  kIsWeb 
                    ? 'Camera scanning not available on web.\nUse manual entry below.'
                    : 'Camera scanning available on mobile devices.\nUse manual entry as alternative.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                
                SizedBox(height: 40),
                
                // Manual Entry Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(colors: [Colors.white, Colors.grey[50]!]),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue[600], size: 24),
                            SizedBox(width: 12),
                            Text('Manual Entry', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[800])),
                          ],
                        ),
                        
                        SizedBox(height: 20),
                        
                        TextField(
                          controller: _manualController,
                          decoration: InputDecoration(
                            labelText: 'Enter Part ID',
                            hintText: 'e.g., P-001, P-002, P-003',
                            prefixIcon: Icon(Icons.qr_code),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue, width: 2),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 20),
                        
                        Container(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isProcessing ? null : _processManualEntry,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isProcessing
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Processing...', style: TextStyle(fontSize: 16)),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.search, size: 24),
                                      SizedBox(width: 8),
                                      Text('Scan Part', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Sample Part IDs
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.amber[50],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.amber[700]),
                            SizedBox(width: 8),
                            Text('Sample Part IDs', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber[800])),
                          ],
                        ),
                        SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ['P-001', 'P-002', 'P-003'].map((partId) {
                            return GestureDetector(
                              onTap: () {
                                _manualController.text = partId;
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.amber[300]!),
                                ),
                                child: Text(partId, style: TextStyle(fontWeight: FontWeight.w500)),
                              ),
                            );
                          }).toList(),
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
    );
  }

  Future<void> _processManualEntry() async {
    final partId = _manualController.text.trim();
    if (partId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a Part ID')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Fetch part details from Firebase
      final part = await FirebaseService.getPartById(partId);
      
      if (part != null) {
        // Save scan history
        final scanHistory = ScanHistoryModel(
          id: '', // Will be set by Firestore
          inspectorId: widget.inspectorId,
          partId: part.id,
          partName: part.partName,
          vendorName: part.vendorName,
          scannedAt: DateTime.now(),
          status: 'scanned',
        );
        
        await FirebaseService.addScanHistory(scanHistory);
        
        // Navigate to result screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QRResultScreen(
              part: part,
              inspectorId: widget.inspectorId,
            ),
          ),
        );
      } else {
        _showErrorDialog('Invalid Part ID', 'Part ID "$partId" is not recognized in our system.');
      }
    } catch (e) {
      _showErrorDialog('Error', 'Failed to process Part ID: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }
  
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }
}