import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'providers/schedule_provider.dart';
import 'services/storage_service.dart';
import 'screens/home/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ScheduleAIApp());
}

class ScheduleAIApp extends StatelessWidget {
  const ScheduleAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = StorageService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskProvider(storage: storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => ScheduleProvider(storage: storageService),
        ),
      ],
      child: MaterialApp(
        title: 'Schedule AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}