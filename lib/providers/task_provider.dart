import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../services/storage_service.dart';

class TaskProvider extends ChangeNotifier {
  final StorageService _storage;
  final _uuid = const Uuid();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  TaskProvider({required StorageService storage}) : _storage = storage {
    _loadTasks();
  }

  List<TaskModel> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  int get taskCount => _tasks.length;
  int get completedCount => _tasks.where((t) => t.isCompleted).length;

  List<TaskModel> get pendingTasks =>
      _tasks.where((t) => !t.isCompleted).toList();

  List<TaskModel> get sortedByPriority {
    final sorted = [..._tasks];
    sorted.sort((a, b) => b.priority.value.compareTo(a.priority.value));
    return sorted;
  }

  List<TaskModel> getTasksByCategory(TaskCategory category) =>
      _tasks.where((t) => t.category == category).toList();

  Future<void> _loadTasks() async {
    _isLoading = true;
    notifyListeners();
    _tasks = await _storage.loadTasks();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask({
    required String name,
    required int durationMinutes,
    required Priority priority,
    required TaskCategory category,
    DateTime? deadline,
    String? notes,
  }) async {
    final task = TaskModel(
      id: _uuid.v4(),
      name: name,
      durationMinutes: durationMinutes,
      priorityStr: priority.name,
      categoryStr: category.name,
      deadline: deadline,
      notes: notes,
      createdAt: DateTime.now(),
    );
    _tasks.add(task);
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> updateTask(TaskModel updated) async {
    final idx = _tasks.indexWhere((t) => t.id == updated.id);
    if (idx == -1) return;
    _tasks[idx] = updated;
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> toggleComplete(String taskId) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    _tasks[idx] = _tasks[idx].copyWith(
      isCompleted: !_tasks[idx].isCompleted,
    );
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final task = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, task);
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> clearCompleted() async {
    _tasks.removeWhere((t) => t.isCompleted);
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }
}