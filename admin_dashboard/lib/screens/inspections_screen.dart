// Inspections management screen with inspections data table
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import '../models/inspection.dart';
import '../services/api_service.dart';

class InspectionsScreen extends StatefulWidget {
  @override
  _InspectionsScreenState createState() => _InspectionsScreenState();
}

class _InspectionsScreenState extends State<InspectionsScreen> {
  List<Inspection> _inspections = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _resultFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadInspections();
  }

  // Load inspections data from API
  Future<void> _loadInspections() async {
    setState(() => _isLoading = true);
    
    try {
      final inspections = await ApiService.fetchInspections();
      setState(() {
        _inspections = inspections;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load inspections: $e');
    }
  }

  // Filter inspections based on search and result
  List<Inspection> get _filteredInspections {
    return _inspections.where((inspection) {
      final matchesSearch = inspection.partName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           inspection.inspectorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           inspection.remarks.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesResult = _resultFilter == 'all' || inspection.result.toLowerCase() == _resultFilter;
      
      return matchesSearch && matchesResult;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with search and filters
          _buildHeader(),
          const SizedBox(height: 16),
          
          // Summary cards
          _buildSummaryCards(),
          const SizedBox(height: 16),
          
          // Inspections data table
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildInspectionsTable(),
          ),
        ],
      ),
    );
  }

  // Build header with search and filter controls
  Widget _buildHeader() {
    return Row(
      children: [
        // Search field
        Expanded(
          flex: 2,
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search inspections...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ),
        const SizedBox(width: 16),
        
        // Result filter dropdown
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _resultFilter,
            decoration: const InputDecoration(
              labelText: 'Result Filter',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Results')),
              DropdownMenuItem(value: 'passed', child: Text('Passed')),
              DropdownMenuItem(value: 'failed', child: Text('Failed')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
            ],
            onChanged: (value) {
              setState(() => _resultFilter = value ?? 'all');
            },
          ),
        ),
        const SizedBox(width: 16),
        
        // Refresh button
        ElevatedButton.icon(
          onPressed: _loadInspections,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),
      ],
    );
  }

  // Build summary cards showing inspection statistics
  Widget _buildSummaryCards() {
    final total = _inspections.length;
    final passed = _inspections.where((i) => i.result.toLowerCase() == 'passed').length;
    final failed = _inspections.where((i) => i.result.toLowerCase() == 'failed').length;
    final pending = _inspections.where((i) => i.result.toLowerCase() == 'pending').length;

    return Row(
      children: [
        _buildSummaryCard('Total', total.toString(), Colors.blue),
        const SizedBox(width: 16),
        _buildSummaryCard('Passed', passed.toString(), Colors.green),
        const SizedBox(width: 16),
        _buildSummaryCard('Failed', failed.toString(), Colors.red),
        const SizedBox(width: 16),
        _buildSummaryCard('Pending', pending.toString(), Colors.orange),
      ],
    );
  }

  // Build individual summary card
  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build inspections data table
  Widget _buildInspectionsTable() {
    final filteredInspections = _filteredInspections;
    
    if (filteredInspections.isEmpty) {
      return const Center(
        child: Text('No inspections found', style: TextStyle(fontSize: 18)),
      );
    }

    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 1200,
      columns: const [
        DataColumn2(label: Text('Part Name'), size: ColumnSize.L),
        DataColumn2(label: Text('Inspector'), size: ColumnSize.M),
        DataColumn2(label: Text('Date'), size: ColumnSize.M),
        DataColumn2(label: Text('Result'), size: ColumnSize.S),
        DataColumn2(label: Text('Score'), size: ColumnSize.S, numeric: true),
        DataColumn2(label: Text('Remarks'), size: ColumnSize.L),
        DataColumn2(label: Text('Actions'), size: ColumnSize.S),
      ],
      rows: filteredInspections.map((inspection) => DataRow2(
        cells: [
          DataCell(Text(inspection.partName)),
          DataCell(Text(inspection.inspectorName)),
          DataCell(Text(_formatDate(inspection.inspectionDate))),
          DataCell(_buildResultChip(inspection.result)),
          DataCell(Text(inspection.score?.toString() ?? 'N/A')),
          DataCell(
            Tooltip(
              message: inspection.remarks,
              child: Text(
                inspection.remarks.length > 50 
                  ? '${inspection.remarks.substring(0, 50)}...'
                  : inspection.remarks,
              ),
            ),
          ),
          DataCell(_buildActionButtons(inspection)),
        ],
      )).toList(),
    );
  }

  // Build result chip with color coding
  Widget _buildResultChip(String result) {
    Color color;
    switch (result.toLowerCase()) {
      case 'passed':
        color = Colors.green;
        break;
      case 'failed':
        color = Colors.red;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        result.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  // Build action buttons for each row
  Widget _buildActionButtons(Inspection inspection) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.visibility, size: 18),
          onPressed: () => _viewInspection(inspection),
          tooltip: 'View Details',
        ),
        IconButton(
          icon: const Icon(Icons.edit, size: 18),
          onPressed: () => _editInspection(inspection),
          tooltip: 'Edit',
        ),
      ],
    );
  }

  // View inspection details
  void _viewInspection(Inspection inspection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Inspection Details'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Part Name', inspection.partName),
              _buildDetailRow('Inspector', inspection.inspectorName),
              _buildDetailRow('Date', _formatDate(inspection.inspectionDate)),
              _buildDetailRow('Result', inspection.result.toUpperCase()),
              _buildDetailRow('Score', inspection.score?.toString() ?? 'N/A'),
              const SizedBox(height: 8),
              const Text('Remarks:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(inspection.remarks),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Build detail row for inspection view
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Edit inspection functionality
  void _editInspection(Inspection inspection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Inspection'),
        content: const Text('Edit functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessSnackBar('Inspection updated successfully');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Show success message
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Show error message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}