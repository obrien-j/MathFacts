import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'storage_interface.dart';
import 'storage_web.dart' if (dart.library.io) 'storage_mobile.dart';

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
  
  int get answer {
    switch (operation) {
      case '+':
        return operand1 + operand2;
      case '-':
        return operand1 - operand2;
      default:
        return operand1 + operand2;
    }
  }
  
  double get accuracy => attempts > 0 ? correctCount / attempts : 0.0;
  
  bool get needsPractice => attempts < 3 || accuracy < 0.8;
  
  bool get isMastered => attempts >= 3 && accuracy >= 0.8;
  
  String get factString => '$operand1 $operation $operand2';
  
  void recordAttempt(bool isCorrect) {
    attempts++;
    if (isCorrect) correctCount++;
    lastSeen = DateTime.now();
  }
  
  // JSON serialization for persistence
  Map<String, dynamic> toJson() => {
    'operand1': operand1,
    'operand2': operand2,
    'operation': operation,
    'attempts': attempts,
    'correctCount': correctCount,
    'lastSeen': lastSeen.toIso8601String(),
  };
  
  factory MathFact.fromJson(Map<String, dynamic> json) => MathFact(
    operand1: json['operand1'] as int,
    operand2: json['operand2'] as int,
    operation: json['operation'] as String,
    attempts: json['attempts'] as int,
    correctCount: json['correctCount'] as int,
    lastSeen: DateTime.parse(json['lastSeen'] as String),
  );
}

// Service for persisting math facts progress
class MathFactsStorage {
  static const String _storageKey = 'math_facts_data';
  static const String _scoreKey = 'practice_score';
  static const String _questionsKey = 'questions_answered';
  static const String _isInitializedKey = 'is_initialized';
  
  // Singleton pattern to ensure we use the same instance
  static final MathFactsStorage _instance = MathFactsStorage._internal();
  factory MathFactsStorage() => _instance;
  MathFactsStorage._internal();
  
  // Abstract storage implementation
  final StorageInterface _storage = getStorage();
  
  /// Save string to storage
  Future<bool> _saveString(String key, String value) async {
    try {
      await _storage.setString(key, value);
      return true;
    } catch (e) {
      print('   Storage error: $e');
      return false;
    }
  }
  
  /// Load string from storage
  Future<String?> _loadString(String key) async {
    try {
      return await _storage.getString(key);
    } catch (e) {
      print('   Storage error: $e');
      return null;
    }
  }
  
  /// Save int to storage
  Future<bool> _saveInt(String key, int value) async {
    try {
      await _storage.setInt(key, value);
      return true;
    } catch (e) {
      print('   Storage error: $e');
      return false;
    }
  }
  
  /// Load int from storage
  Future<int?> _loadInt(String key) async {
    try {
      return await _storage.getInt(key);
    } catch (e) {
      print('   Storage error: $e');
      return null;
    }
  }
  
  /// Remove key from storage
  Future<bool> _remove(String key) async {
    try {
      await _storage.remove(key);
      return true;
    } catch (e) {
      print('   Storage error: $e');
      return false;
    }
  }
  
  /// Save bool to storage
  Future<bool> _saveBool(String key, bool value) async {
    try {
      await _storage.setBool(key, value);
      return true;
    } catch (e) {
      print('   Storage error: $e');
      return false;
    }
  }
  
  /// Load bool from storage
  Future<bool> _loadBool(String key) async {
    try {
      return await _storage.getBool(key);
    } catch (e) {
      print('   Storage error: $e');
      return false;
    }
  }
  
  /// Check if app is initialized
  Future<bool> isInitialized() async {
    return await _loadBool(_isInitializedKey);
  }
  
  /// Set initialization status
  Future<void> setInitialized(bool value) async {
    await _saveBool(_isInitializedKey, value);
    print('🔧 Initialization status set to: $value');
  }
  
  /// Initialize app with all math facts
  Future<void> initializeApp() async {
    print('🚀 Initializing app...');
    
    // Generate all addition facts (121 facts)
    final additionFacts = <MathFact>[];
    for (int i = 0; i <= 10; i++) {
      for (int j = 0; j <= 10; j++) {
        additionFacts.add(MathFact(
          operand1: i,
          operand2: j,
          operation: '+',
        ));
      }
    }
    
    // Generate all subtraction facts (66 facts)
    final subtractionFacts = <MathFact>[];
    for (int i = 0; i <= 10; i++) {
      for (int j = 0; j <= i; j++) {
        subtractionFacts.add(MathFact(
          operand1: i,
          operand2: j,
          operation: '-',
        ));
      }
    }
    
    // Save all facts
    final allFacts = [...additionFacts, ...subtractionFacts];
    await saveFacts(allFacts);
    
    // Mark as initialized
    await setInitialized(true);
    
    print('✅ App initialized with ${allFacts.length} facts (${additionFacts.length} addition, ${subtractionFacts.length} subtraction)');
  }
  
  /// Save all math facts to persistent storage (used on initial save or full reset)
  Future<void> saveFacts(List<MathFact> facts) async {
    final factsJson = facts.map((fact) => fact.toJson()).toList();
    final jsonString = jsonEncode(factsJson);
    
    print('💾 Storage: Saving ${facts.length} facts (${jsonString.length} bytes)');
    final success = await _saveString(_storageKey, jsonString);
    print('   Save success: $success');
    
    // Verify the save by reading it back
    final verification = await _loadString(_storageKey);
    print('   Verification: ${verification != null && verification.length == jsonString.length}');
  }
  
  /// Save a single updated fact (more efficient API than saving all 121 facts)
  Future<void> saveUpdatedFact(MathFact updatedFact, List<MathFact> allFacts) async {
    // Find the index of this fact in the list
    final index = allFacts.indexWhere((f) => 
      f.operand1 == updatedFact.operand1 && 
      f.operand2 == updatedFact.operand2 && 
      f.operation == updatedFact.operation
    );
    
    if (index == -1) {
      print('⚠️ Warning: Could not find fact to update');
      return;
    }
    
    // NOTE: For now, we still serialize the entire list because localStorage/SharedPreferences
    // requires storing the full array. However, this method:
    // 1. Makes the intent clear (only one fact changed)
    // 2. Allows future optimization (e.g., IndexedDB with individual fact keys)
    // 3. Could be enhanced to only serialize changed facts if size becomes an issue
    // 
    // TODO: If performance becomes an issue, consider:
    // - Using IndexedDB on web (store each fact as separate key: "fact_5_7")
    // - Using SQLite on mobile (UPDATE single row)
    // - Only serializing facts with attempts > 0 (reduce payload size)
    final factsJson = allFacts.map((fact) => fact.toJson()).toList();
    final jsonString = jsonEncode(factsJson);
    
    print('💾 Storage: Updated fact ${updatedFact.factString} (${jsonString.length} bytes total)');
    await _saveString(_storageKey, jsonString);
  }
  
  /// Load all math facts from persistent storage
  Future<List<MathFact>?> loadFacts() async {
    print('🔍 Storage: Loading facts...');
    
    final factsString = await _loadString(_storageKey);
    
    print('   Found data: ${factsString != null} (${factsString?.length ?? 0} bytes)');
    
    if (factsString == null || factsString.isEmpty) return null;
    
    try {
      final factsList = jsonDecode(factsString) as List;
      final facts = factsList.map((json) => MathFact.fromJson(json as Map<String, dynamic>)).toList();
      print('   Loaded ${facts.length} facts');
      return facts;
    } catch (e) {
      print('   Error parsing facts: $e');
      return null;
    }
  }
  
  /// Save practice session statistics
  Future<void> saveSessionStats(int score, int questionsAnswered) async {
    await _saveInt(_scoreKey, score);
    await _saveInt(_questionsKey, questionsAnswered);
  }
  
  /// Load practice session statistics
  Future<Map<String, int>> loadSessionStats() async {
    final score = await _loadInt(_scoreKey);
    final questions = await _loadInt(_questionsKey);
    
    return {
      'score': score ?? 0,
      'questionsAnswered': questions ?? 0,
    };
  }
  
  /// Clear all stored data (useful for testing or reset)
  Future<void> clearAll() async {
    await _remove(_storageKey);
    await _remove(_scoreKey);
    await _remove(_questionsKey);
    await _remove(_isInitializedKey);
    print('🗑️ Storage cleared');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check if app is initialized
  final storage = MathFactsStorage();
  final isInitialized = await storage.isInitialized();
  
  if (!isInitialized) {
    print('📋 First run detected - initializing app...');
    await storage.initializeApp();
  } else {
    print('✅ App already initialized');
  }
  
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

  Future<void> _resetProgress(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text('Are you sure you want to reset all progress? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true && context.mounted) {
      await MathFactsStorage().clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progress reset successfully!')),
        );
      }
    }
  }

  Future<void> _resetStorage(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Storage'),
        content: const Text('This will clear all data and regenerate all math facts from scratch. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true && context.mounted) {
      final storage = MathFactsStorage();
      
      // Clear all storage
      await storage.clearAll();
      
      // Reinitialize the app
      await storage.initializeApp();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage reset and reinitialized successfully!')),
        );
      }
    }
  }

  Future<void> _viewStorage(BuildContext context) async {
    final storage = MathFactsStorage();
    
    print('\n========================================');
    print('📊 STORAGE CONTENTS');
    print('========================================\n');
    
    // Get initialization status
    final isInitialized = await storage.isInitialized();
    print('🔧 Initialized: $isInitialized');
    
    // Get all facts
    final facts = await storage.loadFacts();
    print('\n📚 Math Facts: ${facts?.length ?? 0} total');
    if (facts != null) {
      final additionFacts = facts.where((f) => f.operation == '+').toList();
      final subtractionFacts = facts.where((f) => f.operation == '-').toList();
      print('   ➕ Addition: ${additionFacts.length}');
      print('   ➖ Subtraction: ${subtractionFacts.length}');
      
      // Show practiced facts
      final practiced = facts.where((f) => f.attempts > 0).toList();
      print('\n📝 Practiced Facts: ${practiced.length}');
      for (var fact in practiced.take(10)) {
        print('   ${fact.factString} = ${fact.answer} | Attempts: ${fact.attempts}, Correct: ${fact.correctCount}, Accuracy: ${(fact.accuracy * 100).toStringAsFixed(1)}%');
      }
      if (practiced.length > 10) {
        print('   ... and ${practiced.length - 10} more');
      }
      
      // Show mastered facts
      final mastered = facts.where((f) => f.isMastered).toList();
      print('\n✅ Mastered Facts: ${mastered.length}');
    }
    
    // Get session stats
    final stats = await storage.loadSessionStats();
    print('\n📈 Session Statistics:');
    print('   Score: ${stats['score']} / ${stats['questionsAnswered']}');
    if (stats['questionsAnswered']! > 0) {
      final percentage = (stats['score']! / stats['questionsAnswered']! * 100).toStringAsFixed(1);
      print('   Accuracy: $percentage%');
    }
    
    print('\n========================================\n');
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage details printed to console')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MathFacts'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Progress',
            onPressed: () => _resetProgress(context),
          ),
        ],
      ),
      body: Center(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: PracticeButton(operation: '+'),
                ),
                SizedBox(width: 20),
                Flexible(
                  child: PracticeButton(operation: '-'),
                ),
              ],
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _resetStorage(context),
              icon: const Icon(Icons.storage),
              label: const Text('Reset Storage'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _viewStorage(context),
              icon: const Icon(Icons.visibility),
              label: const Text('View Storage'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PracticeButton extends StatelessWidget {
  final String operation;
  
  const PracticeButton({super.key, required this.operation});

  @override
  Widget build(BuildContext context) {
    final isAddition = operation == '+';
    final label = isAddition ? 'Practice Addition' : 'Practice Subtraction';
    final color = isAddition ? Colors.green : Colors.purple;
    
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PracticeScreen(operation: operation),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 16),
      ),
      child: Text(label),
    );
  }
}

class PracticeScreen extends StatefulWidget {
  final String operation;
  
  const PracticeScreen({super.key, required this.operation});

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
  bool _showFeedbackBorder = false;
  bool _isCorrectAnswer = false;
  
  // All math facts (filtered by operation)
  List<MathFact> _allFacts = [];
  
  // Storage service
  final MathFactsStorage _storage = MathFactsStorage();
  
  // Loading state
  bool _isLoading = true;
  
  // Controllers for autofocus functionality
  late TextEditingController _answerController;
  late FocusNode _answerFocusNode;
  
  // Random number generator for fact selection
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
    _answerFocusNode = FocusNode();
    _initializeApp();
  }
  
  /// Initialize the app by loading saved data or generating new facts
  Future<void> _initializeApp() async {
    // Try to load saved facts
    final savedFacts = await _storage.loadFacts();
    final savedStats = await _storage.loadSessionStats();
    
    // Debug logging
    print('🔍 Loading saved data for ${widget.operation}...');
    print('   Saved facts: ${savedFacts?.length ?? 0}');
    print('   Saved score: ${savedStats['score']}');
    print('   Saved questions: ${savedStats['questionsAnswered']}');
    
    setState(() {
      if (savedFacts != null && savedFacts.isNotEmpty) {
        // Filter facts for this operation only
        _allFacts = savedFacts.where((f) => f.operation == widget.operation).toList();
        print('✅ Loaded ${_allFacts.length} ${widget.operation} facts from storage');
        
        // Debug: Show some stats about loaded facts
        final practiced = _allFacts.where((f) => f.attempts > 0).length;
        final mastered = _allFacts.where((f) => f.isMastered).length;
        print('   Facts with attempts: $practiced');
        print('   Facts mastered: $mastered');
        
        // Show details of first few practiced facts
        final practicedFacts = _allFacts.where((f) => f.attempts > 0).take(3).toList();
        for (var fact in practicedFacts) {
          print('   ${fact.factString}: ${fact.attempts} attempts, ${fact.correctCount} correct');
        }
      } else {
        // Generate new facts if none saved
        _allFacts = [];
      }
      
      // If no facts for this operation exist, generate them
      if (_allFacts.isEmpty) {
        _generateAllFacts();
        print('🆕 Generated new ${widget.operation} facts');
        
        // Save the newly generated facts immediately
        _saveAllFacts();
      }
      
      // Restore session stats
      _score = savedStats['score'] ?? 0;
      _questionsAnswered = savedStats['questionsAnswered'] ?? 0;
      
      _isLoading = false;
    });
    
    _selectNextFact();
  }
  
  @override
  void dispose() {
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }
  
  /// Generate all facts for the current operation
  void _generateAllFacts() {
    _allFacts.clear();
    if (widget.operation == '+') {
      // Addition: 0+0 through 10+10 (121 facts)
      for (int i = 0; i <= 10; i++) {
        for (int j = 0; j <= 10; j++) {
          _allFacts.add(MathFact(
            operand1: i,
            operand2: j,
            operation: '+',
          ));
        }
      }
    } else if (widget.operation == '-') {
      // Subtraction: keep results non-negative (e.g., 10-0 through 10-10, 9-0 through 9-9, etc.)
      for (int i = 0; i <= 10; i++) {
        for (int j = 0; j <= i; j++) {
          _allFacts.add(MathFact(
            operand1: i,
            operand2: j,
            operation: '-',
          ));
        }
      }
    }
    print('🔧 Generated ${_allFacts.length} facts for ${widget.operation}');
    if (_allFacts.isNotEmpty) {
      print('   First fact: ${_allFacts[0].factString}');
      print('   Last fact: ${_allFacts[_allFacts.length - 1].factString}');
    }
  }

  /// Select the next fact to practice based on performance
  void _selectNextFact() {
    // Priority: facts that need practice (haven't been mastered)
    final factsNeedingPractice = _allFacts.where((fact) => fact.needsPractice).toList();
    
    if (factsNeedingPractice.isNotEmpty) {
      // Select randomly from facts needing practice using proper random
      // Later we can implement more sophisticated spaced repetition
      final randomIndex = _random.nextInt(factsNeedingPractice.length);
      _currentFact = factsNeedingPractice[randomIndex];
    } else {
      // All facts are mastered, select any fact for review
      final randomIndex = _random.nextInt(_allFacts.length);
      _currentFact = _allFacts[randomIndex];
    }
    
    setState(() {
      _userAnswer = '';
      _feedback = '';
      _showFeedbackBorder = false;
    });
    
    // Clear the text field
    _answerController.clear();
  }

  void _checkAnswer() {
    if (_userAnswer.isEmpty || _currentFact == null) return;
    
    final userAnswerInt = int.tryParse(_userAnswer);
    if (userAnswerInt == null) return;

    final isCorrect = userAnswerInt == _currentFact!.answer;
    
    // Record the attempt for this specific fact
    _currentFact!.recordAttempt(isCorrect);
    
    // Debug: Verify the fact was updated
    print('📝 Updated fact: ${_currentFact!.factString}');
    print('   Attempts: ${_currentFact!.attempts}, Correct: ${_currentFact!.correctCount}');
    print('   Needs practice: ${_currentFact!.needsPractice}, Mastered: ${_currentFact!.isMastered}');

    setState(() {
      _questionsAnswered++;
      _showFeedbackBorder = true;
      _isCorrectAnswer = isCorrect;
      if (isCorrect) {
        _score++;
        _feedback = 'Correct! Great job! 🎉';
      } else {
        _feedback = 'Not quite. The answer is ${_currentFact!.answer}. Try again!';
      }
    });
    
    // Save progress to persistent storage
    _saveProgress();

    // Auto-generate new problem - shorter delay for correct, longer for incorrect
    final delay = isCorrect ? const Duration(milliseconds: 800) : const Duration(seconds: 3);
    Future.delayed(delay, () {
      if (mounted) {
        _selectNextFact(); // This will also handle focusing
      }
    });
  }
  
  /// Handle number pad button press
  void _onNumberPressed(String number) {
    setState(() {
      _userAnswer += number;
      _answerController.text = _userAnswer;
    });
  }
  
  /// Handle backspace button press
  void _onBackspace() {
    if (_userAnswer.isNotEmpty) {
      setState(() {
        _userAnswer = _userAnswer.substring(0, _userAnswer.length - 1);
        _answerController.text = _userAnswer;
      });
    }
  }
  
  /// Handle clear button press
  void _onClear() {
    setState(() {
      _userAnswer = '';
      _answerController.clear();
    });
  }
  
  /// Build custom number pad widget
  Widget _buildNumberPad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          // Row 1: 1, 2, 3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('1'),
              _buildNumberButton('2'),
              _buildNumberButton('3'),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: 4, 5, 6
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('4'),
              _buildNumberButton('5'),
              _buildNumberButton('6'),
            ],
          ),
          const SizedBox(height: 8),
          // Row 3: 7, 8, 9
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('7'),
              _buildNumberButton('8'),
              _buildNumberButton('9'),
            ],
          ),
          const SizedBox(height: 8),
          // Row 4: Clear, 0, Backspace
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton('C', _onClear, Colors.red),
              _buildNumberButton('0'),
              _buildActionButton('⌫', _onBackspace, Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('Check Answer ✓'),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build a number button
  Widget _buildNumberButton(String number) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => _onNumberPressed(number),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade100,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(number),
        ),
      ),
    );
  }
  
  /// Build an action button (Clear, Backspace)
  Widget _buildActionButton(String label, VoidCallback onPressed, Color baseColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: baseColor.withOpacity(0.2),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
  
  /// Save progress to persistent storage (saves all facts, not just current operation)
  Future<void> _saveProgress() async {
    if (_currentFact == null) return;
    
    print('💾 Saving progress...');
    print('   Updated fact: ${_currentFact!.factString}');
    print('   Score: $_score / $_questionsAnswered');
    
    // Load all facts from storage (both operations)
    final allStoredFacts = await _storage.loadFacts() ?? [];
    
    // Update or add the current fact
    final index = allStoredFacts.indexWhere((f) => 
      f.operand1 == _currentFact!.operand1 && 
      f.operand2 == _currentFact!.operand2 && 
      f.operation == _currentFact!.operation
    );
    
    if (index != -1) {
      allStoredFacts[index] = _currentFact!;
    } else {
      allStoredFacts.add(_currentFact!);
    }
    
    // Save combined facts (both operations)
    await _storage.saveFacts(allStoredFacts);
    await _storage.saveSessionStats(_score, _questionsAnswered);
    
    print('✅ Progress saved');
  }
  
  /// Save all facts for this operation (used when generating new facts)
  Future<void> _saveAllFacts() async {
    print('💾 Saving all ${_allFacts.length} ${widget.operation} facts...');
    
    // Load all facts from storage (both operations)
    final allStoredFacts = await _storage.loadFacts() ?? [];
    
    // Remove any existing facts for this operation
    allStoredFacts.removeWhere((f) => f.operation == widget.operation);
    
    // Add all current facts
    allStoredFacts.addAll(_allFacts);
    
    // Save combined facts
    await _storage.saveFacts(allStoredFacts);
    
    print('✅ All facts saved (${allStoredFacts.length} total)');
  }

  @override
  Widget build(BuildContext context) {
    final isAddition = widget.operation == '+';
    final title = isAddition ? 'Practice Addition' : 'Practice Subtraction';
    final color = isAddition ? Colors.green : Colors.purple;
    final totalFacts = isAddition ? 121 : 66; // Addition: 121, Subtraction: 66
    
    // Show loading indicator while initializing
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Determine border color based on feedback state
    Color? borderColor;
    if (_showFeedbackBorder) {
      borderColor = _isCorrectAnswer ? Colors.green : Colors.red;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          border: borderColor != null 
            ? Border.all(color: borderColor, width: 8)
            : null,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                    'Facts Practiced: ${_allFacts.where((f) => f.attempts > 0).length}/$totalFacts',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    'Facts Mastered: ${_allFacts.where((f) => f.isMastered).length}/$totalFacts',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Math problem
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      _currentFact != null ? '${_currentFact!.factString} = ?' : 'Loading...',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Answer input (read-only, uses custom number pad)
                    SizedBox(
                      width: 150,
                      child: TextField(
                        controller: _answerController,
                        readOnly: true,
                        showCursor: true,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '?',
                          hintStyle: TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Custom Number Pad
                    _buildNumberPad(),
                    
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
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
        ),
      ),
    );
  }
}