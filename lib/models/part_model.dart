import 'package:cloud_firestore/cloud_firestore.dart';

class PartModel {
  final String id;
  final String partName;
  final String vendorName;
  final String vendorId;
  final String batchNo;
  final int warrantyPeriod; // in months
  final int inspectionInterval; // in days
  final DateTime manufacturingDate;
  final DateTime createdAt;
  final String status;
  final String? description;
  final String? imageUrl;
  final Map<String, dynamic>? specifications;

  PartModel({
    required this.id,
    required this.partName,
    required this.vendorName,
    required this.vendorId,
    required this.batchNo,
    required this.warrantyPeriod,
    required this.inspectionInterval,
    required this.manufacturingDate,
    required this.createdAt,
    this.status = 'active',
    this.description,
    this.imageUrl,
    this.specifications,
  });

  factory PartModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PartModel(
      id: doc.id,
      partName: data['partName'] ?? '',
      vendorName: data['vendorName'] ?? '',
      vendorId: data['vendorId'] ?? '',
      batchNo: data['batchNo'] ?? '',
      warrantyPeriod: data['warrantyPeriod'] ?? 12,
      inspectionInterval: data['inspectionInterval'] ?? 30,
      manufacturingDate: (data['manufacturingDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'active',
      description: data['description'],
      imageUrl: data['imageUrl'],
      specifications: data['specifications'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'partName': partName,
      'vendorName': vendorName,
      'vendorId': vendorId,
      'batchNo': batchNo,
      'warrantyPeriod': warrantyPeriod,
      'inspectionInterval': inspectionInterval,
      'manufacturingDate': Timestamp.fromDate(manufacturingDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'description': description,
      'imageUrl': imageUrl,
      'specifications': specifications,
    };
  }

  bool get isWarrantyValid {
    final warrantyEndDate = manufacturingDate.add(Duration(days: warrantyPeriod * 30));
    return DateTime.now().isBefore(warrantyEndDate);
  }

  DateTime get nextInspectionDate {
    return manufacturingDate.add(Duration(days: inspectionInterval));
  }
}