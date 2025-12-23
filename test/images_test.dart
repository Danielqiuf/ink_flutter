import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ink_self_projects/__$assets__/resources.dart';

void main() {
  test('images assets test', () {
    expect(File(Images.bgInviteHome).existsSync(), isTrue);
    expect(File(Images.bgQuestCard).existsSync(), isTrue);
    expect(File(Images.bgQuestInvite).existsSync(), isTrue);
  });
}
