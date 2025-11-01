# MathFacts App Architecture

## Development Principles

### Minimalism & Necessity
**Rule**: Only add files, dependencies, and features that are immediately necessary and functional.
- ❌ No placeholder files, empty directories, or "future" assets
- ❌ No speculative code or premature abstractions
- ✅ Add only what's needed for current functionality
- ✅ Refactor and expand when requirements demand it

**Rationale**: Keep the codebase lean, maintainable, and focused. Every file should serve a current purpose.

---

## Overview

MathFacts is a Flutter app designed to help children ages 6-15 develop automaticity with single-digit math facts (addition and subtraction, with multiplication planned) using evidence-based learning science principles. The app prioritizes simplicity and effectiveness over complex gamification.

## Current Implementation Status

### Completed Features (MVP - Phase 1)
- ✅ **Addition practice** (0+0 through 10+10 = 121 facts)
- ✅ **Subtraction practice** (0-0 through 10-10, non-negative results = 66 facts)
- ✅ **Active retrieval system** with text input
- ✅ **Individual fact tracking** (attempts, correct count, accuracy)
- ✅ **Smart fact selection** (prioritizes facts needing practice)
- ✅ **Data persistence** (cross-platform storage)
- ✅ **Session statistics** (score tracking, questions answered)
- ✅ **Progress display** (facts practiced, facts mastered)
- ✅ **Reset functionality** (clear progress, regenerate facts)
- ✅ **Initialization system** (first-run setup)
- ✅ **Storage debugging tools** (view storage, reset storage)
- ✅ **Platform support** (Web via Chrome, Android via emulator)

### Architecture Decisions Made

#### 1. Single-File Monolithic Architecture (Current)
**Decision**: All code in `lib/main.dart` (~1000 lines)

**Rationale**:
- Fast MVP development and iteration
- No ceremony or boilerplate overhead
- Easy to understand entire codebase at once
- Simple debugging and testing

**Trade-offs**:
- Will need refactoring as app grows
- Less reusable components
- Harder to maintain at scale

**Future**: Plan to refactor into proper Clean Architecture when adding multiplication and advanced features.

#### 2. Platform-Agnostic Storage Strategy
**Challenge**: Need persistent storage that works on both web and mobile platforms.

**Attempted Solutions**:
1. ❌ **SharedPreferences alone** - Unreliable on web platform
2. ❌ **dart:html localStorage directly** - Breaks on Android (dart:html not available)
3. ✅ **Current: Conditional platform branches within storage service**

**Current Implementation**:
```dart
class MathFactsStorage {
  // Platform detection using kIsWeb
  Future<String?> _loadString(String key) async {
    if (kIsWeb) {
      // Use dart:html window.localStorage
      return html.window.localStorage[key];
    } else {
      // Use SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
  }
}
```

**Known Issues**:
- dart:html import causes Android build failures
- Need abstraction layer to separate web/mobile storage implementations

**Recommended Fix** (Not Yet Implemented):
Create conditional imports with interface pattern:
```dart
// storage_interface.dart
abstract class StorageInterface {
  Future<void> setString(String key, String value);
  Future<String?> getString(String key);
}

// storage_web.dart (uses dart:html)
// storage_mobile.dart (uses SharedPreferences)
// main.dart imports conditionally
```

#### 3. Data Model Design
**MathFact Model**:
```dart
class MathFact {
  final int operand1;
  final int operand2;
  final String operation;  // '+' or '-'
  int attempts;
  int correctCount;
  DateTime lastSeen;
  
  // Computed properties
  int get answer => operation == '+' ? operand1 + operand2 : operand1 - operand2;
  double get accuracy => attempts > 0 ? correctCount / attempts : 0.0;
  bool get needsPractice => attempts < 3 || accuracy < 0.8;
  bool get isMastered => attempts >= 3 && accuracy >= 0.8;
}
```

**Design Decisions**:
- Operation stored as string ('+', '-') for simplicity
- Answer computed dynamically (not stored)
- Mastery defined as: ≥3 attempts AND ≥80% accuracy
- No response time tracking yet (planned for spaced repetition)

#### 4. Storage Format: JSON Serialization
**Decision**: Store all facts as single JSON array in localStorage/SharedPreferences

**Implementation**:
```dart
// Save all facts
final factsJson = facts.map((fact) => fact.toJson()).toList();
final jsonString = jsonEncode(factsJson);
await _saveString('math_facts_data', jsonString);

// Load all facts
final jsonString = await _loadString('math_facts_data');
final factsList = jsonDecode(jsonString) as List;
final facts = factsList.map((json) => MathFact.fromJson(json)).toList();
```

**Trade-offs**:
- ✅ Simple to implement
- ✅ Works across platforms
- ❌ Saves entire list on every update (187 facts for both operations)
- ❌ No indexed queries (must filter in memory)

**Optimization Discussion**:
- Considered saving individual facts with separate keys (e.g., `"fact_5_7"`)
- Would enable updating single facts without full serialization
- Decided against for MVP simplicity
- May revisit when adding spaced repetition with frequent updates

#### 5. Fact Generation Strategy
**Addition**: All combinations 0-10 (11×11 = 121 facts)
**Subtraction**: Only non-negative results (triangular: 1+2+...+11 = 66 facts)

**Example**:
```dart
// Addition: 0+0, 0+1, ... 10+10
for (int i = 0; i <= 10; i++) {
  for (int j = 0; j <= 10; j++) {
    facts.add(MathFact(i, j, '+'));
  }
}

// Subtraction: 0-0, 1-0, 1-1, 2-0, 2-1, 2-2, ... 10-10
for (int i = 0; i <= 10; i++) {
  for (int j = 0; j <= i; j++) {
    facts.add(MathFact(i, j, '-'));
  }
}
```

#### 6. Initialization System
**Decision**: Check for initialization flag on app startup

**Flow**:
```
main() async
  ↓
Check localStorage['is_initialized']
  ↓
[false/missing] → Generate all 187 facts → Save to storage → Set flag true
  ↓
[true] → Continue to app
```

**Benefits**:
- Ensures facts exist before first practice
- Explicit initialization state
- Reset storage re-initializes automatically

#### 7. Smart Fact Selection Algorithm
**Current Implementation**: Prioritize facts needing practice

```dart
void _selectNextFact() {
  // Get facts with <3 attempts OR <80% accuracy
  final factsNeedingPractice = _allFacts.where((fact) => fact.needsPractice).toList();
  
  if (factsNeedingPractice.isNotEmpty) {
    // Random selection from facts needing practice
    _currentFact = factsNeedingPractice[random.nextInt(factsNeedingPractice.length)];
  } else {
    // All mastered: review any fact randomly
    _currentFact = _allFacts[random.nextInt(_allFacts.length)];
  }
}
```

**Not Yet Implemented**:
- Spaced repetition intervals (1, 3, 7, 14, 30 days)
- Response time tracking
- Least-recently-seen prioritization

#### 8. UI Architecture
**Screens**:
1. **HomeScreen** - Navigation hub with operation selection
2. **PracticeScreen** - Active retrieval practice with immediate feedback

**State Management**: Simple StatefulWidget with setState()
- No Provider/Riverpod/Bloc for MVP
- Direct state updates in widget
- May need state management library as app grows

**Key UI Patterns**:
- Immediate feedback on answer submission
- Auto-advance after 2 seconds
- Autofocus on input field for rapid entry
- Progress stats displayed during practice

## Technology Stack (Current)

```
Language: Dart
Framework: Flutter 3.0+
Platforms: Web (Chrome), Android (via emulator)
Storage: 
  - Web: dart:html window.localStorage
  - Android: SharedPreferences
Data Format: JSON
State Management: StatefulWidget + setState()
Dependencies:
  - shared_preferences: ^2.2.2
  - dart:html (web only, via conditional import)
```

## Current Project Structure

```
lib/
├── main.dart                    # Single file containing entire app (~1000 lines)
│   ├── MathFact (model)
│   ├── MathFactsStorage (service)
│   ├── MathFactsApp (app root)
│   ├── HomeScreen (navigation)
│   ├── PracticeButton (widget)
│   └── PracticeScreen (practice UI)
├── storage_web.dart             # Web localStorage implementation (created but not integrated)
├── storage_mobile.dart          # Mobile SharedPreferences implementation (created but not integrated)
└── storage_interface.dart       # Abstract storage interface (created but not integrated)

pubspec.yaml                     # Dependencies
analysis_options.yaml            # Linter rules
android/                         # Android platform config
web/                             # Web platform config
build/                           # Build artifacts
```

**Note**: Storage abstraction files exist but are not currently used. Main.dart still uses inline platform checks.

## Data Flow (Current Implementation)

### Initialization Flow
```
App Launch
  ↓
main() async
  ↓
MathFactsStorage.isInitialized()?
  ↓
[No] → initializeApp()
  ├── Generate 121 addition facts
  ├── Generate 66 subtraction facts  
  ├── Save all 187 facts to storage
  └── Set 'is_initialized' = true
  ↓
runApp(MathFactsApp)
```

### Practice Session Flow
```
User taps "Practice Addition" or "Practice Subtraction"
  ↓
PracticeScreen loads for selected operation
  ↓
_initializeApp() async
  ├── Load all facts from storage
  ├── Filter facts for selected operation
  ├── Load session stats (score, questions answered)
  └── Set _isLoading = false
  ↓
_selectNextFact()
  ├── Filter facts needing practice (attempts < 3 OR accuracy < 0.8)
  ├── Random selection from filtered list
  └── Display fact with autofocus on input
  ↓
User enters answer
  ↓
_checkAnswer()
  ├── Compare answer to fact.answer
  ├── Record attempt (attempts++, correctCount++ if correct)
  ├── Update fact.lastSeen = DateTime.now()
  ├── Show feedback (correct/incorrect)
  ├── _saveProgress()
  │   ├── Load all stored facts (both operations)
  │   ├── Update or add current fact
  │   ├── Save combined facts list
  │   └── Save session stats
  └── Auto-advance after 2 seconds
  ↓
Repeat until user exits
```

### Storage Operations
```
Save Facts:
  facts → toJson() → jsonEncode() → localStorage['math_facts_data']

Load Facts:  
  localStorage['math_facts_data'] → jsonDecode() → fromJson() → facts

Update Single Fact:
  1. Load all facts from storage (187 facts)
  2. Find and replace updated fact
  3. Save entire array back to storage
```

## Known Issues & Technical Debt

### 1. Storage Platform Compatibility ⚠️
**Problem**: dart:html import breaks Android builds
**Current Workaround**: None (blocks Android deployment)
**Fix Needed**: Implement conditional imports with storage abstraction layer
**Priority**: HIGH - Required for Android support

### 2. Storage Efficiency 📊
**Problem**: Saving entire 187-fact array on every answer
**Impact**: ~20KB JSON serialization per save (manageable for MVP)
**Future Optimization**: 
- Individual fact keys for web localStorage
- SQLite for mobile with UPDATE queries
- Only serialize facts with attempts > 0
**Priority**: LOW - Works fine for current scale

### 3. No Spaced Repetition Yet 📅
**Current**: Random selection from facts needing practice
**Missing**: 
- Response time tracking
- Next review date calculation
- Interval-based scheduling (1, 3, 7, 14, 30 days)
**Priority**: MEDIUM - Planned for Phase 2

### 4. Lack of Code Organization 📁
**Problem**: 1000-line single file
**Impact**: Hard to navigate, find features
**Future**: Refactor into proper architecture when adding multiplication
**Priority**: LOW - Works for current MVP scope

### 5. No Automated Testing 🧪
**Current**: Manual testing only
**Missing**: Unit tests, widget tests, integration tests
**Priority**: MEDIUM - Add before major refactoring

## Performance Characteristics

### Storage Performance
- **Web**: Synchronous localStorage access (<1ms)
- **Android**: Asynchronous SharedPreferences (~10-50ms)
- **Save frequency**: Once per answer (every 5-30 seconds during practice)
- **Data size**: ~20KB JSON for 187 facts with statistics

### Memory Footprint
- All facts loaded in memory during practice session
- 187 facts × ~200 bytes ≈ 37KB in memory
- Negligible for modern devices

### UI Responsiveness
- Autofocus and auto-advance provide smooth UX
- No perceived lag during fact selection or save operations
- setState() updates are instantaneous for current widget complexity

## Future Architecture Plans

### Phase 2: Refactoring Goals
When adding multiplication and advanced features:

1. **Extract Storage Layer**
   ```
   lib/
   ├── core/
   │   └── storage/
   │       ├── storage_interface.dart
   │       ├── web_storage.dart
   │       └── mobile_storage.dart
   ```

2. **Separate Models**
   ```
   lib/
   ├── models/
   │   ├── math_fact.dart
   │   ├── practice_session.dart
   │   └── user_progress.dart
   ```

3. **Feature-Based Structure**
   ```
   lib/
   ├── features/
   │   ├── practice/
   │   │   ├── practice_screen.dart
   │   │   ├── practice_viewmodel.dart
   │   │   └── widgets/
   │   └── progress/
   ```

4. **Add State Management** (Provider or Riverpod)

5. **Implement Proper Testing**

### Phase 3: Advanced Features
- Spaced repetition with intervals
- Math strategy hints (decomposition, doubles, etc.)
- Progress visualization and charts
- Weekly assessments
- Cloud sync (optional)

## Deployment Strategy

### Current Platforms
- **Web**: Deployed via `flutter run -d chrome` for development
- **Android**: Testing in emulator (`flutter run -d emulator-5554`)

### Blocked for Production
- ❌ **Android**: dart:html import breaks build
- ✅ **Web**: Works but needs proper hosting

### Required Before Release
1. Fix storage platform compatibility
2. Implement conditional imports properly
3. Add app icons and splash screens
4. Configure Android signing keys
5. Test on physical Android devices
6. Deploy web build to hosting (Firebase Hosting, Netlify, etc.)

---

## Summary

The current MathFacts app implements a functional MVP with addition and subtraction practice, smart fact selection, and cross-platform persistence (with known Android build issues). The monolithic architecture in a single file enables rapid iteration but will need refactoring before adding multiplication and advanced learning science features like spaced repetition and strategy hints.

**Key Architectural Principles**:
1. **Simplicity first** - Single file, simple patterns
2. **Platform-agnostic** - Conditional storage per platform
3. **Learning-focused** - Active retrieval, immediate feedback
4. **Offline-first** - All data stored locally
5. **Scalable foundation** - Ready for Clean Architecture refactor

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