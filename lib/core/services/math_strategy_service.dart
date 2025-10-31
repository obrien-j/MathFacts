import '../../data/models/math_fact.dart';
import '../../data/models/math_strategy.dart';
import '../constants/app_constants.dart';
import '../database/database_helper.dart';

/// Service for generating and managing math strategy hints
class MathStrategyService {
  final DatabaseHelper _databaseHelper;

  MathStrategyService(this._databaseHelper);

  /// Get the best strategy for a given math fact
  Future<MathStrategy?> getBestStrategy(MathFact mathFact) async {
    final strategies = await getApplicableStrategies(
      mathFact.operand1,
      mathFact.operand2,
      mathFact.operation,
    );

    if (strategies.isEmpty) return null;

    // For now, return the first applicable strategy
    // In the future, we could rank by effectiveness
    return strategies.first;
  }

  /// Get all strategies that apply to the given problem
  Future<List<MathStrategy>> getApplicableStrategies(
    int operand1,
    int operand2,
    MathOperation operation,
  ) async {
    final db = await _databaseHelper.database;
    
    final result = await db.query(
      'math_strategies',
      where: '''
        operation = ? AND
        min_operand1 <= ? AND max_operand1 >= ? AND
        min_operand2 <= ? AND max_operand2 >= ?
      ''',
      whereArgs: [
        operation.name,
        operand1, operand1,
        operand2, operand2,
      ],
    );

    return result.map((map) => MathStrategy.fromMap(map)).toList();
  }

  /// Get strategy effectiveness for a specific fact
  Future<double> getStrategyEffectiveness(String strategyId, int factId) async {
    final db = await _databaseHelper.database;
    
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_uses,
        SUM(was_helpful) as successful_uses
      FROM strategy_usage 
      WHERE strategy_id = ? AND fact_id = ?
    ''', [strategyId, factId]);

    if (result.isEmpty) return 0.0;

    final row = result.first;
    final totalUses = row['total_uses'] as int;
    final successfulUses = row['successful_uses'] as int;

    if (totalUses == 0) return 0.0;
    return successfulUses / totalUses;
  }

  /// Record strategy usage and effectiveness
  Future<void> recordStrategyUsage({
    required int factId,
    required String strategyId,
    required int sessionId,
    required bool wasHelpful,
  }) async {
    final db = await _databaseHelper.database;
    
    await db.insert('strategy_usage', {
      'fact_id': factId,
      'strategy_id': strategyId,
      'session_id': sessionId,
      'was_helpful': wasHelpful ? 1 : 0,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Generate hint text for a specific problem
  String generateHint(MathStrategy strategy, int operand1, int operand2) {
    switch (strategy.type) {
      case StrategyType.decomposition:
        return _generateDecompositionHint(operand1, operand2);
      
      case StrategyType.doubles:
        return _generateDoublesHint(operand1, operand2);
      
      case StrategyType.nearDoubles:
        return _generateNearDoublesHint(operand1, operand2);
      
      case StrategyType.makeTen:
        return _generateMakeTenHint(operand1, operand2);
      
      case StrategyType.countOn:
        return _generateCountOnHint(operand1, operand2);
      
      default:
        return strategy.generateHintFor(operand1, operand2);
    }
  }

  /// Generate decomposition hint
  String _generateDecompositionHint(int operand1, int operand2) {
    // Find the best way to decompose based on making 10
    if (operand1 < 10 && operand2 > 5) {
      final needed = 10 - operand1;
      final remaining = operand2 - needed;
      if (remaining > 0 && needed <= operand2) {
        return 'Break $operand2 into $needed + $remaining. Then: $operand1 + $needed = 10, and 10 + $remaining = ${operand1 + operand2}.';
      }
    }
    
    // Default decomposition
    if (operand2 > 5) {
      final part1 = operand2 ~/ 2;
      final part2 = operand2 - part1;
      return 'Break $operand2 into $part1 + $part2. Then add: $operand1 + $part1 + $part2 = ${operand1 + operand2}.';
    }
    
    return 'Try breaking one of the numbers into smaller parts to make adding easier.';
  }

  /// Generate doubles hint
  String _generateDoublesHint(int operand1, int operand2) {
    if (operand1 == operand2) {
      return 'This is a doubles fact! $operand1 + $operand1 = ${operand1 * 2}. Doubles are easy to remember!';
    }
    return 'Look for doubles patterns to help solve this problem.';
  }

  /// Generate near doubles hint
  String _generateNearDoublesHint(int operand1, int operand2) {
    final diff = (operand1 - operand2).abs();
    if (diff == 1) {
      final smaller = operand1 < operand2 ? operand1 : operand2;
      final larger = operand1 > operand2 ? operand1 : operand2;
      final doubleResult = smaller * 2;
      return 'This is near doubles! $smaller + $smaller = $doubleResult, so $smaller + $larger = ${doubleResult + 1}.';
    }
    return 'Look for a doubles fact close to this problem, then add or subtract the difference.';
  }

  /// Generate make ten hint
  String _generateMakeTenHint(int operand1, int operand2) {
    if (operand1 <= 10 && operand2 <= 10) {
      if (operand1 < 10) {
        final needed = 10 - operand1;
        if (operand2 >= needed) {
          final remaining = operand2 - needed;
          return 'Make 10 first! $operand1 + $needed = 10. You have $remaining left from $operand2, so 10 + $remaining = ${operand1 + operand2}.';
        }
      }
      if (operand2 < 10) {
        final needed = 10 - operand2;
        if (operand1 >= needed) {
          final remaining = operand1 - needed;
          return 'Make 10 first! $operand2 + $needed = 10. You have $remaining left from $operand1, so 10 + $remaining = ${operand1 + operand2}.';
        }
      }
    }
    return 'Try breaking one number to help the other reach 10, then add what\'s left.';
  }

  /// Generate count on hint
  String _generateCountOnHint(int operand1, int operand2) {
    final larger = operand1 > operand2 ? operand1 : operand2;
    final smaller = operand1 < operand2 ? operand1 : operand2;
    
    if (smaller <= 3) {
      return 'Start with the bigger number ($larger) and count up by $smaller: ${_generateCountingSequence(larger, smaller)}.';
    }
    
    return 'Start with the larger number and count up by the smaller number.';
  }

  /// Generate counting sequence for count on strategy
  String _generateCountingSequence(int start, int countBy) {
    final sequence = <String>[];
    int current = start;
    sequence.add(current.toString());
    
    for (int i = 0; i < countBy; i++) {
      current++;
      sequence.add(current.toString());
    }
    
    return sequence.join(' → ');
  }

  /// Get step-by-step instructions for a strategy
  List<String> generateSteps(MathStrategy strategy, int operand1, int operand2) {
    switch (strategy.type) {
      case StrategyType.decomposition:
        return _generateDecompositionSteps(operand1, operand2);
      
      case StrategyType.doubles:
        return _generateDoublesSteps(operand1, operand2);
      
      case StrategyType.nearDoubles:
        return _generateNearDoublesSteps(operand1, operand2);
      
      case StrategyType.makeTen:
        return _generateMakeTenSteps(operand1, operand2);
      
      case StrategyType.countOn:
        return _generateCountOnSteps(operand1, operand2);
      
      default:
        return strategy.generateStepsFor(operand1, operand2);
    }
  }

  /// Generate decomposition steps
  List<String> _generateDecompositionSteps(int operand1, int operand2) {
    if (operand1 < 10 && operand2 > 5) {
      final needed = 10 - operand1;
      final remaining = operand2 - needed;
      if (remaining > 0 && needed <= operand2) {
        return [
          'Start with $operand1 + $operand2',
          'Break $operand2 into $needed + $remaining',
          'First: $operand1 + $needed = 10',
          'Then: 10 + $remaining = ${operand1 + operand2}',
        ];
      }
    }
    
    final part1 = operand2 ~/ 2;
    final part2 = operand2 - part1;
    return [
      'Start with $operand1 + $operand2',
      'Break $operand2 into $part1 + $part2',
      'Add step by step: $operand1 + $part1 + $part2',
      'Answer: ${operand1 + operand2}',
    ];
  }

  /// Generate doubles steps
  List<String> _generateDoublesSteps(int operand1, int operand2) {
    if (operand1 == operand2) {
      return [
        'Notice both numbers are the same: $operand1',
        'This is a doubles fact: $operand1 + $operand1',
        'Doubles are easy: ${operand1 * 2}',
      ];
    }
    return ['Look for doubles patterns in this problem'];
  }

  /// Generate near doubles steps
  List<String> _generateNearDoublesSteps(int operand1, int operand2) {
    final diff = (operand1 - operand2).abs();
    if (diff == 1) {
      final smaller = operand1 < operand2 ? operand1 : operand2;
      final larger = operand1 > operand2 ? operand1 : operand2;
      return [
        'Find the doubles fact: $smaller + $smaller = ${smaller * 2}',
        'This problem is one more: $smaller + $larger',
        'So add 1: ${smaller * 2} + 1 = ${operand1 + operand2}',
      ];
    }
    return ['Find a nearby doubles fact to help solve this'];
  }

  /// Generate make ten steps
  List<String> _generateMakeTenSteps(int operand1, int operand2) {
    if (operand1 < 10) {
      final needed = 10 - operand1;
      if (operand2 >= needed) {
        final remaining = operand2 - needed;
        return [
          'Start with $operand1',
          'Need ${needed} more to make 10',
          'Take $needed from $operand2: $operand1 + $needed = 10',
          'Add remaining: 10 + $remaining = ${operand1 + operand2}',
        ];
      }
    }
    return [
      'Look for ways to make 10 first',
      'Then add any remaining numbers',
    ];
  }

  /// Generate count on steps
  List<String> _generateCountOnSteps(int operand1, int operand2) {
    final larger = operand1 > operand2 ? operand1 : operand2;
    final smaller = operand1 < operand2 ? operand1 : operand2;
    
    return [
      'Start with the larger number: $larger',
      'Count up by $smaller: ${_generateCountingSequence(larger, smaller)}',
      'Answer: ${operand1 + operand2}',
    ];
  }

  /// Get strategy recommendation based on problem characteristics
  Future<MathStrategy?> getRecommendedStrategy(int operand1, int operand2, MathOperation operation) async {
    final strategies = await getApplicableStrategies(operand1, operand2, operation);
    
    if (strategies.isEmpty) return null;
    
    // Prioritize strategies based on problem characteristics
    for (final strategy in strategies) {
      switch (strategy.type) {
        case StrategyType.doubles:
          if (operand1 == operand2) return strategy;
          break;
        
        case StrategyType.nearDoubles:
          if ((operand1 - operand2).abs() == 1) return strategy;
          break;
        
        case StrategyType.makeTen:
          if ((operand1 < 10 && operand2 >= (10 - operand1)) ||
              (operand2 < 10 && operand1 >= (10 - operand2))) {
            return strategy;
          }
          break;
        
        case StrategyType.countOn:
          final smaller = operand1 < operand2 ? operand1 : operand2;
          if (smaller <= 3) return strategy;
          break;
        
        default:
          continue;
      }
    }
    
    // If no specific strategy fits, return the first applicable one
    return strategies.first;
  }
}