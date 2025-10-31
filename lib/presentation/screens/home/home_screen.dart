import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/database/database_helper.dart';
import '../../themes/app_theme.dart';
import '../../widgets/common/custom_button.dart';
import '../practice/practice_screen.dart';
import '../progress/progress_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StorageService _storageService;
  late DatabaseHelper _databaseHelper;
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _storageService = Provider.of<StorageService>(context, listen: false);
    _databaseHelper = Provider.of<DatabaseHelper>(context, listen: false);
    
    await _loadStats();
    setState(() {
      _isLoading = false;
    });

    // Show welcome message for first-time users
    if (_storageService.isFirstLaunch) {
      _showWelcomeDialog();
    }
  }

  Future<void> _loadStats() async {
    final stats = await _databaseHelper.getDatabaseStats();
    setState(() {
      _stats = stats;
    });
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Welcome to MathFacts! 🎉'),
        content: const Text(
          'Ready to master your math facts? This app uses proven learning techniques to help you become fluent with addition, subtraction, and multiplication.\n\n'
          'Start with some practice problems and build your skills!'
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _storageService.setFirstLaunchComplete();
            },
            child: const Text('Let\'s Start!'),
          ),
        ],
      ),
    );
  }

  void _navigateToPractice() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PracticeScreen(),
      ),
    );
  }

  void _navigateToProgress() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProgressScreen(),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MathFacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome section
              _buildWelcomeSection(),
              
              const SizedBox(height: AppTheme.spacingLarge),
              
              // Quick stats
              _buildQuickStats(),
              
              const SizedBox(height: AppTheme.spacingLarge),
              
              // Main action buttons
              Expanded(
                child: _buildActionButtons(),
              ),
              
              const SizedBox(height: AppTheme.spacingMedium),
              
              // Daily streak info
              _buildStreakInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final currentStreak = _storageService.currentStreak;
    final hasApracticedToday = _storageService.hasApracticedToday;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Icon(
            hasApracticedToday ? Icons.check_circle : Icons.play_circle_filled,
            size: 48,
            color: hasApracticedToday ? AppTheme.successColor : AppTheme.primaryColor,
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Text(
            hasApracticedToday ? 'Great job today! 🎉' : 'Ready to practice? 🚀',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          Text(
            hasApracticedToday 
                ? 'You\'ve practiced today and kept your streak alive!'
                : 'Let\'s strengthen those math facts with some quick practice.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (currentStreak > 0) ...[
            const SizedBox(height: AppTheme.spacingMedium),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMedium,
                vertical: AppTheme.spacingSmall,
              ),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                border: Border.all(color: AppTheme.successColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: AppTheme.successColor,
                    size: 20,
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),
                  Text(
                    '$currentStreak day${currentStreak == 1 ? '' : 's'} streak!',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final totalSessions = _storageService.totalSessionsCount;
    final mathFactsCount = _stats['mathFacts'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.school,
            title: 'Total Sessions',
            value: totalSessions.toString(),
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: AppTheme.spacingMedium),
        Expanded(
          child: _buildStatCard(
            icon: Icons.calculate,
            title: 'Math Facts',
            value: mathFactsCount.toString(),
            color: AppTheme.secondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: AppTheme.spacingSmall),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXSmall),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: CustomButton(
            text: 'Start Practice',
            icon: Icons.play_arrow,
            onPressed: _navigateToPractice,
            variant: ButtonVariant.primary,
            size: ButtonSize.large,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Progress',
                  icon: Icons.analytics,
                  onPressed: _navigateToProgress,
                  variant: ButtonVariant.outlined,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: CustomButton(
                  text: 'Settings',
                  icon: Icons.settings,
                  onPressed: _navigateToSettings,
                  variant: ButtonVariant.outlined,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStreakInfo() {
    final daysSinceLastPractice = _storageService.daysSinceLastPractice;
    
    if (daysSinceLastPractice == 0) {
      return const SizedBox.shrink();
    }

    String message;
    Color color;
    IconData icon;

    if (daysSinceLastPractice == 1) {
      message = 'Practice today to continue your streak!';
      color = AppTheme.warningColor;
      icon = Icons.warning_amber;
    } else {
      message = 'It\'s been $daysSinceLastPractice days since your last practice';
      color = AppTheme.errorColor;
      icon = Icons.refresh;
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}