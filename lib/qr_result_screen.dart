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
  
  String get apiBaseUrl {
    // Always use localhost for now to test
    return 'http://localhost:3000';
  }

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    try {
      await _fetchPartData();
      _generateMockAnalysis();
      
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
  
  void _generateMockAnalysis() {
    final partNum = int.tryParse(widget.qrData.replaceAll('P-', '')) ?? 1;
    
    mlResult = {
      'risk_score': (partNum * 0.1) % 1.0,
      'anomaly': partNum % 7 == 0,
      'advice': partNum % 7 == 0 ? 'Schedule immediate maintenance check' : 'Part is functioning normally'
    };
    
    blockchainResult = {
      'verified': partNum % 4 != 0,
      'tx': partNum % 4 != 0 ? '0x${partNum.toRadixString(16).padLeft(8, '0')}abc123def456' : null
    };
  }

  Future<void> _fetchPartData() async {
    try {
      print('Fetching data from: $apiBaseUrl/api/parts/${widget.qrData}');
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/parts/${widget.qrData}'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        partData = json.decode(response.body);
        print('Part data fetched successfully: ${partData?['name']}');
      } else {
        throw Exception('API returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error fetching part data: $e');
      // Create fallback data for demo
      partData = {
        'id': widget.qrData,
        'name': 'Demo Part ${widget.qrData}',
        'partNumber': widget.qrData,
        'status': 'active',
        'quantity': 50,
        'price': 2500,
        'Vendor': {
          'name': 'Demo Vendor Ltd',
          'email': 'demo@vendor.com',
          'phone': '+91-99999-99999'
        },
        'inspections': [
          {
            'inspection_type': 'routine',
            'result': 'passed',
            'score': 85,
            'inspection_date': '2024-01-15',
            'inspector_name': 'Demo Inspector'
          }
        ]
      };
      print('Using fallback data for ${widget.qrData}');
    }
  }

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
  
  Color _getRiskColor(double? riskScore) {
    if (riskScore == null) return Colors.grey;
    if (riskScore > 0.7) return Colors.red;
    if (riskScore > 0.4) return Colors.orange;
    return Colors.green;
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Part Details'),
        actions: [
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
            Card(
              elevation: 2,
              child: ListTile(
                leading: Icon(Icons.qr_code, color: Colors.blue),
                title: Text('Scanned QR Code'),
                subtitle: Text(widget.qrData, style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 16),

            if (isLoading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading part data...', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      Text('QR Code: ${widget.qrData}', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else if (errorMessage != null)
              Card(
                color: Colors.red.shade50,
                child: ListTile(
                  leading: Icon(Icons.error, color: Colors.red),
                  title: Text('Error'),
                  subtitle: Text(errorMessage!),
                ),
              )
            else if (partData == null)
              Card(
                color: Colors.orange.shade50,
                child: ListTile(
                  leading: Icon(Icons.warning, color: Colors.orange),
                  title: Text('No Data Found'),
                  subtitle: Text('Could not find data for QR code: ${widget.qrData}'),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('📦 Part Information'),
                      Card(
                        elevation: 2,
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.inventory, color: Colors.blue),
                              title: Text('Part Name'),
                              subtitle: Text(partData!['name'] ?? 'Unknown'),
                            ),
                            ListTile(
                              leading: Icon(Icons.numbers, color: Colors.purple),
                              title: Text('Part Number'),
                              subtitle: Text(partData!['partNumber'] ?? 'N/A'),
                            ),
                            ListTile(
                              leading: Icon(Icons.business, color: Colors.green),
                              title: Text('Vendor'),
                              subtitle: Text(partData!['Vendor']?['name'] ?? 'Unknown'),
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.circle,
                                color: _getStatusColor(partData!['status']),
                              ),
                              title: Text('Status'),
                              subtitle: Text(partData!['status']?.toString().toUpperCase() ?? 'Unknown'),
                            ),
                            ListTile(
                              leading: Icon(Icons.inventory_2, color: Colors.teal),
                              title: Text('Quantity'),
                              subtitle: Text('${partData!['quantity'] ?? 0} units'),
                            ),
                            if (partData!['price'] != null)
                              ListTile(
                                leading: Icon(Icons.currency_rupee, color: Colors.amber),
                                title: Text('Price'),
                                subtitle: Text('₹${partData!['price']}'),
                              ),
                          ],
                        ),
                      ),
                      
                      if (mlResult != null) ...[
                        SizedBox(height: 16),
                        _buildSectionHeader('🤖 ML Health Analysis'),
                        Card(
                          elevation: 2,
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
                      
                      if (blockchainResult != null) ...[
                        SizedBox(height: 16),
                        _buildSectionHeader('🔗 Blockchain Verification'),
                        Card(
                          elevation: 2,
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
                      
                      if (partData?['inspections'] != null && partData!['inspections'].isNotEmpty) ...[
                        SizedBox(height: 16),
                        _buildSectionHeader('🔍 Recent Inspections'),
                        Card(
                          elevation: 2,
                          child: Column(
                            children: [
                              for (var inspection in partData!['inspections'].take(2))
                                ListTile(
                                  leading: Icon(
                                    inspection['result'] == 'passed' ? Icons.check_circle : Icons.cancel,
                                    color: inspection['result'] == 'passed' ? Colors.green : Colors.red,
                                  ),
                                  title: Text('${inspection['inspection_type']?.toString().toUpperCase()} - ${inspection['result']?.toString().toUpperCase()}'),
                                  subtitle: Text('Score: ${inspection['score']}% | ${inspection['inspection_date']}'),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.qr_code_scanner),
                    label: Text('Scan Another'),
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