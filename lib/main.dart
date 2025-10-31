import 'package:flutter/material.dart';

// Model for individual math facts
class MathFact {
  final int operand1;
  final int operand2;
  final String operation;
  int attempts;
  int correctCount;
  DateTime lastSeen;
  
  MathFact({
    required this.operand1,
    required this.operand2,
    required this.operation,
    this.attempts = 0,
    this.correctCount = 0,
    DateTime? lastSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();
  
  int get answer => operand1 + operand2; // For now, only addition
  
  double get accuracy => attempts > 0 ? correctCount / attempts : 0.0;
  
  bool get needsPractice => attempts < 3 || accuracy < 0.8;
  
  bool get isMastered => attempts >= 3 && accuracy >= 0.8;
  
  String get factString => '$operand1 $operation $operand2';
  
  void recordAttempt(bool isCorrect) {
    attempts++;
    if (isCorrect) correctCount++;
    lastSeen = DateTime.now();
  }
}

void main() {
  runApp(const MathFactsApp());
}

class MathFactsApp extends StatelessWidget {
  const MathFactsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MathFacts',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MathFacts'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calculate,
              size: 80,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to MathFacts!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Learn math facts through active retrieval',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 40),
            PracticeButton(),
          ],
        ),
      ),
    );
  }
}

class PracticeButton extends StatelessWidget {
  const PracticeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PracticeScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontSize: 18),
      ),
      child: const Text('Practice Math Facts'),
    );
  }
}

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  // Current practice data
  MathFact? _currentFact;
  String _userAnswer = '';
  int _score = 0;
  int _questionsAnswered = 0;
  String _feedback = '';
  
  // All math facts (121 addition facts: 0+0 through 10+10)
  late List<MathFact> _allFacts;
  
  // Controllers for autofocus functionality
  late TextEditingController _answerController;
  late FocusNode _answerFocusNode;

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
    _answerFocusNode = FocusNode();
    _generateAllFacts();
    _selectNextFact();
  }
  
  @override
  void dispose() {
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }
  
  /// Generate all 121 addition facts (0+0 through 10+10)
  void _generateAllFacts() {
    _allFacts = [];
    for (int i = 0; i <= 10; i++) {
      for (int j = 0; j <= 10; j++) {
        _allFacts.add(MathFact(
          operand1: i,
          operand2: j,
          operation: '+',
        ));
      }
    }
  }

  /// Select the next fact to practice based on performance
  void _selectNextFact() {
    // Priority: facts that need practice (haven't been mastered)
    final factsNeedingPractice = _allFacts.where((fact) => fact.needsPractice).toList();
    
    if (factsNeedingPractice.isNotEmpty) {
      // For now, select randomly from facts needing practice
      // Later we can implement more sophisticated spaced repetition
      final randomIndex = DateTime.now().millisecond % factsNeedingPractice.length;
      _currentFact = factsNeedingPractice[randomIndex];
    } else {
      // All facts are mastered, select any fact for review
      final randomIndex = DateTime.now().millisecond % _allFacts.length;
      _currentFact = _allFacts[randomIndex];
    }
    
    setState(() {
      _userAnswer = '';
      _feedback = '';
    });
    
    // Clear the text field and request focus
    _answerController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _answerFocusNode.requestFocus();
      }
    });
  }

  void _checkAnswer() {
    if (_userAnswer.isEmpty || _currentFact == null) return;
    
    final userAnswerInt = int.tryParse(_userAnswer);
    if (userAnswerInt == null) return;

    final isCorrect = userAnswerInt == _currentFact!.answer;
    
    // Record the attempt for this specific fact
    _currentFact!.recordAttempt(isCorrect);

    setState(() {
      _questionsAnswered++;
      if (isCorrect) {
        _score++;
        _feedback = 'Correct! Great job! 🎉';
      } else {
        _feedback = 'Not quite. The answer is ${_currentFact!.answer}. Try again!';
      }
    });

    // Auto-generate new problem after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _selectNextFact(); // This will also handle focusing
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Addition'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Score display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Score: $_score / $_questionsAnswered',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Facts Practiced: ${_allFacts.where((f) => f.attempts > 0).length}/121',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    'Facts Mastered: ${_allFacts.where((f) => f.isMastered).length}/121',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Math problem
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      _currentFact != null ? '${_currentFact!.factString} = ?' : 'Loading...',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Answer input
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _answerController,
                        focusNode: _answerFocusNode,
                        autofocus: true,
                        onChanged: (value) {
                          _userAnswer = value;
                        },
                        onSubmitted: (_) => _checkAnswer(),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintStyle: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Submit button
                    ElevatedButton(
                      onPressed: _checkAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Check Answer'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Feedback
            if (_feedback.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _feedback.contains('Correct') 
                    ? Colors.green.shade50 
                    : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _feedback.contains('Correct') 
                      ? Colors.green 
                      : Colors.orange,
                  ),
                ),
                child: Text(
                  _feedback,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _feedback.contains('Correct') 
                      ? Colors.green.shade700 
                      : Colors.orange.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}