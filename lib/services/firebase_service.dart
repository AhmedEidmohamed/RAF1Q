import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/child_model.dart';
import '../models/doctor_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ===== CHILD METHODS =====

  // Register child with email and password
  Future<UserCredential> registerChild({
    required String email,
    required String password,
    required String name,
    required String age,
    required String parentId,
  }) async {
    try {
      // Create auth user
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create child profile in Firestore
      ChildModel child = ChildModel(
        id: userCredential.user!.uid,
        name: name,
        age: age,
        parentId: parentId,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('children').doc(child.id).set(child.toMap());

      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Login child
  Future<UserCredential> loginChild({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verify it's a child account
      DocumentSnapshot childDoc = await _firestore
          .collection('children')
          .doc(userCredential.user!.uid)
          .get();

      if (!childDoc.exists) {
        await _auth.signOut();
        throw Exception('This is not a child account');
      }

      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Get child data
  Future<ChildModel?> getChildData(String childId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('children').doc(childId).get();

      if (doc.exists) {
        return ChildModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get child data: $e');
    }
  }

  // Update child profile
  Future<void> updateChildProfile(ChildModel child) async {
    try {
      await _firestore
          .collection('children')
          .doc(child.id)
          .update(child.toMap());
    } catch (e) {
      throw Exception('Failed to update child profile: $e');
    }
  }

  // Save child profile (creates or updates) - uses set with merge for both new and existing users
  Future<void> saveChildProfile(ChildModel child) async {
    try {
      await _firestore
          .collection('children')
          .doc(child.id)
          .set(child.toMap(), SetOptions(merge: true));
      print('Child profile saved to Firestore: ${child.id}');
    } catch (e) {
      throw Exception('Failed to save child profile: $e');
    }
  }

  // Upload child profile image
  Future<String> uploadChildImage(String childId, String imagePath) async {
    try {
      Reference ref = _storage.ref().child('children/$childId/profile.jpg');
      UploadTask uploadTask = ref.putFile(imagePath as File);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // ===== DOCTOR METHODS =====

  // Register doctor
  Future<UserCredential> registerDoctor({
    required String email,
    required String password,
    required String name,
    required String specialization,
    String? licenseNumber,
    String? phoneNumber,
  }) async {
    try {
      // Create auth user
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create doctor profile in Firestore
      DoctorModel doctor = DoctorModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        specialization: specialization,
        licenseNumber: licenseNumber,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('doctors').doc(doctor.id).set(doctor.toMap());

      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Login doctor
  Future<UserCredential> loginDoctor({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verify it's a doctor account
      DocumentSnapshot doctorDoc = await _firestore
          .collection('doctors')
          .doc(userCredential.user!.uid)
          .get();

      if (!doctorDoc.exists) {
        await _auth.signOut();
        throw Exception('This is not a doctor account');
      }

      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Get doctor data
  Future<DoctorModel?> getDoctorData(String doctorId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('doctors').doc(doctorId).get();

      if (doc.exists) {
        return DoctorModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get doctor data: $e');
    }
  }

  // Update doctor profile
  Future<void> updateDoctorProfile(DoctorModel doctor) async {
    try {
      await _firestore
          .collection('doctors')
          .doc(doctor.id)
          .update(doctor.toMap());
    } catch (e) {
      throw Exception('Failed to update doctor profile: $e');
    }
  }

  // Generic image upload to Firebase Storage
  Future<String> uploadImage(String path, File imageFile) async {
    try {
      Reference ref = _storage.ref().child(path);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Upload doctor profile image
  Future<String> uploadDoctorImage(String doctorId, String imagePath) async {
    return uploadImage('doctors/$doctorId/profile.jpg', File(imagePath));
  }

  // Get all children for a doctor
  Future<List<ChildModel>> getDoctorPatients(String doctorId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('children')
          .where('assignedDoctorId', isEqualTo: doctorId)
          .get();

      return querySnapshot.docs
          .map((doc) =>
              ChildModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get patients: $e');
    }
  }

  // Assign doctor to child
  Future<void> assignDoctorToChild(String doctorId, String childId) async {
    try {
      await _firestore.collection('children').doc(childId).update({
        'assignedDoctorId': doctorId,
      });

      await _firestore.collection('doctors').doc(doctorId).update({
        'patients': FieldValue.arrayUnion([childId]),
      });
    } catch (e) {
      throw Exception('Failed to assign doctor: $e');
    }
  }

  // ===== ACTIVITY METHODS =====

  // Assign training activity to child
  Future<void> assignActivityToChild({
    required String childId,
    required String type, // 'person', 'place', 'object'
    required Map<String, dynamic> activityData,
  }) async {
    try {
      await _firestore
          .collection('children')
          .doc(childId)
          .collection('assigned_activities')
          .add({
        ...activityData,
        'type': type,
        'assignedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to assign activity: $e');
    }
  }

  // Log granular learning activity (for detailed doctor reports)
  Future<void> logLearningActivity({
    required String childId,
    required String activityType, // 'view_item', 'quiz_success', 'quiz_fail'
    required String itemName,
    required String category, // 'object', 'person', 'place'
    Map<String, dynamic>? extraData,
  }) async {
    try {
      await _firestore
          .collection('children')
          .doc(childId)
          .collection('learning_activities')
          .add({
        'activityType': activityType,
        'itemName': itemName,
        'category': category,
        'extraData': extraData,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging learning activity: $e');
    }
  }

  // Get learning activities for a child
  Stream<QuerySnapshot> getLearningActivities(String childId) {
    return _firestore
        .collection('children')
        .doc(childId)
        .collection('learning_activities')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get assigned activities for a child
  Stream<QuerySnapshot> getAssignedActivities(String childId, String type) {
    return _firestore
        .collection('children')
        .doc(childId)
        .collection('assigned_activities')
        .where('type', isEqualTo: type)
        .snapshots();
  }

  // ===== GENERAL METHODS =====

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  // Handle auth errors
  String _handleAuthError(dynamic error) {
    print('Firebase Auth Error: $error'); // Debug logging

    if (error is FirebaseAuthException) {
      print('Firebase Auth Error Code: ${error.code}'); // Debug logging
      print('Firebase Auth Error Message: ${error.message}'); // Debug logging

      switch (error.code) {
        case 'weak-password':
          return 'Password should be at least 6 characters';
        case 'email-already-in-use':
          return 'An account already exists for this email';
        case 'user-not-found':
          return 'No user found for this email';
        case 'wrong-password':
          return 'Wrong password provided';
        case 'invalid-email':
          return 'Invalid email address';
        case 'user-disabled':
          return 'This user account has been disabled';
        case 'too-many-requests':
          return 'Too many requests. Try again later';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled';
        case 'configuration-missing':
          return 'Firebase configuration is missing. Please check your firebase_options.dart file';
        case 'project-not-found':
          return 'Firebase project not found. Please check your project ID configuration';
        default:
          final message = error.message ?? 'Unknown error';
          return 'Authentication failed (${error.code}): $message';
      }
    }
    return 'An unexpected error occurred: $error';
  }
}
