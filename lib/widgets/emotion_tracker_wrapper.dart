import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/emotion_tracker_service.dart';

class EmotionTrackerWrapper extends StatefulWidget {
  final Widget child;
  final String activityTitle;

  const EmotionTrackerWrapper({
    Key? key,
    required this.child,
    required this.activityTitle,
  }) : super(key: key);

  @override
  State<EmotionTrackerWrapper> createState() => _EmotionTrackerWrapperState();
}

class _EmotionTrackerWrapperState extends State<EmotionTrackerWrapper> {
  final _tracker = EmotionTrackerService();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  Future<void> _startTracking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _tracker.initialize(user.uid);
      _tracker.startTracking(activityTitle: widget.activityTitle);
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _tracker.stopTracking(activityTitle: widget.activityTitle);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_initialized && _tracker.controller != null && _tracker.controller!.value.isInitialized)
          Positioned(
            bottom: 0,
            right: 0,
            child: SizedBox(
              width: 1,
              height: 1,
              child: Opacity(
                opacity: 0.01,
                child: CameraPreview(_tracker.controller!),
              ),
            ),
          ),
      ],
    );
  }
}
