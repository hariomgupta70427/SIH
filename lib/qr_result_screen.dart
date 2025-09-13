import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QRResultScreen extends StatefulWidget {
  final String qrData;

  const QRResultScreen({Key? key, required this.qrData}) : super(key: key);

  @override
  _QRResultScreenState createState() => _QRResultScreenState();
}

class _QRResultScreenState extends State<QRResultScreen> {
  Map<String, dynamic>? partMetadata;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPartMetadata();
  }

  // Fetch part metadata from backend API
  Future<void> _fetchPartMetadata() async {
    try {
      // Replace with your actual API endpoint
      final response = await http.get(
        Uri.parse('https://your-api.com/parts/${widget.qrData}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer your-token', // Add if needed
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          partMetadata = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch part data: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
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
            else if (partMetadata != null) ...[
              // Part Metadata Display
              Text(
                'Part Information',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 12),

              // Part Name
              ListTile(
                leading: Icon(Icons.inventory, color: Colors.blue),
                title: Text('Part Name'),
                subtitle: Text(partMetadata!['name'] ?? 'Unknown'),
              ),

              // Vendor Information
              ListTile(
                leading: Icon(Icons.business, color: Colors.green),
                title: Text('Vendor'),
                subtitle: Text(partMetadata!['vendor'] ?? 'Unknown'),
              ),

              // Status with colored indicator
              ListTile(
                leading: Icon(
                  Icons.circle,
                  color: _getStatusColor(partMetadata!['status']),
                ),
                title: Text('Status'),
                subtitle: Text(partMetadata!['status'] ?? 'Unknown'),
              ),

              // Analytics Section
              if (partMetadata!['analytics'] != null) ...[
                SizedBox(height: 16),
                Text(
                  'Analytics',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),

                // Usage Count
                ListTile(
                  leading: Icon(Icons.analytics, color: Colors.purple),
                  title: Text('Usage Count'),
                  subtitle: Text('${partMetadata!['analytics']['usageCount'] ?? 0}'),
                ),

                // Last Maintenance
                ListTile(
                  leading: Icon(Icons.build, color: Colors.orange),
                  title: Text('Last Maintenance'),
                  subtitle: Text(partMetadata!['analytics']['lastMaintenance'] ?? 'Never'),
                ),

                // Performance Score
                ListTile(
                  leading: Icon(Icons.speed, color: Colors.indigo),
                  title: Text('Performance Score'),
                  subtitle: Text('${partMetadata!['analytics']['performanceScore'] ?? 'N/A'}%'),
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