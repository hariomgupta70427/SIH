// Main dashboard screen with navigation tabs
import 'package:flutter/material.dart';
import 'inventory_screen.dart';
import 'inspections_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with title and navigation tabs
      appBar: AppBar(
        title: const Text('Railway Parts Admin Dashboard'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.inventory),
              text: 'Inventory',
            ),
            Tab(
              icon: Icon(Icons.assignment),
              text: 'Inspections',
            ),
          ],
        ),
      ),
      
      // Main content area with tab views
      body: TabBarView(
        controller: _tabController,
        children: [
          InventoryScreen(), // Parts inventory management
          InspectionsScreen(), // Inspections management
        ],
      ),
      
      // Floating action button for quick actions
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickActions(context),
        icon: const Icon(Icons.add),
        label: Text(_selectedIndex == 0 ? 'Add Part' : 'Add Inspection'),
        backgroundColor: Colors.blue[800],
      ),
    );
  }

  // Show quick action dialog
  void _showQuickActions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_selectedIndex == 0 ? 'Add New Part' : 'Add New Inspection'),
        content: Text(_selectedIndex == 0 
          ? 'Quick add functionality for new parts will be implemented here.'
          : 'Quick add functionality for new inspections will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement quick add functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Quick add feature coming soon')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}