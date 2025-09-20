import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DataEntryScreen extends StatefulWidget {
  const DataEntryScreen({super.key});

  @override
  State<DataEntryScreen> createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends State<DataEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _partIdController = TextEditingController();
  final _partNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _partType = '';
  String _condition = '';
  String _priority = 'medium';
  File? _image;
  List<Map<String, String>> _measurements = [];
  List<String> _defects = [];
  bool _isSubmitting = false;

  final List<String> _partTypes = ['Wheel', 'Brake', 'Engine', 'Track', 'Signal', 'Coupling', 'Suspension'];
  final List<String> _conditions = ['excellent', 'good', 'fair', 'poor', 'critical'];
  final List<String> _priorities = ['low', 'medium', 'high', 'urgent'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Inspection'),
        backgroundColor: const Color(0xFF2c3e50),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBasicInfo(),
            const SizedBox(height: 20),
            _buildMeasurements(),
            const SizedBox(height: 20),
            _buildDefects(),
            const SizedBox(height: 20),
            _buildImagePicker(),
            const SizedBox(height: 20),
            _buildNotes(),
            const SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Basic Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _partIdController,
              decoration: const InputDecoration(labelText: 'Part ID *', border: OutlineInputBorder()),
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _partType.isEmpty ? null : _partType,
              decoration: const InputDecoration(labelText: 'Part Type *', border: OutlineInputBorder()),
              items: _partTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (value) => setState(() => _partType = value ?? ''),
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _partNameController,
              decoration: const InputDecoration(labelText: 'Part Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location *', border: OutlineInputBorder()),
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _condition.isEmpty ? null : _condition,
                    decoration: const InputDecoration(labelText: 'Condition *', border: OutlineInputBorder()),
                    items: _conditions.map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase()))).toList(),
                    onChanged: (value) => setState(() => _condition = value ?? ''),
                    validator: (value) => value?.isEmpty == true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _priority,
                    decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
                    items: _priorities.map((p) => DropdownMenuItem(value: p, child: Text(p.toUpperCase()))).toList(),
                    onChanged: (value) => setState(() => _priority = value ?? 'medium'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurements() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Measurements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _measurements.add({'param': '', 'value': ''})),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._measurements.asMap().entries.map((entry) {
              int index = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Parameter', border: OutlineInputBorder()),
                        onChanged: (value) => _measurements[index]['param'] = value,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Value', border: OutlineInputBorder()),
                        onChanged: (value) => _measurements[index]['value'] = value,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _measurements.removeAt(index)),
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDefects() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Defects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _defects.add('')),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._defects.asMap().entries.map((entry) {
              int index = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Defect Description', border: OutlineInputBorder()),
                        onChanged: (value) => _defects[index] = value,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _defects.removeAt(index)),
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Inspection Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (_image != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.file(_image!, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Additional Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitInspection,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2c3e50)),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Submit Inspection', style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _submitInspection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Get Firebase Auth token
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      final token = await user.getIdToken();
      
      final request = http.MultipartRequest('POST', Uri.parse('http://localhost:3000/api/inspections'));
      
      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';
      
      request.fields['partId'] = _partIdController.text;
      request.fields['partType'] = _partType;
      request.fields['partName'] = _partNameController.text;
      request.fields['location'] = _locationController.text;
      request.fields['condition'] = _condition;
      request.fields['priority'] = _priority;
      request.fields['notes'] = _notesController.text;
      request.fields['measurements'] = jsonEncode(Map.fromEntries(
        _measurements.where((m) => m['param']!.isNotEmpty && m['value']!.isNotEmpty)
            .map((m) => MapEntry(m['param']!, m['value']!))
      ));
      request.fields['defects'] = jsonEncode(_defects.where((d) => d.isNotEmpty).toList());

      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
      }

      final response = await request.send();
      
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inspection submitted successfully!')),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to submit inspection');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}