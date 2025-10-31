import '../../core/constants/app_constants.dart';

/// Represents a single practice attempt within a session
class PracticeAttempt {
  final int id;
  final int factId;
  final int sessionId;
  final double responseTime;
  final int userAnswer;
  final bool isCorrect;
  final DateTime timestamp;
  final bool hintRequested;
  final String? strategyUsed;
  final bool answeredAfterHint;

  const PracticeAttempt({
    required this.id,
    required this.factId,
    required this.sessionId,
    required this.responseTime,
    required this.userAnswer,
    required this.isCorrect,
    required this.timestamp,
    this.hintRequested = false,
    this.strategyUsed,
    this.answeredAfterHint = false,
  });

  /// Create PracticeAttempt from database map
  factory PracticeAttempt.fromMap(Map<String, dynamic> map) {
    return PracticeAttempt(
      id: map['id'] as int,
      factId: map['fact_id'] as int,
      sessionId: map['session_id'] as int,
      responseTime: map['response_time'] as double,
      userAnswer: map['user_answer'] as int,
      isCorrect: map['is_correct'] == 1,
      timestamp: DateTime.parse(map['timestamp']),
      hintRequested: map['hint_requested'] == 1,
      strategyUsed: map['strategy_used'] as String?,
      answeredAfterHint: map['answered_after_hint'] == 1,
    );
  }

  /// Convert PracticeAttempt to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fact_id': factId,
      'session_id': sessionId,
      'response_time': responseTime,
      'user_answer': userAnswer,
      'is_correct': isCorrect ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
      'hint_requested': hintRequested ? 1 : 0,
      'strategy_used': strategyUsed,
      'answered_after_hint': answeredAfterHint ? 1 : 0,
    };
  }

  @override
  String toString() {
    return 'PracticeAttempt{factId: $factId, correct: $isCorrect, time: ${responseTime}s}';
  }
}

/// Represents a complete practice session
class PracticeSession {
  final int id;
  final DateTime startTime;
  final DateTime? endTime;
  final List<PracticeAttempt> attempts;
  final SessionType type;
  final Map<MathOperation, int> operationsIncluded;
  final int hintsUsed;
  final List<String> strategiesShown;

  const PracticeSession({
    required this.id,
    required this.startTime,
    this.endTime,
    this.attempts = const [],
    this.type = SessionType.practice,
    this.operationsIncluded = const {},
    this.hintsUsed = 0,
    this.strategiesShown = const [],
  });

  /// Create PracticeSession from database map
  factory PracticeSession.fromMap(Map<String, dynamic> map) {
    return PracticeSession(
      id: map['id'] as int,
      startTime: DateTime.parse(map['start_time']),
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
      type: SessionType.values.firstWhere(
        (e) => e.name == (map['session_type'] ?? 'practice'),
      ),
      operationsIncluded: _parseOperationsMap(map['operations_included']),
      hintsUsed: map['hints_used'] as int? ?? 0,
      strategiesShown: map['strategies_shown'] != null
          ? (map['strategies_shown'] as String).split(',')
          : [],
    );
  }

  /// Convert PracticeSession to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'session_type': type.name,
      'total_problems': attempts.length,
      'correct_answers': attempts.where((a) => a.isCorrect).length,
      'average_response_time': averageResponseTime,
      'operations_included': _serializeOperationsMap(operationsIncluded),
      'hints_used': hintsUsed,
      'strategies_shown': strategiesShown.join(','),
    };
  }

  /// Parse operations map from database string
  static Map<MathOperation, int> _parseOperationsMap(String? data) {
    if (data == null || data.isEmpty) return {};
    
    final Map<MathOperation, int> result = {};
    for (String pair in data.split(',')) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        final operation = MathOperation.values.firstWhere(
          (e) => e.name == parts[0],
        );
        result[operation] = int.parse(parts[1]);
      }
    }
    return result;
  }

  /// Serialize operations map to database string
  static String _serializeOperationsMap(Map<MathOperation, int> operations) {
    return operations.entries
        .map((e) => '${e.key.name}:${e.value}')
        .join(',');
  }

  /// Calculate session duration
  Duration get duration {
    if (endTime == null) return Duration.zero;
    return endTime!.difference(startTime);
  }

  /// Calculate accuracy percentage
  double get accuracy {
    if (attempts.isEmpty) return 0.0;
    final correct = attempts.where((a) => a.isCorrect).length;
    return correct / attempts.length;
  }

  /// Calculate average response time
  double get averageResponseTime {
    if (attempts.isEmpty) return 0.0;
    final totalTime = attempts.fold<double>(0.0, (sum, a) => sum + a.responseTime);
    return totalTime / attempts.length;
  }

  /// Get attempts that used hints
  List<PracticeAttempt> get hintsUsedAttempts {
    return attempts.where((a) => a.hintRequested).toList();
  }

  /// Calculate hint effectiveness (correct answers after hints)
  double get hintEffectiveness {
    final hintAttempts = hintsUsedAttempts;
    if (hintAttempts.isEmpty) return 0.0;
    
    final successfulHints = hintAttempts.where((a) => a.answeredAfterHint).length;
    return successfulHints / hintAttempts.length;
  }

  /// Create a copy with updated values
  PracticeSession copyWith({
    int? id,
    DateTime? startTime,
    DateTime? endTime,
    List<PracticeAttempt>? attempts,
    SessionType? type,
    Map<MathOperation, int>? operationsIncluded,
    int? hintsUsed,
    List<String>? strategiesShown,
  }) {
    return PracticeSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      attempts: attempts ?? this.attempts,
      type: type ?? this.type,
      operationsIncluded: operationsIncluded ?? this.operationsIncluded,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      strategiesShown: strategiesShown ?? this.strategiesShown,
    );
  }

  @override
  String toString() {
    return 'PracticeSession{id: $id, problems: ${attempts.length}, accuracy: ${(accuracy * 100).toStringAsFixed(1)}%}';
  }
}