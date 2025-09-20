import 'package:flutter/material.dart';

class ManageInspectionsScreen extends StatefulWidget {
  final String inspectorId;

  const ManageInspectionsScreen({Key? key, required this.inspectorId}) : super(key: key);

  @override
  _ManageInspectionsScreenState createState() => _ManageInspectionsScreenState();
}

class _ManageInspectionsScreenState extends State<ManageInspectionsScreen> {
  final List<Map<String, dynamic>> _inspections = [
    {'id': 'P-001', 'status': 'pending', 'date': '2024-01-15', 'notes': 'Brake pad inspection'},
    {'id': 'P-002', 'status': 'passed', 'date': '2024-01-14', 'notes': 'Wheel assembly check'},
    {'id': 'P-003', 'status': 'failed', 'date': '2024-01-13', 'notes': 'Coupling defect found'},
    {'id': 'P-004', 'status': 'pending', 'date': '2024-01-12', 'notes': 'Signal light test'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Inspections'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Filter Chips
            Row(
              children: [
                _buildFilterChip('All', true),
                SizedBox(width: 8),
                _buildFilterChip('Pending', false),
                SizedBox(width: 8),
                _buildFilterChip('Passed', false),
                SizedBox(width: 8),
                _buildFilterChip('Failed', false),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Inspections List
            Expanded(
              child: ListView.builder(
                itemCount: _inspections.length,
                itemBuilder: (context, index) {
                  final inspection = _inspections[index];
                  return _buildInspectionCard(inspection);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // Filter logic here
      },
      selectedColor: Colors.purple[100],
      checkmarkColor: Colors.purple[600],
    );
  }

  Widget _buildInspectionCard(Map<String, dynamic> inspection) {
    Color statusColor = _getStatusColor(inspection['status']);
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.assignment, color: statusColor),
        ),
        title: Text('Part ${inspection['id']}', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(inspection['notes']),
            SizedBox(height: 4),
            Text('Date: ${inspection['date']}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            inspection['status'].toUpperCase(),
            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () => _showInspectionDetails(inspection),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'passed': return Colors.green;
      case 'failed': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _showInspectionDetails(Map<String, dynamic> inspection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Inspection Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Part ID: ${inspection['id']}', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Status: ${inspection['status']}'),
            SizedBox(height: 8),
            Text('Date: ${inspection['date']}'),
            SizedBox(height: 8),
            Text('Notes: ${inspection['notes']}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Close')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('Edit')),
        ],
      ),
    );
  }
}