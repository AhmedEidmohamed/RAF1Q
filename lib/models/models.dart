import 'package:flutter/material.dart';

/// Data model for Child Profile
class ChildProfile {
  final String? id; // Document ID from Firestore
  final String fullName;
  final int age;
  final DateTime dateOfBirth;
  final String gender;
  final String governorate;
  final String? school; // Optional
  final String? iqLevel; // Optional
  final String healthStatus;
  final String username;
  final String password;
  final String? doctorId; // ID of linked doctor
  final String? photoUrl; // Profile photo URL
  final String? parentName; // Parent/Guardian name
  final String? parentPhone; // Parent phone number
  final String? address; // Full address
  final List<String> allergies; // Medical allergies
  final List<String> medications; // Current medications
  final String? emergencyContact; // Emergency contact person
  final String? emergencyPhone; // Emergency contact phone

  ChildProfile({
    required this.fullName,
    required this.age,
    required this.dateOfBirth,
    required this.gender,
    required this.governorate,
    this.school,
    this.iqLevel,
    required this.healthStatus,
    required this.username,
    required this.password,
    this.doctorId,
    this.photoUrl,
    this.parentName,
    this.parentPhone,
    this.address,
    this.allergies = const [],
    this.medications = const [],
    this.emergencyContact,
    this.emergencyPhone,
    this.id,
  });

  // Convert to Map for database storage (TODO: Implement database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'age': age,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'governorate': governorate,
      'school': school,
      'iqLevel': iqLevel,
      'healthStatus': healthStatus,
      'username': username,
      'password': password,
      'doctorId': doctorId,
      'photoUrl': photoUrl,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'address': address,
      'allergies': allergies,
      'medications': medications,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
    };
  }

  // Create from Map (for database retrieval)
  factory ChildProfile.fromMap(Map<String, dynamic> map, [String? docId]) {
    return ChildProfile(
      id: docId ?? map['id'],
      fullName: map['fullName'],
      age: map['age'],
      dateOfBirth: DateTime.parse(map['dateOfBirth']),
      gender: map['gender'],
      governorate: map['governorate'],
      school: map['school'],
      iqLevel: map['iqLevel'],
      healthStatus: map['healthStatus'],
      username: map['username'],
      password: map['password'],
      doctorId: map['doctorId'],
      photoUrl: map['photoUrl'],
      parentName: map['parentName'],
      parentPhone: map['parentPhone'],
      address: map['address'],
      allergies: List<String>.from(map['allergies'] ?? []),
      medications: List<String>.from(map['medications'] ?? []),
      emergencyContact: map['emergencyContact'],
      emergencyPhone: map['emergencyPhone'],
    );
  }
}

/// Data model for Doctor Profile
class DoctorProfile {
  final String id;
  final String fullName;
  final String username;
  final String password;
  final String specialization;
  final String email;
  final String phone;
  final List<String> linkedChildrenIds; // IDs of children linked to this doctor
  final String? photoUrl; // Profile photo URL
  final String? clinicName; // Clinic/Hospital name
  final String? clinicAddress; // Clinic address
  final String? qualifications; // Medical qualifications
  final String? experience; // Years of experience
  final String? about; // About the doctor
  final List<String> languages; // Languages spoken
  final String? licenseNumber; // Medical license number
  final String? workingHours; // Working hours

  DoctorProfile({
    required this.id,
    required this.fullName,
    required this.username,
    required this.password,
    required this.specialization,
    required this.email,
    required this.phone,
    this.linkedChildrenIds = const [],
    this.photoUrl,
    this.clinicName,
    this.clinicAddress,
    this.qualifications,
    this.experience,
    this.about,
    this.languages = const [],
    this.licenseNumber,
    this.workingHours,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'password': password,
      'specialization': specialization,
      'email': email,
      'phone': phone,
      'linkedChildrenIds': linkedChildrenIds,
      'photoUrl': photoUrl,
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
      'qualifications': qualifications,
      'experience': experience,
      'about': about,
      'languages': languages,
      'licenseNumber': licenseNumber,
      'workingHours': workingHours,
    };
  }

  // Create from Map (for database retrieval)
  factory DoctorProfile.fromMap(Map<String, dynamic> map) {
    return DoctorProfile(
      id: map['id'],
      fullName: map['fullName'],
      username: map['username'],
      password: map['password'],
      specialization: map['specialization'],
      email: map['email'],
      phone: map['phone'],
      linkedChildrenIds: List<String>.from(map['linkedChildrenIds'] ?? []),
      photoUrl: map['photoUrl'],
      clinicName: map['clinicName'],
      clinicAddress: map['clinicAddress'],
      qualifications: map['qualifications'],
      experience: map['experience'],
      about: map['about'],
      languages: List<String>.from(map['languages'] ?? []),
      licenseNumber: map['licenseNumber'],
      workingHours: map['workingHours'],
    );
  }
}

/// User Role enum
enum UserRole {
  parent,
  specialist,
}

/// Person model for Stage 1 - Recognizing People
class Person {
  final String id;
  final String name;
  final String relationship;
  final String imageUrl;

  Person({
    required this.id,
    required this.name,
    required this.relationship,
    required this.imageUrl,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Person &&
        other.id == id &&
        other.name == name &&
        other.relationship == relationship &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        relationship.hashCode ^
        imageUrl.hashCode;
  }
}

/// Place model for Stage 1 - Recognizing Places
class Place {
  final String id;
  final String name;
  final String imageUrl;

  Place({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Place &&
        other.id == id &&
        other.name == name &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ imageUrl.hashCode;
  }
}

/// Object model for Stage 1 - Recognizing Objects
class ObjectItem {
  final String id;
  final String name;
  final String category; // toys, fruits, vegetables
  final String imageUrl;

  ObjectItem({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ObjectItem &&
        other.id == id &&
        other.name == name &&
        other.category == category &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ category.hashCode ^ imageUrl.hashCode;
  }
}

/// Learning Stage model
class LearningStage {
  final int stageNumber;
  final String title;
  final String description;
  final IconData icon;
  final double progress;
  final List<String> activities;

  LearningStage({
    required this.stageNumber,
    required this.title,
    required this.description,
    required this.icon,
    required this.progress,
    required this.activities,
  });
}

/// Achievement model
class Achievement {
  final String id;
  final String title;
  final String emoji;
  final DateTime dateEarned;

  Achievement({
    required this.id,
    required this.title,
    required this.emoji,
    required this.dateEarned,
  });
}
