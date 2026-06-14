import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const String _email = 'software19951995@gmail.com';

  void _copyEmail(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _email));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('E-posta adresi kopyalandı: $_email'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Destek & İletişim'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Başlık ikonu
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.support_agent_outlined, size: 40, color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Radyo Tüneli',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              'Destek & İletişim',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ),
          const SizedBox(height: 32),

          // E-Posta
          _buildCard(
            theme,
            icon: Icons.email_outlined,
            title: 'E-Posta ile İletişim',
            subtitle: _email,
            trailing: const Icon(Icons.copy_outlined, size: 20),
            onTap: () => _copyEmail(context),
          ),
          const SizedBox(height: 12),

          // Soru & Sorunlar
          _buildCard(
            theme,
            icon: Icons.help_outline,
            title: 'Sık Sorulan Sorular',
            subtitle: 'Uygulama hakkında sorularınız için',
            onTap: () => _showFaqDialog(context, theme),
          ),
          const SizedBox(height: 12),

          // Hata bildirimi
          _buildCard(
            theme,
            icon: Icons.bug_report_outlined,
            title: 'Hata Bildir',
            subtitle: 'Bir sorunla mı karşılaştınız? Bize bildirin',
            trailing: const Icon(Icons.copy_outlined, size: 20),
            onTap: () {
              Clipboard.setData(const ClipboardData(text: _email));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('E-posta adresi kopyalandı. Sorununuzu mail ile iletebilirsiniz.')),
              );
            },
          ),
          const SizedBox(height: 32),

          // Uygulama Bilgisi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Uygulama Hakkında', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _infoRow(theme, 'Uygulama', 'Radyo Tüneli'),
                _infoRow(theme, 'Versiyon', '2.0.4'),
                _infoRow(theme, 'Platform', 'Android / iOS'),
                _infoRow(theme, 'İletişim', _email),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              '© 2025 Radyo Tüneli. Tüm hakları saklıdır.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.45)),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCard(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                  ],
                ),
              ),
              trailing ?? const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.55))),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  void _showFaqDialog(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sık Sorulan Sorular', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _faqItem(theme, 'Radyo neden çalmıyor?', 'İnternet bağlantınızı kontrol edin. İstasyonun sunucusu geçici olarak devre dışı olabilir.'),
            _faqItem(theme, 'Favori istasyonlarım kayboldu?', 'Uygulama verilerini temizlerseniz favoriler silinir. Ayarlar > Verileri Sil seçeneğine dikkat edin.'),
            _faqItem(theme, 'Android Auto çalışmıyor?', 'Android Auto uyumluluğu için uygulamanın güncel sürümünü kullandığınızdan emin olun.'),
            _faqItem(theme, 'Yeni istasyon eklenebilir mi?', 'software19951995@gmail.com adresine yazarak öneri iletebilirsiniz.'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _faqItem(ThemeData theme, String q, String a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• $q', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(a, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.65))),
          ),
        ],
      ),
    );
  }
}
