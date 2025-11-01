/// App-wide constants for MathFacts
class AppConstants {
  // App Information
  static const String appName = 'MathFacts';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'mathfacts.db';
  static const int databaseVersion = 1;

  // Session Configuration
  static const int defaultSessionDurationMinutes = 10;
  static const int minSessionDurationMinutes = 5;
  static const int maxSessionDurationMinutes = 15;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;

  // Asset Paths
  static const String imagesPath = 'assets/images/';
  static const String soundsPath = 'assets/sounds/';
}

/// Math operation types
enum MathOperation {
  addition,
  subtraction,
  multiplication,
}

/// Session types for practice
enum SessionType {
  practice,
  assessment,
  review,
}

/// Mastery levels for math facts
enum MasteryLevel {
  newFact, // Never practiced
  learning, // Practicing but not consistent
  familiar, // Usually correct but may be slow
  mastered, // Consistent correct answers under 3 seconds
}
