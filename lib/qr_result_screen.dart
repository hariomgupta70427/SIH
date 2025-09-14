import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class QRResultScreen extends StatefulWidget {
  final String qrData;

  const QRResultScreen({Key? key, required this.qrData}) : super(key: key);

  @override
  _QRResultScreenState createState() => _QRResultScreenState();
}

class _QRResultScreenState extends State<QRResultScreen> {
  Map<String, dynamic>? partData;
  Map<String, dynamic>? mlResult;
  Map<String, dynamic>? blockchainResult;
  bool isLoading = true;
  String? errorMessage;
  
  // API base URL logic
  String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000'; // Android emulator
    }
    return 'http://localhost:3000'; // Web/iOS simulator
  }

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  // Fetch all data from backend, ML, and blockchain APIs
  Future<void> _fetchAllData() async {
    try {
      // Fetch part data from backend
      await _fetchPartData();
      
      // Fetch ML analysis
      await _fetchMLAnalysis();
      
      // Fetch blockchain verification
      await _fetchBlockchainVerification();
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }
  
  Future<void> _fetchPartData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/parts/${widget.qrData}'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        partData = json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching part data: $e');
    }
  }
  
  Future<void> _fetchMLAnalysis() async {
    try {
      final mlUrl = Platform.isAndroid ? 'http://10.0.2.2:5000' : 'http://localhost:5000';
      final response = await http.post(
        Uri.parse('$mlUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'part_id': widget.qrData,
          'inspections': partData?['inspections'] ?? [],
        }),
      );
      
      if (response.statusCode == 200) {
        mlResult = json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching ML analysis: $e');
    }
  }
  
  Future<void> _fetchBlockchainVerification() async {
    try {
      final blockchainUrl = Platform.isAndroid ? 'http://10.0.2.2:6000' : 'http://localhost:6000';
      final response = await http.get(
        Uri.parse('$blockchainUrl/verify/${widget.qrData}'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        blockchainResult = json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching blockchain verification: $e');
    }
  }

  // Get status color based on part status
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      case 'maintenance':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  // Get risk color based on ML risk score
  Color _getRiskColor(double? riskScore) {
    if (riskScore == null) return Colors.grey;
    if (riskScore > 0.7) return Colors.red;
    if (riskScore > 0.4) return Colors.orange;
    return Colors.green;
  }
  
  // Build section header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Part Details'),
        actions: [
          // Scan another QR code
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // QR Data Display
            Card(
              child: ListTile(
                leading: Icon(Icons.qr_code, color: Colors.blue),
                title: Text('Scanned QR Code'),
                subtitle: Text(widget.qrData),
                trailing: IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () {
                    // Copy QR data to clipboard
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('QR data copied to clipboard')),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 16),

            // Loading or Error State
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (errorMessage != null)
              Card(
                color: Colors.red.shade50,
                child: ListTile(
                  leading: Icon(Icons.error, color: Colors.red),
                  title: Text('Error'),
                  subtitle: Text(errorMessage!),
                ),
              )
            else ...[
              // Part Information Section
              if (partData != null) ...[
                _buildSectionHeader('Part Information'),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.inventory, color: Colors.blue),
                        title: Text('Part Name'),
                        subtitle: Text(partData!['name'] ?? 'Unknown'),
                      ),
                      ListTile(
                        leading: Icon(Icons.business, color: Colors.green),
                        title: Text('Vendor'),
                        subtitle: Text(partData!['vendor']?['name'] ?? 'Unknown'),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.circle,
                          color: _getStatusColor(partData!['status']),
                        ),
                        title: Text('Status'),
                        subtitle: Text(partData!['status'] ?? 'Unknown'),
                      ),
                      if (partData!['warranty_months'] != null)
                        ListTile(
                          leading: Icon(Icons.security, color: Colors.orange),
                          title: Text('Warranty'),
                          subtitle: Text('${partData!['warranty_months']} months'),
                        ),
                    ],
                  ),
                ),
              ],
              
              // ML Health Analysis Section
              if (mlResult != null) ...[
                SizedBox(height: 16),
                _buildSectionHeader('ML Health Analysis'),
                Card(
                  color: _getRiskColor(mlResult!['risk_score']).withOpacity(0.1),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          mlResult!['anomaly'] ? Icons.warning : Icons.check_circle,
                          color: mlResult!['anomaly'] ? Colors.red : Colors.green,
                        ),
                        title: Text('Risk Score'),
                        subtitle: Text('${(mlResult!['risk_score'] * 100).toInt()}%'),
                        trailing: Chip(
                          label: Text(
                            mlResult!['anomaly'] ? 'ANOMALY' : 'NORMAL',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: mlResult!['anomaly'] ? Colors.red : Colors.green,
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.lightbulb, color: Colors.amber),
                        title: Text('Recommendation'),
                        subtitle: Text(mlResult!['advice'] ?? 'No recommendations'),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Blockchain Verification Section
              if (blockchainResult != null) ...[
                SizedBox(height: 16),
                _buildSectionHeader('Blockchain Verification'),
                Card(
                  color: blockchainResult!['verified'] 
                      ? Colors.green.withOpacity(0.1) 
                      : Colors.red.withOpacity(0.1),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          blockchainResult!['verified'] ? Icons.verified : Icons.error,
                          color: blockchainResult!['verified'] ? Colors.green : Colors.red,
                        ),
                        title: Text('Verification Status'),
                        subtitle: Text(
                          blockchainResult!['verified'] ? 'VERIFIED' : 'NOT VERIFIED'
                        ),
                        trailing: blockchainResult!['verified']
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : Icon(Icons.cancel, color: Colors.red),
                      ),
                      if (blockchainResult!['tx'] != null)
                        ListTile(
                          leading: Icon(Icons.link, color: Colors.blue),
                          title: Text('Transaction'),
                          subtitle: Text(blockchainResult!['tx']),
                        ),
                    ],
                  ),
                ),
              ],
              
              // Inspection History
              if (partData?['inspections'] != null && partData!['inspections'].isNotEmpty) ...[
                SizedBox(height: 16),
                _buildSectionHeader('Recent Inspections'),
                Card(
                  child: Column(
                    children: [
                      for (var inspection in partData!['inspections'].take(3))
                        ListTile(
                          leading: Icon(
                            inspection['result'] == 'passed' ? Icons.check : Icons.close,
                            color: inspection['result'] == 'passed' ? Colors.green : Colors.red,
                          ),
                          title: Text('${inspection['inspection_type']} - ${inspection['result']}'),
                          subtitle: Text('Score: ${inspection['score']}% - ${inspection['inspection_date']}'),
                        ),
                    ],
                  ),
                ),
              ],
            ],

            Spacer(),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Scan Another'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Navigate to detailed view or perform action
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Feature coming soon')),
                      );
                    },
                    child: Text('View Details'),
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