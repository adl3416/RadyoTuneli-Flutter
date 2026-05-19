import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

/// Google Play In-App Update kontrolü.
/// Sadece Android'de çalışır; iOS veya debug build'de sessizce atlanır.
class UpdateService {
  static Future<void> checkForUpdate(BuildContext context) async {
    if (!Platform.isAndroid) return;

    try {
      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability != UpdateAvailability.updateAvailable) {
        return;
      }

      if (updateInfo.immediateUpdateAllowed) {
        // Zorunlu güncelleme: uygulama kapanmadan önce güncellenmeli
        await InAppUpdate.performImmediateUpdate();
      } else if (updateInfo.flexibleUpdateAllowed) {
        // Esnek güncelleme: arka planda indir, hazır olunca bildir
        await InAppUpdate.startFlexibleUpdate();
        // İndirme bitti mi kontrol et ve tamamla
        await InAppUpdate.completeFlexibleUpdate();
      }
    } catch (_) {
      // Güncelleme kontrolü uygulamayı çökertmemeli
    }
  }
}
