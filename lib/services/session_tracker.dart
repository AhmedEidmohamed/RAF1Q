import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class SessionTracker {
  DateTime? _startTime;
  final int stageNumber;
  final String activityName;

  SessionTracker({required this.stageNumber, required this.activityName});

  void startSession() {
    _startTime = DateTime.now();
    debugPrint('Session started for Stage $stageNumber: $activityName at $_startTime');
  }

  Future<void> endSession() async {
    if (_startTime == null) return;

    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds;

    // Only record sessions longer than 5 seconds to avoid noise
    if (seconds < 5) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final sessionRef = FirebaseFirestore.instance
            .collection('children')
            .doc(user.uid)
            .collection('learning_sessions')
            .doc();

        await sessionRef.set({
          'stageNumber': stageNumber,
          'activityName': activityName,
          'startTime': Timestamp.fromDate(_startTime!),
          'endTime': Timestamp.fromDate(endTime),
          'durationMinutes': minutes > 0 ? minutes : 1, // Minimum 1 minute if > 5 sec
          'durationSeconds': seconds,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Update aggregate progress for the stage
        final progressRef = FirebaseFirestore.instance
            .collection('children')
            .doc(user.uid)
            .collection('stage_progress')
            .doc('stage_$stageNumber');

        await progressRef.set({
          'totalMinutes': FieldValue.increment(minutes > 0 ? minutes : 1),
          'totalSessions': FieldValue.increment(1),
          'lastActive': FieldValue.serverTimestamp(),
          'stageNumber': stageNumber,
        }, SetOptions(merge: true));

        debugPrint('Session saved: $minutes minutes in Stage $stageNumber');
      } catch (e) {
        debugPrint('Error saving session: $e');
      }
    }
    
    _startTime = null;
  }
}
