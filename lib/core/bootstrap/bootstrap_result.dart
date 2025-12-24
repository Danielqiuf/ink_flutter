import 'package:hive/hive.dart';

class BootstrapResult {
  final String initialLocation;
  final String localeCode;
  final Box<dynamic> authBox;
  BootstrapResult({
    required this.initialLocation,
    required this.localeCode,
    required this.authBox,
  });
}
