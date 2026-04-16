import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';
import '../models/schedule_model.dart';

class AIScheduleService {
  // gemini-1.5-flash has more generous free tier quota than gemini-2.0-flash
  static const String _model = 'gemini-1.5-flash';

  // IMPORTANT: In production, store API key securely (e.g., env vars, backend proxy)
  // Never hardcode API keys in production apps
  final String apiKey;

  AIScheduleService({required this.apiKey});

  String get _baseUrl =>
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$apiKey';

  Future<DaySchedule> generateDailySchedule({
    required List<TaskModel> tasks,
    required WorkPreferences preferences,
    required DateTime date,
  }) async {
    final taskList = tasks
        .map((t) =>
            '- ${t.name} (${t.durationMinutes} menit, prioritas: ${t.priority.label}'
            '${t.deadline != null ? ', deadline: ${_formatDateTime(t.deadline!)}' : ''}'
            ', kategori: ${t.category.label})')
        .join('\n');

    final prompt = '''Kamu adalah AI scheduler ahli manajemen waktu dan produktivitas.

Buat jadwal harian optimal untuk tanggal ${_formatDate(date)}.

DAFTAR TUGAS:
$taskList

PREFERENSI WAKTU KERJA:
- Jam mulai: ${preferences.workStartTime}
- Jam selesai: ${preferences.workEndTime}
- Istirahat: ${preferences.breakStartTime} selama ${preferences.breakDurationMinutes} menit
${preferences.additionalNotes != null ? '- Catatan: ${preferences.additionalNotes}' : ''}

ATURAN PENJADWALAN:
1. Tugas prioritas TINGGI → tempatkan di jam paling produktif (pagi 08:00-10:00)
2. Tugas besar (>90 menit) → pecah dengan buffer 15 menit setelahnya
3. Sertakan waktu istirahat sesuai preferensi
4. Distribusikan beban kerja secara seimbang (tidak terlalu padat di satu waktu)
5. Tambahkan buffer 10-15 menit antara tugas penting
6. Akhiri dengan review singkat 15 menit jika memungkinkan

Balas HANYA dengan JSON valid tanpa markdown, format PERSIS seperti ini:
{
  "summary": "Ringkasan strategi jadwal hari ini dalam 1-2 kalimat yang memotivasi",
  "totalWorkTime": "X jam Y menit",
  "blocks": [
    {
      "time": "08:00 - 08:30",
      "title": "Nama tugas",
      "description": "Deskripsi singkat atau tips untuk blok ini",
      "type": "task",
      "priority": "high",
      "category": "work"
    }
  ]
}

Untuk "type" gunakan: "task", "break", "buffer"
Untuk "priority" gunakan: "high", "medium", "low" (hanya untuk type task)''';

    return _callAPI(prompt, date);
  }

  Future<WeekSchedule> generateWeeklySchedule({
    required List<TaskModel> tasks,
    required WorkPreferences preferences,
    required DateTime weekStart,
  }) async {
    final taskList = tasks
        .map((t) =>
            '- ${t.name} (${t.durationMinutes} menit, prioritas: ${t.priority.label}'
            '${t.deadline != null ? ', deadline: ${_formatDateTime(t.deadline!)}' : ''}'
            ', kategori: ${t.category.label})')
        .join('\n');

    final weekDays = List.generate(5, (i) {
      final day = weekStart.add(Duration(days: i));
      return _formatDate(day);
    }).join(', ');

    final prompt = '''Kamu adalah AI scheduler ahli manajemen waktu dan produktivitas.

Buat jadwal MINGGUAN yang seimbang untuk minggu: $weekDays

DAFTAR TUGAS YANG PERLU DIJADWALKAN:
$taskList

PREFERENSI WAKTU KERJA (berlaku setiap hari):
- Jam mulai: ${preferences.workStartTime}
- Jam selesai: ${preferences.workEndTime}
- Istirahat: ${preferences.breakStartTime} selama ${preferences.breakDurationMinutes} menit
${preferences.additionalNotes != null ? '- Catatan: ${preferences.additionalNotes}' : ''}

ATURAN:
1. Distribusikan tugas secara merata sepanjang minggu
2. Tugas berdeadline dekat → prioritaskan di awal minggu
3. Senin/Selasa untuk tugas berat, Rabu buffer, Kamis/Jumat lebih ringan
4. Jangan overload satu hari dengan terlalu banyak tugas

Balas HANYA dengan JSON valid tanpa markdown:
{
  "weeklySummary": "Strategi distribusi tugas minggu ini",
  "days": [
    {
      "date": "YYYY-MM-DD",
      "summary": "Fokus hari ini",
      "totalWorkTime": "X jam Y menit",
      "blocks": [
        {
          "time": "08:00 - 09:00",
          "title": "Nama tugas",
          "description": "Keterangan",
          "type": "task",
          "priority": "high"
        }
      ]
    }
  ]
}''';

    for (int attempt = 0; attempt <= 2; attempt++) {
      try {
        final response = await http.post(
          Uri.parse(_baseUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ]
              }
            ],
            'generationConfig': {
              'temperature': 0.7,
              'maxOutputTokens': 4000,
            },
          }),
        );

        if (response.statusCode == 429) {
          if (attempt < 2) {
            await Future.delayed(Duration(seconds: (attempt + 1) * 5));
            continue;
          }
          throw AIServiceException(
            'Batas kuota Gemini API tercapai. Coba lagi dalam beberapa menit.',
          );
        }

        if (response.statusCode != 200) {
          throw AIServiceException(
              'API Error ${response.statusCode}: ${response.body}');
        }

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawText =
            data['candidates'][0]['content']['parts'][0]['text'] as String;
        final cleanJson = rawText.replaceAll(RegExp(r'```json|```'), '').trim();
        final parsed = jsonDecode(cleanJson) as Map<String, dynamic>;

        final days = (parsed['days'] as List<dynamic>).map((d) {
          final dayMap = d as Map<String, dynamic>;
          final date = DateTime.parse(dayMap['date'] as String);
          return DaySchedule.fromJson(dayMap, date);
        }).toList();

        return WeekSchedule(
          days: days,
          weeklySummary: parsed['weeklySummary'] as String? ?? '',
        );
      } on AIServiceException {
        rethrow;
      } catch (e) {
        if (attempt < 2) {
          await Future.delayed(Duration(seconds: (attempt + 1) * 3));
          continue;
        }
        throw AIServiceException(
            'Gagal terhubung ke Gemini API: ${e.toString()}');
      }
    }
    throw AIServiceException('Gagal setelah beberapa percobaan.');
  }

  Future<DaySchedule> _callAPI(String prompt, DateTime date) async {
    return _callWithRetry(prompt, date, maxRetries: 2);
  }

  Future<DaySchedule> _callWithRetry(String prompt, DateTime date,
      {int maxRetries = 2}) async {
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await http.post(
          Uri.parse(_baseUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ]
              }
            ],
            'generationConfig': {
              'temperature': 0.7,
              'maxOutputTokens': 2000,
            },
          }),
        );

        if (response.statusCode == 429) {
          if (attempt < maxRetries) {
            // Wait before retry: 5s, 10s
            await Future.delayed(Duration(seconds: (attempt + 1) * 5));
            continue;
          }
          throw AIServiceException(
            'Batas kuota Gemini API tercapai. Coba lagi dalam beberapa menit, '
            'atau upgrade ke Gemini API berbayar di aistudio.google.com.',
          );
        }

        if (response.statusCode != 200) {
          throw AIServiceException(
              'API Error ${response.statusCode}: ${response.body}');
        }

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawText =
            data['candidates'][0]['content']['parts'][0]['text'] as String;
        final cleanJson =
            rawText.replaceAll(RegExp(r'```json|```'), '').trim();
        final parsed = jsonDecode(cleanJson) as Map<String, dynamic>;

        return DaySchedule.fromJson(parsed, date);
      } on AIServiceException {
        rethrow;
      } catch (e) {
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: (attempt + 1) * 3));
          continue;
        }
        throw AIServiceException(
            'Gagal terhubung ke Gemini API: ${e.toString()}');
      }
    }
    throw AIServiceException('Gagal setelah beberapa percobaan.');
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    const days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class AIServiceException implements Exception {
  final String message;
  AIServiceException(this.message);

  @override
  String toString() => 'AIServiceException: $message';
}