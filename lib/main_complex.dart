import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'core/database/database_helper.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/math_strategy_service.dart';
import 'data/repositories/math_facts_repository.dart';
import 'presentation/themes/app_theme.dart';
import 'presentation/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize core services (skip database for web)
  final databaseHelper = DatabaseHelper();
  if (!kIsWeb) {
    await databaseHelper.initDatabase();
  }
  
  final storageService = StorageService();
  await storageService.init();
  
  final notificationService = NotificationService();
  await notificationService.init();
  
  final mathStrategyService = MathStrategyService(databaseHelper);
  
  final mathFactsRepository = MathFactsRepository(databaseHelper);
  
  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseHelper>.value(value: databaseHelper),
        Provider<StorageService>.value(value: storageService),
        Provider<NotificationService>.value(value: notificationService),
        Provider<MathStrategyService>.value(value: mathStrategyService),
        Provider<MathFactsRepository>.value(value: mathFactsRepository),
      ],
      child: const MathFactsApp(),
    ),
  );
}

class MathFactsApp extends StatelessWidget {
  const MathFactsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MathFacts',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}