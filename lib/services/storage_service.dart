import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import '../models/schedule_model.dart';

class StorageService {
  static const String _tasksKey = 'tasks';
  static const String _preferencesKey = 'work_preferences';
  static const String _apiKeyKey = 'api_key';
  static const String _schedulesKey = 'cached_schedules';

  // ─── Tasks ───────────────────────────────────────────────

  Future<List<TaskModel>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_tasksKey);
    if (jsonStr == null) return [];
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTasks(List<TaskModel> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_tasksKey, jsonStr);
  }

  // ─── Work Preferences ────────────────────────────────────

  Future<WorkPreferences> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_preferencesKey);
    if (jsonStr == null) return const WorkPreferences();
    return WorkPreferences.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  Future<void> savePreferences(WorkPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferencesKey, jsonEncode(preferences.toJson()));
  }

  // ─── API Key ─────────────────────────────────────────────

  Future<String?> loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, key);
  }

  Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyKey);
  }

  // ─── Cached Schedules ────────────────────────────────────

  Future<Map<String, dynamic>?> loadCachedSchedule(String dateKey) async {
    final prefs = await SharedPreferences.getInstance();
    final allStr = prefs.getString(_schedulesKey);
    if (allStr == null) return null;
    final all = jsonDecode(allStr) as Map<String, dynamic>;
    return all[dateKey] as Map<String, dynamic>?;
  }

  Future<void> cacheSchedule(
      String dateKey, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final allStr = prefs.getString(_schedulesKey);
    final all = allStr != null
        ? jsonDecode(allStr) as Map<String, dynamic>
        : <String, dynamic>{};
    all[dateKey] = data;
    // Keep only last 14 days of cache
    if (all.length > 14) {
      final keys = all.keys.toList()..sort();
      all.remove(keys.first);
    }
    await prefs.setString(_schedulesKey, jsonEncode(all));
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}