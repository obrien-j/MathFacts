import 'package:flutter/material.dart';
import '../presentation/themes/app_theme.dart';
import '../presentation/screens/home/home_screen.dart';

class MathFactsApp extends StatelessWidget {
  const MathFactsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MathFacts',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}