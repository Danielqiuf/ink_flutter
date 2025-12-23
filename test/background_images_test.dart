import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ink_self_projects/__assets__/resources.dart';

void main() {
  test('background_images assets test', () {
    expect(File(BackgroundImages.bgInviteHome).existsSync(), isTrue);
    expect(File(BackgroundImages.bgQuestCard).existsSync(), isTrue);
    expect(File(BackgroundImages.bgQuestInvite).existsSync(), isTrue);
  });
}
