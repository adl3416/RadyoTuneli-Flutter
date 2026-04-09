import 'package:flutter/material.dart';

class ImpressumScreen extends StatelessWidget {
  const ImpressumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impressum'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionTitle(theme, 'Angaben gemäß § 5 TMG'),
          const SizedBox(height: 8),
          _bodyText(theme, 'Radyo Tüneli'),
          _bodyText(theme, 'com.turkradyo.bsr.de'),
          const SizedBox(height: 16),
          _sectionTitle(theme, 'Kontakt / İletişim'),
          const SizedBox(height: 8),
          _bodyText(theme, 'E-Mail: radyotuneli@gmail.com'),
          const SizedBox(height: 24),
          _sectionTitle(theme, 'Haftungsausschluss / Sorumluluk Reddi'),
          const SizedBox(height: 8),
          _bodyText(theme,
            'Bu uygulama yalnızca radyo istasyonlarının internet üzerinden '
            'yayınlarına erişim sağlamaktadır. Yayın içeriklerinden ilgili '
            'radyo istasyonları sorumludur.\n\n'
            'Diese App bietet lediglich Zugang zu Radiosendern, die ihre '
            'Inhalte über das Internet streamen. Für die Inhalte der Sender '
            'sind die jeweiligen Rundfunkanstalten verantwortlich.',
          ),
          const SizedBox(height: 24),
          _sectionTitle(theme, 'Urheberrecht / Telif Hakkı'),
          const SizedBox(height: 8),
          _bodyText(theme,
            'Die durch den App-Betreiber erstellten Inhalte und Werke unterliegen '
            'dem deutschen Urheberrecht. Die Vervielfältigung, Bearbeitung, Verbreitung '
            'und jede Art der Verwertung außerhalb der Grenzen des Urheberrechtes '
            'bedürfen der schriftlichen Zustimmung des Erstellers.\n\n'
            'Uygulama geliştiricisi tarafından oluşturulan içerik ve eserler Alman '
            'telif hakkı yasasına tabidir.',
          ),
          const SizedBox(height: 24),
          _sectionTitle(theme, 'Streitschlichtung'),
          const SizedBox(height: 8),
          _bodyText(theme,
            'Die Europäische Kommission stellt eine Plattform zur '
            'Online-Streitbeilegung (OS) bereit.\n\n'
            'Wir sind nicht bereit oder verpflichtet, an Streitbeilegungsverfahren '
            'vor einer Verbraucherschlichtungsstelle teilzunehmen.',
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              '© 2025 Radyo Tüneli. Alle Rechte vorbehalten.',
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
