import '../../core/constants/app_constants.dart';

/// Represents a single math fact (e.g., 7 + 8 = 15)
class MathFact {
  final int id;
  final int operand1;
  final int operand2;
  final MathOperation operation;
  final int answer;
  final DateTime? lastPracticed;
  final int timesCorrect;
  final int timesIncorrect;
  final double averageResponseTime;
  final MasteryLevel masteryLevel;
  final DateTime? nextReviewDate;
  final List<String> associatedStrategies;

  const MathFact({
    required this.id,
    required this.operand1,
    required this.operand2,
    required this.operation,
    required this.answer,
    this.lastPracticed,
    this.timesCorrect = 0,
    this.timesIncorrect = 0,
    this.averageResponseTime = 0.0,
    this.masteryLevel = MasteryLevel.newFact,
    this.nextReviewDate,
    this.associatedStrategies = const [],
  });

  /// Create MathFact from database map
  factory MathFact.fromMap(Map<String, dynamic> map) {
    return MathFact(
      id: map['id'] as int,
      operand1: map['operand1'] as int,
      operand2: map['operand2'] as int,
      operation: MathOperation.values.firstWhere(
        (e) => e.name == map['operation'],
      ),
      answer: map['answer'] as int,
      lastPracticed: map['last_practiced'] != null
          ? DateTime.parse(map['last_practiced'])
          : null,
      timesCorrect: map['times_correct'] as int? ?? 0,
      timesIncorrect: map['times_incorrect'] as int? ?? 0,
      averageResponseTime: map['average_response_time'] as double? ?? 0.0,
      masteryLevel: MasteryLevel.values.firstWhere(
        (e) => e.name == (map['mastery_level'] ?? 'newFact'),
      ),
      nextReviewDate: map['next_review_date'] != null
          ? DateTime.parse(map['next_review_date'])
          : null,
      associatedStrategies: map['associated_strategies'] != null
          ? (map['associated_strategies'] as String).split(',')
          : [],
    );
  }

  /// Convert MathFact to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'operand1': operand1,
      'operand2': operand2,
      'operation': operation.name,
      'answer': answer,
      'last_practiced': lastPracticed?.toIso8601String(),
      'times_correct': timesCorrect,
      'times_incorrect': timesIncorrect,
      'average_response_time': averageResponseTime,
      'mastery_level': masteryLevel.name,
      'next_review_date': nextReviewDate?.toIso8601String(),
      'associated_strategies': associatedStrategies.join(','),
    };
  }

  /// Create a copy with updated values
  MathFact copyWith({
    int? id,
    int? operand1,
    int? operand2,
    MathOperation? operation,
    int? answer,
    DateTime? lastPracticed,
    int? timesCorrect,
    int? timesIncorrect,
    double? averageResponseTime,
    MasteryLevel? masteryLevel,
    DateTime? nextReviewDate,
    List<String>? associatedStrategies,
  }) {
    return MathFact(
      id: id ?? this.id,
      operand1: operand1 ?? this.operand1,
      operand2: operand2 ?? this.operand2,
      operation: operation ?? this.operation,
      answer: answer ?? this.answer,
      lastPracticed: lastPracticed ?? this.lastPracticed,
      timesCorrect: timesCorrect ?? this.timesCorrect,
      timesIncorrect: timesIncorrect ?? this.timesIncorrect,
      averageResponseTime: averageResponseTime ?? this.averageResponseTime,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      associatedStrategies: associatedStrategies ?? this.associatedStrategies,
    );
  }

  /// Get the problem as a string (e.g., "7 + 8")
  String get problemString {
    String operatorSymbol;
    switch (operation) {
      case MathOperation.addition:
        operatorSymbol = '+';
        break;
      case MathOperation.subtraction:
        operatorSymbol = '-';
        break;
      case MathOperation.multiplication:
        operatorSymbol = '×';
        break;
    }
    return '$operand1 $operatorSymbol $operand2';
  }

  /// Get the full equation as a string (e.g., "7 + 8 = 15")
  String get equationString => '$problemString = $answer';

  @override
  String toString() {
    return 'MathFact{$equationString, mastery: $masteryLevel}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MathFact &&
        other.operand1 == operand1 &&
        other.operand2 == operand2 &&
        other.operation == operation;
  }

  @override
  int get hashCode {
    return operand1.hashCode ^ operand2.hashCode ^ operation.hashCode;
  }
}