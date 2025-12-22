import 'dart:io';

import 'package:flutter/cupertino.dart';

/// 获取OS
final String os = Platform.operatingSystem;

final mediaData = MediaQueryData.fromView(
  WidgetsBinding.instance.platformDispatcher.views.first,
);

const String kEnv = String.fromEnvironment(
  'ENVIRONMENT',
  defaultValue: 'development',
);

const String kEnvMode = String.fromEnvironment(
  'ENV_MODE',
  defaultValue: 'test',
);

///
/// 是否为release模式
/// 若在production环境下使用test功能，如显示某些debug模块，ENV_MODE设置为test,则kReleaseMode=false
///
bool isReleaseMode = kEnvMode == "release";

/// 是否为开发环境
const bool isDev = kEnv == 'development';

const bool isProd = kEnv == 'production';
