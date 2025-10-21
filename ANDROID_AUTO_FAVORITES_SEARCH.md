# Android Auto - Favoriler, Arama & Son Dinlenenler 🚗❤️🔍🕐

## ✅ Eklenen Özellikler

### 1. 🕐 Son Dinlenenler Kategorisi
- Android Auto'da **"Son Dinlenenler"** kategorisi eklendi
- İlk kategori olarak görünür (en üstte)
- En son dinlenen 20 radyo gösterilir
- Her radyo çaldığında otomatik olarak en üste eklenir
- Offline çalışır (SharedPreferences ile kaydedilir)

### 2. ❤️ Favoriler Kategorisi
- Android Auto'da **"Favoriler"** kategorisi eklendi
- İkinci kategori olarak görünür
- Favorilere eklenen radyolar otomatik olarak bu kategoride görünür
- Favori radyolar ❤️ ikonuyla işaretlenir

### 3. 🔍 Arama Özelliği
- Android Auto'da radyo arama desteği eklendi
- **Sesli arama** desteklenir
- İsim, sanatçı ve tür bazında arama yapılır
- En fazla 20 sonuç döndürülür

### 4. 📱 Favori Ekleme/Çıkarma
**Önemli:** Android Auto protokolü, araç ekranından favori ekleme/çıkarma özelliğini desteklemez. Bu kısıtlama Google tarafından konulmuştur.

**Çözüm:**
- Favorilere ekleme/çıkarma **telefon uygulamasından** yapılır
- Değişiklikler **anında** Android Auto'ya yansır
- Favori radyolar ❤️ işaretiyle görünür

## 📊 Kategori Yapısı

```
🚗 Android Auto Ana Menü
├── 🕐 Son Dinlenenler (Yakın zamanda dinlediğiniz radyolar - max 20)
├── ❤️ Favoriler (Favori radyolarınız)
├── ⭐ Popüler (En çok dinlenen 50 radyo)
├── 📻 Tüm İstasyonlar (Tüm radyo kanalları)
├── 📰 Haber (Güncel haberler)
├── 🎵 Müzik (Pop, Rock & Eğlence)
├── 🎻 Türkü (Halk Müziği & Türküler)
├── ⚽ Spor (Spor yayınları)
└── 🕌 Dini (Dini içerikler)
```

## 🎯 Kullanım Senaryoları

### Senaryo 1: Son Dinlenenler
1. **Arabada:** Bir radyoyu çal (örn: TRT Radyo 1)
2. Android Auto'dan çık
3. Tekrar Android Auto'ya bağlan
4. "🕐 Son Dinlenenler" kategorisine gir
5. TRT Radyo 1'i en üstte gör
6. Hızlıca tekrar çal

### Senaryo 2: Favori Ekleme
1. **Telefonda:** Radyo Tüneli uygulamasını aç
2. Bir radyoyu favorilere ekle (❤️ ikonu)
3. **Arabada:** Android Auto'ya bağlan
4. "❤️ Favoriler" kategorisinde radyoyu gör
5. Favorilerdeki radyoyu çal

### Senaryo 3: Sesli Arama
1. **Arabada:** Android Auto'da mikrofon butonuna bas
2. "Radyo Tüneli'nde TRT 1 ara" de
3. Arama sonuçları görüntülenir
4. İstediğin radyoyu seç ve dinle

### Senaryo 4: Manuel Arama
1. **Arabada:** Android Auto'da arama ikonuna dokun
2. Radyo ismini yaz (örn: "Kral FM")
3. Sonuçlardan seçim yap
4. Radyoyu dinle

## 🔧 Teknik Detaylar

### Son Dinlenenler Yönetimi
- **Depolama:** SharedPreferences (`recently_played_stations`)
- **Sıralama:** LIFO (Last In First Out - En son çalınan en üstte)
- **Limit:** 20 radyo
- **Güncelleme:** Her radyo çaldığında otomatik
- **Persistance:** Offline çalışır

### Favori Yönetimi
- **Depolama:** SharedPreferences (`favorite_stations`)
- **Senkronizasyon:** Otomatik
- **Güncellenme:** Anlık
- **Limit:** Sınırsız

### Arama Algoritması
```dart
// Arama kriterleri:
- Radyo ismi
- Sanatçı/Tür
- Kategori bilgisi

// Sonuç limiti: 20 radyo
// Sıralama: Relevans bazlı
```

### Android Auto Bildirimleri
```dart
notifyChildrenChanged(AudioService.browsableRootId); // Ana menüyü güncelle
notifyChildrenChanged('son_dinlenenler'); // Son dinlenenleri güncelle
notifyChildrenChanged('favoriler'); // Favoriler kategorisini güncelle
```

## 📝 Kod Örnekleri

### Son Dinlenenlere Ekle
```dart
// Otomatik eklenir (playStation çağrıldığında)
await audioHandler.playStation(
  streamUrl, 
  title, 
  artist, 
  artUri, 
  stationId: stationId
);

// Manuel kontrol
final recentList = audioHandler._recentlyPlayed;
print('Son dinlenen ${recentList.length} radyo');
```

### Favori Toggle
```dart
// Favoriye ekle/çıkar
await audioHandler.toggleFavorite(stationId);

// Favori durumunu kontrol et
bool isFav = audioHandler.isFavorite(stationId);
```

### Arama
```dart
// Arama yap
final results = await audioHandler.search('TRT Radyo 1');

// Sonuç: List<MediaItem>
for (var station in results) {
  print('${station.title} - ${station.artist}');
}
```

## 🎨 UI/UX Tasarımı

### Son Dinlenenler Gösterimi
- 🕐 ikonu: Son Dinlenenler kategorisi
- En son çalınan en üstte
- Maksimum 20 radyo gösterilir
- Sıralama: Zaman bazlı (LIFO)

### Favori Gösterimi
- ❤️ ikonu: Favori radyolar
- 🔴 ikonu: Normal radyolar
- Artist bilgisi: "❤️ CANLI • TRT Radyo 1"

### Kategoriler
- Grid görünüm (2x2)
- Büyük ikonlar
- Alt başlık: İstasyon sayısı
- Açıklama metni

## 🐛 Bilinen Kısıtlamalar

1. **Android Auto Favorileri:**
   - Araç ekranından favori eklenemez
   - Google'ın Android Auto protokol kısıtlaması
   - Çözüm: Telefon uygulamasından ekle

2. **Son Dinlenenler:**
   - Maksimum 20 radyo
   - Eski kayıtlar otomatik silinir
   - Sadece tamamlanan çalmalar kaydedilir

3. **Arama Limiti:**
   - Maksimum 20 sonuç
   - Performance optimizasyonu için

4. **Kategori Güncellemesi:**
   - Manuel refresh gerekebilir
   - Android Auto'yu yeniden başlat

## 🚀 Gelecek Geliştirmeler

- [x] Son dinlenenler kategorisi ✅
- [ ] Önerilen radyolar (AI bazlı)
- [ ] Yakın radyolar (lokasyon bazlı)
- [ ] Playlist desteği
- [ ] Offline cache
- [ ] İstatistikler (en çok dinlenen, dinleme süresi)

## 📱 Test Senaryoları

### Test 1: Son Dinlenenler
1. ✅ Radyo çalınca son dinlenenlere eklendi mi?
2. ✅ En son çalınan en üstte mi?
3. ✅ 21. radyo eklenince ilk radyo silindi mi?
4. ✅ Uygulama kapatılıp açılınca kayıtlar kaldı mı?

### Test 2: Favori Ekleme
1. ✅ Telefonda radyo favorilere eklendi mi?
2. ✅ Android Auto'da favoriler kategorisi göründü mü?
3. ✅ Favori radyo ❤️ ile işaretlendi mi?

### Test 3: Arama
1. ✅ Sesli arama çalışıyor mu?
2. ✅ Manuel arama çalışıyor mu?
3. ✅ Sonuçlar doğru mu?

### Test 4: Senkronizasyon
1. ✅ Telefonda favori çıkarıldı mı?
2. ✅ Android Auto'da da çıktı mı?
3. ✅ Kategori güncelendi mi?

### Test 5: Son Dinlenenler Persistance
1. ✅ Radyo çalındı mı?
2. ✅ Uygulama kapatıldı mı?
3. ✅ Tekrar açıldığında son dinlenenler hala orada mı?
4. ✅ Android Auto'da son dinlenenler kategorisi dolu mu?

---

**Not:** Bu özellikler Android Auto protokolüne uygun olarak geliştirilmiştir. Android Auto'nun bazı kısıtlamaları (örn: custom action desteği olmaması) nedeniyle favori ekleme telefon uygulamasından yapılmaktadır.
