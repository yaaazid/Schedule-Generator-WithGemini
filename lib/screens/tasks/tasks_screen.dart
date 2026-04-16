import 'package:flutter/material.dart';
import 'package:myschedule/widgets/common_widgets.dart';
import 'package:provider/provider.dart';
import '../../../providers/task_provider.dart';
import '../../../models/task_model.dart';
import '../../../theme/app_theme.dart';
import '../tasks/add_task_sheet.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Tugas Saya'),
        actions: [
          Consumer<TaskProvider>(
            builder: (context, provider, _) {
              if (provider.completedCount == 0) return const SizedBox();
              return TextButton(
                onPressed: () => _confirmClearCompleted(context, provider),
                child: const Text(
                  'Hapus selesai',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.tasks.isEmpty) {
            return EmptyState(
              icon: Icons.task_alt_outlined,
              title: 'Belum ada tugas',
              subtitle:
                  'Tambahkan tugas yang ingin kamu selesaikan hari ini atau minggu ini.',
              action: ElevatedButton.icon(
                onPressed: () => _showAddTask(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah Tugas Pertama'),
              ),
            );
          }

          return Column(
            children: [
              // Stats row
              _buildStatsRow(provider),
              // Task list
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: provider.tasks.length,
                  onReorder: provider.reorderTasks,
                  itemBuilder: (context, index) {
                    final task = provider.tasks[index];
                    return Padding(
                      key: ValueKey(task.id),
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Dismissible(
                        key: ValueKey('dismiss_${task.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppTheme.priorityHighLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: AppTheme.priorityHigh,
                            size: 22,
                          ),
                        ),
                        onDismissed: (_) => provider.deleteTask(task.id),
                        child: TaskCard(
                          task: task,
                          onTap: () => _showEditTask(context, task),
                          onToggleComplete: () =>
                              provider.toggleComplete(task.id),
                          onDelete: () => provider.deleteTask(task.id),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTask(context),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.add, size: 24),
      ),
    );
  }

  Widget _buildStatsRow(TaskProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              label: 'Total tugas',
              value: '${provider.taskCount}',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StatCard(
              label: 'Selesai',
              value: '${provider.completedCount}',
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StatCard(
              label: 'Tersisa',
              value: '${provider.taskCount - provider.completedCount}',
              color: AppTheme.priorityMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTask(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTaskSheet(),
    );
  }

  void _showEditTask(BuildContext context, TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskSheet(task: task),
    );
  }

  Future<void> _confirmClearCompleted(
      BuildContext context, TaskProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus tugas selesai?'),
        content: const Text(
            'Semua tugas yang sudah diselesaikan akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
                foregroundColor: AppTheme.priorityHigh),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) provider.clearCompleted();
  }
}