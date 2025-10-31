import 'package:flutter/material.dart';

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
  int _num1 = 0;
  int _num2 = 0;
  int _correctAnswer = 0;
  String _userAnswer = '';
  int _score = 0;
  int _questionsAnswered = 0;
  String _feedback = '';

  @override
  void initState() {
    super.initState();
    _generateNewProblem();
  }

  void _generateNewProblem() {
    setState(() {
      _num1 = _generateRandomNumber();
      _num2 = _generateRandomNumber();
      _correctAnswer = _num1 + _num2;
      _userAnswer = '';
      _feedback = '';
    });
  }

  int _generateRandomNumber() {
    return DateTime.now().millisecond % 11; // 0-10
  }

  void _checkAnswer() {
    if (_userAnswer.isEmpty) return;
    
    final userAnswerInt = int.tryParse(_userAnswer);
    if (userAnswerInt == null) return;

    setState(() {
      _questionsAnswered++;
      if (userAnswerInt == _correctAnswer) {
        _score++;
        _feedback = 'Correct! Great job! 🎉';
      } else {
        _feedback = 'Not quite. The answer is $_correctAnswer. Try again!';
      }
    });

    // Auto-generate new problem after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _generateNewProblem();
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
              child: Text(
                'Score: $_score / $_questionsAnswered',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
                      '$_num1 + $_num2 = ?',
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
                        controller: TextEditingController(text: _userAnswer),
                        onChanged: (value) {
                          _userAnswer = value;
                        },
                        onSubmitted: (_) => _checkAnswer(),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '?',
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