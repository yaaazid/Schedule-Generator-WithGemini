import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyCtrl = TextEditingController();
  bool _obscureKey = true;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill if key exists (we show placeholder only)
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundSecondary,
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // API Key section
          _buildSection(
            title: 'Konfigurasi AI',
            children: [
              Consumer<ScheduleProvider>(
                builder: (context, sp, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: sp.hasApiKey
                                  ? AppTheme.primaryGreen
                                  : AppTheme.priorityHigh,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            sp.hasApiKey
                                ? 'API Key tersimpan'
                                : 'API Key belum diset',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: sp.hasApiKey
                                  ? AppTheme.primaryGreenDark
                                  : AppTheme.priorityHigh,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Masukkan Google Gemini API Key untuk mengaktifkan fitur AI Schedule Generator.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _apiKeyCtrl,
                        obscureText: _obscureKey,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'monospace',
                          color: AppTheme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Google Gemini API Key',
                          hintText: sp.hasApiKey ? 'AIza••••••••' : 'AIzaSy...',
                          prefixIcon: const Icon(Icons.key_outlined, size: 18),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureKey
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18,
                            ),
                            onPressed: () =>
                                setState(() => _obscureKey = !_obscureKey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _saveApiKey(context),
                              child: const Text('Simpan API Key'),
                            ),
                          ),
                          if (sp.hasApiKey) ...[
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () => _removeApiKey(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.priorityHigh,
                                side: const BorderSide(
                                    color: AppTheme.priorityHigh, width: 0.5),
                              ),
                              child: const Text('Hapus'),
                            ),
                          ],
                        ],
                      ),
                      if (_saved) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreenLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  size: 14, color: AppTheme.primaryGreenDark),
                              SizedBox(width: 6),
                              Text(
                                'API Key berhasil disimpan!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryGreenDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // About section
          _buildSection(
            title: 'Tentang Aplikasi',
            children: [
              _buildInfoRow('Versi', '1.0.0'),
              _buildInfoRow('Model AI', 'Gemini 1.5 Flash (Google)'),
              _buildInfoRow('Framework', 'Flutter'),
              _buildInfoRow('Developer', 'Yazed Troya'),
            ],
          ),
          const SizedBox(height: 16),

          // How to get API key
          _buildSection(
            title: 'Cara Mendapatkan API Key',
            children: [
              const Text(
                '1. Kunjungi aistudio.google.com\n'
                '2. Login dengan akun Google\n'
                '3. Klik "Get API Key" → "Create API Key"\n'
                '4. Pilih project Google Cloud atau buat baru\n'
                '5. Copy API Key dan paste di field di atas',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundPrimary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight, width: 0.5),
      ),
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
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14, color: AppTheme.textSecondary)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Future<void> _saveApiKey(BuildContext context) async {
    final key = _apiKeyCtrl.text.trim();
    if (key.isEmpty) return;
    await context.read<ScheduleProvider>().saveApiKey(key);
    _apiKeyCtrl.clear();
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  Future<void> _removeApiKey(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus API Key?'),
        content: const Text(
            'API Key akan dihapus dan fitur AI tidak akan bisa digunakan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
                foregroundColor: AppTheme.priorityHigh),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      // ignore: use_build_context_synchronously
      await context.read<ScheduleProvider>().removeApiKey();
    }
  }
}