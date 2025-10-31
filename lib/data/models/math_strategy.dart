import '../../core/constants/app_constants.dart';

/// Strategy types for math fact hints
enum StrategyType {
  decomposition,    // Break apart numbers (e.g., 8+7 = 8+2+5)
  doubles,          // Use doubles facts (e.g., 6+6 = 12)
  nearDoubles,      // Doubles plus/minus one (e.g., 6+7 = 6+6+1)
  makeTen,          // Addition to make 10 (e.g., 8+5 = 8+2+3)
  countOn,          // Count up from larger number
  factFamilies,     // Related facts (e.g., if 3+4=7, then 7-4=3)
  skipCounting,     // For multiplication (e.g., 3x4 = 3,6,9,12)
  arrays,           // Visual arrangement for multiplication
}

/// Represents a math strategy for solving problems
class MathStrategy {
  final String id;
  final String name;
  final String description;
  final MathOperation operation;
  final StrategyType type;
  final int minOperand1;
  final int maxOperand1;
  final int minOperand2;
  final int maxOperand2;
  final String hintText;
  final List<String> stepByStepInstructions;
  final String? visualRepresentation;

  const MathStrategy({
    required this.id,
    required this.name,
    required this.description,
    required this.operation,
    required this.type,
    required this.minOperand1,
    required this.maxOperand1,
    required this.minOperand2,
    required this.maxOperand2,
    required this.hintText,
    required this.stepByStepInstructions,
    this.visualRepresentation,
  });

  /// Create MathStrategy from database map
  factory MathStrategy.fromMap(Map<String, dynamic> map) {
    return MathStrategy(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      operation: MathOperation.values.firstWhere(
        (e) => e.name == map['operation'],
      ),
      type: StrategyType.values.firstWhere(
        (e) => e.name == map['strategy_type'],
      ),
      minOperand1: map['min_operand1'] as int,
      maxOperand1: map['max_operand1'] as int,
      minOperand2: map['min_operand2'] as int,
      maxOperand2: map['max_operand2'] as int,
      hintText: map['hint_text'] as String,
      stepByStepInstructions: map['step_by_step_instructions'] != null
          ? List<String>.from(map['step_by_step_instructions'].split('|'))
          : [],
      visualRepresentation: map['visual_representation'] as String?,
    );
  }

  /// Convert MathStrategy to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'operation': operation.name,
      'strategy_type': type.name,
      'min_operand1': minOperand1,
      'max_operand1': maxOperand1,
      'min_operand2': minOperand2,
      'max_operand2': maxOperand2,
      'hint_text': hintText,
      'step_by_step_instructions': stepByStepInstructions.join('|'),
      'visual_representation': visualRepresentation,
    };
  }

  /// Check if this strategy applies to the given math fact
  bool appliesTo(int operand1, int operand2, MathOperation operation) {
    return this.operation == operation &&
        operand1 >= minOperand1 &&
        operand1 <= maxOperand1 &&
        operand2 >= minOperand2 &&
        operand2 <= maxOperand2;
  }

  /// Generate strategy hint text for specific operands
  String generateHintFor(int operand1, int operand2) {
    String hint = hintText;
    
    // Replace placeholders with actual numbers
    hint = hint.replaceAll('{op1}', operand1.toString());
    hint = hint.replaceAll('{op2}', operand2.toString());
    hint = hint.replaceAll('{sum}', (operand1 + operand2).toString());
    hint = hint.replaceAll('{product}', (operand1 * operand2).toString());
    hint = hint.replaceAll('{difference}', (operand1 - operand2).toString());
    
    return hint;
  }

  /// Generate step-by-step instructions for specific operands
  List<String> generateStepsFor(int operand1, int operand2) {
    return stepByStepInstructions.map((step) {
      String processedStep = step;
      processedStep = processedStep.replaceAll('{op1}', operand1.toString());
      processedStep = processedStep.replaceAll('{op2}', operand2.toString());
      processedStep = processedStep.replaceAll('{sum}', (operand1 + operand2).toString());
      processedStep = processedStep.replaceAll('{product}', (operand1 * operand2).toString());
      processedStep = processedStep.replaceAll('{difference}', (operand1 - operand2).toString());
      return processedStep;
    }).toList();
  }

  @override
  String toString() {
    return 'MathStrategy{$name, $type, $operation}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MathStrategy && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}