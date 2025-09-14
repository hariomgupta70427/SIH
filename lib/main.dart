import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
import 'services/offline_sync_service.dart';

// Debug flag for demo mode
const bool USE_DEV_AUTH = bool.fromEnvironment('USE_DEV_AUTH', defaultValue: true);

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!USE_DEV_AUTH) {
    // Initialize Firebase only in production mode
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  
  // Initialize offline sync service
  await OfflineSyncService().initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Railway Parts QR Scanner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthWrapper(),
    );
  }
}

// Wrapper to handle authentication state with offline sync status
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (USE_DEV_AUTH) {
      // Demo mode - bypass Firebase auth
      return HomeScreen();
    }
    
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing...'),
                  SizedBox(height: 8),
                  // Show offline sync status
                  StreamBuilder<bool>(
                    stream: OfflineSyncService().syncStatusStream,
                    builder: (context, syncSnapshot) {
                      final isOnline = syncSnapshot.data ?? true;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isOnline ? Icons.cloud_done : Icons.cloud_off,
                            color: isOnline ? Colors.green : Colors.orange,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            isOnline ? 'Online' : 'Offline',
                            style: TextStyle(
                              color: isOnline ? Colors.green : Colors.orange,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }
        
        // Navigate based on auth state
        if (snapshot.hasData) {
          return HomeScreen();
        } else {
          return AuthScreen();
        }
      },
    );
  }
}