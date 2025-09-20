class UserModel {
  final String email;
  final String name;
  final String role;
  
  UserModel({
    required this.email,
    required this.name,
    required this.role,
  });
  
  bool get isInspector => role == 'inspector';
  bool get isVendor => role == 'vendor';
  bool get isUser => role == 'user';
}