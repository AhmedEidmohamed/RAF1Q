import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/app_state.dart';

class EmotionTrackerService {
  static final EmotionTrackerService _instance = EmotionTrackerService._internal();
  factory EmotionTrackerService() => _instance;
  EmotionTrackerService._internal();

  CameraController? _controller;
  Timer? _timer;
  bool _isTracking = false;
  bool _isPaused = false;
  bool _isInitializing = false;
  String? _childId;
  String? _currentActivityTitle;

  bool get isTracking => _isTracking;
  CameraController? get controller => _controller;
  
  final String apiUrl = "https://manar312-real-time-emotion-detection.hf.space/predict-json";

  Future<void> initialize(String childId) async {
    if (_isInitializing) return;
    _childId = childId;
    
    if (_controller != null && _controller!.value.isInitialized) return;

    _isInitializing = true;
    print("Initializing EmotionTracker for Child ID: $_childId");

    try {
      // تنظيف أي محاولة سابقة فاشلة
      if (_controller != null) {
        try {
          await _controller!.dispose();
        } catch (_) {}
        _controller = null;
      }
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        print("No cameras found for tracking.");
        return;
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.low,
        enableAudio: false,
      );

      // ضبط مهلة زمنية للتهيئة
      await _controller!.initialize().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException("Camera initialization timed out.");
        },
      );
      
      print("Global EmotionTracker initialized successfully.");
    } catch (e) {
      print("Error initializing EmotionTracker camera: $e");
      try {
        await _controller?.dispose();
      } catch (_) {}
      _controller = null;
    } finally {
      _isInitializing = false;
    }
  }

  final List<String> _activityStack = [];

  void startTracking({String? activityTitle}) {
    _isPaused = false;
    
    bool isNewActivity = false;
    if (activityTitle != null) {
      // Avoid pushing the same title if it's already the active one
      if (_activityStack.isEmpty || _activityStack.last != activityTitle) {
        _activityStack.add(activityTitle);
        _currentActivityTitle = activityTitle;
        isNewActivity = true;
        print("EmotionTracker: Pushed new activity title: $activityTitle. Current stack: $_activityStack");
      }
    }
    
    if (_isTracking) {
      print("EmotionTracker is already running. Current title: $_currentActivityTitle");
      // Trigger an immediate capture if this is a new specific activity
      if (isNewActivity) {
        print("EmotionTracker: Triggering delayed immediate capture (1s) for new activity: $activityTitle");
        Future.delayed(const Duration(seconds: 1), () {
          if (_isTracking && _currentActivityTitle == activityTitle) {
            _captureAndAnalyze(activityTitle: _currentActivityTitle);
          }
        });
      }
      return;
    }
    
    _isTracking = true;
    print("EmotionTracker: Starting timer for $_currentActivityTitle");

    // Trigger first capture with slight delay to ensure initialization/transition
    Future.delayed(const Duration(seconds: 1), () {
      if (_isTracking) {
        _captureAndAnalyze(activityTitle: _currentActivityTitle);
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!_isPaused && _isTracking) {
        _captureAndAnalyze(activityTitle: _currentActivityTitle);
      }
    });
  }

  void stopTracking({String? activityTitle}) {
    if (activityTitle != null) {
      // Remove the specific title from the stack (not just the last one, to be safe)
      _activityStack.remove(activityTitle);
      print("EmotionTracker: Removed activity title: $activityTitle. Remaining stack: $_activityStack");
      
      if (_activityStack.isNotEmpty) {
        _currentActivityTitle = _activityStack.last;
        print("EmotionTracker continuing with previous title: $_currentActivityTitle");
        return;
      }
    }
    
    print("Stopping EmotionTracker timer.");
    _isTracking = false;
    _timer?.cancel();
    _timer = null;
    _currentActivityTitle = null;
    _activityStack.clear();
  }

  Future<void> pauseTracking() async {
    _isPaused = true;
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
      print("Global camera released for pause.");
    }
  }

  Future<void> resumeTracking() async {
    _isPaused = false;
    if (_childId != null) {
      await initialize(_childId!);
    }
  }

  bool _isCapturing = false;

  Future<void> _captureAndAnalyze({String? activityTitle}) async {
    if (_controller == null || !_controller!.value.isInitialized || _isPaused || _isCapturing) {
      print("Tracking skipped: Controller null/uninitialized, paused, or already capturing.");
      return;
    }

    if (_childId == null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _childId = user.uid;
      } else {
        print("Tracking skipped: No child ID or logged in user found.");
        return;
      }
    }

    try {
      _isCapturing = true;
      print("Capturing background image for analysis... Title: $activityTitle");
      final XFile image = await _controller!.takePicture();
      final Uint8List imageBytes = await image.readAsBytes();
      
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'track_image.jpg',
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Global API Response: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print("Global Emotion Detected: ${data['emotion']}");
          await saveEmotion(data['emotion'], activityTitle: activityTitle);
        } else {
          print("Global API success = false: ${data['message']}");
        }
      } else {
        print("Global API Error: ${response.body}");
      }
    } catch (e) {
      print("Error in global emotion tracking capture/analyze: $e");
    } finally {
      _isCapturing = false;
    }
  }

  Future<void> saveEmotion(String emotion, {String? activityTitle, String? gestureId}) async {
    if (_childId == null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) _childId = user.uid;
    }
    if (_childId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('children')
          .doc(_childId)
          .collection('emotion_logs')
          .add({
        'emotion': emotion,
        'timestamp': FieldValue.serverTimestamp(),
        'activity': activityTitle != null ? 'practice_session' : 'global_monitoring',
        'gesture_title': activityTitle,
        'gesture_id': gestureId,
      });
      print("Successfully saved emotion '$emotion' for $activityTitle to Firestore");
    } catch (e) {
      print("Error saving emotion to Firestore: $e");
    }
  }

  Future<void> _saveEmotionToFirestore(String emotion) async {
    await saveEmotion(emotion);
  }

  void dispose() {
    stopTracking();
    _isTracking = false;
    _isPaused = true;
    _controller?.dispose();
    _controller = null;
    print("Global EmotionTracker disposed.");
  }
}
