import 'package:flutter/material.dart';

class AnalyticsDashboardScreen extends StatelessWidget {
  final String inspectorId;

  const AnalyticsDashboardScreen({Key? key, required this.inspectorId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics Dashboard'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Stats Cards
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Inspections', '156', Icons.assignment, Colors.blue)),
                SizedBox(width: 16),
                Expanded(child: _buildStatCard('Pending', '23', Icons.pending, Colors.orange)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('Completed', '120', Icons.check_circle, Colors.green)),
                SizedBox(width: 16),
                Expanded(child: _buildStatCard('Failed', '13', Icons.error, Colors.red)),
              ],
            ),
            SizedBox(height: 32),
            
            // Chart Placeholder
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 80, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text('Analytics Chart', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                    Text('Real-time inspection data visualization', style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}