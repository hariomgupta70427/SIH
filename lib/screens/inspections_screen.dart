import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class InspectionsScreen extends StatefulWidget {
  const InspectionsScreen({super.key});

  @override
  State<InspectionsScreen> createState() => _InspectionsScreenState();
}

class _InspectionsScreenState extends State<InspectionsScreen> {
  List<Map<String, dynamic>> inspections = [];
  List<Map<String, dynamic>> filteredInspections = [];
  String statusFilter = '';
  String typeFilter = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadInspections();
  }

  Future<void> loadInspections() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      final token = await user.getIdToken();
      
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/inspections'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          inspections = data.cast<Map<String, dynamic>>();
          filteredInspections = inspections;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading inspections: $e')),
      );
    }
  }

  void applyFilters() {
    setState(() {
      filteredInspections = inspections.where((inspection) {
        final matchesStatus = statusFilter.isEmpty || inspection['status'] == statusFilter;
        final matchesType = typeFilter.isEmpty || inspection['partType'] == typeFilter;
        return matchesStatus && matchesType;
      }).toList();
    });
  }

  Future<void> updateStatus(String inspectionId, String newStatus) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      final token = await user.getIdToken();
      
      final response = await http.patch(
        Uri.parse('http://localhost:3000/api/inspections/$inspectionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        setState(() {
          final index = inspections.indexWhere((i) => i['id'] == inspectionId);
          if (index != -1) {
            inspections[index]['status'] = newStatus;
            applyFilters();
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $newStatus')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Inspections'),
        backgroundColor: const Color(0xFF2c3e50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadInspections,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredInspections.isEmpty
                    ? const Center(child: Text('No inspections found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredInspections.length,
                        itemBuilder: (context, index) {
                          final inspection = filteredInspections[index];
                          return _buildInspectionCard(inspection);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final statuses = ['', 'pending', 'completed', 'failed'];
    final types = <String>['', ...inspections.map((i) => i['partType']?.toString() ?? '').where((t) => t.isNotEmpty).toSet()];

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: statusFilter,
              decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
              items: statuses.map((status) => DropdownMenuItem(
                value: status,
                child: Text(status.isEmpty ? 'All' : status.toUpperCase()),
              )).toList(),
              onChanged: (value) {
                statusFilter = value ?? '';
                applyFilters();
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: typeFilter,
              decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
              items: types.map((type) => DropdownMenuItem<String>(
                value: type,
                child: Text(type.isEmpty ? 'All' : type),
              )).toList(),
              onChanged: (value) {
                typeFilter = value ?? '';
                applyFilters();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionCard(Map<String, dynamic> inspection) {
    final status = inspection['status'] ?? 'pending';
    final statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  inspection['partId'] ?? 'N/A',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Type', inspection['partType']),
            _buildDetailRow('Location', inspection['location']),
            _buildDetailRow('Condition', inspection['condition']),
            _buildDetailRow('Priority', inspection['priority']),
            if (inspection['notes']?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text('Notes: ${inspection['notes']}', style: TextStyle(color: Colors.grey[600])),
            ],
            const SizedBox(height: 16),
            _buildActionButtons(inspection),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ),
          Text(value?.toString() ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> inspection) {
    final status = inspection['status'] ?? 'pending';
    final inspectionId = inspection['id'];

    return Wrap(
      spacing: 8,
      children: [
        if (status != 'completed')
          ElevatedButton(
            onPressed: () => updateStatus(inspectionId, 'completed'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Complete', style: TextStyle(color: Colors.white)),
          ),
        if (status != 'failed')
          ElevatedButton(
            onPressed: () => updateStatus(inspectionId, 'failed'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Failed', style: TextStyle(color: Colors.white)),
          ),
        if (status != 'pending')
          ElevatedButton(
            onPressed: () => updateStatus(inspectionId, 'pending'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Pending', style: TextStyle(color: Colors.white)),
          ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed': return Colors.green;
      case 'failed': return Colors.red;
      case 'pending': return Colors.orange;
      default: return Colors.grey;
    }
  }
}