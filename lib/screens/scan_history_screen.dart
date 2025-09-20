import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/scan_history_model.dart';
import '../services/firebase_service.dart';

class ScanHistoryScreen extends StatefulWidget {
  final String inspectorId;
  
  const ScanHistoryScreen({Key? key, required this.inspectorId}) : super(key: key);
  
  @override
  _ScanHistoryScreenState createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.purple[600]!, Colors.purple[800]!]),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple[50]!, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Header and Filters
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Search Bar
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search scans...',
                        prefixIcon: Container(
                          margin: EdgeInsets.all(12),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.purple[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.search, color: Colors.purple[700], size: 20),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all'),
                        SizedBox(width: 8),
                        _buildFilterChip('Scanned', 'scanned'),
                        SizedBox(width: 8),
                        _buildFilterChip('Inspected', 'inspected'),
                        SizedBox(width: 8),
                        _buildFilterChip('Today', 'today'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Scan History List
            Expanded(
              child: StreamBuilder<List<ScanHistoryModel>>(
                stream: FirebaseService.getScanHistoryByInspector(widget.inspectorId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.purple[600]),
                          SizedBox(height: 16),
                          Text('Loading scan history...', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    );
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                          SizedBox(height: 16),
                          Text('Error loading history', style: TextStyle(fontSize: 18, color: Colors.red[600])),
                          SizedBox(height: 8),
                          Text('${snapshot.error}', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    );
                  }
                  
                  final scans = snapshot.data ?? [];
                  final filteredScans = _filterScans(scans);
                  
                  if (filteredScans.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 64, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text('No scan history found', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                          SizedBox(height: 8),
                          Text('Start scanning QR codes to build your history', style: TextStyle(color: Colors.grey[500])),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredScans.length,
                    itemBuilder: (context, index) {
                      final scan = filteredScans[index];
                      return _buildScanCard(scan);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: Colors.purple[100],
      checkmarkColor: Colors.purple[700],
      labelStyle: TextStyle(
        color: isSelected ? Colors.purple[700] : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.purple[300]! : Colors.grey[300]!,
        ),
      ),
    );
  }

  Widget _buildScanCard(ScanHistoryModel scan) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[50]!],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.purple[400]!, Colors.purple[600]!]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.qr_code_scanner, color: Colors.white, size: 24),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scan.partName,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Vendor: ${scan.vendorName}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(scan.status),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Details Grid
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildDetailItem('Scanned At', _formatDateTime(scan.scannedAt), Icons.access_time)),
                        SizedBox(width: 16),
                        Expanded(child: _buildDetailItem('Part ID', scan.partId, Icons.qr_code)),
                      ],
                    ),
                    if (scan.inspectionResult != null) ...[
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildDetailItem('Inspection', scan.inspectionResult!.toUpperCase(), Icons.assignment_turned_in)),
                          SizedBox(width: 16),
                          Expanded(child: _buildDetailItem('Status', scan.status.toUpperCase(), Icons.info)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              if (scan.remarks != null) ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.note, color: Colors.blue[600], size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Remarks: ${scan.remarks!}',
                          style: TextStyle(color: Colors.blue[800], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              SizedBox(height: 16),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showScanDetails(scan),
                      icon: Icon(Icons.visibility, size: 18),
                      label: Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purple[600],
                        side: BorderSide(color: Colors.purple[300]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  if (scan.status == 'scanned')
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _addInspectionNotes(scan),
                        icon: Icon(Icons.edit_note, size: 18),
                        label: Text('Add Notes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _rescanPart(scan),
                        icon: Icon(Icons.refresh, size: 18),
                        label: Text('Rescan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'scanned':
        color = Colors.blue;
        icon = Icons.qr_code_scanner;
        break;
      case 'inspected':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]),
        ),
      ],
    );
  }

  List<ScanHistoryModel> _filterScans(List<ScanHistoryModel> scans) {
    var filtered = scans;
    
    // Apply status filter
    if (_selectedFilter == 'today') {
      final today = DateTime.now();
      filtered = filtered.where((scan) {
        return scan.scannedAt.year == today.year &&
               scan.scannedAt.month == today.month &&
               scan.scannedAt.day == today.day;
      }).toList();
    } else if (_selectedFilter != 'all') {
      filtered = filtered.where((scan) => scan.status.toLowerCase() == _selectedFilter).toList();
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((scan) {
        return scan.partName.toLowerCase().contains(_searchQuery) ||
               scan.vendorName.toLowerCase().contains(_searchQuery) ||
               scan.partId.toLowerCase().contains(_searchQuery) ||
               (scan.remarks?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }
    
    return filtered;
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  void _showScanDetails(ScanHistoryModel scan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.purple[600]),
            SizedBox(width: 8),
            Text('Scan Details'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Part Name', scan.partName),
              _buildDetailRow('Vendor', scan.vendorName),
              _buildDetailRow('Part ID', scan.partId),
              _buildDetailRow('Scanned At', _formatDateTime(scan.scannedAt)),
              _buildDetailRow('Status', scan.status),
              if (scan.inspectionResult != null)
                _buildDetailRow('Inspection Result', scan.inspectionResult!),
              if (scan.remarks != null)
                _buildDetailRow('Remarks', scan.remarks!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  void _addInspectionNotes(ScanHistoryModel scan) {
    final TextEditingController notesController = TextEditingController();
    String inspectionResult = 'pass';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.edit_note, color: Colors.purple[600]),
            SizedBox(width: 8),
            Text('Add Inspection Notes'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Part: ${scan.partName}'),
            SizedBox(height: 16),
            
            Text('Inspection Result:', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Pass'),
                    value: 'pass',
                    groupValue: inspectionResult,
                    onChanged: (value) => setState(() => inspectionResult = value!),
                    activeColor: Colors.green,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Fail'),
                    value: 'fail',
                    groupValue: inspectionResult,
                    onChanged: (value) => setState(() => inspectionResult = value!),
                    activeColor: Colors.red,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notes',
                hintText: 'Enter inspection notes...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseService.updateScanHistory(scan.id, {
                  'inspectionResult': inspectionResult,
                  'remarks': notesController.text.trim(),
                  'status': 'inspected',
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Inspection notes added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to add notes: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[600]),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _rescanPart(ScanHistoryModel scan) {
    // Navigate back to scanner with part ID
    Navigator.pop(context, scan.partId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}