import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/part_model.dart';
import '../services/firebase_service.dart';

class QRGeneratorScreen extends StatefulWidget {
  final String vendorId;
  final String vendorName;
  
  const QRGeneratorScreen({Key? key, required this.vendorId, required this.vendorName}) : super(key: key);
  
  @override
  _QRGeneratorScreenState createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _partNameController = TextEditingController();
  final _batchNoController = TextEditingController();
  final _warrantyController = TextEditingController();
  final _inspectionIntervalController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _manufacturingDate = DateTime.now();
  String? _generatedPartId;
  bool _isLoading = false;

  void _showImageNotSupported() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image upload not supported in this version')),
    );
  }

  Future<void> _selectManufacturingDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _manufacturingDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _manufacturingDate) {
      setState(() {
        _manufacturingDate = picked;
      });
    }
  }

  Future<void> _generateQR() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      final part = PartModel(
        id: '', // Will be set by Firestore
        partName: _partNameController.text.trim(),
        vendorName: widget.vendorName,
        vendorId: widget.vendorId,
        batchNo: _batchNoController.text.trim(),
        warrantyPeriod: int.parse(_warrantyController.text),
        inspectionInterval: int.parse(_inspectionIntervalController.text),
        manufacturingDate: _manufacturingDate,
        createdAt: DateTime.now(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        status: 'active',
      );
      
      final partId = await FirebaseService.createPart(part);
      
      setState(() {
        _generatedPartId = partId;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QR Code generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate QR: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _partNameController.clear();
    _batchNoController.clear();
    _warrantyController.clear();
    _inspectionIntervalController.clear();
    _descriptionController.clear();
    setState(() {
      _manufacturingDate = DateTime.now();
      _generatedPartId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Part QR', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.teal[600]!, Colors.teal[800]!]),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal[50]!, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(colors: [Colors.white, Colors.teal[50]!]),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.teal[400]!, Colors.teal[600]!]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.qr_code_2, color: Colors.white, size: 32),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Create New Part', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[800])),
                              Text('Generate QR code for railway part', style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Form Fields
                _buildTextField(
                  controller: _partNameController,
                  label: 'Part Name',
                  icon: Icons.precision_manufacturing,
                  hint: 'e.g., Brake Pad, Wheel Bearing',
                ),
                
                SizedBox(height: 16),
                
                _buildTextField(
                  controller: _batchNoController,
                  label: 'Batch Number',
                  icon: Icons.numbers,
                  hint: 'e.g., BP-2024-001',
                ),
                
                SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _warrantyController,
                        label: 'Warranty (months)',
                        icon: Icons.schedule,
                        keyboardType: TextInputType.number,
                        hint: '12',
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _inspectionIntervalController,
                        label: 'Inspection Interval (days)',
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                        hint: '30',
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Manufacturing Date
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.event, color: Colors.teal[700]),
                    ),
                    title: Text('Manufacturing Date'),
                    subtitle: Text('${_manufacturingDate.day}/${_manufacturingDate.month}/${_manufacturingDate.year}'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _selectManufacturingDate,
                  ),
                ),
                
                SizedBox(height: 16),
                
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description (Optional)',
                  icon: Icons.description,
                  maxLines: 3,
                  hint: 'Additional part specifications or notes',
                  required: false,
                ),
                
                SizedBox(height: 16),
                
                // Image Picker (Disabled for web compatibility)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.image, color: Colors.grey[600]),
                    ),
                    title: Text('Part Image (Not Available)'),
                    subtitle: Text('Image upload not supported in this version'),
                    trailing: Icon(Icons.info_outline, size: 16, color: Colors.grey),
                    onTap: _showImageNotSupported,
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Generate Button
                Container(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _generateQR,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[600],
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: Colors.teal.withOpacity(0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text('Generating...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.qr_code_2, size: 24),
                              SizedBox(width: 8),
                              Text('Generate QR Code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),
                  ),
                ),
                
                // Generated QR Code
                if (_generatedPartId != null) ...[
                  SizedBox(height: 32),
                  Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.teal[50]!],
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 28),
                              SizedBox(width: 12),
                              Text('QR Code Generated!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[800])),
                            ],
                          ),
                          SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 2))],
                            ),
                            child: QrImageView(
                              data: _generatedPartId!,
                              version: QrVersions.auto,
                              size: 200.0,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Part ID: $_generatedPartId',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Scan this QR code to view part details',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _resetForm,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.teal[600],
                                    side: BorderSide(color: Colors.teal[600]!),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text('Create Another'),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal[600],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text('Done'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool required = true,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.teal[700], size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: required ? (value) => value?.isEmpty == true ? '$label is required' : null : null,
      ),
    );
  }

  @override
  void dispose() {
    _partNameController.dispose();
    _batchNoController.dispose();
    _warrantyController.dispose();
    _inspectionIntervalController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}