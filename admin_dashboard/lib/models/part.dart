// Part model for inventory management
class Part {
  final String id;
  final String name;
  final String partNumber;
  final String category;
  final int quantity;
  final double? price;
  final String status;
  final String location;
  final String vendorName;
  final DateTime createdAt;

  Part({
    required this.id,
    required this.name,
    required this.partNumber,
    required this.category,
    required this.quantity,
    this.price,
    required this.status,
    required this.location,
    required this.vendorName,
    required this.createdAt,
  });

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      partNumber: json['part_number'] ?? json['partNumber'] ?? '',
      category: json['category'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: json['unit_price']?.toDouble() ?? json['price']?.toDouble(),
      status: json['status'] ?? '',
      location: json['location'] ?? '',
      vendorName: json['vendor_name'] ?? json['vendorName'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'part_number': partNumber,
      'category': category,
      'quantity': quantity,
      'unit_price': price,
      'status': status,
      'location': location,
      'vendor_name': vendorName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}