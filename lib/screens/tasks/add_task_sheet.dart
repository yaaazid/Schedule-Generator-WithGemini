import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AddTaskSheet extends StatefulWidget {
  final TaskModel? task;

  const AddTaskSheet({super.key, this.task});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  Priority _priority = Priority.medium;
  TaskCategory _category = TaskCategory.work;
  int _duration = 60;
  DateTime? _deadline;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.task!;
      _nameCtrl.text = t.name;
      _notesCtrl.text = t.notes ?? '';
      _priority = t.priority;
      _category = t.category;
      _duration = t.durationMinutes;
      _deadline = t.deadline;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
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
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
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
            Text(
              _isEditing ? 'Edit Tugas' : 'Tambah Tugas Baru',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Name field
            TextFormField(
              controller: _nameCtrl,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                fillColor: Colors.black,
                labelText: 'Nama tugas',
                hintText: 'Contoh: Review laporan bulanan',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama tidak boleh kosong' : null,
            ),
            const SizedBox(height: 14),

            // Duration
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Durasi',
                      style:
                          TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                    const Spacer(),
                    Text(
                      '$_duration menit',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _duration.toDouble(),
                  min: 15,
                  max: 480,
                  divisions: 31,
                  activeColor: AppTheme.primaryGreen,
                  inactiveColor: AppTheme.primaryGreenLight,
                  onChanged: (v) => setState(() => _duration = v.round()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final t in [15, 60, 120, 240, 480])
                      GestureDetector(
                        onTap: () => setState(() => _duration = t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _duration == t
                                ? AppTheme.primaryGreenLight
                                : AppTheme.backgroundSecondary,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _duration == t
                                  ? AppTheme.primaryGreen
                                  : AppTheme.borderLight,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            t < 60
                                ? '${t}m'
                                : t == 60
                                    ? '1j'
                                    : '${t ~/ 60}j',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _duration == t
                                  ? AppTheme.primaryGreenDark
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Priority
            const Text(
              'PRIORITAS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
                color: AppTheme.textTertiary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: Priority.values.map((p) {
                final selected = _priority == p;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? priorityLightColor(p.name)
                              : AppTheme.backgroundSecondary,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? priorityColor(p.name)
                                : AppTheme.borderLight,
                            width: selected ? 1.5 : 0.5,
                          ),
                        ),
                        child: Text(
                          p.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: selected
                                ? priorityColor(p.name)
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Category
            const Text(
              'KATEGORI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
                color: AppTheme.textTertiary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskCategory.values
                  .map((c) => CategoryChip(
                        category: c,
                        selected: _category == c,
                        onTap: () => setState(() => _category = c),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),

            // Deadline
            GestureDetector(
              onTap: _pickDeadline,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundPrimary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _deadline != null
                        ? AppTheme.primaryGreen
                        : AppTheme.borderMedium,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: 18,
                      color: _deadline != null
                          ? AppTheme.primaryGreen
                          : AppTheme.textTertiary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _deadline != null
                            ? 'Deadline: ${_formatDate(_deadline!)}'
                            : 'Tambah deadline (opsional)',
                        style: TextStyle(
                          fontSize: 14,
                          color: _deadline != null
                              ? AppTheme.textPrimary
                              : AppTheme.textTertiary,
                        ),
                      ),
                    ),
                    if (_deadline != null)
                      GestureDetector(
                        onTap: () => setState(() => _deadline = null),
                        child: const Icon(Icons.close,
                            size: 16, color: AppTheme.textTertiary),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Notes
            TextFormField(
              controller: _notesCtrl,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                hintText: 'Info tambahan tentang tugas ini...',
              ),
            ),
            const SizedBox(height: 24),

            // Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: Text(_isEditing ? 'Simpan Perubahan' : 'Tambah Tugas'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primaryGreen),
        ),
        child: child!,
      ),
    );
    if (date == null) return;

    final time = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: TimeOfDay.now(),
    );

    setState(() {
      _deadline = time != null
          ? DateTime(date.year, date.month, date.day, time.hour, time.minute)
          : date;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<TaskProvider>();

    if (_isEditing) {
      final updated = widget.task!.copyWith(
        name: _nameCtrl.text.trim(),
        durationMinutes: _duration,
        priorityStr: _priority.name,
        categoryStr: _category.name,
        deadline: _deadline,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      provider.updateTask(updated);
    } else {
      provider.addTask(
        name: _nameCtrl.text.trim(),
        durationMinutes: _duration,
        priority: _priority,
        category: _category,
        deadline: _deadline,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
    }

    Navigator.pop(context);
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}