import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsTile(
            context,
            'Ses Kalitesi',
            'Yüksek kalite (256 kbps)',
            Icons.high_quality,
            () {},
          ),
          _buildSettingsTile(
            context,
            'Otomatik Oynat',
            'Uygulamayı açarken son çalınan istasyonu oynat',
            Icons.autorenew,
            () {},
          ),
          _buildSettingsTile(
            context,
            'Bildirimler',
            'Oynatma bildirimleri ve kontroller',
            Icons.notifications_outlined,
            () {},
          ),
          _buildSettingsTile(
            context,
            'Karanlık Mod',
            'Sistem ayarını takip et',
            Icons.dark_mode_outlined,
            () {},
          ),
          const Divider(height: 32),
          _buildSettingsTile(
            context,
            'Hakkında',
            'Versiyon 1.0.0',
            Icons.info_outline,
            () {},
          ),
          _buildSettingsTile(
            context,
            'Destek',
            'Sorun bildir veya öneride bulun',
            Icons.support_outlined,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}