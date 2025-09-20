import 'package:flutter/material.dart';

class AddInspectionScreen extends StatefulWidget {
  final String inspectorId;

  const AddInspectionScreen({Key? key, required this.inspectorId}) : super(key: key);

  @override
  _AddInspectionScreenState createState() => _AddInspectionScreenState();
}

class _AddInspectionScreenState extends State<AddInspectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _partIdController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedStatus = 'pending';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Inspection Data'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Part ID Field
              TextFormField(
                controller: _partIdController,
                decoration: InputDecoration(
                  labelText: 'Part ID',
                  prefixIcon: Icon(Icons.qr_code),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value?.isEmpty == true ? 'Part ID is required' : null,
              ),
              
              SizedBox(height: 16),
              
              // Status Selection
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Inspection Status',
                  prefixIcon: Icon(Icons.assignment),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'passed', child: Text('Passed')),
                  DropdownMenuItem(value: 'failed', child: Text('Failed')),
                ],
                onChanged: (value) => setState(() => _selectedStatus = value!),
              ),
              
              SizedBox(height: 16),
              
              // Notes Field
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Inspection Notes',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              
              SizedBox(height: 32),
              
              // Submit Button
              Container(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitInspection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save),
                      SizedBox(width: 8),
                      Text('Save Inspection', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitInspection() {
    if (_formKey.currentState!.validate()) {
      // Save inspection data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inspection data saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _partIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}