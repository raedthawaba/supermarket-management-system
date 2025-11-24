import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String? id;
  final String name;
  final String? description;
  final String? iconUrl;
  final Timestamp? createdAt;

  Category({
    this.id,
    required this.name,
    this.description,
    this.iconUrl,
    this.createdAt,
  });

  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>? ?? {};
    
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      iconUrl: data['iconUrl'],
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name)';
  }
}