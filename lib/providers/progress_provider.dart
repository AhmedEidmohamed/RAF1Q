import 'package:flutter/foundation.dart';

/// Model for Stage Progress
class StageProgress {
  final String stageId;
  final String stageName;
  double progress; // 0.0 to 1.0
  int completedActivities;
  int totalActivities;
  DateTime? lastUpdated;

  StageProgress({
    required this.stageId,
    required this.stageName,
    this.progress = 0.0,
    this.completedActivities = 0,
    this.totalActivities = 0,
    this.lastUpdated,
  });

  void updateProgress(double newProgress) {
    progress = newProgress.clamp(0.0, 1.0);
    lastUpdated = DateTime.now();
  }

  void incrementCompleted() {
    if (completedActivities < totalActivities) {
      completedActivities++;
      progress =
          totalActivities > 0 ? completedActivities / totalActivities : 0.0;
      lastUpdated = DateTime.now();
    }
  }
}

/// Progress Provider - يدير تقدم الطفل
class ProgressProvider extends ChangeNotifier {
  final Map<String, StageProgress> _stagesProgress = {
    'stage1': StageProgress(
      stageId: 'stage1',
      stageName: 'Social Recognition',
      totalActivities: 30,
    ),
    'stage2': StageProgress(
      stageId: 'stage2',
      stageName: 'Social Interaction',
      totalActivities: 25,
    ),
    'stage3': StageProgress(
      stageId: 'stage3',
      stageName: 'Communication',
      totalActivities: 35,
    ),
  };

  Map<String, StageProgress> get stagesProgress => _stagesProgress;

  // Get overall progress
  double get overallProgress {
    if (_stagesProgress.isEmpty) return 0.0;
    final total = _stagesProgress.values.fold<double>(
      0.0,
      (sum, stage) => sum + stage.progress,
    );
    return total / _stagesProgress.length;
  }

  // Get specific stage progress
  StageProgress? getStageProgress(String stageId) {
    return _stagesProgress[stageId];
  }

  // Update stage progress
  void updateStageProgress(String stageId, double progress) {
    if (_stagesProgress.containsKey(stageId)) {
      _stagesProgress[stageId]!.updateProgress(progress);
      notifyListeners();
    }
  }

  // Mark activity as completed
  void completeActivity(String stageId) {
    if (_stagesProgress.containsKey(stageId)) {
      _stagesProgress[stageId]!.incrementCompleted();
      notifyListeners();
    }
  }

  // Get achievement badges
  List<String> getAchievements() {
    final achievements = <String>[];

    // First stage completed
    if (_stagesProgress['stage1']?.progress == 1.0) {
      achievements.add('First Steps');
    }

    // All stages started
    if (_stagesProgress.values.every((s) => s.progress > 0)) {
      achievements.add('Explorer');
    }

    // Overall progress milestone
    if (overallProgress >= 0.25) achievements.add('25% Complete');
    if (overallProgress >= 0.5) achievements.add('Half Way');
    if (overallProgress >= 0.75) achievements.add('Almost There');
    if (overallProgress == 1.0) achievements.add('Master');

    return achievements;
  }

  // Reset all progress
  void resetProgress() {
    for (var stage in _stagesProgress.values) {
      stage.progress = 0.0;
      stage.completedActivities = 0;
      stage.lastUpdated = null;
    }
    notifyListeners();
  }
}
