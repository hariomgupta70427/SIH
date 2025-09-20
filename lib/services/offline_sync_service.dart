// Offline sync service for Firebase integration
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _realtimeDb = FirebaseDatabase.instance;

  // Connectivity monitoring
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Sync status
  bool _isOnline = true;
  bool _isSyncing = false;
  final StreamController<bool> _syncStatusController =
      StreamController<bool>.broadcast();

  // Pending operations queue
  final List<PendingOperation> _pendingOperations = [];

  // Initialize offline sync
  Future<void> initialize() async {
    // Enable Firestore offline persistence (enabled by default on mobile)
    await _enableFirestoreOffline();

    // Enable Realtime Database offline persistence
    await _enableRealtimeDbOffline();

    // Start connectivity monitoring
    _startConnectivityMonitoring();

    print('✓ Offline sync service initialized');
  }

  // Enable Firestore offline persistence
  Future<void> _enableFirestoreOffline() async {
    try {
      // Only enable persistence on mobile platforms
      if (!kIsWeb) {
        // Firestore offline persistence is enabled by default on mobile
        _firestore.settings = const Settings(persistenceEnabled: true);
        print('✓ Firestore offline persistence enabled');
      } else {
        print('✓ Web platform - using default Firestore settings');
      }
    } catch (e) {
      // Persistence may already be enabled
      print('Firestore persistence: $e');
    }
  }

  // Enable Realtime Database offline persistence
  Future<void> _enableRealtimeDbOffline() async {
    try {
      // Only enable on mobile platforms
      if (!kIsWeb) {
        // Enable offline persistence for Realtime Database
        _realtimeDb.setPersistenceEnabled(true);

        // Set cache size (10MB)
        _realtimeDb.setPersistenceCacheSizeBytes(10 * 1024 * 1024);

        print('✓ Realtime Database offline persistence enabled');
      } else {
        print('✓ Web platform - using default Realtime DB settings');
      }
    } catch (e) {
      print('Realtime DB persistence error: $e');
    }
  }

  // Start monitoring connectivity changes
  void _startConnectivityMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final wasOnline = _isOnline;
        _isOnline = !results.contains(ConnectivityResult.none);

        print('Connectivity changed: ${_isOnline ? 'Online' : 'Offline'}');

        // If we just came back online, sync pending operations
        if (!wasOnline && _isOnline) {
          _syncPendingOperations();
        }

        _syncStatusController.add(_isOnline);
      },
    );
  }

  // Add part data with offline support
  Future<void> addPart(Map<String, dynamic> partData) async {
    try {
      if (_isOnline) {
        // Online: Write directly to Firestore
        await _firestore.collection('parts').add({
          ...partData,
          'createdAt': FieldValue.serverTimestamp(),
          'syncStatus': 'synced',
        });
        print('✓ Part added online');
      } else {
        // Offline: Queue operation and write to local cache
        final operation = PendingOperation(
          type: OperationType.create,
          collection: 'parts',
          data: partData,
          timestamp: DateTime.now(),
        );

        _pendingOperations.add(operation);

        // Write to local cache with pending status
        await _firestore.collection('parts').add({
          ...partData,
          'createdAt': DateTime.now(),
          'syncStatus': 'pending',
        });

        print('✓ Part queued for sync (offline)');
      }
    } catch (e) {
      print('Error adding part: $e');
      rethrow;
    }
  }

  // Update part data with offline support
  Future<void> updatePart(String partId, Map<String, dynamic> updates) async {
    try {
      if (_isOnline) {
        // Online: Update directly
        await _firestore.collection('parts').doc(partId).update({
          ...updates,
          'updatedAt': FieldValue.serverTimestamp(),
          'syncStatus': 'synced',
        });
        print('✓ Part updated online');
      } else {
        // Offline: Queue operation
        final operation = PendingOperation(
          type: OperationType.update,
          collection: 'parts',
          documentId: partId,
          data: updates,
          timestamp: DateTime.now(),
        );

        _pendingOperations.add(operation);

        // Update local cache
        await _firestore.collection('parts').doc(partId).update({
          ...updates,
          'updatedAt': DateTime.now(),
          'syncStatus': 'pending',
        });

        print('✓ Part update queued for sync (offline)');
      }
    } catch (e) {
      print('Error updating part: $e');
      rethrow;
    }
  }

  // Add inspection with offline support
  Future<void> addInspection(Map<String, dynamic> inspectionData) async {
    try {
      if (_isOnline) {
        // Online: Write to both Firestore and Realtime Database
        await Future.wait([
          _firestore.collection('inspections').add({
            ...inspectionData,
            'createdAt': FieldValue.serverTimestamp(),
            'syncStatus': 'synced',
          }),
          _realtimeDb.ref('inspections').push().set({
            ...inspectionData,
            'createdAt': ServerValue.timestamp,
          }),
        ]);
        print('✓ Inspection added online');
      } else {
        // Offline: Queue for sync
        final operation = PendingOperation(
          type: OperationType.create,
          collection: 'inspections',
          data: inspectionData,
          timestamp: DateTime.now(),
        );

        _pendingOperations.add(operation);

        // Store locally
        await _firestore.collection('inspections').add({
          ...inspectionData,
          'createdAt': DateTime.now(),
          'syncStatus': 'pending',
        });

        print('✓ Inspection queued for sync (offline)');
      }
    } catch (e) {
      print('Error adding inspection: $e');
      rethrow;
    }
  }

  // Get parts with offline support
  Stream<QuerySnapshot> getPartsStream() {
    return _firestore
        .collection('parts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get inspections with offline support
  Stream<QuerySnapshot> getInspectionsStream() {
    return _firestore
        .collection('inspections')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Sync pending operations when back online
  Future<void> _syncPendingOperations() async {
    if (_isSyncing || _pendingOperations.isEmpty) return;

    _isSyncing = true;
    print('🔄 Syncing ${_pendingOperations.length} pending operations...');

    final operationsToSync = List<PendingOperation>.from(_pendingOperations);
    _pendingOperations.clear();

    int successCount = 0;
    int failureCount = 0;

    for (final operation in operationsToSync) {
      try {
        await _executePendingOperation(operation);
        successCount++;
      } catch (e) {
        print('Failed to sync operation: $e');
        _pendingOperations.add(operation); // Re-queue failed operation
        failureCount++;
      }
    }

    print('✓ Sync completed: $successCount success, $failureCount failed');
    _isSyncing = false;
  }

  // Execute a pending operation
  Future<void> _executePendingOperation(PendingOperation operation) async {
    switch (operation.type) {
      case OperationType.create:
        if (operation.collection == 'inspections') {
          // Sync to both Firestore and Realtime Database
          await Future.wait([
            _firestore.collection(operation.collection).add({
              ...operation.data,
              'createdAt': FieldValue.serverTimestamp(),
              'syncStatus': 'synced',
            }),
            _realtimeDb.ref(operation.collection).push().set({
              ...operation.data,
              'createdAt': ServerValue.timestamp,
            }),
          ]);
        } else {
          await _firestore.collection(operation.collection).add({
            ...operation.data,
            'createdAt': FieldValue.serverTimestamp(),
            'syncStatus': 'synced',
          });
        }
        break;

      case OperationType.update:
        await _firestore
            .collection(operation.collection)
            .doc(operation.documentId!)
            .update({
          ...operation.data,
          'updatedAt': FieldValue.serverTimestamp(),
          'syncStatus': 'synced',
        });
        break;

      case OperationType.delete:
        await _firestore
            .collection(operation.collection)
            .doc(operation.documentId!)
            .delete();
        break;
    }
  }

  // Get sync status stream
  Stream<bool> get syncStatusStream => _syncStatusController.stream;

  // Get current online status
  bool get isOnline => _isOnline;

  // Get pending operations count
  int get pendingOperationsCount => _pendingOperations.length;

  // Force sync (manual trigger)
  Future<void> forcSync() async {
    if (_isOnline) {
      await _syncPendingOperations();
    } else {
      print('Cannot sync: Device is offline');
    }
  }

  // Clear all pending operations (use with caution)
  void clearPendingOperations() {
    _pendingOperations.clear();
    print('⚠️ All pending operations cleared');
  }

  // Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncStatusController.close();
  }
}

// Enum for operation types
enum OperationType { create, update, delete }

// Class to represent pending operations
class PendingOperation {
  final OperationType type;
  final String collection;
  final String? documentId;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  PendingOperation({
    required this.type,
    required this.collection,
    this.documentId,
    required this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'collection': collection,
      'documentId': documentId,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}