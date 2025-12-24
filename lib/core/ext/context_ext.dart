import 'package:flutter/material.dart';

import '../../shared/specs/color_themed_spec.dart';
import '../../shared/specs/typography_themed_spec.dart';

extension TypographyContextX on BuildContext {
  TypographyThemedSpec get typography =>
      Theme.of(this).extension<TypographyThemedSpec>() ??
      const TypographyThemedSpec();
}

extension ColorSpecX on BuildContext {
  ColorThemedSpec get colors =>
      Theme.of(this).extension<ColorThemedSpec>() ?? ColorThemedSpec.light;
}
