import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

///
/// 系统设备信息相关工具
///

/// ios会返回null,不会抛出异常
const _androidIdPlugin = AndroidId();

Future<String?> getAndroidId() => _androidIdPlugin.getId();

/// UA
Future<String> getUserAgent() async {
  final deviceInfo = DeviceInfoPlugin();
  final packageInfo = await PackageInfo.fromPlatform();

  String platform;
  String model;
  String systemVersion;

  if (Platform.isAndroid) {
    final android = await deviceInfo.androidInfo;
    platform = 'Android';
    model = android.data['model'] ?? '';
    systemVersion = android.data['version.release'] ?? '';
  } else if (Platform.isIOS) {
    final ios = await deviceInfo.iosInfo;
    platform = 'iOS';
    model = ios.utsname.machine;
    systemVersion = ios.systemVersion;
  } else if (Platform.isMacOS) {
    final macOs = await deviceInfo.macOsInfo;
    platform = 'MacOS';
    model = macOs.modelName;
    systemVersion = macOs.kernelVersion;
  } else {
    platform = Platform.operatingSystem;
    model = '';
    systemVersion = '';
  }

  final userAgent =
      'HahaHub/${packageInfo.version} ($platform $systemVersion; $model)';

  return userAgent;
}

///
/// 获取系统版本
///
Future<String> getPrettyOS() async {
  final di = DeviceInfoPlugin();

  if (Platform.isIOS) {
    final info = await di.iosInfo;
    final name = (info.systemName).trim(); // 通常为 "iOS"
    final ver = (info.systemVersion).trim(); // 例如 "18.6.2"
    return ver.isEmpty ? name : '$name $ver';
  }

  if (Platform.isAndroid) {
    final info = await di.androidInfo;
    // version.release: "12", "13", "14"...，有些机型可能带小版本，如 "12", "12L", "14"
    final release = (info.version.release).trim();
    final pretty = release.isEmpty ? 'Android' : 'Android $release';
    return pretty;
  }

  // 其它平台（web/desktop/…）可按需扩展；这里简单兜底
  return 'unknown';
}

/// 获取系统CPU架构
Future<String> getSupportedCpuArchs() async {
  final deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    // 新版 device_info_plus，字段在 data Map 里
    final abis =
        (androidInfo.data['supportedAbis'] as List?)?.cast<String>() ?? [];
    return abis.join(',');
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    // iOS 没有 supportedAbis，只有设备型号
    // 返回设备型号
    return iosInfo.utsname.machine;
  } else if (Platform.isMacOS) {
    final macInfo = await deviceInfo.macOsInfo;
    return macInfo.arch;
  }

  return '';
}

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
