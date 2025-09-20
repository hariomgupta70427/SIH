import '../models/part_model.dart';
import '../models/scan_history_model.dart';
import '../models/user_model.dart';

class DemoFirebaseService {
  static final List<PartModel> _parts = [];
  static final List<ScanHistoryModel> _scanHistory = [];
  static int _partIdCounter = 1;
  static int _scanIdCounter = 1;

  // Parts Management
  static Future<String> createPart(PartModel part) async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
    
    final partId = 'P-${_partIdCounter.toString().padLeft(3, '0')}';
    _partIdCounter++;
    
    final newPart = PartModel(
      id: partId,
      partName: part.partName,
      vendorName: part.vendorName,
      vendorId: part.vendorId,
      batchNo: part.batchNo,
      warrantyPeriod: part.warrantyPeriod,
      inspectionInterval: part.inspectionInterval,
      manufacturingDate: part.manufacturingDate,
      createdAt: DateTime.now(),
      description: part.description,
      status: 'active',
    );
    
    _parts.add(newPart);
    return partId;
  }

  static Future<PartModel?> getPartById(String partId) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    try {
      return _parts.firstWhere((part) => part.id == partId);
    } catch (e) {
      // If part not found in demo data, create a sample part
      final samplePart = PartModel(
        id: partId,
        partName: 'Demo Railway Brake Pad',
        vendorName: 'Demo Railway Parts Ltd',
        vendorId: 'vendor_demo',
        batchNo: 'BP-2024-${partId.replaceAll('P-', '')}',
        warrantyPeriod: 24,
        inspectionInterval: 30,
        manufacturingDate: DateTime.now().subtract(Duration(days: 60)),
        createdAt: DateTime.now().subtract(Duration(days: 60)),
        description: 'High-quality brake pad for railway applications. Manufactured with premium materials for enhanced safety and durability.',
        status: 'active',
      );
      
      _parts.add(samplePart);
      return samplePart;
    }
  }

  static Stream<List<PartModel>> getPartsByVendor(String vendorId) {
    return Stream.periodic(Duration(seconds: 1), (count) {
      return _parts.where((part) => part.vendorId == vendorId).toList();
    });
  }

  static Future<void> updatePartStatus(String partId, String status) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final partIndex = _parts.indexWhere((part) => part.id == partId);
    if (partIndex != -1) {
      // Create updated part (since PartModel is immutable)
      final oldPart = _parts[partIndex];
      final updatedPart = PartModel(
        id: oldPart.id,
        partName: oldPart.partName,
        vendorName: oldPart.vendorName,
        vendorId: oldPart.vendorId,
        batchNo: oldPart.batchNo,
        warrantyPeriod: oldPart.warrantyPeriod,
        inspectionInterval: oldPart.inspectionInterval,
        manufacturingDate: oldPart.manufacturingDate,
        createdAt: oldPart.createdAt,
        description: oldPart.description,
        status: status,
      );
      
      _parts[partIndex] = updatedPart;
    }
  }

  // Scan History Management
  static Future<String> addScanHistory(ScanHistoryModel scanHistory) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final scanId = 'SCAN-${_scanIdCounter.toString().padLeft(4, '0')}';
    _scanIdCounter++;
    
    final newScan = ScanHistoryModel(
      id: scanId,
      inspectorId: scanHistory.inspectorId,
      partId: scanHistory.partId,
      partName: scanHistory.partName,
      vendorName: scanHistory.vendorName,
      scannedAt: DateTime.now(),
      status: scanHistory.status,
      remarks: scanHistory.remarks,
      inspectionResult: scanHistory.inspectionResult,
      inspectionData: scanHistory.inspectionData,
    );
    
    _scanHistory.add(newScan);
    return scanId;
  }

  static Stream<List<ScanHistoryModel>> getScanHistoryByInspector(String inspectorId) {
    return Stream.periodic(Duration(seconds: 1), (count) {
      return _scanHistory
          .where((scan) => scan.inspectorId == inspectorId)
          .toList()
        ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    });
  }

  static Future<void> updateScanHistory(String scanId, Map<String, dynamic> updates) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final scanIndex = _scanHistory.indexWhere((scan) => scan.id == scanId);
    if (scanIndex != -1) {
      final oldScan = _scanHistory[scanIndex];
      final updatedScan = ScanHistoryModel(
        id: oldScan.id,
        inspectorId: oldScan.inspectorId,
        partId: oldScan.partId,
        partName: oldScan.partName,
        vendorName: oldScan.vendorName,
        scannedAt: oldScan.scannedAt,
        status: updates['status'] ?? oldScan.status,
        remarks: updates['remarks'] ?? oldScan.remarks,
        inspectionResult: updates['inspectionResult'] ?? oldScan.inspectionResult,
        inspectionData: updates['inspectionData'] ?? oldScan.inspectionData,
      );
      
      _scanHistory[scanIndex] = updatedScan;
    }
  }

  // Authentication methods
  static Future<UserModel?> signInWithEmailPassword(String email, String password) async {
    await Future.delayed(Duration(milliseconds: 500));
    
    // Demo authentication
    String role = 'user';
    if (email == 'inspector@qrail.com') role = 'inspector';
    if (email == 'vendor@qrail.com') role = 'vendor';
    
    return UserModel(
      email: email,
      name: 'Demo User',
      role: role,
    );
  }

  static Future<UserModel?> registerWithEmailPassword(String email, String password, String name, String role) async {
    await Future.delayed(Duration(milliseconds: 500));
    
    return UserModel(
      email: email,
      name: name,
      role: role,
    );
  }

  // Initialize with some sample data
  static void initializeSampleData() {
    if (_parts.isEmpty) {
      // Add sample parts
      _parts.addAll([
        PartModel(
          id: 'P-001',
          partName: 'Railway Brake Disc',
          vendorName: 'Premium Rail Components',
          vendorId: 'vendor_001',
          batchNo: 'BD-2024-001',
          warrantyPeriod: 36,
          inspectionInterval: 45,
          manufacturingDate: DateTime.now().subtract(Duration(days: 90)),
          createdAt: DateTime.now().subtract(Duration(days: 90)),
          description: 'High-performance brake disc for high-speed trains',
          status: 'active',
        ),
        PartModel(
          id: 'P-002',
          partName: 'Wheel Bearing Assembly',
          vendorName: 'Elite Railway Parts',
          vendorId: 'vendor_002',
          batchNo: 'WB-2024-002',
          warrantyPeriod: 24,
          inspectionInterval: 30,
          manufacturingDate: DateTime.now().subtract(Duration(days: 45)),
          createdAt: DateTime.now().subtract(Duration(days: 45)),
          description: 'Precision wheel bearing for smooth operation',
          status: 'active',
        ),
        PartModel(
          id: 'P-003',
          partName: 'Signal Control Unit',
          vendorName: 'Smart Rail Systems',
          vendorId: 'vendor_003',
          batchNo: 'SC-2024-003',
          warrantyPeriod: 60,
          inspectionInterval: 90,
          manufacturingDate: DateTime.now().subtract(Duration(days: 30)),
          createdAt: DateTime.now().subtract(Duration(days: 30)),
          description: 'Advanced signal control system with IoT capabilities',
          status: 'active',
        ),
      ]);
      
      _partIdCounter = 4;
    }
    
    if (_scanHistory.isEmpty) {
      // Add sample scan history
      _scanHistory.addAll([
        ScanHistoryModel(
          id: 'SCAN-0001',
          inspectorId: 'inspector_demo',
          partId: 'P-001',
          partName: 'Railway Brake Disc',
          vendorName: 'Premium Rail Components',
          scannedAt: DateTime.now().subtract(Duration(hours: 2)),
          status: 'inspected',
          remarks: 'Part in excellent condition',
          inspectionResult: 'pass',
        ),
        ScanHistoryModel(
          id: 'SCAN-0002',
          inspectorId: 'inspector_demo',
          partId: 'P-002',
          partName: 'Wheel Bearing Assembly',
          vendorName: 'Elite Railway Parts',
          scannedAt: DateTime.now().subtract(Duration(hours: 5)),
          status: 'inspected',
          remarks: 'Minor wear detected, schedule maintenance',
          inspectionResult: 'pass',
        ),
      ]);
      
      _scanIdCounter = 3;
    }
  }
}