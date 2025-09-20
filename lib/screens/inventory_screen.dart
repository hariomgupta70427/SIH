import 'package:flutter/material.dart';
import '../models/part_model.dart';
import '../services/firebase_service.dart';

class InventoryScreen extends StatefulWidget {
  final String vendorId;
  final String vendorName;
  
  const InventoryScreen({Key? key, required this.vendorId, required this.vendorName}) : super(key: key);
  
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.indigo[600]!, Colors.indigo[800]!]),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo[50]!, Colors.white],
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
                        hintText: 'Search parts...',
                        prefixIcon: Container(
                          margin: EdgeInsets.all(12),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.indigo[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.search, color: Colors.indigo[700], size: 20),
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
                        _buildFilterChip('Active', 'active'),
                        SizedBox(width: 8),
                        _buildFilterChip('Inactive', 'inactive'),
                        SizedBox(width: 8),
                        _buildFilterChip('Under Review', 'review'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Parts List
            Expanded(
              child: StreamBuilder<List<PartModel>>(
                stream: FirebaseService.getPartsByVendor(widget.vendorId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.indigo[600]),
                          SizedBox(height: 16),
                          Text('Loading inventory...', style: TextStyle(color: Colors.grey[600])),
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
                          Text('Error loading inventory', style: TextStyle(fontSize: 18, color: Colors.red[600])),
                          SizedBox(height: 8),
                          Text('${snapshot.error}', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    );
                  }
                  
                  final parts = snapshot.data ?? [];
                  final filteredParts = _filterParts(parts);
                  
                  if (filteredParts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text('No parts found', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                          SizedBox(height: 8),
                          Text('Create your first part to get started', style: TextStyle(color: Colors.grey[500])),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredParts.length,
                    itemBuilder: (context, index) {
                      final part = filteredParts[index];
                      return _buildPartCard(part);
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
      selectedColor: Colors.indigo[100],
      checkmarkColor: Colors.indigo[700],
      labelStyle: TextStyle(
        color: isSelected ? Colors.indigo[700] : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.indigo[300]! : Colors.grey[300]!,
        ),
      ),
    );
  }

  Widget _buildPartCard(PartModel part) {
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
                      gradient: LinearGradient(colors: [Colors.indigo[400]!, Colors.indigo[600]!]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.precision_manufacturing, color: Colors.white, size: 24),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          part.partName,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Batch: ${part.batchNo}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(part.status),
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
                        Expanded(child: _buildDetailItem('Manufacturing Date', _formatDate(part.manufacturingDate), Icons.event)),
                        SizedBox(width: 16),
                        Expanded(child: _buildDetailItem('Warranty', '${part.warrantyPeriod} months', Icons.schedule)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildDetailItem('Inspection Interval', '${part.inspectionInterval} days', Icons.calendar_today)),
                        SizedBox(width: 16),
                        Expanded(child: _buildDetailItem('Warranty Status', part.isWarrantyValid ? 'Valid' : 'Expired', Icons.verified_user)),
                      ],
                    ),
                  ],
                ),
              ),
              
              if (part.description != null) ...[
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
                      Icon(Icons.description, color: Colors.blue[600], size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          part.description!,
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
                      onPressed: () => _showPartDetails(part),
                      icon: Icon(Icons.visibility, size: 18),
                      label: Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.indigo[600],
                        side: BorderSide(color: Colors.indigo[300]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updatePartStatus(part),
                      icon: Icon(Icons.edit, size: 18),
                      label: Text('Update Status'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[600],
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
      case 'active':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'inactive':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case 'review':
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

  List<PartModel> _filterParts(List<PartModel> parts) {
    var filtered = parts;
    
    // Apply status filter
    if (_selectedFilter != 'all') {
      filtered = filtered.where((part) => part.status.toLowerCase() == _selectedFilter).toList();
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((part) {
        return part.partName.toLowerCase().contains(_searchQuery) ||
               part.batchNo.toLowerCase().contains(_searchQuery) ||
               (part.description?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }
    
    return filtered;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showPartDetails(PartModel part) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.indigo[600]),
            SizedBox(width: 8),
            Text('Part Details'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Part Name', part.partName),
              _buildDetailRow('Vendor', part.vendorName),
              _buildDetailRow('Batch Number', part.batchNo),
              _buildDetailRow('Manufacturing Date', _formatDate(part.manufacturingDate)),
              _buildDetailRow('Warranty Period', '${part.warrantyPeriod} months'),
              _buildDetailRow('Inspection Interval', '${part.inspectionInterval} days'),
              _buildDetailRow('Status', part.status),
              _buildDetailRow('Created At', _formatDate(part.createdAt)),
              if (part.description != null)
                _buildDetailRow('Description', part.description!),
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
            width: 120,
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

  void _updatePartStatus(PartModel part) {
    showDialog(
      context: context,
      builder: (context) {
        String selectedStatus = part.status;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.indigo[600]),
              SizedBox(width: 8),
              Text('Update Status'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select new status for ${part.partName}:'),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: ['active', 'inactive', 'review'].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedStatus = value!;
                },
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
                  await FirebaseService.updatePartStatus(part.id, selectedStatus);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Status updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update status: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo[600]),
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}