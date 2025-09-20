import '../models/part_model.dart';
import '../models/scan_history_model.dart';
import '../models/user_model.dart';
import 'demo_firebase_service.dart';

class FirebaseService {
  static bool _useDemo = true; // Always use demo mode
  
  static void enableDemoMode() {
    _useDemo = true;
    DemoFirebaseService.initializeSampleData();
  }
  
  static bool get isDemoMode => _useDemo;

  // Authentication
  static Future<UserModel?> signInWithEmailPassword(String email, String password) async {
    return DemoFirebaseService.signInWithEmailPassword(email, password);
  }

  static Future<UserModel?> registerWithEmailPassword(String email, String password, String name, String role) async {
    return DemoFirebaseService.registerWithEmailPassword(email, password, name, role);
  }

  static Future<void> signOut() async {
    // Demo mode - no action needed
  }

  // Parts Management
  static Future<String> createPart(PartModel part) async {
    return await DemoFirebaseService.createPart(part);
  }

  static Future<PartModel?> getPartById(String partId) async {
    return await DemoFirebaseService.getPartById(partId);
  }

  static Stream<List<PartModel>> getPartsByVendor(String vendorId) {
    return DemoFirebaseService.getPartsByVendor(vendorId);
  }

  static Future<void> updatePartStatus(String partId, String status) async {
    return await DemoFirebaseService.updatePartStatus(partId, status);
  }

  // Scan History Management
  static Future<String> addScanHistory(ScanHistoryModel scanHistory) async {
    return await DemoFirebaseService.addScanHistory(scanHistory);
  }

  static Stream<List<ScanHistoryModel>> getScanHistoryByInspector(String inspectorId) {
    return DemoFirebaseService.getScanHistoryByInspector(inspectorId);
  }

  static Future<void> updateScanHistory(String scanId, Map<String, dynamic> updates) async {
    return await DemoFirebaseService.updateScanHistory(scanId, updates);
  }
}