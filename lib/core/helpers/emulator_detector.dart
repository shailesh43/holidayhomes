import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class EmulatorDetector {
  static Future<bool> isEmulator() async {
    try {
      if (!Platform.isAndroid) return false;

      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      final model = androidInfo.model.toLowerCase();
      final product = androidInfo.product.toLowerCase();
      final hardware = androidInfo.hardware.toLowerCase();
      final manufacturer = androidInfo.manufacturer.toLowerCase();
      final fingerprint = androidInfo.fingerprint.toLowerCase();

      // Strong emulator indicators only
      final isGenericEmulator =
          !androidInfo.isPhysicalDevice ||
              hardware.contains('goldfish') ||
              hardware.contains('ranchu') ||
              model.contains('sdk') ||
              model.contains('emulator') ||
              product.contains('sdk') ||
              product.contains('google_sdk') ||
              fingerprint.startsWith('generic');

      // NoxPlayer
      final isNox =
          manufacturer.contains('nox') ||
              model.contains('nox') ||
              product.contains('nox') ||
              hardware.contains('nox');

      // BlueStacks
      final isBlueStacks =
          manufacturer.contains('bluestacks') ||
              model.contains('bluestacks') ||
              product.contains('bluestacks');

      // LDPlayer
      final isLDPlayer =
          manufacturer.contains('ldplayer') ||
              model.contains('ldplayer') ||
              hardware.contains('vbox');

      return isGenericEmulator ||
          isNox ||
          isBlueStacks ||
          isLDPlayer;

    } catch (e) {
      return false;
    }
  }
}