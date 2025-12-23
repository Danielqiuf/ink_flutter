import 'dart:io';

import 'package:flutter/cupertino.dart';

///
/// 系统变量工具
///

/// 获取OS
final String os = Platform.operatingSystem;

final mediaData = MediaQueryData.fromView(
  WidgetsBinding.instance.platformDispatcher.views.first,
);

// 编译环境，只有development和production
const String kEnv = String.fromEnvironment(
  'ENVIRONMENT',
  defaultValue: 'development',
);

// 接口环境, dev/prod
const String kFlavorEnv = String.fromEnvironment(
  "FLAVOR_ENV",
  defaultValue: "dev",
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
