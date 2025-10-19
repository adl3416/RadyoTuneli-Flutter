import 'dart:convert';
import 'dart:io';

String normalizeName(String name) {
  var n = name.toLowerCase().trim();
  n = n.replaceAll(RegExp(r'^[\s\-_\.]+|[\s\-_\.]+$'), '');
  n = n.replaceAll(RegExp(r'\s*(radyo|radio|fm|am)\s*'), ' ');
  n = n.replaceAll(RegExp(r'\s*(türkiye|turkey|tr)\s*'), ' ');
  n = n.replaceAll(RegExp(r'\s*\d+[\.,]?\d*\s*(mhz|khz|fm|am)\s*'), ' ');
  n = n.replaceAll(RegExp(r'\s+'), ' ').trim();
  n = n.replaceAll(RegExp(r'[^\w\s]'), '');
  return n;
}

void main() async {
  final file = File('assets/data/TR.json');
  final jsonStr = await file.readAsString();
  final List<dynamic> stations = json.decode(jsonStr);

  final Map<String, List<Map<String, dynamic>>> dups = {};

  for (final station in stations) {
    final name = station['name'] ?? '';
    final norm = normalizeName(name);
    dups.putIfAbsent(norm, () => []).add(station);
  }

  print('Birden fazla olan istasyonlar:');
  dups.forEach((norm, list) {
    if (list.length > 1) {
      print('\n--- $norm ---');
      for (final s in list) {
        print('  - ${s['name']} | url: ${s['url']}');
      }
    }
  });
}
