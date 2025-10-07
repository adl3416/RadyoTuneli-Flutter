import 'package:flutter/material.dart';
import 'src/core/utils/logo_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🎨 Vintage Radio Logo PNG oluşturuluyor...');
  
  // Ana logo dosyası oluştur (512x512)
  await LogoGenerator.generateVintageRadioLogoPNG(
    size: 512.0,
    fileName: 'vintage_radio_logo.png',
  );
  
  // Farklı boyutlarda logolar oluştur
  await LogoGenerator.generateAllIconSizes();
  
  print('✅ Tüm logo dosyaları oluşturuldu!');
  print('📁 Dosyalar: assets/images/ klasöründe');
  
  // Uygulama kapatılır
}