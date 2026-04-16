import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/task_model.dart';
import '../models/schedule_model.dart';

// ─── Priority Badge ───────────────────────────────────────

class PriorityBadge extends StatelessWidget {
  final String priority;
  final bool small;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: priorityLightColor(priority),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priorityLabel(priority),
        style: TextStyle(
          fontSize: small ? 10 : 11,
          fontWeight: FontWeight.w600,
          color: priorityColor(priority),
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ─── Category Chip ────────────────────────────────────────

class CategoryChip extends StatelessWidget {
  final TaskCategory category;
  final bool selected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryGreenLight
              : AppTheme.backgroundSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primaryGreen : AppTheme.borderLight,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              category.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    selected ? FontWeight.w500 : FontWeight.w400,
                color: selected
                    ? AppTheme.primaryGreenDark
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  color: AppTheme.textTertiary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ─── Task Card ────────────────────────────────────────────

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleComplete;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onDelete,
    this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.isCompleted
              ? AppTheme.borderLight
              : AppTheme.borderMedium,
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Priority dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: task.isCompleted
                      ? AppTheme.borderMedium
                      : priorityColor(task.priorityStr),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: task.isCompleted
                            ? AppTheme.textTertiary
                            : AppTheme.textPrimary,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${task.durationMinutes} menit',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          task.category.emoji,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.category.label,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PriorityBadge(priority: task.priorityStr, small: true),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onToggleComplete,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? AppTheme.primaryGreen
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: task.isCompleted
                          ? AppTheme.primaryGreen
                          : AppTheme.borderMedium,
                      width: task.isCompleted ? 0 : 0.5,
                    ),
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Schedule Block Card ──────────────────────────────────

class ScheduleBlockCard extends StatelessWidget {
  final ScheduleBlock block;
  final VoidCallback? onToggle;

  const ScheduleBlockCard({
    super.key,
    required this.block,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isBreak = block.type == BlockType.breakTime;
    final isBuffer = block.type == BlockType.buffer;

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: block.isCompleted
              ? AppTheme.backgroundSecondary
              : AppTheme.backgroundPrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: block.isCompleted
                ? AppTheme.borderLight
                : AppTheme.borderMedium,
            width: 0.5,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left accent bar
              Container(
                width: 3,
                decoration: BoxDecoration(
                  color: isBreak || isBuffer
                      ? AppTheme.borderMedium
                      : block.priority != null
                          ? priorityColor(block.priority!)
                          : AppTheme.primaryGreen,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // Time column
                      SizedBox(
                        width: 74,
                        child: Text(
                          block.timeRange.replaceAll(' - ', '\n'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textTertiary,
                            height: 1.4,
                          ),
                        ),
                      ),
                      // Divider
                      Container(
                        width: 0.5,
                        height: double.infinity,
                        color: AppTheme.borderLight,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              block.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: block.isCompleted
                                    ? AppTheme.textTertiary
                                    : AppTheme.textPrimary,
                                decoration: block.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            if (block.description.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                block.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Badge
                      if (isBreak)
                        _buildBadge('Istirahat', AppTheme.textTertiary,
                            AppTheme.backgroundTertiary)
                      else if (isBuffer)
                        _buildBadge('Buffer', AppTheme.textTertiary,
                            AppTheme.backgroundTertiary)
                      else if (block.priority != null)
                        PriorityBadge(priority: block.priority!, small: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight, width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.backgroundTertiary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, size: 28, color: AppTheme.textTertiary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Loading Overlay ─────────────────────────────────────

class LoadingOverlay extends StatelessWidget {
  final String message;

  const LoadingOverlay({super.key, this.message = 'Memproses...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppTheme.backgroundPrimary,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.borderLight, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(AppTheme.primaryGreen),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color?.withOpacity(0.08) ?? AppTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: color ?? AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}