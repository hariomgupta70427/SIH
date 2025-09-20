import 'package:flutter/material.dart';
import 'qr_scanner_screen.dart';
import 'screens/history_screen.dart';
import 'services/scan_history_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  int _scanCount = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _slideController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _slideController.forward();
    _loadScanCount();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadScanCount() async {
    final count = await ScanHistoryService.getHistoryCount();
    setState(() {
      _scanCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[50]!,
              Colors.white,
              Colors.blue[50]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                // Header Section
                SlideTransition(
                  position: _slideAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Railway Parts',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w300,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            'QR Scanner',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[400]!, Colors.blue[600]!],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.train_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 40),
                
                // Stats Card
                if (_scanCount > 0)
                  SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 32),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green[400]!, Colors.green[600]!],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.analytics_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Scans',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '$_scanCount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Main Content
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated QR Icon
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.blue[100]!, Colors.blue[200]!],
                                  ),
                                  borderRadius: BorderRadius.circular(70),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.2),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.qr_code_scanner_rounded,
                                  size: 70,
                                  color: Colors.blue[700],
                                ),
                              ),
                            );
                          },
                        ),
                        
                        SizedBox(height: 32),
                        
                        Text(
                          'Ready to Scan',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        
                        SizedBox(height: 12),
                        
                        Text(
                          'Point your camera at a QR code\nto get railway part information',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Action Buttons
                SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // Main Scan Button
                      Container(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, _) => QRScannerScreen(),
                                transitionsBuilder: (context, animation, _, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: Offset(0, 1),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    )),
                                    child: child,
                                  );
                                },
                              ),
                            );
                            if (result == true) {
                              _loadScanCount();
                            }
                          },
                          icon: Icon(Icons.qr_code_scanner_rounded, size: 24),
                          label: Text(
                            'Start QR Scanner',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: theme.primaryColor.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      // History Button
                      Container(
                        width: double.infinity,
                        height: 60,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, _) => HistoryScreen(),
                                transitionsBuilder: (context, animation, _, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: Offset(1, 0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                              ),
                            );
                            _loadScanCount();
                          },
                          icon: Icon(Icons.history_rounded, size: 24),
                          label: Text(
                            'Scan History',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.primaryColor,
                            side: BorderSide(color: theme.primaryColor, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}