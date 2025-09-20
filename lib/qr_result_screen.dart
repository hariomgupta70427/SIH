import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/part_model.dart';

class QRResultScreen extends StatefulWidget {
  final PartModel part;
  final String inspectorId;
  
  const QRResultScreen({Key? key, required this.part, required this.inspectorId}) : super(key: key);
  
  @override
  _QRResultScreenState createState() => _QRResultScreenState();
}

class _QRResultScreenState extends State<QRResultScreen> {
  final TextEditingController _remarksController = TextEditingController();
  String _inspectionResult = 'pass';
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Part Details', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.green[600]!, Colors.green[800]!]),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[50]!, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
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
                    gradient: LinearGradient(colors: [Colors.white, Colors.green[50]!]),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.green[400]!, Colors.green[600]!]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.check_circle, color: Colors.white, size: 32),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('QR Scan Successful', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[800])),
                            Text('Part information retrieved', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Part Information
              Text('Part Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
              SizedBox(height: 12),
              
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(colors: [Colors.white, Colors.grey[50]!]),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Part Name', widget.part.partName, Icons.precision_manufacturing),
                      _buildInfoRow('Vendor', widget.part.vendorName, Icons.business),
                      _buildInfoRow('Batch Number', widget.part.batchNo, Icons.numbers),
                      _buildInfoRow('Manufacturing Date', _formatDate(widget.part.manufacturingDate), Icons.event),
                      _buildInfoRow('Warranty Period', '${widget.part.warrantyPeriod} months', Icons.schedule),
                      _buildInfoRow('Inspection Interval', '${widget.part.inspectionInterval} days', Icons.calendar_today),
                      _buildInfoRow('Status', widget.part.status.toUpperCase(), Icons.info, statusColor: _getStatusColor(widget.part.status)),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Warranty Status
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: widget.part.isWarrantyValid 
                          ? [Colors.green[50]!, Colors.green[100]!]
                          : [Colors.red[50]!, Colors.red[100]!],
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.part.isWarrantyValid ? Icons.verified_user : Icons.warning,
                        color: widget.part.isWarrantyValid ? Colors.green[700] : Colors.red[700],
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.part.isWarrantyValid ? 'Warranty Valid' : 'Warranty Expired',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: widget.part.isWarrantyValid ? Colors.green[800] : Colors.red[800],
                              ),
                            ),
                            Text(
                              'Next inspection: ${_formatDate(widget.part.nextInspectionDate)}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              if (widget.part.description != null) ...[
                SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.blue[50],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.description, color: Colors.blue[700]),
                            SizedBox(width: 8),
                            Text('Description', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800])),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(widget.part.description!, style: TextStyle(color: Colors.blue[700])),
                      ],
                    ),
                  ),
                ),
              ],
              
              SizedBox(height: 24),
              
              // Inspection Form
              Text('Inspection Report', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
              SizedBox(height: 12),
              
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(colors: [Colors.white, Colors.grey[50]!]),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Inspection Result', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('Pass'),
                              value: 'pass',
                              groupValue: _inspectionResult,
                              onChanged: (value) => setState(() => _inspectionResult = value!),
                              activeColor: Colors.green,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('Fail'),
                              value: 'fail',
                              groupValue: _inspectionResult,
                              onChanged: (value) => setState(() => _inspectionResult = value!),
                              activeColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16),
                      
                      Text('Remarks (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 8),
                      
                      TextField(
                        controller: _remarksController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Enter inspection remarks...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey[600],
                                side: BorderSide(color: Colors.grey[400]!),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text('Cancel'),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitInspection,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: _isSubmitting
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text('Submit Report'),
                            ),
                          ),
                        ],
                      ),
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
  
  Widget _buildInfoRow(String label, String value, IconData icon, {Color? statusColor}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: Colors.grey[700]),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700])),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: statusColor ?? Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      case 'review':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  Future<void> _submitInspection() async {
    setState(() => _isSubmitting = true);
    
    try {
      // Update scan history with inspection results
      final updates = {
        'inspectionResult': _inspectionResult,
        'remarks': _remarksController.text.trim().isEmpty ? null : _remarksController.text.trim(),
        'status': 'inspected',
      };
      
      // Note: In a real implementation, you'd need to get the scan history ID
      // For now, we'll just show success
      
      await Future.delayed(Duration(seconds: 1)); // Simulate API call
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Inspection report submitted successfully'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
  
  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }
}