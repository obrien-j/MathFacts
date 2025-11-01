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

#### Step 2: Mastery System ⏳ NEXT UP
**Goal**: Define and track when facts are "mastered"
- [ ] Set mastery criteria (e.g., 3 consecutive correct responses)
- [ ] Visual indicators for mastered vs. learning facts
- [ ] Celebration animations for newly mastered facts

#### Step 3: Progress Visualization
**Goal**: Show learning progress clearly
- [ ] Grid view of all 121 facts with status colors
- [ ] Progress bars for overall mastery
- [ ] Daily/weekly practice summaries

#### Step 4: Spaced Repetition Algorithm
**Goal**: Show facts based on performance history
- [ ] Implement spaced repetition intervals (1, 3, 7, 14, 30 days)
- [ ] Prioritize struggling facts for more frequent practice
- [ ] Reduce frequency of mastered facts

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

### 🎯 PRIORITY 3: Technical Foundation ⏳ CURRENT FOCUS

#### User Profiles & Authentication
**Goal**: Enable user identification and personalized experience
- [ ] Minimal user profile system (username, optional display name)
- [ ] Simple authentication (email/password or anonymous)
- [ ] User ID for data association

#### Cloud Storage & Persistence
**Goal**: Persist user progress and sync across devices
- [ ] Azure Static Web Apps setup for hosting Flutter web app
- [ ] Azure Functions (Consumption) for backend API
- [ ] Azure Table Storage for data persistence
- [ ] Save/load user progress data (MathFact performance)
- [ ] Real-time sync across devices
- [ ] Offline support with local caching

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

## Current Sprint: Cloud Storage & User Profiles (Azure)

### Implementation Steps
1. **Azure Infrastructure (Terraform)** ✅ COMPLETED
   - ✅ Terraform configuration created for all Azure resources
   - ✅ Security best practices implemented (HTTPS, Managed Identity, RBAC)
   - ✅ Canadian data residency enforced
   - ✅ Key Vault for secrets management
   - ✅ Network security (deny by default)
   - ⏳ Manual deployment guide ready
   - [ ] Initial deployment to Azure
   - [ ] GitHub Actions for automated updates (next phase)
   
2. **Azure AD B2C Setup** ⏳ NEXT
   - [ ] Create B2C tenant (Canada region)
   - [ ] Register application
   - [ ] Configure sign-up/sign-in user flow
   - [ ] Update Terraform with B2C configuration

3. **User Profile Model**: Define minimal user data structure
4. **Backend API**: Create Azure Functions for data operations
   - GET /api/progress - Retrieve user progress
   - POST /api/progress - Save user progress
   - Functions validate B2C tokens and access Table Storage
5. **Cloud Storage Schema**: Design Table Storage schema for user progress data
6. **Flutter Integration**: Implement Azure AD B2C authentication in Flutter
7. **Sync Logic**: Implement save/load MathFact performance to/from Azure
8. **Offline Support**: Cache data locally and sync when online

### Infrastructure Created (Terraform)
- **Azure Static Web Apps**: Flutter web app hosting (~$0/month, free tier)
- **Azure Functions (Consumption)**: Backend API (~$0/month, free tier: 1M executions)
- **Azure Table Storage**: NoSQL storage for user progress (~$0-1/month)
- **Azure Key Vault**: Secure secrets management (~$0-1/month)
- **Application Insights**: Monitoring and telemetry (~$0/month, 5GB free)
- **Azure AD B2C**: User authentication (~$0/month, free tier: 50K auths)

**Total Estimated Cost**: ~$0-3/month for small-medium usage

**Security Features**:
- ✅ All resources in Canada Central region
- ✅ HTTPS/TLS 1.2+ everywhere
- ✅ Managed Identity (no credentials in code)
- ✅ RBAC for resource access
- ✅ Network rules (deny by default)
- ✅ Infrastructure encryption at rest
- ✅ Key Vault for centralized secrets

### Architecture Flow
1. User authenticates with Azure AD B2C → Gets token
2. Flutter app calls Azure Functions API with token
3. Functions validate token → Access Table Storage via Managed Identity
4. Functions return user-specific data to Flutter app

### Success Criteria
- [x] Terraform infrastructure code created with security best practices
- [x] Canadian data residency enforced
- [x] Infrastructure documentation complete (ARCHITECTURE.md)
- [x] Manual deployment guide ready (SETUP.md)
- [ ] Infrastructure deployed to Azure
- [ ] Azure AD B2C tenant created and configured
- [ ] Flutter web app hosted on Azure Static Web Apps
- [ ] Azure Functions API handles authenticated requests
- [ ] Progress data persists in Azure Table Storage
- [ ] Data syncs across devices via Azure backend
- [ ] Offline mode works with local caching
- [ ] Existing fact tracking continues to work
- [ ] GitHub Actions CI/CD pipeline configured

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
*Last Updated: October 31, 2025*
*Current Focus: Cloud Storage & User Profiles*