# Play Store Release Notes

Bu dosya, gelecekte Play Store guncellemelerinde sorun yasamamak icin kritik release bilgilerini tutar.

## Uygulama Kimligi

- Application ID: `com.turkradyo.bsr.de.turkradyo`

## Imzalama

- Upload keystore dosyasi: `android/upload-keystore.jks`
- `key.properties` konumu: `android/key.properties`
- Key alias: `upload`

Not:
- Play Store'a yuklenen release `.aab` dosyalari bu upload key ile imzalanmalidir.
- Google Play, son kullaniciya dagitilan nihai paketi kendi app signing key ile tekrar imzalar.

## Play Console Ile Eslesen Upload Key Parmak Izleri

- SHA-1: `C8:D5:7D:35:B4:15:2C:81:D2:B4:50:DF:B3:2B:3F:B0:9C:28:50:30`
- SHA-256: `1A:DA:27:88:D8:9C:AE:E9:1B:A7:C0:CF:AE:12:5B:1E:07:2C:D8:1E:F9:B6:B3:FD:DF:38:B8:7B:32:2F:6E:8C`

Durum:
- Bu fingerprint degerleri Play Console `Upload key certificate` ile eslesiyor.
- Bu eslesme sayesinde mevcut kullanicilar uygulamayi normal sekilde guncelleyebilir.

## Son Hazirlanan Release

- Version name: `2.1.1`
- Version code: `2022`
- AAB cikti yolu: `build/app/outputs/bundle/release/app-release.aab`
- AAB boyutu: yaklasik `66.15 MB`

## Onceki Play Store Surumu

- Play Store'da gorulen onceki surum: `2.0.6`
- Play Store version code: `2017`

## Release Alirken Kontrol Listesi

1. `pubspec.yaml` icinde `versionName` ve `versionCode` degerlerini artir.
2. `android/upload-keystore.jks` dosyasinin yerinde oldugunu kontrol et.
3. `android/key.properties` dosyasinin dogru oldugunu kontrol et.
4. Release bundle uret: `flutter build appbundle --release`
5. Ciktiyi kontrol et: `build/app/outputs/bundle/release/app-release.aab`
6. Play Console `Upload key certificate` fingerprint degerlerinin ayni kaldigini dogrula.

## Onemli Uyari

- `upload-keystore.jks`, `keyAlias`, `storePassword` ve `keyPassword` kaybedilmemelidir.
- Bu bilgiler kaybolursa sonraki guncellemelerde imza problemi yasanabilir.
- En az iki ayri guvenli yedek tutulmasi onerilir.
