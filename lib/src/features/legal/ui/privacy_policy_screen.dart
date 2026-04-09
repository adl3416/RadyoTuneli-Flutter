import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datenschutzerklärung'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionTitle(theme, 'Gizlilik Politikası / Datenschutzerklärung'),
          const SizedBox(height: 8),
          _bodyText(theme,
            'Son güncelleme / Letzte Aktualisierung: 09.04.2026',
          ),
          const SizedBox(height: 16),

          _sectionTitle(theme, '1. Genel Bilgi / Allgemeine Hinweise'),
          const SizedBox(height: 8),
          _bodyText(theme,
            'Radyo Tüneli uygulamasını kullandığınız için teşekkür ederiz. '
            'Gizliliğiniz bizim için önemlidir. Bu uygulama kişisel verilerinizi '
            'toplamaz, analiz etmez veya üçüncü taraflarla paylaşmaz.\n\n'
            'Vielen Dank für die Nutzung der Radyo Tüneli App. Ihre Privatsphäre '
            'ist uns wichtig. Diese App sammelt, analysiert oder teilt keine '
            'personenbezogenen Daten mit Dritten.',
          ),
          const SizedBox(height: 16),

          _sectionTitle(theme, '2. Toplanan Veriler / Erhobene Daten'),
          const SizedBox(height: 8),
          _bodyText(theme,
            'Bu uygulama yalnızca aşağıdaki verileri cihazınızda yerel olarak saklar:\n\n'
            '• Favori radyo istasyonları (ID listesi)\n'
            '• Son dinlenen istasyonlar\n'
            '• Uygulama ayarları (ses seviyesi, tema tercihi, otomatik oynatma)\n'
            '• Onboarding tamamlanma durumu\n\n'
            'Bu veriler yalnızca cihazınızda saklanır ve hiçbir sunucuya gönderilmez.\n\n'
            'Diese App speichert ausschließlich folgende Daten lokal auf Ihrem Gerät:\n\n'
            '• Favorisierte Radiosender (ID-Liste)\n'
            '• Zuletzt gehörte Sender\n'
            '• App-Einstellungen (Lautstärke, Thema, Autoplay)\n'
            '• Onboarding-Status\n\n'
            'Diese Daten werden ausschließlich auf Ihrem Gerät gespeichert und '
            'nicht an Server übermittelt.',
          ),
          const SizedBox(height: 16),

          _sectionTitle(theme, '3. Analiz & İzleme / Analyse & Tracking'),
          const SizedBox(height: 8),
          _bodyText(theme,
            'Bu uygulama herhangi bir analiz veya izleme aracı kullanmamaktadır. '
            'Google Analytics, Firebase Analytics, Facebook SDK veya benzeri hiçbir '
            'üçüncü taraf hizmeti entegre edilmemiştir.\n\n'
            'Diese App verwendet keinerlei Analyse- oder Tracking-Tools. Es sind '
            'weder Google Analytics, Firebase Analytics, Facebook SDK noch '
            'vergleichbare Drittanbieterdienste integriert.',
          ),
          const SizedBox(height: 16),

          _sectionTitle(theme, '4. İnternet Erişimi / Internetzugriff'),
          const SizedBox(height: 8),
          _bodyText(theme,
            'Uygulama yalnızca aşağıdaki amaçlarla internet kullanır:\n\n'
            '• Radyo istasyonlarının canlı yayınlarını dinlemek (audio streaming)\n'
            '• İstasyon listesini güncellemek (radio-browser.info API)\n'
            '• İstasyon logolarını yüklemek\n\n'
            'Bu bağlantılar sırasında kişisel veri aktarılmaz.\n\n'
            'Die App nutzt das Internet ausschließlich für:\n\n'
            '• Live-Streaming von Radiosendern\n'
            '• Aktualisierung der Senderliste (radio-browser.info API)\n'
            '• Laden von Senderlogos\n\n'
            'Bei diesen Verbindungen werden keine personenbezogenen Daten übertragen.',
          ),
          const SizedBox(height: 16),

          _sectionTitle(theme, '5. İzinler / Berechtigungen'),
          const SizedBox(height: 8),
          _bodyText(theme,
            '• INTERNET: Radyo yayınlarını dinlemek için\n'
            '• WAKE_LOCK: Arka planda kesintisiz dinleme için\n'
            '• FOREGROUND_SERVICE: Arka plan ses çalma için\n'
            '• POST_NOTIFICATIONS: Oynatma kontrolleri bildirimi için\n\n'
            'Hiçbir izin kişisel veri toplamak amacıyla kullanılmamaktadır.',
          ),
          const SizedBox(height: 16),

          _sectionTitle(theme, '6. DSGVO Hakları / Ihre Rechte nach DSGVO'),
          const SizedBox(height: 8),
          _bodyText(theme,
            'DSGVO (Datenschutz-Grundverordnung) kapsamında aşağıdaki haklara sahipsiniz:\n\n'
            '• Bilgi edinme hakkı (Art. 15 DSGVO)\n'
            '• Düzeltme hakkı (Art. 16 DSGVO)\n'
            '• Silme hakkı (Art. 17 DSGVO)\n'
            '• İşlemeyi kısıtlama hakkı (Art. 18 DSGVO)\n'
            '• Veri taşınabilirliği hakkı (Art. 20 DSGVO)\n'
            '• İtiraz hakkı (Art. 21 DSGVO)\n\n'
            'Tüm yerel verilerinizi Ayarlar > Tüm Verileri Sil seçeneğiyle '
            'cihazınızdan tamamen silebilirsiniz.\n\n'
            'Sie können alle lokalen Daten über Einstellungen > Alle Daten löschen '
            'vollständig von Ihrem Gerät entfernen.',
          ),
          const SizedBox(height: 16),

          _sectionTitle(theme, '7. Çocukların Korunması / Kinder'),
          const SizedBox(height: 8),
          _bodyText(theme,
            'Bu uygulama çocuklardan bilerek kişisel veri toplamaz. '
            'Herhangi bir kişisel veri toplama mekanizması bulunmamaktadır.\n\n'
            'Diese App erhebt wissentlich keine personenbezogenen Daten von Kindern. '
            'Es gibt keinerlei Mechanismen zur Erfassung personenbezogener Daten.',
          ),
          const SizedBox(height: 16),

          _sectionTitle(theme, '8. İletişim / Kontakt'),
          const SizedBox(height: 8),
          _bodyText(theme,
            'Gizlilik politikası ile ilgili sorularınız için:\n'
            'Bei Fragen zum Datenschutz:\n\n'
            'E-Mail: radyotuneli@gmail.com',
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              '© 2025 Radyo Tüneli',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionTitle(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _bodyText(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.85),
          height: 1.5,
        ),
      ),
    );
  }
}
