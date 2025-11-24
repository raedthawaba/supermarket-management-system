import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? id;
  final String uid;
  final String email;
  final String name;
  final String role; // 'admin' or 'staff'
  final Timestamp? createdAt;
  final bool active;

  User({
    this.id,
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.createdAt,
    this.active = true,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>? ?? {};
    
    return User(
      id: doc.id,
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'staff',
      createdAt: data['createdAt'] as Timestamp?,
      active: data['active'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'active': active,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isStaff => role == 'staff';

  @override
  String toString() {
    return 'User(id: $id, name: $name, role: $role)';
  }
}