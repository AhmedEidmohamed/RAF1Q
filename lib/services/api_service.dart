import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service for interacting with the Rafiq Backend API
/// provides endpoints for authentication, AI, assessment, behavior,
/// child profiles, communication, diagnostics, emotions, interactions,
/// progress tracking, recognition, specialist operations, and training sessions.
class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web/Desktop
  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:5000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000';
    }
    return 'http://localhost:5000';
  }

  late final String baseUrl;
  String? _cachedToken;

  ApiService({String? baseUrl}) {
    this.baseUrl = baseUrl ?? defaultBaseUrl;
  }

  /// Initialize token from shared preferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString('auth_token');
  }

  /// Get current cached token
  String? get token => _cachedToken;

  /// Check if user is authenticated
  bool get isAuthenticated => _cachedToken != null;

  /// Save token to preferences and memory cache
  Future<void> setToken(String? token) async {
    _cachedToken = token;
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('auth_token', token);
    } else {
      await prefs.remove('auth_token');
    }
  }

  /// Helper to generate headers with Authorization token if available
  Map<String, String> _getHeaders({String? contentType}) {
    final headers = <String, String>{};
    if (contentType != null) {
      headers['Content-Type'] = contentType;
    }
    if (_cachedToken != null) {
      headers['Authorization'] = 'Bearer $_cachedToken';
    }
    return headers;
  }

  /// Process response and throw exceptions on failure
  dynamic _processResponse(http.Response response) {
    final int statusCode = response.statusCode;
    
    // Decode response body if it's JSON
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = response.body;
    }

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    } else {
      final errorMessage = body is Map && body.containsKey('message')
          ? body['message']
          : 'Server returned error status code: $statusCode';
      throw HttpException(errorMessage, uri: response.request?.url);
    }
  }

  // ==========================================
  // MODULE 1: AUTHENTICATION ROUTES (/auth)
  // ==========================================

  /// POST /auth/register - تسجيل مستخدم جديد (أب/أم)
  Future<Map<String, dynamic>> registerParent({
    required String name,
    required String email,
    required String password,
    Map<String, dynamic>? extraData,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _getHeaders(contentType: 'application/json'),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        if (extraData != null) ...extraData,
      }),
    );
    final result = _processResponse(response) as Map<String, dynamic>;
    if (result.containsKey('token')) {
      await setToken(result['token']);
    }
    return result;
  }

  /// POST /auth/register-specialist - تسجيل أخصائي جديد
  Future<Map<String, dynamic>> registerSpecialist({
    required String name,
    required String email,
    required String password,
    required String specialization,
    String? licenseNumber,
    String? phone,
    Map<String, dynamic>? extraData,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register-specialist'),
      headers: _getHeaders(contentType: 'application/json'),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'specialization': specialization,
        if (licenseNumber != null) 'licenseNumber': licenseNumber,
        if (phone != null) 'phone': phone,
        if (extraData != null) ...extraData,
      }),
    );
    final result = _processResponse(response) as Map<String, dynamic>;
    if (result.containsKey('token')) {
      await setToken(result['token']);
    }
    return result;
  }

  /// POST /auth/login - تسجيل الدخول
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _getHeaders(contentType: 'application/json'),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    final result = _processResponse(response) as Map<String, dynamic>;
    if (result.containsKey('token')) {
      await setToken(result['token']);
    }
    return result;
  }

  /// GET /auth/me - الحصول على بيانات المستخدم الحالي
  Future<Map<String, dynamic>> getMe() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  /// Logout - clear local authentication state
  Future<void> logout() async {
    await setToken(null);
  }

  // ==========================================
  // MODULE 2: AI ROUTES (/api/ai)
  // ==========================================

  /// POST /api/ai/detect-gesture - كشف الإيماءات من صورة
  /// Expects multipart/form-data
  Future<Map<String, dynamic>> detectGesture(dynamic fileSource) async {
    final uri = Uri.parse('$baseUrl/api/ai/detect-gesture');
    final request = http.MultipartRequest('POST', uri);
    
    // Add auth headers
    request.headers.addAll(_getHeaders());

    if (kIsWeb) {
      if (fileSource is List<int>) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            fileSource,
            filename: 'gesture_upload.jpg',
          ),
        );
      } else {
        throw ArgumentError('For Web platform, fileSource must be a List<int> of bytes.');
      }
    } else {
      if (fileSource is File) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            fileSource.path,
          ),
        );
      } else if (fileSource is String) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            fileSource,
          ),
        );
      } else {
        throw ArgumentError('fileSource must be a File or a String path on native platforms.');
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _processResponse(response) as Map<String, dynamic>;
  }

  // ==========================================
  // MODULE 3: ASSESSMENT ROUTES (/api/assessment)
  // ==========================================

  /// GET /api/assessment/challenge - الحصول على تحدي تقييم
  Future<Map<String, dynamic>> getAssessmentChallenge() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/assessment/challenge'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  /// POST /api/assessment/submit - إرسال إجابة التقييم
  Future<Map<String, dynamic>> submitAssessmentAnswer(Map<String, dynamic> answerData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/assessment/submit'),
      headers: _getHeaders(contentType: 'application/json'),
      body: jsonEncode(answerData),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  // ==========================================
  // MODULE 4: BEHAVIOR ROUTES (/api/behavior)
  // ==========================================

  /// GET /api/behavior/guidelines - الحصول على جميع الإرشادات الأبوية
  Future<List<dynamic>> getBehaviorGuidelines() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/behavior/guidelines'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as List<dynamic>;
  }

  /// GET /api/behavior/list - الحصول على قائمة أسماء السلوكيات
  Future<List<dynamic>> getBehaviorList() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/behavior/list'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as List<dynamic>;
  }

  /// GET /api/behavior/guidelines/:behaviorName - الحصول على تفاصيل سلوك محدد
  Future<Map<String, dynamic>> getBehaviorGuidelinesByName(String behaviorName) async {
    final encodedName = Uri.encodeComponent(behaviorName);
    final response = await http.get(
      Uri.parse('$baseUrl/api/behavior/guidelines/$encodedName'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  /// POST /api/behavior/recommend - الحصول على توصية لسلوك محدد
  Future<Map<String, dynamic>> getBehaviorRecommendation({
    required String behavior,
    required String function,
    required String severity,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/behavior/recommend'),
      headers: _getHeaders(contentType: 'application/json'),
      body: jsonEncode({
        'behavior': behavior,
        'function': function,
        'severity': severity,
      }),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  /// POST /api/behavior/assess - تقييم سلوك (توقع function + severity)
  Future<Map<String, dynamic>> assessBehavior({
    required String description,
    Map<String, dynamic>? extraContext,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/behavior/assess'),
      headers: _getHeaders(contentType: 'application/json'),
      body: jsonEncode({
        'description': description,
        if (extraContext != null) ...extraContext,
      }),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  // ==========================================
  // MODULE 5: CHILD ROUTES (/api/child)
  // ==========================================

  /// GET /api/child/:childId/profile - الحصول على ملف الطفل
  Future<Map<String, dynamic>> getChildProfile(String childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/child/$childId/profile'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  /// GET /api/child/:childId/treatment-plan - الحصول على خطة علاج الطفل
  Future<Map<String, dynamic>> getChildTreatmentPlan(String childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/child/$childId/treatment-plan'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  // ==========================================
  // MODULE 6: COMMUNICATION ROUTES (/api/communication)
  // ==========================================

  /// POST /api/communication/stt - تحويل الصوت إلى نص
  /// Expects audio file upload via multipart/form-data
  Future<Map<String, dynamic>> speechToText(dynamic fileSource) async {
    final uri = Uri.parse('$baseUrl/api/communication/stt');
    final request = http.MultipartRequest('POST', uri);
    
    // Add auth headers
    request.headers.addAll(_getHeaders());

    if (kIsWeb) {
      if (fileSource is List<int>) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'audio',
            fileSource,
            filename: 'speech_recording.mp3',
          ),
        );
      } else {
        throw ArgumentError('For Web platform, fileSource must be a List<int> of bytes.');
      }
    } else {
      if (fileSource is File) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'audio',
            fileSource.path,
          ),
        );
      } else if (fileSource is String) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'audio',
            fileSource,
          ),
        );
      } else {
        throw ArgumentError('fileSource must be a File or a String path on native platforms.');
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _processResponse(response) as Map<String, dynamic>;
  }

  // ==========================================
  // MODULE 7: DIAGNOSTIC ROUTES (/api/diagnostic)
  // ==========================================

  /// POST /api/diagnostic/submit - إرسال اختبار تشخيصي
  Future<Map<String, dynamic>> submitDiagnosticTest(Map<String, dynamic> testData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/diagnostic/submit'),
      headers: _getHeaders(contentType: 'application/json'),
      body: jsonEncode(testData),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  /// GET /api/diagnostic/child/:childId - الحصول على نتائج التشخيص للطفل
  Future<Map<String, dynamic>> getDiagnosticResults(String childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/diagnostic/child/$childId'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  /// GET /api/diagnostic/recommend/:childId - الحصول على توصية Rafiq للطفل
  Future<Map<String, dynamic>> getRafiqRecommendation(String childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/diagnostic/recommend/$childId'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  // ==========================================
  // MODULE 8: EMOTION ROUTES (/api/emotion)
  // ==========================================

  /// POST /api/emotion/log - تسجيل عاطفة للطفل
  Future<Map<String, dynamic>> logEmotion({
    required String childId,
    required String emotion,
    required double confidence,
    Map<String, dynamic>? details,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/emotion/log'),
      headers: _getHeaders(contentType: 'application/json'),
      body: jsonEncode({
        'childId': childId,
        'emotion': emotion,
        'confidence': confidence,
        if (details != null) 'details': details,
      }),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  /// GET /api/emotion/summary/:childId - الحصول على ملخص العواطف للطفل
  Future<Map<String, dynamic>> getEmotionSummary(String childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/emotion/summary/$childId'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  // ==========================================
  // MODULE 9: INTERACTION ROUTES (/api/interaction)
  // ==========================================

  /// GET /api/interaction/signals - الحصول على الإشارات
  Future<List<dynamic>> getSignals() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/interaction/signals'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as List<dynamic>;
  }

  /// GET /api/interaction/emotions - الحصول على العواطف
  Future<List<dynamic>> getEmotions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/interaction/emotions'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as List<dynamic>;
  }

  /// GET /api/interaction/daily-life - الحصول على الحياة اليومية
  Future<List<dynamic>> getDailyLife() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/interaction/daily-life'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as List<dynamic>;
  }

  /// GET /api/interaction/test/items - الحصول على عناصر اختبار التفاعل
  Future<List<dynamic>> getInteractionTestItems() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/interaction/test/items'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as List<dynamic>;
  }

  /// POST /api/interaction/test/submit - إرسال إجابة اختبار التفاعل
  Future<Map<String, dynamic>> submitInteractionTestAnswer(Map<String, dynamic> submissionData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/interaction/test/submit'),
      headers: _getHeaders(contentType: 'application/json'),
      body: jsonEncode(submissionData),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  // ==========================================
  // MODULE 10: PROGRESS ROUTES (/api/progress)
  // ==========================================

  /// GET /api/progress/child/:childId - الحصول على تقدم الطفل
  Future<Map<String, dynamic>> getChildProgress(String childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/progress/child/$childId'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  // ==========================================
  // MODULE 11: RECOGNITION ROUTES (/api/recognition)
  // ==========================================

  /// GET /api/recognition/categories - الحصول على الفئات
  Future<List<dynamic>> getRecognitionCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/recognition/categories'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as List<dynamic>;
  }

  /// POST /api/recognition/categories - إضافة فئة جديدة
  Future<Map<String, dynamic>> addRecognitionCategory({
    required String name,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/recognition/categories'),
      headers: _getHeaders(contentType: 'application/json'),
      body: jsonEncode({
        'name': name,
        if (description != null) 'description': description,
      }),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  /// GET /api/recognition/people - الحصول على الأشخاص
  Future<List<dynamic>> getPeople() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/recognition/people'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as List<dynamic>;
  }

  /// GET /api/recognition/places - الحصول على الأماكن
  Future<List<dynamic>> getPlaces() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/recognition/places'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as List<dynamic>;
  }

  /// GET /api/recognition/objects - الحصول على الأشياء
  Future<List<dynamic>> getObjects() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/recognition/objects'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as List<dynamic>;
  }

  /// POST /api/recognition/add - إضافة عنصر جديد (مع رفع صورة)
  /// Expects multipart/form-data with fields: name, category, and file 'image'
  Future<Map<String, dynamic>> addRecognitionItem({
    required String name,
    required String category, // 'people', 'places', 'objects' or custom
    required dynamic fileSource, // File, String path, or List<int> bytes
  }) async {
    final uri = Uri.parse('$baseUrl/api/recognition/add');
    final request = http.MultipartRequest('POST', uri);
    
    // Add auth headers
    request.headers.addAll(_getHeaders());
    
    // Add text fields
    request.fields['name'] = name;
    request.fields['category'] = category;

    // Add file field
    if (kIsWeb) {
      if (fileSource is List<int>) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            fileSource,
            filename: 'recognition_upload.jpg',
          ),
        );
      } else {
        throw ArgumentError('For Web platform, fileSource must be a List<int> of bytes.');
      }
    } else {
      if (fileSource is File) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            fileSource.path,
          ),
        );
      } else if (fileSource is String) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            fileSource,
          ),
        );
      } else {
        throw ArgumentError('fileSource must be a File or a String path on native platforms.');
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _processResponse(response) as Map<String, dynamic>;
  }

  /// GET /api/recognition/test/items - الحصول على عناصر اختبار التعرف
  Future<List<dynamic>> getRecognitionTestItems() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/recognition/test/items'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as List<dynamic>;
  }

  /// POST /api/recognition/test/submit - إرسال إجابة اختبار التعرف
  Future<Map<String, dynamic>> submitRecognitionTestAnswer(Map<String, dynamic> answerData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/recognition/test/submit'),
      headers: _getHeaders(contentType: 'application/json'),
      body: jsonEncode(answerData),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  /// GET /api/recognition/test/history - الحصول على سجل اختبارات التعرف
  Future<List<dynamic>> getRecognitionTestHistory() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/recognition/test/history'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as List<dynamic>;
  }

  // ==========================================
  // MODULE 12: SPECIALIST ROUTES (/api/specialist)
  // ==========================================

  /// GET /api/specialist/children - الحصول على الأطفال تحت إشراف الأخصائي
  Future<List<dynamic>> getSpecialistChildren() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/specialist/children'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as List<dynamic>;
  }

  /// GET /api/specialist/child/:childId/report - الحصول على تقرير الطفل
  Future<Map<String, dynamic>> getChildReport(String childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/specialist/child/$childId/report'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  /// GET /api/specialist/child/:childId/treatment-plan - الحصول على خطة علاج الطفل
  Future<Map<String, dynamic>> getChildTreatmentPlanForSpecialist(String childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/specialist/child/$childId/treatment-plan'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  /// POST /api/specialist/child/:childId/treatment-plan - تحديث خطة علاج الطفل
  Future<Map<String, dynamic>> updateChildTreatmentPlan({
    required String childId,
    required Map<String, dynamic> treatmentPlanData,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/specialist/child/$childId/treatment-plan'),
      headers: _getHeaders(contentType: 'application/json'),
      body: jsonEncode(treatmentPlanData),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  /// GET /api/specialist/child/:childId/all-training-data - الحصول على جميع بيانات التدريب للطفل
  Future<Map<String, dynamic>> getAllTrainingDataForSpecialist(String childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/specialist/child/$childId/all-training-data'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }

  // ==========================================
  // MODULE 13: TRAINING ROUTES (/api/training)
  // ==========================================

  /// GET /api/training/session - الحصول على عناصر جلسة التدريب
  Future<Map<String, dynamic>> getTrainingSession() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/training/session'),
      headers: _getHeaders(),
    );
    return _processResponse(response) as Map<String, dynamic>;
  }
}
