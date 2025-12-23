import 'package:flutter/material.dart';
import 'package:ink_self_projects/core/bootstrap/bootstrap_runner.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(BootstrapRunner.preserve());
}
