import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../constants/learning_constants.dart';

/// Database helper class for managing SQLite database
class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'mathfacts.db';
  static const int _databaseVersion = 1;

  /// Get database instance (singleton)
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    // For web platform, skip database initialization for now
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on web platform. Use SharedPreferences or IndexedDB instead.');
    }
    
    final String path = join(await getDatabasesPath(), _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create all database tables
  Future<void> _createTables(Database db, int version) async {
    // Math facts table
    await db.execute('''
      CREATE TABLE math_facts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operand1 INTEGER NOT NULL,
        operand2 INTEGER NOT NULL,
        operation TEXT NOT NULL,
        answer INTEGER NOT NULL,
        times_correct INTEGER DEFAULT 0,
        times_incorrect INTEGER DEFAULT 0,
        last_practiced TEXT,
        average_response_time REAL DEFAULT 0,
        mastery_level TEXT DEFAULT 'newFact',
        next_review_date TEXT,
        associated_strategies TEXT DEFAULT ''
      )
    ''');

    // Math strategies table
    await db.execute('''
      CREATE TABLE math_strategies (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        operation TEXT NOT NULL,
        strategy_type TEXT NOT NULL,
        min_operand1 INTEGER,
        max_operand1 INTEGER,
        min_operand2 INTEGER,
        max_operand2 INTEGER,
        hint_text TEXT,
        step_by_step_instructions TEXT,
        visual_representation TEXT
      )
    ''');

    // Practice sessions table
    await db.execute('''
      CREATE TABLE practice_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_time TEXT NOT NULL,
        end_time TEXT,
        session_type TEXT DEFAULT 'practice',
        total_problems INTEGER DEFAULT 0,
        correct_answers INTEGER DEFAULT 0,
        average_response_time REAL DEFAULT 0,
        operations_included TEXT DEFAULT '',
        hints_used INTEGER DEFAULT 0,
        strategies_shown TEXT DEFAULT ''
      )
    ''');

    // Practice attempts table
    await db.execute('''
      CREATE TABLE practice_attempts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fact_id INTEGER NOT NULL,
        session_id INTEGER NOT NULL,
        response_time REAL NOT NULL,
        user_answer INTEGER NOT NULL,
        is_correct INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        hint_requested INTEGER DEFAULT 0,
        strategy_used TEXT,
        answered_after_hint INTEGER DEFAULT 0,
        FOREIGN KEY (fact_id) REFERENCES math_facts (id),
        FOREIGN KEY (session_id) REFERENCES practice_sessions (id)
      )
    ''');

    // User progress table
    await db.execute('''
      CREATE TABLE user_progress (
        id INTEGER PRIMARY KEY DEFAULT 1,
        current_streak INTEGER DEFAULT 0,
        total_sessions INTEGER DEFAULT 0,
        last_session_date TEXT,
        overall_fluency_score REAL DEFAULT 0,
        hint_usage_frequency REAL DEFAULT 0,
        settings TEXT DEFAULT '{}'
      )
    ''');

    // Strategy usage tracking table
    await db.execute('''
      CREATE TABLE strategy_usage (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fact_id INTEGER NOT NULL,
        strategy_id TEXT NOT NULL,
        session_id INTEGER NOT NULL,
        was_helpful INTEGER DEFAULT 0,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (fact_id) REFERENCES math_facts (id),
        FOREIGN KEY (strategy_id) REFERENCES math_strategies (id),
        FOREIGN KEY (session_id) REFERENCES practice_sessions (id)
      )
    ''');

    // Spaced repetition table
    await db.execute('''
      CREATE TABLE spaced_repetition (
        fact_id INTEGER PRIMARY KEY,
        next_review_date TEXT NOT NULL,
        interval_level INTEGER DEFAULT 0,
        consecutive_correct INTEGER DEFAULT 0,
        last_reviewed TEXT NOT NULL,
        FOREIGN KEY (fact_id) REFERENCES math_facts (id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_math_facts_operation ON math_facts(operation)');
    await db.execute('CREATE INDEX idx_math_facts_mastery ON math_facts(mastery_level)');
    await db.execute('CREATE INDEX idx_math_facts_next_review ON math_facts(next_review_date)');
    await db.execute('CREATE INDEX idx_practice_attempts_fact_id ON practice_attempts(fact_id)');
    await db.execute('CREATE INDEX idx_practice_attempts_session_id ON practice_attempts(session_id)');
    await db.execute('CREATE INDEX idx_spaced_repetition_next_review ON spaced_repetition(next_review_date)');

    // Insert initial data
    await _insertInitialData(db);
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here when we need to update the schema
    if (oldVersion < 2) {
      // Future migrations will go here
    }
  }

  /// Insert initial math facts and strategies
  Future<void> _insertInitialData(Database db) async {
    await _insertAdditionFacts(db);
    await _insertAdditionStrategies(db);
    await _insertInitialUserProgress(db);
  }

  /// Insert all addition facts (0-10)
  Future<void> _insertAdditionFacts(Database db) async {
    final List<Map<String, dynamic>> facts = [];
    
    for (int i = 0; i <= LearningConstants.maxOperandMVP; i++) {
      for (int j = 0; j <= LearningConstants.maxOperandMVP; j++) {
        facts.add({
          'operand1': i,
          'operand2': j,
          'operation': 'addition',
          'answer': i + j,
          'mastery_level': 'newFact',
        });
      }
    }

    final batch = db.batch();
    for (final fact in facts) {
      batch.insert('math_facts', fact);
    }
    await batch.commit(noResult: true);
  }

  /// Insert addition strategies
  Future<void> _insertAdditionStrategies(Database db) async {
    final strategies = [
      // Decomposition strategy
      {
        'id': 'add_decomposition',
        'name': 'Break Apart Numbers',
        'description': 'Break one number into parts to make adding easier',
        'operation': 'addition',
        'strategy_type': 'decomposition',
        'min_operand1': 6,
        'max_operand1': 10,
        'min_operand2': 6,
        'max_operand2': 10,
        'hint_text': 'Break {op2} into parts to make adding easier. Try breaking it into parts that help you reach 10.',
        'step_by_step_instructions': 'Look at {op1} + {op2}|Break {op2} into smaller parts|Add {op1} + part1, then add part2|{op1} + {op2} = {sum}',
      },
      
      // Doubles strategy
      {
        'id': 'add_doubles',
        'name': 'Doubles Facts',
        'description': 'Use known doubles to solve problems',
        'operation': 'addition',
        'strategy_type': 'doubles',
        'min_operand1': 1,
        'max_operand1': 10,
        'min_operand2': 1,
        'max_operand2': 10,
        'hint_text': 'This is a doubles fact! {op1} + {op1} = {sum}',
        'step_by_step_instructions': 'Notice both numbers are the same|{op1} + {op1} = {sum}|Doubles are easy to remember!',
      },
      
      // Near doubles strategy
      {
        'id': 'add_near_doubles',
        'name': 'Near Doubles',
        'description': 'Use doubles facts plus or minus one',
        'operation': 'addition',
        'strategy_type': 'nearDoubles',
        'min_operand1': 1,
        'max_operand1': 10,
        'min_operand2': 1,
        'max_operand2': 10,
        'hint_text': 'This is close to a doubles fact! Think about {op1} + {op1}, then add or subtract 1.',
        'step_by_step_instructions': 'Find the doubles fact close to this|If {op1} + {op1} = result|Then {op1} + {op2} = result ± 1|{op1} + {op2} = {sum}',
      },
      
      // Make ten strategy
      {
        'id': 'add_make_ten',
        'name': 'Make Ten',
        'description': 'Break numbers to make 10 first, then add the rest',
        'operation': 'addition',
        'strategy_type': 'makeTen',
        'min_operand1': 6,
        'max_operand1': 10,
        'min_operand2': 2,
        'max_operand2': 9,
        'hint_text': 'Make 10 first! Break {op2} to help {op1} reach 10, then add what\'s left.',
        'step_by_step_instructions': 'Start with {op1}|How much more to make 10?|Break {op2} into parts|{op1} + part = 10|10 + remaining = {sum}',
      },
      
      // Count on strategy
      {
        'id': 'add_count_on',
        'name': 'Count On',
        'description': 'Start with the larger number and count up',
        'operation': 'addition',
        'strategy_type': 'countOn',
        'min_operand1': 1,
        'max_operand1': 10,
        'min_operand2': 1,
        'max_operand2': 5,
        'hint_text': 'Start with the bigger number and count up by the smaller number.',
        'step_by_step_instructions': 'Start with the larger number|Count up by the smaller number|Keep track on your fingers|{op1} + {op2} = {sum}',
      },
    ];

    final batch = db.batch();
    for (final strategy in strategies) {
      batch.insert('math_strategies', strategy);
    }
    await batch.commit(noResult: true);
  }

  /// Insert initial user progress record
  Future<void> _insertInitialUserProgress(Database db) async {
    await db.insert('user_progress', {
      'id': 1,
      'current_streak': 0,
      'total_sessions': 0,
      'overall_fluency_score': 0.0,
      'hint_usage_frequency': 0.0,
      'settings': '{}',
    });
  }

  /// Initialize database (call this in main.dart)
  Future<void> initDatabase() async {
    await database; // This will trigger initialization
  }

  /// Close database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Clear all data (for testing/reset)
  Future<void> clearAllData() async {
    final db = await database;
    
    // Clear all tables
    await db.delete('strategy_usage');
    await db.delete('practice_attempts');
    await db.delete('practice_sessions');
    await db.delete('spaced_repetition');
    await db.delete('math_facts');
    await db.delete('math_strategies');
    await db.delete('user_progress');
    
    // Reinsert initial data
    await _insertInitialData(db);
  }

  /// Get database statistics
  Future<Map<String, int>> getDatabaseStats() async {
    final db = await database;
    
    final mathFactsCount = await db.rawQuery('SELECT COUNT(*) as count FROM math_facts');
    final strategiesCount = await db.rawQuery('SELECT COUNT(*) as count FROM math_strategies');
    final sessionsCount = await db.rawQuery('SELECT COUNT(*) as count FROM practice_sessions');
    final attemptsCount = await db.rawQuery('SELECT COUNT(*) as count FROM practice_attempts');
    
    return {
      'mathFacts': mathFactsCount.first['count'] as int,
      'strategies': strategiesCount.first['count'] as int,
      'sessions': sessionsCount.first['count'] as int,
      'attempts': attemptsCount.first['count'] as int,
    };
  }
}