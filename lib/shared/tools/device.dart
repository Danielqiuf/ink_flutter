import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<dynamic> getDeviceInfo() {
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    return deviceInfoPlugin.androidInfo;
  }
  return deviceInfoPlugin.iosInfo;
}

Future<PackageInfo> getVersionInfo() {
  return PackageInfo.fromPlatform();
}
