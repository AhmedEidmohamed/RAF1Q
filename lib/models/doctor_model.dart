import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  final String? id;
  final String name;
  final String email;
  final String specialization;
  final String? licenseNumber;
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final bool isVerified;
  final Map<String, dynamic>? clinicInfo;
  final List<String>? patients;

  DoctorModel({
    this.id,
    required this.name,
    required this.email,
    required this.specialization,
    this.licenseNumber,
    this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
    this.isVerified = false,
    this.clinicInfo,
    this.patients,
  });

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'specialization': specialization,
      'licenseNumber': licenseNumber,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
      'isVerified': isVerified,
      'clinicInfo': clinicInfo ?? {},
      'patients': patients ?? [],
    };
  }

  // Create from Firestore document
  factory DoctorModel.fromMap(String id, Map<String, dynamic> map) {
    return DoctorModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      specialization: map['specialization'] ?? '',
      licenseNumber: map['licenseNumber'],
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isVerified: map['isVerified'] ?? false,
      clinicInfo: map['clinicInfo'],
      patients: List<String>.from(map['patients'] ?? []),
    );
  }

  // Create copy with updated fields
  DoctorModel copyWith({
    String? id,
    String? name,
    String? email,
    String? specialization,
    String? licenseNumber,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    bool? isVerified,
    Map<String, dynamic>? clinicInfo,
    List<String>? patients,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      specialization: specialization ?? this.specialization,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      clinicInfo: clinicInfo ?? this.clinicInfo,
      patients: patients ?? this.patients,
    );
  }
}
