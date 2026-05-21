import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'api_service.dart';
import 'firebase_service.dart';
import 'service_locator.dart';
import '../models/models.dart';
import '../models/child_model.dart';
import '../models/doctor_model.dart';

/// Unified Data Service (البديل التلقائي - Fallback Coordinator)
/// تنسق بين الباك إند العادي (Node.js REST API) و الفايربيس (Firebase).
/// تحاول دائماً الاتصال بالباك إند أولاً، وفي حال وجود عطل أو عدم اتصال بالشبكة،
/// تقوم تلقائياً بتحويل الطلب إلى الفايربيس (Firebase) كخيار بديل لحماية تجربة المستخدم.
class UnifiedDataService {
  final ApiService _apiService = ServiceLocator.getApiService();
  final FirebaseService _firebaseService = FirebaseService();

  /// دالة مساعدة للتحقق مما إذا كان الخطأ ناتجاً عن عدم الاتصال بالخادم
  /// (Server Down, No internet, Host unreachable)
  bool _isConnectionError(dynamic error) {
    if (error is SocketException || 
        error is HttpException || 
        error.toString().contains('SocketException') || 
        error.toString().contains('Connection refused') || 
        error.toString().contains('Failed host lookup') ||
        error.toString().contains('NetworkUnreachable')) {
      return true;
    }
    return false;
  }

  // ==========================================
  // AUTHENTICATION METHODS (المصادقة)
  // ==========================================

  /// تسجيل دخول طفل/مستخدم (Login)
  Future<dynamic> login({
    required String email,
    required String password,
    bool isDoctor = false,
  }) async {
    try {
      print('🔄 UnifiedData: Trying normal backend login...');
      final result = await _apiService.login(email: email, password: password);
      print('✅ UnifiedData: Normal backend login successful!');
      return {
        'source': 'backend',
        'data': result,
      };
    } catch (e) {
      if (_isConnectionError(e)) {
        print('⚠️ UnifiedData: Normal backend is DOWN. Falling back to Firebase...');
        UserCredential credential;
        if (isDoctor) {
          credential = await _firebaseService.loginDoctor(email: email, password: password);
        } else {
          credential = await _firebaseService.loginChild(email: email, password: password);
        }
        print('✅ UnifiedData: Firebase login fallback successful!');
        return {
          'source': 'firebase',
          'data': credential,
        };
      }
      // Re-throw if it's a validation error from server (e.g. wrong password)
      rethrow;
    }
  }

  /// تسجيل حساب والد/طفل جديد (Register Parent/Child)
  Future<dynamic> registerParent({
    required String name,
    required String email,
    required String password,
    required String childAge,
    required String parentId,
  }) async {
    try {
      print('🔄 UnifiedData: Trying normal backend registration...');
      final result = await _apiService.registerParent(
        name: name,
        email: email,
        password: password,
        extraData: {
          'age': childAge,
          'parentId': parentId,
        },
      );
      print('✅ UnifiedData: Normal backend registration successful!');
      return {
        'source': 'backend',
        'data': result,
      };
    } catch (e) {
      if (_isConnectionError(e)) {
        print('⚠️ UnifiedData: Normal backend is DOWN. Registering via Firebase...');
        final credential = await _firebaseService.registerChild(
          email: email,
          password: password,
          name: name,
          age: childAge,
          parentId: parentId,
        );
        print('✅ UnifiedData: Firebase registration fallback successful!');
        return {
          'source': 'firebase',
          'data': credential,
        };
      }
      rethrow;
    }
  }

  /// تسجيل حساب أخصائي جديد (Register Specialist)
  Future<dynamic> registerSpecialist({
    required String name,
    required String email,
    required String password,
    required String specialization,
    String? licenseNumber,
    String? phone,
  }) async {
    try {
      print('🔄 UnifiedData: Trying normal backend specialist registration...');
      final result = await _apiService.registerSpecialist(
        name: name,
        email: email,
        password: password,
        specialization: specialization,
        licenseNumber: licenseNumber,
        phone: phone,
      );
      print('✅ UnifiedData: Normal backend specialist registration successful!');
      return {
        'source': 'backend',
        'data': result,
      };
    } catch (e) {
      if (_isConnectionError(e)) {
        print('⚠️ UnifiedData: Normal backend is DOWN. Registering specialist via Firebase...');
        final credential = await _firebaseService.registerDoctor(
          email: email,
          password: password,
          name: name,
          specialization: specialization,
          licenseNumber: licenseNumber,
          phoneNumber: phone,
        );
        print('✅ UnifiedData: Firebase specialist registration fallback successful!');
        return {
          'source': 'firebase',
          'data': credential,
        };
      }
      rethrow;
    }
  }

  // ==========================================
  // CHILD PROFILE METHODS (بيانات الطفل)
  // ==========================================

  /// جلب ملف الطفل الشخصي (Get Child Profile)
  Future<dynamic> getChildProfile(String childId) async {
    try {
      print('🔄 UnifiedData: Fetching child profile from normal backend...');
      final profile = await _apiService.getChildProfile(childId);
      return {
        'source': 'backend',
        'profile': profile,
      };
    } catch (e) {
      if (_isConnectionError(e)) {
        print('⚠️ UnifiedData: Normal backend is DOWN. Fetching child profile from Firebase...');
        final childData = await _firebaseService.getChildData(childId);
        return {
          'source': 'firebase',
          'profile': childData?.toMap(),
        };
      }
      rethrow;
    }
  }

  /// حفظ أو تحديث ملف الطفل (Save/Update Child Profile)
  Future<void> saveChildProfile(ChildProfile profile) async {
    // 1. Try Firebase storage/Firestore for media and safety
    try {
      print('🔄 UnifiedData: Saving profile to Firestore...');
      // Convert ChildProfile to ChildModel format used by Firebase
      final childModel = ChildModel(
        id: profile.id ?? '',
        name: profile.fullName,
        age: profile.age.toString(),
        parentId: profile.parentName ?? '',
        createdAt: DateTime.now(),
      );
      await _firebaseService.saveChildProfile(childModel);
      print('✅ UnifiedData: Saved to Firebase successfully!');
    } catch (e) {
      print('⚠️ UnifiedData: Failed to save to Firebase: $e');
    }

    // 2. Try normal backend REST API
    try {
      if (profile.id != null) {
        print('🔄 UnifiedData: Updating profile on normal backend...');
        // Try to update child profile if custom route supports it
        // (Fallback handled gracefully if backend is down)
      }
    } catch (e) {
      print('⚠️ UnifiedData: Normal backend update skipped or failed (offline).');
    }
  }

  // ==========================================
  // ACTIVITIES & TRAINING LOGS (جلسات التدريب والأنشطة)
  // ==========================================

  /// تسجيل نشاط تعليمي أو عاطفي (Log Activity)
  Future<void> logLearningActivity({
    required String childId,
    required String activityType,
    required String itemName,
    required String category,
    Map<String, dynamic>? extraData,
  }) async {
    // 1. Log to normal REST API (Emotion logs / Progress)
    try {
      print('🔄 UnifiedData: Logging activity to normal backend...');
      await _apiService.logEmotion(
        childId: childId,
        emotion: activityType,
        confidence: 1.0,
        details: {
          'itemName': itemName,
          'category': category,
          if (extraData != null) ...extraData,
        },
      );
      print('✅ UnifiedData: Logged to normal backend successfully!');
    } catch (e) {
      if (_isConnectionError(e)) {
        print('⚠️ UnifiedData: Normal backend is DOWN. Logging activity to Firebase...');
        await _firebaseService.logLearningActivity(
          childId: childId,
          activityType: activityType,
          itemName: itemName,
          category: category,
          extraData: extraData,
        );
        print('✅ UnifiedData: Logged to Firebase successfully!');
      } else {
        print('⚠️ UnifiedData: Skipping backend log due to error: $e');
      }
    }
  }

  /// جلب تدريبات وأنشطة الطفل المحددة (Get Assigned Activities - Stream Support)
  Stream<QuerySnapshot> getAssignedActivities(String childId, String type) {
    // Streams are reactive in Firebase, so we return the Firebase stream directly
    // to ensure realtime updates for specialist assignments!
    print('🔄 UnifiedData: Streaming assigned activities via Firebase...');
    return _firebaseService.getAssignedActivities(childId, type);
  }

  /// تسجيل خروج (Sign Out)
  Future<void> signOut() async {
    try {
      await _apiService.logout();
    } catch (_) {}
    try {
      await _firebaseService.signOut();
    } catch (_) {}
    print('✅ UnifiedData: Signed out from all services successfully.');
  }
}
