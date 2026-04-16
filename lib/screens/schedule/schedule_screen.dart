import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/schedule_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'preferences_sheet.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Jadwal AI'),
        actions: [
          Consumer<ScheduleProvider>(
            builder: (context, sp, _) => Row(
              children: [
                // View toggle
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundSecondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppTheme.borderLight, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      _ViewToggleBtn(
                        label: 'Harian',
                        active: sp.viewMode == ScheduleViewMode.daily,
                        onTap: () =>
                            sp.setViewMode(ScheduleViewMode.daily),
                      ),
                      _ViewToggleBtn(
                        label: 'Mingguan',
                        active: sp.viewMode == ScheduleViewMode.weekly,
                        onTap: () =>
                            sp.setViewMode(ScheduleViewMode.weekly),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.tune_outlined, size: 20),
                  tooltip: 'Preferensi',
                  onPressed: () => _showPreferences(context),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer2<ScheduleProvider, TaskProvider>(
        builder: (context, sp, tp, _) {
          return Column(
            children: [
              // Generate button section
              _buildGenerateSection(context, sp, tp),
              // Content
              Expanded(
                child: _buildContent(context, sp),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGenerateSection(
      BuildContext context, ScheduleProvider sp, TaskProvider tp) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundPrimary,
        border: Border(bottom: BorderSide(color: AppTheme.borderLight, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!sp.hasApiKey)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.priorityMediumLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_outlined,
                      size: 16, color: AppTheme.priorityMedium),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Masukkan API Key di Pengaturan untuk menggunakan AI',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.priorityMedium),
                    ),
                  ),
                ],
              ),
            ),
          if (sp.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.priorityHighLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 16, color: AppTheme.priorityHigh),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sp.errorMessage!,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.priorityHigh),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${tp.pendingTasks.length} tugas menunggu',
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textSecondary),
                    ),
                    Text(
                      'Preferensi: ${sp.preferences.workStartTime} - ${sp.preferences.workEndTime}',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textTertiary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: sp.isLoading
                    ? null
                    : () => _generate(context, sp, tp),
                icon: sp.isLoading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.bolt, size: 16),
                label: Text(sp.isLoading ? 'Memproses...' : 'Buat Jadwal'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ScheduleProvider sp) {
    if (sp.isLoading) {
      return const Center(
        child: LoadingOverlay(message: 'AI sedang menyusun jadwal optimal...'),
      );
    }

    if (sp.viewMode == ScheduleViewMode.daily) {
      return _buildDailyView(context, sp);
    } else {
      return _buildWeeklyView(context, sp);
    }
  }

  Widget _buildDailyView(BuildContext context, ScheduleProvider sp) {
    final schedule = sp.currentDaySchedule;

    if (schedule == null) {
      return const EmptyState(
        icon: Icons.calendar_today_outlined,
        title: 'Jadwal belum dibuat',
        subtitle: 'Klik "Buat Jadwal" untuk membiarkan AI menyusun hari yang optimal untukmu.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Summary card
        if (schedule.summary.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreenLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppTheme.primaryGreen, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome,
                        size: 14, color: AppTheme.primaryGreenDark),
                    SizedBox(width: 6),
                    Text(
                      'STRATEGI HARI INI',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                        color: AppTheme.primaryGreenDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  schedule.summary,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.primaryGreenDark,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        // Stats
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Total tugas',
                value: '${schedule.totalTasks}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                label: 'Waktu kerja',
                value: schedule.totalWorkTime,
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Blocks
        const SectionHeader(title: 'Timeline Jadwal'),
        const SizedBox(height: 10),
        ...schedule.blocks.asMap().entries.map((entry) {
          final i = entry.key;
          final block = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline dots
                Column(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 18),
                      decoration: BoxDecoration(
                        color: block.type == BlockType.task
                            ? AppTheme.primaryGreen
                            : AppTheme.borderMedium,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (i < schedule.blocks.length - 1)
                      Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.borderLight,
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ScheduleBlockCard(
                    block: block,
                    onToggle: () => sp.toggleBlockComplete(block.id),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWeeklyView(BuildContext context, ScheduleProvider sp) {
    final schedule = sp.currentWeekSchedule;

    if (schedule == null) {
      return const EmptyState(
        icon: Icons.date_range_outlined,
        title: 'Jadwal mingguan belum dibuat',
        subtitle:
            'Klik "Buat Jadwal" untuk mendapat distribusi tugas yang optimal selama satu minggu.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        if (schedule.weeklySummary.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreenLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppTheme.primaryGreen, width: 0.5),
            ),
            child: Text(
              schedule.weeklySummary,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.primaryGreenDark,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        ...schedule.days.map((day) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day header
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundPrimary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.borderLight, width: 0.5),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _dayName(day.date),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          day.summary,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '${day.totalTasks} tugas',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...day.blocks.map((block) => Padding(
                    padding: const EdgeInsets.only(bottom: 6, left: 8),
                    child: ScheduleBlockCard(block: block),
                  )),
              const SizedBox(height: 16),
            ],
          );
        }),
      ],
    );
  }

  String _dayName(DateTime date) {
    const days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  Future<void> _generate(
      BuildContext context, ScheduleProvider sp, TaskProvider tp) async {
    final tasks = tp.pendingTasks;
    if (sp.viewMode == ScheduleViewMode.daily) {
      await sp.generateDailySchedule(tasks);
    } else {
      await sp.generateWeeklySchedule(tasks);
    }
  }

  void _showPreferences(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PreferencesSheet(),
    );
  }
}

class _ViewToggleBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ViewToggleBtn({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.backgroundPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w500 : FontWeight.w400,
            color: active ? AppTheme.textPrimary : AppTheme.textTertiary,
          ),
        ),
      ),
    );
  }
}