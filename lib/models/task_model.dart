import 'package:hive/hive.dart';

part 'task_model.g.dart';

enum Priority { high, medium, low }

enum TaskCategory {
  work,
  meeting,
  study,
  personal,
  health,
  other,
}

extension PriorityExtension on Priority {
  String get label {
    switch (this) {
      case Priority.high:
        return 'Tinggi';
      case Priority.medium:
        return 'Sedang';
      case Priority.low:
        return 'Rendah';
    }
  }

  int get value {
    switch (this) {
      case Priority.high:
        return 3;
      case Priority.medium:
        return 2;
      case Priority.low:
        return 1;
    }
  }
}

extension TaskCategoryExtension on TaskCategory {
  String get label {
    switch (this) {
      case TaskCategory.work:
        return 'Pekerjaan';
      case TaskCategory.meeting:
        return 'Rapat';
      case TaskCategory.study:
        return 'Belajar';
      case TaskCategory.personal:
        return 'Pribadi';
      case TaskCategory.health:
        return 'Kesehatan';
      case TaskCategory.other:
        return 'Lainnya';
    }
  }

  String get emoji {
    switch (this) {
      case TaskCategory.work:
        return '💼';
      case TaskCategory.meeting:
        return '🤝';
      case TaskCategory.study:
        return '📚';
      case TaskCategory.personal:
        return '🏠';
      case TaskCategory.health:
        return '💪';
      case TaskCategory.other:
        return '📌';
    }
  }
}

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int durationMinutes;

  @HiveField(3)
  String priorityStr;

  @HiveField(4)
  String categoryStr;

  @HiveField(5)
  DateTime? deadline;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  bool isCompleted;

  @HiveField(8)
  DateTime createdAt;

  TaskModel({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.priorityStr,
    required this.categoryStr,
    this.deadline,
    this.notes,
    this.isCompleted = false,
    required this.createdAt,
  });

  Priority get priority => Priority.values.firstWhere(
        (p) => p.name == priorityStr,
        orElse: () => Priority.medium,
      );

  set priority(Priority p) => priorityStr = p.name;

  TaskCategory get category => TaskCategory.values.firstWhere(
        (c) => c.name == categoryStr,
        orElse: () => TaskCategory.other,
      );

  set category(TaskCategory c) => categoryStr = c.name;

  TaskModel copyWith({
    String? id,
    String? name,
    int? durationMinutes,
    String? priorityStr,
    String? categoryStr,
    DateTime? deadline,
    String? notes,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      name: name ?? this.name,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      priorityStr: priorityStr ?? this.priorityStr,
      categoryStr: categoryStr ?? this.categoryStr,
      deadline: deadline ?? this.deadline,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'durationMinutes': durationMinutes,
        'priority': priorityStr,
        'category': categoryStr,
        'deadline': deadline?.toIso8601String(),
        'notes': notes,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'],
        name: json['name'],
        durationMinutes: json['durationMinutes'],
        priorityStr: json['priority'],
        categoryStr: json['category'],
        deadline:
            json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
        notes: json['notes'],
        isCompleted: json['isCompleted'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
      );
}