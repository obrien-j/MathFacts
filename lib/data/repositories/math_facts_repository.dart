import '../models/math_fact.dart';
import '../../core/database/database_helper.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/learning_constants.dart';

/// Repository for managing math facts data
class MathFactsRepository {
  final DatabaseHelper _databaseHelper;

  MathFactsRepository(this._databaseHelper);

  /// Get all math facts
  Future<List<MathFact>> getAllMathFacts() async {
    final db = await _databaseHelper.database;
    final result = await db.query('math_facts', orderBy: 'operand1, operand2');
    return result.map((map) => MathFact.fromMap(map)).toList();
  }

  /// Get math facts by operation
  Future<List<MathFact>> getMathFactsByOperation(MathOperation operation) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'math_facts',
      where: 'operation = ?',
      whereArgs: [operation.name],
      orderBy: 'operand1, operand2',
    );
    return result.map((map) => MathFact.fromMap(map)).toList();
  }

  /// Get math facts by mastery level
  Future<List<MathFact>> getMathFactsByMastery(MasteryLevel masteryLevel) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'math_facts',
      where: 'mastery_level = ?',
      whereArgs: [masteryLevel.name],
      orderBy: 'operand1, operand2',
    );
    return result.map((map) => MathFact.fromMap(map)).toList();
  }

  /// Get facts due for review (spaced repetition)
  Future<List<MathFact>> getFactsDueForReview() async {
    final db = await _databaseHelper.database;
    final now = DateTime.now().toIso8601String();
    
    final result = await db.query(
      'math_facts',
      where: 'next_review_date IS NOT NULL AND next_review_date <= ?',
      whereArgs: [now],
      orderBy: 'next_review_date',
      limit: LearningConstants.problemsPerSession,
    );
    
    return result.map((map) => MathFact.fromMap(map)).toList();
  }

  /// Get facts that need practice (new or struggling)
  Future<List<MathFact>> getFactsNeedingPractice({
    required MathOperation operation,
    int? limit,
  }) async {
    final db = await _databaseHelper.database;
    
    final result = await db.query(
      'math_facts',
      where: '''
        operation = ? AND 
        (mastery_level IN ('newFact', 'learning') OR
         (mastery_level = 'familiar' AND average_response_time > ?))
      ''',
      whereArgs: [
        operation.name,
        LearningConstants.masteryResponseTimeSeconds,
      ],
      orderBy: 'last_practiced ASC, times_incorrect DESC',
      limit: limit,
    );
    
    return result.map((map) => MathFact.fromMap(map)).toList();
  }

  /// Get a specific math fact
  Future<MathFact?> getMathFact(int id) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'math_facts',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (result.isEmpty) return null;
    return MathFact.fromMap(result.first);
  }

  /// Get math fact by operands and operation
  Future<MathFact?> getMathFactByProblem(
    int operand1,
    int operand2,
    MathOperation operation,
  ) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'math_facts',
      where: 'operand1 = ? AND operand2 = ? AND operation = ?',
      whereArgs: [operand1, operand2, operation.name],
    );
    
    if (result.isEmpty) return null;
    return MathFact.fromMap(result.first);
  }

  /// Update math fact
  Future<void> updateMathFact(MathFact mathFact) async {
    final db = await _databaseHelper.database;
    await db.update(
      'math_facts',
      mathFact.toMap(),
      where: 'id = ?',
      whereArgs: [mathFact.id],
    );
  }

  /// Update math fact after practice attempt
  Future<void> updateFactAfterAttempt({
    required int factId,
    required bool isCorrect,
    required double responseTime,
  }) async {
    final fact = await getMathFact(factId);
    if (fact == null) return;

    // Update statistics
    final newTimesCorrect = isCorrect ? fact.timesCorrect + 1 : fact.timesCorrect;
    final newTimesIncorrect = isCorrect ? fact.timesIncorrect : fact.timesIncorrect + 1;
    
    // Calculate new average response time
    final totalAttempts = newTimesCorrect + newTimesIncorrect;
    final newAverageResponseTime = totalAttempts > 0
        ? ((fact.averageResponseTime * (totalAttempts - 1)) + responseTime) / totalAttempts
        : responseTime;

    // Determine new mastery level
    final newMasteryLevel = _calculateMasteryLevel(
      newTimesCorrect,
      newTimesIncorrect,
      newAverageResponseTime,
    );

    // Calculate next review date
    final nextReviewDate = _calculateNextReviewDate(
      fact,
      isCorrect,
      responseTime,
      newMasteryLevel,
    );

    final updatedFact = fact.copyWith(
      lastPracticed: DateTime.now(),
      timesCorrect: newTimesCorrect,
      timesIncorrect: newTimesIncorrect,
      averageResponseTime: newAverageResponseTime,
      masteryLevel: newMasteryLevel,
      nextReviewDate: nextReviewDate,
    );

    await updateMathFact(updatedFact);
  }

  /// Calculate mastery level based on performance
  MasteryLevel _calculateMasteryLevel(
    int timesCorrect,
    int timesIncorrect,
    double averageResponseTime,
  ) {
    // Check for mastery
    if (timesCorrect >= LearningConstants.masteryCorrectAnswers &&
        averageResponseTime <= LearningConstants.masteryResponseTimeSeconds &&
        timesIncorrect == 0) {
      return MasteryLevel.mastered;
    }

    // Check for familiar level
    if (timesCorrect >= 2 && 
        averageResponseTime <= LearningConstants.masteryResponseTimeSeconds * 1.5) {
      return MasteryLevel.familiar;
    }

    // Check for learning level
    if (timesCorrect > 0) {
      return MasteryLevel.learning;
    }

    // Still new
    return MasteryLevel.newFact;
  }

  /// Calculate next review date using spaced repetition
  DateTime _calculateNextReviewDate(
    MathFact fact,
    bool isCorrect,
    double responseTime,
    MasteryLevel newMasteryLevel,
  ) {
    final now = DateTime.now();
    
    // If incorrect, review soon
    if (!isCorrect) {
      return now.add(const Duration(hours: 4));
    }

    // If correct but slow, review sooner
    if (responseTime > LearningConstants.masteryResponseTimeSeconds * 2) {
      return now.add(const Duration(days: 1));
    }

    // Use spaced repetition intervals based on mastery level
    int intervalIndex = 0;
    switch (newMasteryLevel) {
      case MasteryLevel.newFact:
      case MasteryLevel.learning:
        intervalIndex = 0; // 1 day
        break;
      case MasteryLevel.familiar:
        intervalIndex = 1; // 3 days
        break;
      case MasteryLevel.mastered:
        intervalIndex = 2; // 7 days, then longer
        break;
    }

    // If already mastered and was correct quickly, increase interval
    if (fact.masteryLevel == MasteryLevel.mastered && isCorrect &&
        responseTime <= LearningConstants.masteryResponseTimeSeconds) {
      final currentInterval = fact.nextReviewDate?.difference(fact.lastPracticed ?? now).inDays ?? 1;
      final nextIntervalIndex = LearningConstants.spacedRepetitionIntervals
          .indexWhere((interval) => interval > currentInterval);
      
      if (nextIntervalIndex != -1 && nextIntervalIndex < LearningConstants.spacedRepetitionIntervals.length) {
        intervalIndex = nextIntervalIndex;
      } else {
        intervalIndex = LearningConstants.spacedRepetitionIntervals.length - 1;
      }
    }

    final daysToAdd = LearningConstants.spacedRepetitionIntervals[
        intervalIndex.clamp(0, LearningConstants.spacedRepetitionIntervals.length - 1)
    ];
    
    return now.add(Duration(days: daysToAdd));
  }

  /// Get mastery statistics for an operation
  Future<Map<MasteryLevel, int>> getMasteryStats(MathOperation operation) async {
    final db = await _databaseHelper.database;
    
    final result = await db.rawQuery('''
      SELECT mastery_level, COUNT(*) as count 
      FROM math_facts 
      WHERE operation = ? 
      GROUP BY mastery_level
    ''', [operation.name]);

    final stats = <MasteryLevel, int>{};
    for (final level in MasteryLevel.values) {
      stats[level] = 0;
    }

    for (final row in result) {
      final level = MasteryLevel.values.firstWhere(
        (l) => l.name == row['mastery_level'],
        orElse: () => MasteryLevel.newFact,
      );
      stats[level] = row['count'] as int;
    }

    return stats;
  }

  /// Get facts with low accuracy that need extra practice
  Future<List<MathFact>> getStrugglingFacts({
    MathOperation? operation,
    int limit = 10,
  }) async {
    final db = await _databaseHelper.database;
    
    String whereClause = 'times_incorrect > times_correct AND times_incorrect > 2';
    List<dynamic> whereArgs = [];
    
    if (operation != null) {
      whereClause += ' AND operation = ?';
      whereArgs.add(operation.name);
    }

    final result = await db.query(
      'math_facts',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'times_incorrect DESC, last_practiced ASC',
      limit: limit,
    );
    
    return result.map((map) => MathFact.fromMap(map)).toList();
  }

  /// Reset progress for all facts (for testing or fresh start)
  Future<void> resetAllProgress() async {
    final db = await _databaseHelper.database;
    
    await db.update(
      'math_facts',
      {
        'times_correct': 0,
        'times_incorrect': 0,
        'last_practiced': null,
        'average_response_time': 0.0,
        'mastery_level': MasteryLevel.newFact.name,
        'next_review_date': null,
      },
    );
  }

  /// Get progress summary
  Future<Map<String, dynamic>> getProgressSummary(MathOperation operation) async {
    final db = await _databaseHelper.database;
    
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_facts,
        SUM(CASE WHEN mastery_level = 'mastered' THEN 1 ELSE 0 END) as mastered_count,
        SUM(CASE WHEN mastery_level = 'familiar' THEN 1 ELSE 0 END) as familiar_count,
        SUM(CASE WHEN mastery_level = 'learning' THEN 1 ELSE 0 END) as learning_count,
        SUM(CASE WHEN mastery_level = 'newFact' THEN 1 ELSE 0 END) as new_count,
        AVG(CASE WHEN average_response_time > 0 THEN average_response_time ELSE NULL END) as avg_response_time,
        SUM(times_correct) as total_correct,
        SUM(times_incorrect) as total_incorrect
      FROM math_facts 
      WHERE operation = ?
    ''', [operation.name]);

    if (result.isEmpty) {
      return {
        'totalFacts': 0,
        'masteredCount': 0,
        'familiarCount': 0,
        'learningCount': 0,
        'newCount': 0,
        'averageResponseTime': 0.0,
        'accuracy': 0.0,
        'progressPercentage': 0.0,
      };
    }

    final row = result.first;
    final totalCorrect = row['total_correct'] as int;
    final totalIncorrect = row['total_incorrect'] as int;
    final totalAttempts = totalCorrect + totalIncorrect;
    
    final masteredCount = row['mastered_count'] as int;
    final familiarCount = row['familiar_count'] as int;
    final totalFacts = row['total_facts'] as int;

    return {
      'totalFacts': totalFacts,
      'masteredCount': masteredCount,
      'familiarCount': familiarCount,
      'learningCount': row['learning_count'] as int,
      'newCount': row['new_count'] as int,
      'averageResponseTime': row['avg_response_time'] as double? ?? 0.0,
      'accuracy': totalAttempts > 0 ? totalCorrect / totalAttempts : 0.0,
      'progressPercentage': totalFacts > 0 ? (masteredCount + familiarCount) / totalFacts : 0.0,
    };
  }
}