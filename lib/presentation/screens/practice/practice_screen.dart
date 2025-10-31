import 'package:flutter/material.dart';
import 'dart:math';
import '../../themes/app_theme.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({Key? key}) : super(key: key);

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final TextEditingController _answerController = TextEditingController();
  final Random _random = Random();
  
  int _operand1 = 0;
  int _operand2 = 0;
  int _correctAnswer = 0;
  int _problemsCompleted = 0;
  bool _showingFeedback = false;
  bool _isCorrect = false;
  String _feedbackMessage = '';

  @override
  void initState() {
    super.initState();
    _generateNewProblem();
  }

  void _generateNewProblem() {
    _operand1 = _random.nextInt(11); // 0-10
    _operand2 = _random.nextInt(11); // 0-10
    _correctAnswer = _operand1 + _operand2;
    _answerController.clear();
    setState(() {
      _showingFeedback = false;
    });
  }

  void _submitAnswer() {
    final userAnswer = int.tryParse(_answerController.text.trim());
    if (userAnswer == null) return;

    final isCorrect = userAnswer == _correctAnswer;
    _problemsCompleted++;

    setState(() {
      _isCorrect = isCorrect;
      _showingFeedback = true;
      _feedbackMessage = isCorrect ? 'Correct! 🎉' : 'The answer is $_correctAnswer';
    });

    if (_problemsCompleted >= 20) {
      _showSessionComplete();
    } else {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _generateNewProblem();
        }
      });
    }
  }

  void _showSessionComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Complete! 🎉'),
        content: Text('You completed $_problemsCompleted problems!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Practice Session ($_problemsCompleted/20)'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_showingFeedback) ...[
              Icon(
                _isCorrect ? Icons.check_circle : Icons.cancel,
                size: 64,
                color: _isCorrect ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _feedbackMessage,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: _isCorrect ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Text(
                '$_operand1 + $_operand2 = ?',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _answerController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: 'Your answer',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _submitAnswer(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Submit'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}