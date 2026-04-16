import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../theme/app_theme.dart';
import '../tasks/tasks_screen.dart';
import '../schedule/schedule_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TasksScreen(),
    ScheduleScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Consumer2<TaskProvider, ScheduleProvider>(
        builder: (context, tp, sp, _) {
          return Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppTheme.borderLight, width: 0.5),
              ),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) =>
                  setState(() => _currentIndex = i),
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.task_outlined),
                  selectedIcon: Icon(Icons.task),
                  label: 'Tugas',
                  tooltip: '',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: sp.status.name == 'success',
                    backgroundColor: AppTheme.primaryGreen,
                    smallSize: 8,
                    child: const Icon(Icons.calendar_month_outlined),
                  ),
                  selectedIcon: const Icon(Icons.calendar_month),
                  label: 'Jadwal',
                  tooltip: '',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: !sp.hasApiKey,
                    backgroundColor: AppTheme.priorityMedium,
                    smallSize: 8,
                    child: const Icon(Icons.settings_outlined),
                  ),
                  selectedIcon: const Icon(Icons.settings),
                  label: 'Pengaturan',
                  tooltip: '',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}