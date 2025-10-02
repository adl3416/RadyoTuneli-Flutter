# Android Auto Test Checklist

## 📱 Uygulamanızın Android Auto'da Görünmesi İçin:

### ✅ Yapılan Değişiklikler:
1. AndroidManifest.xml'e Android Auto permissions eklendi
2. automotive_app_desc.xml dosyası güncellendi  
3. CAR_LAUNCHER intent filter eklendi
4. MediaBrowserService için CAR_MODE intent filter eklendi
5. strings.xml ile uygulama isimleri tanımlandı

### 🔧 Test Etme Adımları:

1. **Telefonu Hazırlayın:**
   - Developer Options → USB Debugging ON
   - Google Play'den "Android Auto" uygulaması indirin

2. **Phone Screen Mode ile Test:**
   - Android Auto uygulamasını açın
   - "Start Driving" butonuna basın
   - Media apps bölümünde "Radyo Tüneli" arayın

3. **Araç ile Test:**
   - USB ile telefonu araca bağlayın
   - Android Auto başlatın
   - Media apps → "Radyo Tüneli"

### ⚠️ Troubleshooting:

**Eğer uygulama görünmüyorsa:**

1. **Android Auto Cache Temizle:**
   - Settings → Apps → Android Auto → Storage → Clear Cache
   - Android Auto uygulamasını kapatıp tekrar açın

2. **Developer Mode:**
   - Android Auto → Settings → About → Version (10 kez tap)
   - Developer settings → Unknown sources ON

3. **Phone Screen Mode:**
   - Android Auto → Settings → Connected cars → Phone screen mode

### 📋 Final Kontrol:
- Uygulama açılıyor mu? ✓
- Radyo istasyonları browsable mı? ✓  
- Play/Pause çalışıyor mu? ✓
- Metadata görünüyor mu? ✓

### 🚀 Yayınlamadan Önce:
- Release APK build edin
- Google Play Console'da Android Auto section'ı doldurun
- Car app quality guidelines'ı kontrol edin