import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local storage using SharedPreferences
class StorageService {
  static SharedPreferences? _prefs;

  /// Initialize the storage service
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  SharedPreferences get _preferences {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // User Settings Keys
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keySessionDuration = 'session_duration';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyNotificationTime = 'notification_time';
  static const String _keyHintsEnabled = 'hints_enabled';
  static const String _keyDifficultyLevel = 'difficulty_level';
  static const String _keySelectedOperations = 'selected_operations';
  static const String _keyLastSessionDate = 'last_session_date';
  static const String _keyTotalSessionsCount = 'total_sessions_count';
  static const String _keyCurrentStreak = 'current_streak';

  /// Check if this is the first launch
  bool get isFirstLaunch {
    return _preferences.getBool(_keyFirstLaunch) ?? true;
  }

  /// Mark first launch as complete
  Future<void> setFirstLaunchComplete() async {
    await _preferences.setBool(_keyFirstLaunch, false);
  }

  /// Get session duration in minutes
  int get sessionDuration {
    return _preferences.getInt(_keySessionDuration) ?? 10;
  }

  /// Set session duration in minutes
  Future<void> setSessionDuration(int minutes) async {
    await _preferences.setInt(_keySessionDuration, minutes);
  }

  /// Check if notifications are enabled
  bool get notificationsEnabled {
    return _preferences.getBool(_keyNotificationsEnabled) ?? true;
  }

  /// Set notifications enabled/disabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _preferences.setBool(_keyNotificationsEnabled, enabled);
  }

  /// Get notification time (24-hour format, e.g., "19:00")
  String get notificationTime {
    return _preferences.getString(_keyNotificationTime) ?? "19:00";
  }

  /// Set notification time
  Future<void> setNotificationTime(String time) async {
    await _preferences.setString(_keyNotificationTime, time);
  }

  /// Check if hints are enabled
  bool get hintsEnabled {
    return _preferences.getBool(_keyHintsEnabled) ?? true;
  }

  /// Set hints enabled/disabled
  Future<void> setHintsEnabled(bool enabled) async {
    await _preferences.setBool(_keyHintsEnabled, enabled);
  }

  /// Get difficulty level (0=beginner, 1=intermediate, 2=advanced)
  int get difficultyLevel {
    return _preferences.getInt(_keyDifficultyLevel) ?? 0;
  }

  /// Set difficulty level
  Future<void> setDifficultyLevel(int level) async {
    await _preferences.setInt(_keyDifficultyLevel, level);
  }

  /// Get selected operations as comma-separated string
  String get selectedOperations {
    return _preferences.getString(_keySelectedOperations) ?? "addition";
  }

  /// Set selected operations
  Future<void> setSelectedOperations(String operations) async {
    await _preferences.setString(_keySelectedOperations, operations);
  }

  /// Get last session date
  DateTime? get lastSessionDate {
    final dateString = _preferences.getString(_keyLastSessionDate);
    return dateString != null ? DateTime.parse(dateString) : null;
  }

  /// Set last session date
  Future<void> setLastSessionDate(DateTime date) async {
    await _preferences.setString(_keyLastSessionDate, date.toIso8601String());
  }

  /// Get total sessions count
  int get totalSessionsCount {
    return _preferences.getInt(_keyTotalSessionsCount) ?? 0;
  }

  /// Increment total sessions count
  Future<void> incrementSessionsCount() async {
    final current = totalSessionsCount;
    await _preferences.setInt(_keyTotalSessionsCount, current + 1);
  }

  /// Get current streak
  int get currentStreak {
    return _preferences.getInt(_keyCurrentStreak) ?? 0;
  }

  /// Set current streak
  Future<void> setCurrentStreak(int streak) async {
    await _preferences.setInt(_keyCurrentStreak, streak);
  }

  /// Update streak based on last session date
  Future<void> updateStreak() async {
    final now = DateTime.now();
    final lastSession = lastSessionDate;
    
    if (lastSession == null) {
      // First session
      await setCurrentStreak(1);
    } else {
      final hoursSinceLastSession = now.difference(lastSession).inHours;
      
      if (hoursSinceLastSession <= 36) {
        // Within streak window - increment
        await setCurrentStreak(currentStreak + 1);
      } else {
        // Streak broken - reset to 1
        await setCurrentStreak(1);
      }
    }
    
    await setLastSessionDate(now);
  }

  /// Get all settings as a map
  Map<String, dynamic> getAllSettings() {
    return {
      'sessionDuration': sessionDuration,
      'notificationsEnabled': notificationsEnabled,
      'notificationTime': notificationTime,
      'hintsEnabled': hintsEnabled,
      'difficultyLevel': difficultyLevel,
      'selectedOperations': selectedOperations,
      'currentStreak': currentStreak,
      'totalSessions': totalSessionsCount,
      'lastSessionDate': lastSessionDate?.toIso8601String(),
    };
  }

  /// Clear all stored data (for testing/reset)
  Future<void> clearAll() async {
    await _preferences.clear();
  }

  /// Export settings to JSON string
  String exportSettings() {
    // This could be used for backup/restore functionality
    final settings = getAllSettings();
    return settings.toString(); // In a real app, use proper JSON encoding
  }

  /// Check if user practiced today
  bool get hasApracticedToday {
    final lastSession = lastSessionDate;
    if (lastSession == null) return false;
    
    final now = DateTime.now();
    return now.difference(lastSession).inHours < 24 &&
           now.day == lastSession.day &&
           now.month == lastSession.month &&
           now.year == lastSession.year;
  }

  /// Get days since last practice
  int get daysSinceLastPractice {
    final lastSession = lastSessionDate;
    if (lastSession == null) return 0;
    
    final now = DateTime.now();
    return now.difference(lastSession).inDays;
  }
}