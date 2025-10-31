# MathFacts Learning App - Development Plan

## Project Overview
Building an Android mobile app to help kids (ages 6-15) learn math facts using evidence-based learning science principles including active retrieval, spaced repetition, interleaving, and the test effect.

## Learning Science Requirements
- **Active Retrieval**: Students must actively recall answers (not multiple choice)
- **Spaced Repetition**: Facts reappear at increasing intervals (1, 3, 7, 14, 30 days)
- **Interleaving**: Mix different operations and difficulty levels
- **Test Effect**: Testing enhances learning more than passive review
- **Immediate Feedback**: Show correct answers and explanations
- **Mastery Tracking**: Track individual fact performance

## Current Status ✅

### Completed Features
- [x] **Basic Flutter App Setup**: Working app in Chrome
- [x] **Core UI**: Home screen, practice screen, navigation
- [x] **Addition Practice**: Random addition facts (0-10)
- [x] **Immediate Feedback**: Correct/incorrect with answers shown
- [x] **Basic Progress**: Score tracking (correct/total)
- [x] **UX Enhancements**: Autofocus input field, clean interface
- [x] **Active Retrieval**: Text input for answers

### Current Architecture
- Simple single-file implementation (`main.dart`)
- Random problem generation
- In-memory state management
- No data persistence

## Development Priorities

### 🎯 PRIORITY 1: Learning Science Enhancement (Current Focus)

#### Step 1: Individual Fact Tracking ✅ COMPLETED
**Goal**: Track performance on each of the 121 addition facts (0+0 through 10+10)

**Implementation Plan**:
- [x] Create `MathFact` model (operand1, operand2, operation, attempts, correct_count, last_seen)
- [x] Generate all 121 addition facts systematically
- [x] Track individual fact performance in memory
- [x] Replace random generation with fact-specific selection
- [x] Display which specific facts need practice

**Learning Science Impact**: Enables spaced repetition and mastery tracking per fact

**Completed Features**:
- ✅ MathFact model with performance tracking
- ✅ Systematic generation of all 121 addition facts
- ✅ Intelligent fact selection (prioritizes facts needing practice)
- ✅ Progress display showing facts practiced and mastered
- ✅ Individual fact performance recording

#### Step 2: Spaced Repetition Algorithm ⏳ NEXT UP
**Goal**: Show facts based on performance history
- [ ] Implement spaced repetition intervals (1, 3, 7, 14, 30 days)
- [ ] Prioritize struggling facts for more frequent practice
- [ ] Reduce frequency of mastered facts

#### Step 3: Mastery System
**Goal**: Define and track when facts are "mastered"
- [ ] Set mastery criteria (e.g., 3 consecutive correct responses)
- [ ] Visual indicators for mastered vs. learning facts
- [ ] Celebration animations for newly mastered facts

#### Step 4: Progress Visualization
**Goal**: Show learning progress clearly
- [ ] Grid view of all 121 facts with status colors
- [ ] Progress bars for overall mastery
- [ ] Daily/weekly practice summaries

### 🎯 PRIORITY 2: User Experience Enhancement

#### Engagement Features
- [ ] Achievement system and badges
- [ ] Daily practice streaks
- [ ] Sound effects and animations
- [ ] Different game modes (timed, specific facts)

#### Interface Polish
- [ ] Better responsive design
- [ ] Dark mode support
- [ ] Accessibility improvements

### 🎯 PRIORITY 3: Technical Foundation

#### Data Persistence
- [ ] Local storage for web (IndexedDB/LocalStorage)
- [ ] SQLite for mobile platforms
- [ ] Progress synchronization

#### Architecture
- [ ] Restore complex architecture (services, repositories)
- [ ] State management (Provider/Riverpod)
- [ ] Clean separation of concerns

### 🎯 PRIORITY 4: Content Expansion

#### Additional Operations
- [ ] Subtraction facts (0-10)
- [ ] Multiplication tables (0-12)
- [ ] Mixed operations mode
- [ ] Division facts

#### Advanced Features
- [ ] Adaptive difficulty
- [ ] Custom fact ranges
- [ ] Parent/teacher dashboard

## Current Sprint: Individual Fact Tracking

### Implementation Steps
1. **Create MathFact Model**: Define data structure for individual facts
2. **Generate Fact List**: Create all 121 addition combinations
3. **Performance Tracking**: Track attempts, successes, timestamps
4. **Intelligent Selection**: Choose facts based on performance data
5. **Progress Display**: Show which facts are being worked on

### Success Criteria
- ✅ App tracks each of 121 addition facts individually
- ✅ Facts are selected based on performance history
- ✅ User can see which specific facts need practice
- ✅ No regression in core functionality

## Architecture Evolution

### Phase 1: Simple (Current)
- Single file implementation
- Random problem generation
- Basic score tracking

### Phase 2: Fact-Aware (Target)
- Individual fact tracking
- Performance-based selection
- Mastery indicators

### Phase 3: Full Learning Science
- Spaced repetition algorithm
- Interleaving multiple operations
- Comprehensive progress analytics

### Phase 4: Production Ready
- Data persistence
- Multi-platform support
- Advanced features and content

## Notes
- Focus on learning science effectiveness over feature quantity
- Maintain simple, clean user experience
- Evidence-based approach to feature decisions
- Regular testing with target age group (6-15 years)

---
*Last Updated: October 30, 2025*
*Current Focus: Individual Fact Tracking Implementation*