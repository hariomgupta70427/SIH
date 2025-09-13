// Inventory management screen with parts data table
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import '../models/part.dart';
import '../services/api_service.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Part> _parts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadParts();
  }

  // Load parts data from API
  Future<void> _loadParts() async {
    setState(() => _isLoading = true);
    
    try {
      final parts = await ApiService.fetchParts();
      setState(() {
        _parts = parts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load parts: $e');
    }
  }

  // Filter parts based on search and status
  List<Part> get _filteredParts {
    return _parts.where((part) {
      final matchesSearch = part.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           part.partNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           part.category.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesStatus = _statusFilter == 'all' || part.status.toLowerCase() == _statusFilter;
      
      return matchesSearch && matchesStatus;
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
          
          // Parts data table
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildPartsTable(),
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
              hintText: 'Search parts...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ),
        const SizedBox(width: 16),
        
        // Status filter dropdown
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _statusFilter,
            decoration: const InputDecoration(
              labelText: 'Status Filter',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Status')),
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
              DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
            ],
            onChanged: (value) {
              setState(() => _statusFilter = value ?? 'all');
            },
          ),
        ),
        const SizedBox(width: 16),
        
        // Refresh button
        ElevatedButton.icon(
          onPressed: _loadParts,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),
      ],
    );
  }

  // Build parts data table
  Widget _buildPartsTable() {
    final filteredParts = _filteredParts;
    
    if (filteredParts.isEmpty) {
      return const Center(
        child: Text('No parts found', style: TextStyle(fontSize: 18)),
      );
    }

    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 1200,
      columns: const [
        DataColumn2(label: Text('Part Number'), size: ColumnSize.M),
        DataColumn2(label: Text('Name'), size: ColumnSize.L),
        DataColumn2(label: Text('Category'), size: ColumnSize.M),
        DataColumn2(label: Text('Quantity'), size: ColumnSize.S, numeric: true),
        DataColumn2(label: Text('Price'), size: ColumnSize.S, numeric: true),
        DataColumn2(label: Text('Status'), size: ColumnSize.S),
        DataColumn2(label: Text('Location'), size: ColumnSize.M),
        DataColumn2(label: Text('Vendor'), size: ColumnSize.M),
        DataColumn2(label: Text('Actions'), size: ColumnSize.S),
      ],
      rows: filteredParts.map((part) => DataRow2(
        cells: [
          DataCell(Text(part.partNumber)),
          DataCell(Text(part.name)),
          DataCell(Text(part.category)),
          DataCell(Text(part.quantity.toString())),
          DataCell(Text(part.price != null ? '₹${part.price!.toStringAsFixed(2)}' : 'N/A')),
          DataCell(_buildStatusChip(part.status)),
          DataCell(Text(part.location)),
          DataCell(Text(part.vendorName)),
          DataCell(_buildActionButtons(part)),
        ],
      )).toList(),
    );
  }

  // Build status chip with color coding
  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'inactive':
        color = Colors.red;
        break;
      case 'maintenance':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  // Build action buttons for each row
  Widget _buildActionButtons(Part part) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, size: 18),
          onPressed: () => _editPart(part),
          tooltip: 'Edit',
        ),
        IconButton(
          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
          onPressed: () => _deletePart(part),
          tooltip: 'Delete',
        ),
      ],
    );
  }

  // Edit part functionality
  void _editPart(Part part) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${part.name}'),
        content: const Text('Edit functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessSnackBar('Part updated successfully');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Delete part functionality
  void _deletePart(Part part) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Part'),
        content: Text('Are you sure you want to delete ${part.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ApiService.deletePart(part.id);
                setState(() {
                  _parts.removeWhere((p) => p.id == part.id);
                });
                _showSuccessSnackBar('Part deleted successfully');
              } catch (e) {
                _showErrorSnackBar('Failed to delete part: $e');
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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