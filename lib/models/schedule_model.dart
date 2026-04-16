enum BlockType { task, breakTime, buffer }

class ScheduleBlock {
  final String id;
  final String startTime;
  final String endTime;
  final String title;
  final String description;
  final BlockType type;
  final String? priority;
  final String? category;
  bool isCompleted;

  ScheduleBlock({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.description,
    required this.type,
    this.priority,
    this.category,
    this.isCompleted = false,
  });

  String get timeRange => '$startTime - $endTime';

  factory ScheduleBlock.fromJson(Map<String, dynamic> json) {
    final time = (json['time'] as String? ?? '00:00 - 00:00').split(' - ');
    final typeStr = json['type'] as String? ?? 'task';
    BlockType blockType;
    switch (typeStr) {
      case 'break':
        blockType = BlockType.breakTime;
        break;
      case 'buffer':
        blockType = BlockType.buffer;
        break;
      default:
        blockType = BlockType.task;
    }

    return ScheduleBlock(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: time.isNotEmpty ? time[0].trim() : '00:00',
      endTime: time.length > 1 ? time[1].trim() : '00:00',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: blockType,
      priority: json['priority'] as String?,
      category: json['category'] as String?,
    );
  }
}

class DaySchedule {
  final DateTime date;
  final String summary;
  final List<ScheduleBlock> blocks;
  final String totalWorkTime;
  final int completedTasks;

  DaySchedule({
    required this.date,
    required this.summary,
    required this.blocks,
    required this.totalWorkTime,
    this.completedTasks = 0,
  });

  int get totalTasks => blocks.where((b) => b.type == BlockType.task).length;

  factory DaySchedule.fromJson(Map<String, dynamic> json, DateTime date) {
    final blocks = (json['blocks'] as List<dynamic>? ?? [])
        .map((b) => ScheduleBlock.fromJson(b as Map<String, dynamic>))
        .toList();

    return DaySchedule(
      date: date,
      summary: json['summary'] as String? ?? '',
      blocks: blocks,
      totalWorkTime: json['totalWorkTime'] as String? ?? '',
    );
  }
}

class WeekSchedule {
  final List<DaySchedule> days;
  final String weeklySummary;

  WeekSchedule({
    required this.days,
    required this.weeklySummary,
  });
}

class WorkPreferences {
  final String workStartTime;
  final String workEndTime;
  final String breakStartTime;
  final int breakDurationMinutes;
  final String? additionalNotes;

  const WorkPreferences({
    this.workStartTime = '08:00',
    this.workEndTime = '17:00',
    this.breakStartTime = '12:00',
    this.breakDurationMinutes = 60,
    this.additionalNotes,
  });

  WorkPreferences copyWith({
    String? workStartTime,
    String? workEndTime,
    String? breakStartTime,
    int? breakDurationMinutes,
    String? additionalNotes,
  }) {
    return WorkPreferences(
      workStartTime: workStartTime ?? this.workStartTime,
      workEndTime: workEndTime ?? this.workEndTime,
      breakStartTime: breakStartTime ?? this.breakStartTime,
      breakDurationMinutes: breakDurationMinutes ?? this.breakDurationMinutes,
      additionalNotes: additionalNotes ?? this.additionalNotes,
    );
  }

  Map<String, dynamic> toJson() => {
        'workStartTime': workStartTime,
        'workEndTime': workEndTime,
        'breakStartTime': breakStartTime,
        'breakDurationMinutes': breakDurationMinutes,
        'additionalNotes': additionalNotes,
      };

  factory WorkPreferences.fromJson(Map<String, dynamic> json) =>
      WorkPreferences(
        workStartTime: json['workStartTime'] ?? '08:00',
        workEndTime: json['workEndTime'] ?? '17:00',
        breakStartTime: json['breakStartTime'] ?? '12:00',
        breakDurationMinutes: json['breakDurationMinutes'] ?? 60,
        additionalNotes: json['additionalNotes'],
      );
}