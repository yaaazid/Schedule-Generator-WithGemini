import 'package:flutter/foundation.dart';
import '../models/schedule_model.dart';
import '../models/task_model.dart';
import '../services/ai_schedule_service.dart';
import '../services/storage_service.dart';

enum ScheduleViewMode { daily, weekly }
enum ScheduleStatus { idle, loading, success, error }

class ScheduleProvider extends ChangeNotifier {
  final StorageService _storage;

  WorkPreferences _preferences = const WorkPreferences();
  DaySchedule? _currentDaySchedule;
  WeekSchedule? _currentWeekSchedule;
  ScheduleViewMode _viewMode = ScheduleViewMode.daily;
  ScheduleStatus _status = ScheduleStatus.idle;
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();
  String? _apiKey;

  ScheduleProvider({required StorageService storage}) : _storage = storage {
    _init();
  }

  WorkPreferences get preferences => _preferences;
  DaySchedule? get currentDaySchedule => _currentDaySchedule;
  WeekSchedule? get currentWeekSchedule => _currentWeekSchedule;
  ScheduleViewMode get viewMode => _viewMode;
  ScheduleStatus get status => _status;
  String? get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;
  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;
  bool get isLoading => _status == ScheduleStatus.loading;

  Future<void> _init() async {
    _preferences = await _storage.loadPreferences();
    _apiKey = await _storage.loadApiKey();
    notifyListeners();
  }

  Future<void> updatePreferences(WorkPreferences prefs) async {
    _preferences = prefs;
    await _storage.savePreferences(prefs);
    notifyListeners();
  }

  Future<void> saveApiKey(String key) async {
    _apiKey = key;
    await _storage.saveApiKey(key);
    notifyListeners();
  }

  Future<void> removeApiKey() async {
    _apiKey = null;
    await _storage.clearApiKey();
    notifyListeners();
  }

  void setViewMode(ScheduleViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> generateDailySchedule(List<TaskModel> tasks) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      _status = ScheduleStatus.error;
      _errorMessage = 'API Key belum diset. Silakan masuk ke Pengaturan.';
      notifyListeners();
      return;
    }

    if (tasks.isEmpty) {
      _status = ScheduleStatus.error;
      _errorMessage = 'Tambahkan minimal satu tugas terlebih dahulu.';
      notifyListeners();
      return;
    }

    _status = ScheduleStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final service = AIScheduleService(apiKey: _apiKey!);
      _currentDaySchedule = await service.generateDailySchedule(
        tasks: tasks,
        preferences: _preferences,
        date: _selectedDate,
      );
      _status = ScheduleStatus.success;
    } on AIServiceException catch (e) {
      _status = ScheduleStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = ScheduleStatus.error;
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
    }

    notifyListeners();
  }

  Future<void> generateWeeklySchedule(List<TaskModel> tasks) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      _status = ScheduleStatus.error;
      _errorMessage = 'API Key belum diset. Silakan masuk ke Pengaturan.';
      notifyListeners();
      return;
    }

    if (tasks.isEmpty) {
      _status = ScheduleStatus.error;
      _errorMessage = 'Tambahkan minimal satu tugas terlebih dahulu.';
      notifyListeners();
      return;
    }

    _status = ScheduleStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final service = AIScheduleService(apiKey: _apiKey!);
      // Find Monday of current week
      final now = _selectedDate;
      final monday = now.subtract(Duration(days: now.weekday - 1));

      _currentWeekSchedule = await service.generateWeeklySchedule(
        tasks: tasks,
        preferences: _preferences,
        weekStart: monday,
      );
      _status = ScheduleStatus.success;
    } on AIServiceException catch (e) {
      _status = ScheduleStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = ScheduleStatus.error;
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
    }

    notifyListeners();
  }

  void toggleBlockComplete(String blockId) {
    if (_currentDaySchedule == null) return;
    final block = _currentDaySchedule!.blocks
        .firstWhere((b) => b.id == blockId, orElse: () => throw Exception());
    block.isCompleted = !block.isCompleted;
    notifyListeners();
  }

  void clearSchedule() {
    _currentDaySchedule = null;
    _currentWeekSchedule = null;
    _status = ScheduleStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}