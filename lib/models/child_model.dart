import 'package:cloud_firestore/cloud_firestore.dart';

class ChildModel {
  final String? id;
  final String name;
  final String age;
  final String parentId;
  final String? profileImageUrl;
  final DateTime createdAt;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic>? progress;
  final String? assignedDoctorId;

  ChildModel({
    this.id,
    required this.name,
    required this.age,
    required this.parentId,
    this.profileImageUrl,
    required this.createdAt,
    this.preferences,
    this.progress,
    this.assignedDoctorId,
  });

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'parentId': parentId,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
      'preferences': preferences ?? {},
      'progress': progress ?? {},
      'assignedDoctorId': assignedDoctorId,
    };
  }

  // Create from Firestore document
  factory ChildModel.fromMap(String id, Map<String, dynamic> map) {
    return ChildModel(
      id: id,
      name: map['name'] ?? '',
      age: map['age'] ?? '',
      parentId: map['parentId'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      preferences: map['preferences'],
      progress: map['progress'],
      assignedDoctorId: map['assignedDoctorId'],
    );
  }

  // Create copy with updated fields
  ChildModel copyWith({
    String? id,
    String? name,
    String? age,
    String? parentId,
    String? profileImageUrl,
    DateTime? createdAt,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? progress,
    String? assignedDoctorId,
  }) {
    return ChildModel(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      parentId: parentId ?? this.parentId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
      progress: progress ?? this.progress,
      assignedDoctorId: assignedDoctorId ?? this.assignedDoctorId,
    );
  }
}
