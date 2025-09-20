import 'package:flutter/material.dart';
import 'simple_auth_screen.dart';
import 'qr_scanner_screen.dart';
import 'screens/qr_generator_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/scan_history_screen.dart';
import 'screens/analytics_dashboard_screen.dart';
import 'screens/add_inspection_screen.dart';
import 'screens/manage_inspections_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userRole;
  
  const HomeScreen({Key? key, required this.userRole}) : super(key: key);
  
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(duration: Duration(seconds: 2), vsync: this)..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String get _currentUserId => 'demo_user';
  String get _currentUserName => 'Demo User';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QRail', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue[600]!, Colors.blue[800]!])),
        ),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              } else if (value == 'profile') {
                _showProfileDialog();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'profile', child: Row(children: [Icon(Icons.person, color: Colors.blue), SizedBox(width: 8), Text('Profile')])),
              PopupMenuItem(value: 'logout', child: Row(children: [Icon(Icons.logout, color: Colors.red), SizedBox(width: 8), Text('Logout')])),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white, Colors.blue[50]!],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.white, Colors.blue[50]!]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5))],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome Back!', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                            Text(_getRoleTitle(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[800])),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: _getRoleColors()),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: _getRoleColors()[0].withOpacity(0.3), blurRadius: 8, offset: Offset(0, 2))],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_getRoleIcon(), size: 16, color: Colors.white),
                                  SizedBox(width: 6),
                                  Text(widget.userRole.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.blue[400]!, Colors.blue[600]!]),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4))],
                        ),
                        child: Icon(Icons.train_rounded, color: Colors.white, size: 32),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Main Content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: _getRoleColors().map((c) => c.withOpacity(0.2)).toList()),
                                borderRadius: BorderRadius.circular(60),
                                boxShadow: [BoxShadow(color: _getRoleColors()[0].withOpacity(0.2), blurRadius: 20, spreadRadius: 5)],
                              ),
                              child: Icon(_getRoleIcon(), size: 60, color: _getRoleColors()[0]),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 24),
                      Text(_getCenterTitle(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                      SizedBox(height: 8),
                      Text(_getCenterSubtitle(), textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5)),
                    ],
                  ),
                ),
                
                // Action Buttons
                if (widget.userRole == 'inspector') ..._buildInspectorButtons()
                else if (widget.userRole == 'vendor') ..._buildVendorButtons()
                else ..._buildUserButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onPressed, {bool isOutlined = false}) {
    return Container(
      width: double.infinity,
      height: 64,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, size: 24, color: color),
                  ),
                  SizedBox(width: 16),
                  Expanded(child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color))),
                ],
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: color.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, size: 24, color: Colors.white),
                  ),
                  SizedBox(width: 16),
                  Expanded(child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white))),
                ],
              ),
            ),
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [Icon(Icons.person, color: Colors.blue), SizedBox(width: 8), Text('Profile')]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Text('Email: demo@qrail.com', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  Text('Role: ${widget.userRole.toUpperCase()}', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  Text('User ID: $_currentUserId', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text('Switch Role:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: widget.userRole,
              isExpanded: true,
              items: [
                DropdownMenuItem(value: 'inspector', child: Row(children: [Icon(Icons.search, size: 20, color: Colors.blue), SizedBox(width: 8), Text('Inspector')])),
                DropdownMenuItem(value: 'vendor', child: Row(children: [Icon(Icons.qr_code_2, size: 20, color: Colors.teal), SizedBox(width: 8), Text('Vendor')])),
                DropdownMenuItem(value: 'user', child: Row(children: [Icon(Icons.person, size: 20, color: Colors.grey), SizedBox(width: 8), Text('User')])),
              ],
              onChanged: (role) {
                Navigator.pop(context);
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen(userRole: role!)));
              },
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'))],
      ),
    );
  }

  void _logout() {
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SimpleAuthScreen()));
    }
  }

  String _getRoleTitle() {
    switch (widget.userRole) {
      case 'inspector': return 'Quality Inspector';
      case 'vendor': return 'Parts Vendor';
      default: return 'QRail User';
    }
  }

  IconData _getRoleIcon() {
    switch (widget.userRole) {
      case 'inspector': return Icons.search_rounded;
      case 'vendor': return Icons.qr_code_2_rounded;
      default: return Icons.person_rounded;
    }
  }

  List<Color> _getRoleColors() {
    switch (widget.userRole) {
      case 'inspector': return [Colors.blue[600]!, Colors.blue[800]!];
      case 'vendor': return [Colors.teal[600]!, Colors.teal[800]!];
      default: return [Colors.grey[600]!, Colors.grey[800]!];
    }
  }

  String _getCenterTitle() {
    switch (widget.userRole) {
      case 'inspector': return 'Ready to Inspect';
      case 'vendor': return 'Ready to Generate';
      default: return 'Ready to Scan';
    }
  }

  String _getCenterSubtitle() {
    switch (widget.userRole) {
      case 'inspector': return 'Scan QR codes to inspect railway parts\nand manage quality assessments';
      case 'vendor': return 'Create QR codes for your railway parts\nand manage inventory efficiently';
      default: return 'Point your camera at a QR code\nto get railway part information';
    }
  }

  List<Widget> _buildInspectorButtons() {
    return [
      // Primary Actions Row
      Row(
        children: [
          Expanded(
            child: _buildGridButton('QR Scanner', Icons.qr_code_scanner_rounded, Colors.blue, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => QRScannerScreen(inspectorId: _currentUserId)));
            }),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildGridButton('Analytics', Icons.dashboard_rounded, Colors.orange[600]!, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AnalyticsDashboardScreen(inspectorId: _currentUserId)));
            }),
          ),
        ],
      ),
      SizedBox(height: 12),
      
      // Secondary Actions Row
      Row(
        children: [
          Expanded(
            child: _buildGridButton('Add Data', Icons.add_circle_outline, Colors.green[600]!, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddInspectionScreen(inspectorId: _currentUserId)));
            }),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildGridButton('Manage', Icons.list_alt, Colors.purple[600]!, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ManageInspectionsScreen(inspectorId: _currentUserId)));
            }),
          ),
        ],
      ),
      SizedBox(height: 12),
      
      // History Button (Full Width)
      _buildActionButton('Scan History', Icons.history_rounded, Colors.grey[700]!, () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ScanHistoryScreen(inspectorId: _currentUserId)));
      }, isOutlined: true),
    ];
  }

  List<Widget> _buildVendorButtons() {
    return [
      _buildActionButton('Generate Part QR', Icons.qr_code_2, Colors.teal[600]!, () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => QRGeneratorScreen(vendorId: _currentUserId, vendorName: _currentUserName)));
      }),
      SizedBox(height: 12),
      _buildActionButton('Manage Inventory', Icons.inventory_2, Colors.indigo[600]!, () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => InventoryScreen(vendorId: _currentUserId, vendorName: _currentUserName)));
      }),
    ];
  }

  List<Widget> _buildUserButtons() {
    return [
      _buildActionButton('Start QR Scanner', Icons.qr_code_scanner_rounded, Colors.blue, () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => QRScannerScreen(inspectorId: _currentUserId)));
      }),
      SizedBox(height: 12),
      _buildActionButton('Scan History', Icons.history_rounded, Colors.grey[700]!, () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ScanHistoryScreen(inspectorId: _currentUserId)));
      }, isOutlined: true),
    ];
  }

  Widget _buildGridButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      height: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: color.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: EdgeInsets.all(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            SizedBox(height: 4),
            Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}