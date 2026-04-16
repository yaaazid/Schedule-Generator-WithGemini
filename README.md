# Schedule Generator App with AI

Aplikasi mobile Flutter untuk generate jadwal harian/mingguan secara otomatis menggunakan AI (Claude by Anthropic).

## Fitur Utama

- **AI-Powered Schedule Generation** — Input tugas, prioritas, dan waktu. AI menghasilkan jadwal optimal secara otomatis.
- **Task Input & Customization** — Tambah tugas dengan durasi, prioritas, deadline, dan kategori. Set preferensi jam kerja dan istirahat.
- **Smart Schedule Output** — View harian dan mingguan. Auto-balanced workload distribution.
- **Local Storage** — Tugas dan preferensi tersimpan di perangkat.

## Struktur File

```
lib/
├── main.dart                        # Entry point aplikasi
├── models/
│   ├── task_model.dart              # Model tugas + Priority + Category enum
│   ├── task_model.g.dart            # Generated Hive adapter
│   └── schedule_model.dart          # ScheduleBlock, DaySchedule, WeekSchedule, WorkPreferences
├── services/
│   ├── ai_schedule_service.dart     # Integrasi Anthropic Claude API
│   └── storage_service.dart         # Local storage (SharedPreferences)
├── providers/
│   ├── task_provider.dart           # State management untuk tugas
│   └── schedule_provider.dart       # State management untuk jadwal + preferensi
├── screens/
│   ├── home/
│   │   └── home_screen.dart         # Bottom navigation utama
│   ├── tasks/
│   │   ├── tasks_screen.dart        # Daftar tugas + statistik
│   │   └── add_task_sheet.dart      # Bottom sheet tambah/edit tugas
│   ├── schedule/
│   │   ├── schedule_screen.dart     # Tampilan jadwal harian & mingguan
│   │   └── preferences_sheet.dart  # Setting jam kerja & istirahat
│   └── settings/
│       └── settings_screen.dart     # Konfigurasi API Key
├── widgets/
│   └── common_widgets.dart          # Reusable widgets (TaskCard, ScheduleBlockCard, dll)
└── theme/
    └── app_theme.dart               # Tema aplikasi (light & dark)
```

## Setup & Instalasi

### 1. Prerequisites
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code dengan Flutter extension

### 2. Clone & Install Dependencies
```bash
git clone <repo_url>
cd schedule_ai_app
flutter pub get
```

### 3. Generate Hive Adapters (opsional, sudah disertakan)
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 4. Jalankan Aplikasi
```bash
flutter run
```

### 5. Konfigurasi API Key
1. Buka tab **Pengaturan** di aplikasi
2. Masukkan Google Gemini API Key (dapatkan di [aistudio.google.com](https://aistudio.google.com))
3. Klik **Simpan API Key**

## Cara Penggunaan

### Menambah Tugas
1. Buka tab **Tugas**
2. Klik tombol **+** (FAB)
3. Isi nama, durasi, prioritas, dan kategori
4. Tambahkan deadline jika ada
5. Klik **Tambah Tugas**

### Generate Jadwal Harian
1. Buka tab **Jadwal**
2. Pastikan mode **Harian** aktif
3. Klik tombol **Buat Jadwal**
4. AI akan menyusun jadwal optimal berdasarkan tugas dan preferensi

### Generate Jadwal Mingguan
1. Buka tab **Jadwal**
2. Klik **Mingguan** di toggle view
3. Klik **Buat Jadwal**
4. AI mendistribusikan tugas secara merata sepanjang minggu

### Atur Preferensi Waktu
1. Di tab Jadwal, klik ikon **⊕** (tune) di kanan atas
2. Set jam mulai kerja, selesai, dan istirahat
3. Tambahkan catatan untuk AI (opsional)
4. Klik **Simpan Preferensi**

## Teknologi

| Package | Kegunaan |
|---------|----------|
| `provider` | State management |
| `http` | HTTP client untuk Gemini API |
| `shared_preferences` | Penyimpanan lokal |
| `google_fonts` | Font DM Sans & DM Serif Display |
| `uuid` | Generate unique ID |
| `intl` | Format tanggal |

## Catatan Keamanan

> ⚠️ **Penting**: API Key disimpan di SharedPreferences (tidak terenkripsi).
> Untuk production, gunakan Flutter Secure Storage atau simpan di backend.

```dart
// Ganti StorageService._apiKeyKey dengan flutter_secure_storage:
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// final storage = FlutterSecureStorage();
// await storage.write(key: 'api_key', value: key);
```