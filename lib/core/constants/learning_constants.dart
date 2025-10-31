/// Learning science constants based on research
class LearningConstants {
  // Active Retrieval Timing
  static const int initialWaitTimeSeconds = 5;
  static const int hintAvailableTimeSeconds = 8;
  static const int maxResponseTimeSeconds = 30;
  
  // Mastery Criteria
  static const int masteryCorrectAnswers = 3;
  static const double masteryResponseTimeSeconds = 3.0;
  static const int masteryRecentAttempts = 5; // Look at last N attempts
  
  // Spaced Repetition Intervals (in days)
  static const List<int> spacedRepetitionIntervals = [1, 3, 7, 14, 30];
  
  // Difficulty Ranges for Math Facts
  static const int minOperand = 0;
  static const int maxOperandMVP = 10; // MVP: 0-10 addition facts
  static const int maxOperandFull = 12; // Future: extend to 12x12
  
  // Progress Tracking
  static const int streakResetHours = 36; // Reset streak after 36 hours
  static const double fluencyScoreWeight = 0.7; // Weight response time vs accuracy
  
  // Session Management
  static const int problemsPerSession = 20;
  static const int minProblemsPerSession = 10;
  static const int maxProblemsPerSession = 30;
  
  // Strategy System
  static const int strategyEffectivenessThreshold = 3; // Min uses to measure effectiveness
  static const double strategySuccessThreshold = 0.6; // 60% success rate for good strategy
}