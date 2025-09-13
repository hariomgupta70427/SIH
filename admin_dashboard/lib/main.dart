// Main entry point for Flutter Web admin dashboard
import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(AdminDashboardApp());
}

class AdminDashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Railway Parts Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Optimize for web display
        fontFamily: 'Roboto',
      ),
      home: DashboardScreen(),
    );
  }
}