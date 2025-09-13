// Inspection model for quality control management
class Inspection {
  final String id;
  final String partId;
  final String partName;
  final String inspectorName;
  final DateTime inspectionDate;
  final String result;
  final int? score;
  final String remarks;
  final DateTime createdAt;

  Inspection({
    required this.id,
    required this.partId,
    required this.partName,
    required this.inspectorName,
    required this.inspectionDate,
    required this.result,
    this.score,
    required this.remarks,
    required this.createdAt,
  });

  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      id: json['id'] ?? '',
      partId: json['part_id'] ?? json['partId'] ?? '',
      partName: json['part_name'] ?? json['partName'] ?? '',
      inspectorName: json['inspector_name'] ?? json['inspectorName'] ?? '',
      inspectionDate: DateTime.tryParse(json['inspection_date'] ?? json['inspectionDate'] ?? '') ?? DateTime.now(),
      result: json['result'] ?? '',
      score: json['score'],
      remarks: json['remarks'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'part_id': partId,
      'part_name': partName,
      'inspector_name': inspectorName,
      'inspection_date': inspectionDate.toIso8601String(),
      'result': result,
      'score': score,
      'remarks': remarks,
      'created_at': createdAt.toIso8601String(),
    };
  }
}