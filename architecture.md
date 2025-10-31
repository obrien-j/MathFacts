# MathFacts App Architecture

## Overview

MathFacts is a mobile app designed to help children ages 6-15 develop automaticity with single-digit math facts (addition, subtraction, multiplication) using evidence-based learning science principles. The app prioritizes simplicity and effectiveness over complex gamification.

## Core Requirements Summary

- **Target**: Ages 6-15, adaptive across grade levels
- **Operations**: Addition (MVP), then subtraction and multiplication
- **Learning Focus**: Active retrieval, spaced repetition, optional interleaving
- **Math Strategies**: Optional hint system with decomposition strategies
- **Design**: Simple/minimal, no complex gamification
- **Sessions**: 5-10 minutes, offline-capable
- **Privacy**: Home use, minimal data collection

## Technology Stack

### Recommended: Flutter
**Rationale**: Based on your requirements for cross-platform support, offline capability, and simple UI, Flutter is optimal.

```
Frontend: Flutter (Dart)
State Management: Provider or Riverpod
Local Database: SQLite (via sqflite package)
Local Storage: SharedPreferences
Notifications: flutter_local_notifications
Optional Cloud Sync: Firebase (future feature)
```

## App Architecture Pattern

### Clean Architecture + MVVM
```
┌─────────────────────────────────────────┐
│                  UI Layer               │
│  ┌─────────────┐  ┌─────────────────┐  │
│  │   Screens   │  │     Widgets     │  │
│  └─────────────┘  └─────────────────┘  │
└─────────────────────────────────────────┘
┌─────────────────────────────────────────┐
│              Domain Layer               │
│  ┌─────────────┐  ┌─────────────────┐  │
│  │   Models    │  │  Business Logic │  │
│  └─────────────┘  └─────────────────┘  │
└─────────────────────────────────────────┘
┌─────────────────────────────────────────┐
│               Data Layer                │
│  ┌─────────────┐  ┌─────────────────┐  │
│  │ Local Storage│  │   Repositories  │  │
│  └─────────────┘  └─────────────────┘  │
└─────────────────────────────────────────┘
```

## Project Structure (Flutter)

```
lib/
├── main.dart
├── app/
│   ├── app.dart                    # Main app configuration
│   └── routes.dart                 # Navigation routing
├── core/
│   ├── constants/
│   │   ├── app_constants.dart      # App-wide constants
│   │   └── learning_constants.dart # Learning science parameters
│   ├── database/
│   │   ├── database_helper.dart    # SQLite setup
│   │   └── migrations/             # Database migrations
│   ├── services/
│   │   ├── notification_service.dart
│   │   ├── storage_service.dart
│   │   ├── analytics_service.dart  # Local analytics only
│   │   └── math_strategy_service.dart # Hint/strategy generation
│   └── utils/
│       ├── date_utils.dart
│       └── math_utils.dart
├── data/
│   ├── models/
│   │   ├── math_fact.dart          # Individual math problem
│   │   ├── practice_session.dart   # Session data
│   │   ├── user_progress.dart      # Progress tracking
│   │   ├── spaced_repetition_item.dart
│   │   └── math_strategy.dart      # Strategy/hint definitions
│   ├── repositories/
│   │   ├── math_facts_repository.dart
│   │   ├── progress_repository.dart
│   │   ├── session_repository.dart
│   │   └── strategy_repository.dart
│   └── providers/
│       ├── local_data_provider.dart
│       └── preferences_provider.dart
├── domain/
│   ├── entities/                   # Core business objects
│   │   ├── problem.dart
│   │   ├── session.dart
│   │   └── progress.dart
│   └── usecases/
│       ├── generate_practice_session.dart
│       ├── calculate_spaced_repetition.dart
│       ├── track_progress.dart
│       ├── assess_mastery.dart
│       └── generate_math_strategy.dart
├── presentation/
│   ├── screens/
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── home_viewmodel.dart
│   │   ├── practice/
│   │   │   ├── practice_screen.dart
│   │   │   ├── practice_viewmodel.dart
│   │   │   └── widgets/
│   │   │       ├── problem_display.dart
│   │   │       ├── answer_input.dart
│   │   │       ├── feedback_widget.dart
│   │   │       └── hint_widget.dart
│   │   ├── progress/
│   │   │   ├── progress_screen.dart
│   │   │   ├── progress_viewmodel.dart
│   │   │   └── widgets/
│   │   │       ├── progress_chart.dart
│   │   │       └── fluency_indicator.dart
│   │   ├── assessment/
│   │   │   ├── assessment_screen.dart
│   │   │   └── assessment_viewmodel.dart
│   │   └── settings/
│   │       ├── settings_screen.dart
│   │       └── settings_viewmodel.dart
│   ├── widgets/
│   │   ├── common/
│   │   │   ├── custom_button.dart
│   │   │   ├── loading_widget.dart
│   │   │   └── error_widget.dart
│   │   └── math/
│   │       ├── equation_display.dart
│   │       ├── timer_widget.dart
│   │       └── strategy_hint_display.dart
│   └── themes/
│       ├── app_theme.dart
│       ├── colors.dart
│       └── text_styles.dart
└── tests/
    ├── unit/
    ├── widget/
    └── integration/
```

## Core Data Models

### MathFact
```dart
class MathFact {
  final int id;
  final int operand1;
  final int operand2;
  final MathOperation operation;
  final int answer;
  final DateTime lastPracticed;
  final int timesCorrect;
  final int timesIncorrect;
  final double averageResponseTime;
  final MasteryLevel masteryLevel;
  final DateTime nextReviewDate;
  final List<String> associatedStrategies; // IDs of applicable strategies
}
```

### MathStrategy
```dart
class MathStrategy {
  final String id;
  final String name;
  final String description;
  final MathOperation operation;
  final StrategyType type; // DECOMPOSITION, DOUBLES, NEAR_DOUBLES, etc.
  final int minOperand1;
  final int maxOperand1;
  final int minOperand2;
  final int maxOperand2;
  final String hintText;
  final List<String> stepByStepInstructions;
  final String visualRepresentation; // Path to image or description
}

enum StrategyType {
  DECOMPOSITION,    // Break apart numbers (e.g., 8+7 = 8+2+5)
  DOUBLES,          // Use doubles facts (e.g., 6+6 = 12)
  NEAR_DOUBLES,     // Doubles plus/minus one (e.g., 6+7 = 6+6+1)
  MAKE_TEN,         // Addition to make 10 (e.g., 8+5 = 8+2+3)
  COUNT_ON,         // Count up from larger number
  FACT_FAMILIES,    // Related facts (e.g., if 3+4=7, then 7-4=3)
  SKIP_COUNTING,    // For multiplication (e.g., 3x4 = 3,6,9,12)
  ARRAYS,           // Visual arrangement for multiplication
}
```

### PracticeSession
```dart
class PracticeSession {
  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final List<PracticeAttempt> attempts;
  final SessionType type; // PRACTICE, ASSESSMENT, REVIEW
  final Map<MathOperation, int> operationsIncluded;
  final int hintsUsed;      // Track hint usage
  final List<String> strategiesShown; // Track which strategies were displayed
}
```

### PracticeAttempt
```dart
class PracticeAttempt {
  final int id;
  final int factId;
  final int sessionId;
  final double responseTime;
  final int userAnswer;
  final bool isCorrect;
  final DateTime timestamp;
  final bool hintRequested;     // Did user ask for hint?
  final String? strategyUsed;   // Which strategy was shown (if any)
  final bool answeredAfterHint; // Did they get it right after hint?
}
```

### UserProgress
```dart
class UserProgress {
  final int userId;
  final Map<MathOperation, OperationProgress> operationProgress;
  final int currentStreak;
  final int totalSessions;
  final DateTime lastSessionDate;
  final double overallFluencyScore;
}
```

## Learning Science Implementation

### 1. Active Retrieval System with Optional Hints
```dart
class ActiveRetrievalService {
  static const int INITIAL_WAIT_TIME = 5; // 5-10 seconds as specified
  static const int HINT_AVAILABLE_TIME = 8; // Show hint option after 8 seconds
  
  Future<PracticeResult> presentProblem(MathFact fact) {
    // Present problem without options
    // Start timer
    // After HINT_AVAILABLE_TIME, show subtle hint button
    // Wait for user input or hint request
    // Track response time and hint usage
    // Provide immediate feedback
  }
  
  MathStrategy? getOptimalStrategy(MathFact fact) {
    // Determine best strategy for this specific problem
    // Based on operands and operation type
    // Return strategy with decomposition steps
  }
}
```

### 2. Spaced Repetition Algorithm (Simple)
```dart
class SpacedRepetitionService {
  // Simple intervals: 1 day, 3 days, 1 week, 2 weeks, 1 month
  static const List<int> REVIEW_INTERVALS = [1, 3, 7, 14, 30];
  
  DateTime calculateNextReview(MathFact fact, bool wasCorrect, double responseTime) {
    // If correct AND under 3 seconds -> mastered, longer interval
    // If correct but slow -> shorter interval
    // If incorrect -> reset to shortest interval
  }
}
```

### 3. Mastery Definition
```dart
enum MasteryLevel {
  NEW,        // Never practiced
  LEARNING,   // Practicing but not consistent
  FAMILIAR,   // Usually correct but may be slow
  MASTERED    // Consistent correct answers under 3 seconds
}

bool isMastered(MathFact fact) {
  return fact.timesCorrect >= 3 && 
         fact.averageResponseTime <= 3.0 &&
         fact.timesIncorrect == 0; // Recent attempts
}
```

## User Experience Flow

### 1. App Launch Flow
```
Launch App
    ↓
Check for existing user data
    ↓
[New User] → Quick skill assessment → Set starting level
    ↓
[Returning User] → Show home screen with next practice suggestion
```

### 2. Practice Session Flow (Updated with Hints)
```
Start Practice
    ↓
Generate problems based on:
- Spaced repetition schedule
- Current mastery levels
- Session type (practice/review/assessment)
    ↓
Present problem (5-10 second wait)
    ↓
[After 8 seconds] → Show optional hint button
    ↓
[If hint requested] → Display math strategy breakdown
    ↓
Collect answer and response time
    ↓
Track hint usage and strategy effectiveness
    ↓
Provide immediate feedback
    ↓
Update mastery data (consider hint usage in assessment)
    ↓
Continue until session complete (5-10 minutes)
    ↓
Show session summary with strategy insights
```

### 3. Progress Tracking Flow
```
After each problem:
- Update individual fact mastery
- Recalculate spaced repetition schedule
- Update overall fluency score

Weekly:
- Generate progress summary
- Identify facts needing attention
- Suggest focus areas
```

## Key Features by Release Phase

### MVP (Phase 1) - Addition Facts 0-10
**Core Features:**
- Addition problems (0+0 through 10+10)
- Basic practice sessions
- Simple progress tracking
- Local data storage
- Active retrieval with 5-10 second timing
- **Optional hint system with basic addition strategies**

**Math Strategies for MVP:**
- Decomposition (8+7 = 8+2+5 = 10+5)
- Doubles (6+6, 7+7, etc.)
- Near doubles (6+7 = 6+6+1)
- Make ten (8+5 = 8+2+3 = 10+3)

**Technical Implementation:**
- Flutter app with SQLite storage
- Basic spaced repetition (simple intervals)
- Minimal UI with progress bars
- Push notifications for practice reminders
- Strategy database with hint generation

### Phase 2 - Subtraction & Enhanced Features
**Additional Features:**
- Subtraction facts (0-10)
- Mixed operation sessions (user choice)
- Weekly assessments
- Enhanced progress visualization
- Daily streak tracking
- **Expanded strategy library for subtraction**

**Additional Strategies:**
- Fact families (if 8+5=13, then 13-5=8)
- Count back (13-2 = 11)
- Think addition (13-8 = ? because 8+?=13)

### Phase 3 - Multiplication & Advanced Features
**Additional Features:**
- Multiplication facts (0-10)
- Difficulty level mixing within sessions
- Optional cloud sync
- Parent/teacher sharing capabilities
- Performance analytics
- **Comprehensive strategy system for all operations**

**Multiplication Strategies:**
- Skip counting (3×4 = 3,6,9,12)
- Arrays and visual models
- Doubling (6×4 = 3×4 doubled)
- Square numbers (7×7, 8×8)
- Fact families (6×4 = 4×6 = 24, so 24÷6 = 4)

## Database Schema

### Tables
```sql
-- Core math facts with individual tracking
CREATE TABLE math_facts (
    id INTEGER PRIMARY KEY,
    operand1 INTEGER NOT NULL,
    operand2 INTEGER NOT NULL,
    operation TEXT NOT NULL, -- 'ADD', 'SUB', 'MUL'
    answer INTEGER NOT NULL,
    times_correct INTEGER DEFAULT 0,
    times_incorrect INTEGER DEFAULT 0,
    last_practiced TEXT,
    average_response_time REAL DEFAULT 0,
    mastery_level TEXT DEFAULT 'NEW',
    next_review_date TEXT
);

-- Individual practice attempts for detailed tracking
CREATE TABLE practice_attempts (
    id INTEGER PRIMARY KEY,
    fact_id INTEGER REFERENCES math_facts(id),
    session_id INTEGER REFERENCES practice_sessions(id),
    response_time REAL,
    user_answer INTEGER,
    is_correct BOOLEAN,
    timestamp TEXT
);

-- Practice sessions for broader analysis
CREATE TABLE practice_sessions (
    id INTEGER PRIMARY KEY,
    start_time TEXT,
    end_time TEXT,
    session_type TEXT, -- 'PRACTICE', 'ASSESSMENT', 'REVIEW'
    total_problems INTEGER,
    correct_answers INTEGER,
    average_response_time REAL
);

-- User progress and settings
CREATE TABLE user_progress (
    id INTEGER PRIMARY KEY DEFAULT 1,
    current_streak INTEGER DEFAULT 0,
    total_sessions INTEGER DEFAULT 0,
    last_session_date TEXT,
    overall_fluency_score REAL DEFAULT 0,
    hint_usage_frequency REAL DEFAULT 0, -- Track how often hints are used
    settings TEXT -- JSON for app settings
);

-- Math strategies for hint system
CREATE TABLE math_strategies (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    operation TEXT NOT NULL, -- 'ADD', 'SUB', 'MUL'
    strategy_type TEXT NOT NULL,
    min_operand1 INTEGER,
    max_operand1 INTEGER,
    min_operand2 INTEGER,
    max_operand2 INTEGER,
    hint_text TEXT,
    step_by_step_instructions TEXT, -- JSON array
    visual_representation TEXT
);

-- Track strategy usage and effectiveness
CREATE TABLE strategy_usage (
    id INTEGER PRIMARY KEY,
    fact_id INTEGER REFERENCES math_facts(id),
    strategy_id TEXT REFERENCES math_strategies(id),
    session_id INTEGER REFERENCES practice_sessions(id),
    was_helpful BOOLEAN, -- Did user get correct answer after hint?
    timestamp TEXT
);
```

## Performance Considerations

### Offline-First Architecture
- All core functionality works without internet
- Local SQLite database for all user data
- Background sync when connectivity available (optional feature)

### Memory Management
- Lazy loading of practice sessions
- Efficient problem generation algorithms
- Minimal UI redraws during practice

### Battery Optimization
- Efficient timer management during practice
- Smart notification scheduling
- Background processing limits

## Testing Strategy

### Unit Tests
- Learning algorithm accuracy
- Spaced repetition calculations
- Progress tracking logic
- Database operations

### Widget Tests
- Practice screen interactions
- Progress visualization accuracy
- Navigation flows
- **Hint system user interactions**
- **Strategy display and timing**

### Integration Tests
- End-to-end practice sessions
- Data persistence verification
- Performance benchmarks
- **Hint effectiveness tracking**
- **Strategy recommendation accuracy**

## Security & Privacy

### Data Minimization
- Only collect essential learning data
- No personal identifying information required
- Local storage by default

### Future Cloud Sync Security
- End-to-end encryption of user data
- Anonymous user identification
- COPPA-compliant data handling

## Deployment & Distribution

### Target Platforms
- **Primary**: Android (Google Play Store)
- **Future**: iOS (App Store)

### Build Configuration
- Debug builds for development
- Release builds with obfuscation
- Automated testing in CI/CD pipeline

---

## Next Steps for Implementation

1. **Set up Flutter development environment**
2. **Create basic project structure**
3. **Implement core data models**
4. **Build simple practice screen (MVP)**
5. **Add local storage and progress tracking**
6. **Implement spaced repetition algorithm**
7. **Add notifications and session management**
8. **Create progress visualization**
9. **Testing and refinement**
10. **Deployment preparation**

This architecture provides a solid foundation for building an effective, research-based math facts app that will help children develop automaticity through proven learning science principles.