import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/vintage_radio_logo.dart';

class LogoGenerator {
  /// Vintage radio logosunu PNG olarak oluşturur
  static Future<void> generateVintageRadioLogoPNG({
    double size = 512,
    String fileName = 'vintage_radio_logo.png',
  }) async {
    // GlobalKey ile widget referansı
    final GlobalKey globalKey = GlobalKey();
    
    // Widget oluştur
    final widget = RepaintBoundary(
      key: globalKey,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(size * 0.1),
        ),
        child: VintageRadioLogo(
          size: size,
          primaryColor: const Color(0xFF8B5CF6),
          accentColor: const Color(0xFF9333EA),
        ),
      ),
    );

    // WidgetTester olmadan PNG oluştur
    await _createPNGFromWidget(widget, size, fileName);
  }

  static Future<void> _createPNGFromWidget(
    Widget widget, 
    double size, 
    String fileName
  ) async {
    // CustomPainter'ı direkt kullan
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Painter oluştur
    final painter = VintageRadioPainter(
      primaryColor: const Color(0xFF8B5CF6),
      accentColor: const Color(0xFF9333EA),
    );
    
    // Canvas'a çiz
    painter.paint(canvas, Size(size, size));
    
    // Picture oluştur
    final picture = recorder.endRecording();
    
    // Image oluştur
    final image = await picture.toImage(size.toInt(), size.toInt());
    
    // ByteData'ya çevir
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    
    // Dosyaya kaydet
    await _savePNGFile(pngBytes, fileName);
    
    // Memory'yi temizle
    picture.dispose();
  }

  static Future<void> _savePNGFile(Uint8List pngBytes, String fileName) async {
    try {
      // Assets klasörüne kaydet
      final assetsDir = Directory('assets/images');
      if (!await assetsDir.exists()) {
        await assetsDir.create(recursive: true);
      }
      
      final file = File('assets/images/$fileName');
      await file.writeAsBytes(pngBytes);
      
      print('✅ Logo PNG dosyası oluşturuldu: ${file.path}');
    } catch (e) {
      print('❌ PNG dosyası oluşturulurken hata: $e');
    }
  }

  /// Farklı boyutlarda icon'lar oluştur
  static Future<void> generateAllIconSizes() async {
    final sizes = [
      {'size': 192.0, 'name': 'vintage_radio_logo_192.png'},
      {'size': 512.0, 'name': 'vintage_radio_logo_512.png'},
      {'size': 1024.0, 'name': 'vintage_radio_logo_1024.png'},
    ];

    for (final sizeInfo in sizes) {
      await generateVintageRadioLogoPNG(
        size: sizeInfo['size'] as double,
        fileName: sizeInfo['name'] as String,
      );
    }
  }
}