import '../core/constants/app_constants.dart';

/// Represents overall user progress and statistics
class UserProgress {
  final int userId;
  final Map<MathOperation, OperationProgress> operationProgress;
  final int currentStreak;
  final int totalSessions;
  final DateTime? lastSessionDate;
  final double overallFluencyScore;
  final double hintUsageFrequency;

  const UserProgress({
    this.userId = 1,
    this.operationProgress = const {},
    this.currentStreak = 0,
    this.totalSessions = 0,
    this.lastSessionDate,
    this.overallFluencyScore = 0.0,
    this.hintUsageFrequency = 0.0,
  });

  /// Create UserProgress from database map
  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      userId: map['id'] as int? ?? 1,
      currentStreak: map['current_streak'] as int? ?? 0,
      totalSessions: map['total_sessions'] as int? ?? 0,
      lastSessionDate: map['last_session_date'] != null
          ? DateTime.parse(map['last_session_date'])
          : null,
      overallFluencyScore: map['overall_fluency_score'] as double? ?? 0.0,
      hintUsageFrequency: map['hint_usage_frequency'] as double? ?? 0.0,
    );
  }

  /// Convert UserProgress to database map
  Map<String, dynamic> toMap() {
    return {
      'id': userId,
      'current_streak': currentStreak,
      'total_sessions': totalSessions,
      'last_session_date': lastSessionDate?.toIso8601String(),
      'overall_fluency_score': overallFluencyScore,
      'hint_usage_frequency': hintUsageFrequency,
    };
  }

  /// Create a copy with updated values
  UserProgress copyWith({
    int? userId,
    Map<MathOperation, OperationProgress>? operationProgress,
    int? currentStreak,
    int? totalSessions,
    DateTime? lastSessionDate,
    double? overallFluencyScore,
    double? hintUsageFrequency,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      operationProgress: operationProgress ?? this.operationProgress,
      currentStreak: currentStreak ?? this.currentStreak,
      totalSessions: totalSessions ?? this.totalSessions,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      overallFluencyScore: overallFluencyScore ?? this.overallFluencyScore,
      hintUsageFrequency: hintUsageFrequency ?? this.hintUsageFrequency,
    );
  }

  @override
  String toString() {
    return 'UserProgress{sessions: $totalSessions, streak: $currentStreak, fluency: ${overallFluencyScore.toStringAsFixed(2)}}';
  }
}

/// Progress tracking for a specific math operation
class OperationProgress {
  final MathOperation operation;
  final int totalFacts;
  final int masteredFacts;
  final int familiarFacts;
  final int learningFacts;
  final int newFacts;
  final double averageResponseTime;
  final double accuracy;
  final DateTime lastPracticed;

  const OperationProgress({
    required this.operation,
    this.totalFacts = 0,
    this.masteredFacts = 0,
    this.familiarFacts = 0,
    this.learningFacts = 0,
    this.newFacts = 0,
    this.averageResponseTime = 0.0,
    this.accuracy = 0.0,
    required this.lastPracticed,
  });

  /// Calculate progress percentage (mastered + familiar facts)
  double get progressPercentage {
    if (totalFacts == 0) return 0.0;
    return (masteredFacts + familiarFacts) / totalFacts;
  }

  /// Calculate mastery percentage (only mastered facts)
  double get masteryPercentage {
    if (totalFacts == 0) return 0.0;
    return masteredFacts / totalFacts;
  }

  /// Get progress level description
  String get progressDescription {
    final percentage = progressPercentage * 100;
    if (percentage >= 90) return 'Excellent';
    if (percentage >= 70) return 'Good';
    if (percentage >= 50) return 'Making Progress';
    if (percentage >= 25) return 'Getting Started';
    return 'Just Beginning';
  }

  /// Create a copy with updated values
  OperationProgress copyWith({
    MathOperation? operation,
    int? totalFacts,
    int? masteredFacts,
    int? familiarFacts,
    int? learningFacts,
    int? newFacts,
    double? averageResponseTime,
    double? accuracy,
    DateTime? lastPracticed,
  }) {
    return OperationProgress(
      operation: operation ?? this.operation,
      totalFacts: totalFacts ?? this.totalFacts,
      masteredFacts: masteredFacts ?? this.masteredFacts,
      familiarFacts: familiarFacts ?? this.familiarFacts,
      learningFacts: learningFacts ?? this.learningFacts,
      newFacts: newFacts ?? this.newFacts,
      averageResponseTime: averageResponseTime ?? this.averageResponseTime,
      accuracy: accuracy ?? this.accuracy,
      lastPracticed: lastPracticed ?? this.lastPracticed,
    );
  }

  @override
  String toString() {
    return 'OperationProgress{${operation.name}: ${(progressPercentage * 100).toStringAsFixed(1)}% progress}';
  }
}

/// Represents a spaced repetition item for scheduling
class SpacedRepetitionItem {
  final int factId;
  final DateTime nextReviewDate;
  final int intervalLevel; // Index in the intervals array
  final int consecutiveCorrect;
  final DateTime lastReviewed;

  const SpacedRepetitionItem({
    required this.factId,
    required this.nextReviewDate,
    this.intervalLevel = 0,
    this.consecutiveCorrect = 0,
    required this.lastReviewed,
  });

  /// Create SpacedRepetitionItem from database map
  factory SpacedRepetitionItem.fromMap(Map<String, dynamic> map) {
    return SpacedRepetitionItem(
      factId: map['fact_id'] as int,
      nextReviewDate: DateTime.parse(map['next_review_date']),
      intervalLevel: map['interval_level'] as int? ?? 0,
      consecutiveCorrect: map['consecutive_correct'] as int? ?? 0,
      lastReviewed: DateTime.parse(map['last_reviewed']),
    );
  }

  /// Convert SpacedRepetitionItem to database map
  Map<String, dynamic> toMap() {
    return {
      'fact_id': factId,
      'next_review_date': nextReviewDate.toIso8601String(),
      'interval_level': intervalLevel,
      'consecutive_correct': consecutiveCorrect,
      'last_reviewed': lastReviewed.toIso8601String(),
    };
  }

  /// Create a copy with updated values
  SpacedRepetitionItem copyWith({
    int? factId,
    DateTime? nextReviewDate,
    int? intervalLevel,
    int? consecutiveCorrect,
    DateTime? lastReviewed,
  }) {
    return SpacedRepetitionItem(
      factId: factId ?? this.factId,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      intervalLevel: intervalLevel ?? this.intervalLevel,
      consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
      lastReviewed: lastReviewed ?? this.lastReviewed,
    );
  }

  @override
  String toString() {
    return 'SpacedRepetitionItem{factId: $factId, nextReview: $nextReviewDate}';
  }
}