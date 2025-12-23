library base.router;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ink_self_projects/app/router/styled_route_data.dart';
import 'package:ink_self_projects/app/screens/home/presentation/detail_screen.dart';
import 'package:ink_self_projects/shared/ui/system/system_status_bar_theme.dart';

import '../screens/home/home_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../shell/shell_scaffold.dart';

part 'parts/home_parts.dart';
part 'parts/login_parts.dart';
part 'parts/profile_parts.dart';
part 'parts/shell_parts.dart';
part 'router.g.dart';
