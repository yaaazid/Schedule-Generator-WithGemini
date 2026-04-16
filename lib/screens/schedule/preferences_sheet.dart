import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';
import '../../models/schedule_model.dart';
import '../../theme/app_theme.dart';

class PreferencesSheet extends StatefulWidget {
  const PreferencesSheet({super.key});

  @override
  State<PreferencesSheet> createState() => _PreferencesSheetState();
}

class _PreferencesSheetState extends State<PreferencesSheet> {
  late TimeOfDay _workStart;
  late TimeOfDay _workEnd;
  late TimeOfDay _breakStart;
  late int _breakDuration;
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final prefs = context.read<ScheduleProvider>().preferences;
    _workStart = _parseTime(prefs.workStartTime);
    _workEnd = _parseTime(prefs.workEndTime);
    _breakStart = _parseTime(prefs.breakStartTime);
    _breakDuration = prefs.breakDurationMinutes;
    _notesCtrl.text = prefs.additionalNotes ?? '';
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderMedium,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Preferensi Waktu Kerja',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Work hours row
          Row(
            children: [
              Expanded(
                child: _TimePickerTile(
                  label: 'Mulai kerja',
                  time: _workStart,
                  onPick: () async {
                    final t = await _pickTime(_workStart);
                    if (t != null) setState(() => _workStart = t);
                  },
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward,
                  size: 16, color: AppTheme.textTertiary),
              const SizedBox(width: 12),
              Expanded(
                child: _TimePickerTile(
                  label: 'Selesai kerja',
                  time: _workEnd,
                  onPick: () async {
                    final t = await _pickTime(_workEnd);
                    if (t != null) setState(() => _workEnd = t);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Break
          const Text(
            'ISTIRAHAT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
              color: AppTheme.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _TimePickerTile(
                  label: 'Jam istirahat',
                  time: _breakStart,
                  onPick: () async {
                    final t = await _pickTime(_breakStart);
                    if (t != null) setState(() => _breakStart = t);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Durasi',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        for (final min in [30, 45, 60, 90])
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _breakDuration = min),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 140),
                                margin: const EdgeInsets.only(right: 4),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _breakDuration == min
                                      ? AppTheme.primaryGreenLight
                                      : AppTheme.backgroundSecondary,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _breakDuration == min
                                        ? AppTheme.primaryGreen
                                        : AppTheme.borderLight,
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  '${min}m',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _breakDuration == min
                                        ? AppTheme.primaryGreenDark
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Notes
          TextFormField(
            controller: _notesCtrl,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
            ),
            decoration: const InputDecoration(
              labelText: 'Catatan untuk AI (opsional)',
              hintText: 'Misal: saya lebih produktif di pagi hari...',
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('Simpan Preferensi'),
            ),
          ),
        ],
      ),
    );
  }

  Future<TimeOfDay?> _pickTime(TimeOfDay initial) {
    return showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppTheme.primaryGreen),
        ),
        child: child!,
      ),
    );
  }

  void _save() {
    final prefs = WorkPreferences(
      workStartTime: _formatTime(_workStart),
      workEndTime: _formatTime(_workEnd),
      breakStartTime: _formatTime(_breakStart),
      breakDurationMinutes: _breakDuration,
      additionalNotes: _notesCtrl.text.trim().isEmpty
          ? null
          : _notesCtrl.text.trim(),
    );
    context.read<ScheduleProvider>().updatePreferences(prefs);
    Navigator.pop(context);
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

class _TimePickerTile extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onPick;

  const _TimePickerTile({
    required this.label,
    required this.time,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundPrimary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.borderMedium, width: 0.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time,
                    size: 16, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}