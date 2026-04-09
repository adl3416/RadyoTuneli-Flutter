import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutzungsbedingungen'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionTitle(theme, 'Kullanım Koşulları / Nutzungsbedingungen'),
          const SizedBox(height: 8),
          _bodyText(theme,
            'Son güncelleme / Letzte Aktualisierung: 09.04.2026',
          ),
          const SizedBox(height: 16),

          _sectionTitle(theme, '1. Genel / Allgemeines'),
          const SizedBox(height: 8),
          _bodyText(theme,
            'Radyo Tüneli, Türk radyo istasyonlarının internet üzerinden '
            'canlı yayınlarını dinlemenizi sağlayan ücretsiz bir uygulamadır. '
            'Uygulamayı kullanarak bu koşulları kabul etmiş sayılırsınız.\n\n'
            'Radyo Tüneli ist eine kostenlose App, die Ihnen ermöglicht, '
            'türkische Radiosender live über das Internet zu hören. '
            'Mit der Nutzung der App akzeptieren Sie diese Bedingungen.',
          ),
          const SizedBox(height: 16),

          _sectionTitle(theme, '2. Hizmet Kapsamı / Leistungsumfang'),
          const SizedBox(height: 8),
          _bodyText(theme,
            '• Uygulama radyo istasyonlarının internet yayınlarını sunar\n'
            '• Yayın içerikleri ilgili radyo istasyonlarına aittir\n'
            '• Uygulama geliştiricisi yayın içeriklerinden sorumlu değildir\n'
            '• Tüm yayınlar üçüncü taraf radyo istasyonları tarafından sağlanır\n\n'
            '• Die App bietet Zugang zu Internet-Radiostreams\n'
            '• Sendeinhalte gehören den jeweiligen Radiosendern\n'
            '• Der App-Entwickler ist nicht für Sendeinhalte verantwortlich\n'
            '• Alle Streams werden von Drittanbieter-Radiosendern bereitgestellt',
          ),
          const SizedBox(height: 16),

          _sectionTitle(theme, '3. Kullanım Şartları / Nutzungsbedingungen'),
          const SizedBox(height: 8),
          _bodyText(theme,
            '• Uygulamayı yalnızca kişisel kullanım için kullanabilirsiniz\n'
            '• Yayınları kaydetmek veya yeniden dağıtmak yasaktır\n'
            '• Uygulamayı tersine mühendislik yapmak yasaktır\n'
            '• İnternet bağlantısı gereklidir\n\n'
            '• Die App darf nur für den persönlichen Gebrauch genutzt werden\n'
            '• Das Aufzeichnen oder Weiterverbreiten von Streams ist untersagt\n'
            '• Reverse Engineering der App ist untersagt\n'
            '• Eine Internetverbindung ist erforderlich',
          ),
          const SizedBox(height: 16),

          _sectionTitle(theme, '4. Sorumluluk Sınırlaması / Haftungsbeschränkung'),
          const SizedBox(height: 8),
          _bodyText(theme,
            'Uygulama "olduğu gibi" (as-is) sunulmaktadır. Yayınların '
            'kesintisiz veya hatasız olacağının garantisi verilmez. '
            'İstasyon yayın kesintileri ilgili istasyonun sorumluluğundadır.\n\n'
            'Die App wird „wie besehen" (as-is) bereitgestellt. Es wird keine '
            'Garantie für unterbrechungsfreies oder fehlerfreies Streaming '
            'übernommen. Sendeunterbrechungen liegen in der Verantwortung '
            'der jeweiligen Sender.',
          ),
          const SizedBox(height: 16),

          _sectionTitle(theme, '5. Ücretler / Kosten'),
          const SizedBox(height: 8),
          _bodyText(theme,
            'Uygulama ücretsizdir. İnternet veri kullanımı için mobil operatör '
            'ücretleri geçerli olabilir.\n\n'
            'Die App ist kostenlos. Es können Mobilfunkgebühren für die '
            'Internetdatennutzung anfallen.',
          ),
          const SizedBox(height: 16),

          _sectionTitle(theme, '6. Değişiklikler / Änderungen'),
          const SizedBox(height: 8),
          _bodyText(theme,
            'Bu kullanım koşulları önceden bildirimde bulunmaksızın değiştirilebilir. '
            'Güncel koşullar her zaman uygulama içinden erişilebilir.\n\n'
            'Diese Nutzungsbedingungen können ohne vorherige Ankündigung geändert '
            'werden. Die aktuellen Bedingungen sind jederzeit in der App einsehbar.',
          ),
          const SizedBox(height: 16),

          _sectionTitle(theme, '7. Geçerli Hukuk / Anwendbares Recht'),
          const SizedBox(height: 8),
          _bodyText(theme,
            'Bu koşullar Almanya Federal Cumhuriyeti yasalarına tabidir.\n\n'
            'Es gilt das Recht der Bundesrepublik Deutschland.',
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
