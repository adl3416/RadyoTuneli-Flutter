import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';

enum UpdateActionType {
  none,
  inApp,
  playStoreFallback,
}

class UpdateStatus {
  const UpdateStatus({
    required this.isSupported,
    required this.isUpdateAvailable,
    required this.checkFailed,
    required this.actionType,
    required this.availableVersionCode,
    required this.stalenessDays,
    required this.priority,
    required this.isInProgress,
    required this.isDownloaded,
    required this.message,
  });

  final bool isSupported;
  final bool isUpdateAvailable;
  final bool checkFailed;
  final UpdateActionType actionType;
  final int? availableVersionCode;
  final int? stalenessDays;
  final int priority;
  final bool isInProgress;
  final bool isDownloaded;
  final String message;

  bool get canTriggerUpdate => actionType != UpdateActionType.none;
}

final appUpdateStatusProvider = FutureProvider<UpdateStatus>((ref) async {
  return UpdateService.getStatus();
});

class UpdateService {
  static Future<UpdateStatus> getStatus() async {
    if (!Platform.isAndroid) {
      return const UpdateStatus(
        isSupported: false,
        isUpdateAvailable: false,
        checkFailed: false,
        actionType: UpdateActionType.none,
        availableVersionCode: null,
        stalenessDays: null,
        priority: 0,
        isInProgress: false,
        isDownloaded: false,
        message: 'Bu ozellik yalnizca Android ve Google Play surumunde calisir.',
      );
    }

    try {
      final info = await InAppUpdate.checkForUpdate();
      final isAvailable =
          info.updateAvailability == UpdateAvailability.updateAvailable ||
          info.updateAvailability ==
              UpdateAvailability.developerTriggeredUpdateInProgress;
      final isDownloaded = info.installStatus == InstallStatus.downloaded;
      final isInProgress =
          info.updateAvailability ==
          UpdateAvailability.developerTriggeredUpdateInProgress;

      if (!isAvailable) {
        return const UpdateStatus(
          isSupported: true,
          isUpdateAvailable: false,
          checkFailed: false,
          actionType: UpdateActionType.none,
          availableVersionCode: null,
          stalenessDays: null,
          priority: 0,
          isInProgress: false,
          isDownloaded: false,
          message: 'Uygulama guncel gorunuyor.',
        );
      }

      final actionType =
          (info.immediateUpdateAllowed || info.flexibleUpdateAllowed || isDownloaded)
          ? UpdateActionType.inApp
          : UpdateActionType.playStoreFallback;

      return UpdateStatus(
        isSupported: true,
        isUpdateAvailable: true,
        checkFailed: false,
        actionType: actionType,
        availableVersionCode: info.availableVersionCode,
        stalenessDays: info.clientVersionStalenessDays,
        priority: info.updatePriority,
        isInProgress: isInProgress,
        isDownloaded: isDownloaded,
        message: isDownloaded
            ? 'Guncelleme indirildi, kuruluma hazir.'
            : (actionType == UpdateActionType.inApp
                ? 'Yeni bir surum bulundu. Ayarlar icinden guncelleyebilirsiniz.'
                : 'Yeni bir surum bulundu. Play Store sayfasi uzerinden guncelleyin.'),
      );
    } catch (_) {
      return const UpdateStatus(
        isSupported: true,
        isUpdateAvailable: false,
        checkFailed: true,
        actionType: UpdateActionType.none,
        availableVersionCode: null,
        stalenessDays: null,
        priority: 0,
        isInProgress: false,
        isDownloaded: false,
        message: 'Guncelleme durumu su an alinamadi. Google Play daha sonra tekrar kontrol edilecek.',
      );
    }
  }

  static Future<bool> startUpdate() async {
    if (!Platform.isAndroid) return false;

    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.installStatus == InstallStatus.downloaded) {
        await InAppUpdate.completeFlexibleUpdate();
        return true;
      }

      if (info.immediateUpdateAllowed) {
        final result = await InAppUpdate.performImmediateUpdate();
        return result == AppUpdateResult.success;
      }

      if (info.flexibleUpdateAllowed) {
        final result = await InAppUpdate.startFlexibleUpdate();
        if (result != AppUpdateResult.success) {
          return false;
        }
        await InAppUpdate.completeFlexibleUpdate();
        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }
}
