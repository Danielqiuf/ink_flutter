import 'package:flutter/material.dart';
import 'package:ink_self_projects/__assets.g__/resources.dart';
import 'package:ink_self_projects/__locale.g__/translations.g.dart';
import 'package:ink_self_projects/core/ext/sizing_ext.dart';
import 'package:ink_self_projects/shared/specs/typography_themed_spec.dart';
import 'package:ink_self_projects/shared/tools/log.dart';
import 'package:ink_self_projects/shared/ui/button/scale_alpha_button.dart';
import 'package:ink_self_projects/shared/ui/images/apex_image.dart';
import 'package:ink_self_projects/shared/ui/ripple/tap_ripple_tone.dart';
import 'package:ink_self_projects/shared/ui/text/typo_span.dart';
import 'package:ink_self_projects/shared/ui/text/typos.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[500],
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Typos(context.t.page.home.title, token: TypographyToken.xl),
            SizedBox(height: 12.dp),
            TypoSpan(
              token: TypographyToken.xs,
              defaultColor: Colors.red,
              linkColor: Colors.black,
              defaultLinkDecoration: TextDecoration.none,
              segments: [
                const TypoSpanSegment("阅读并同意"),
                TypoSpanSegment(
                  "用户协议",
                  onTap: () {
                    "click... 用户协议".lw();
                  },
                ),
                const TypoSpanSegment('与'),
                TypoSpanSegment(
                  '《隐私政策》',
                  onTap: () {
                    "click... 隐私政策".lw();
                  },
                ),
              ],
            ),
            SizedBox(height: 12.dp),

            TapImageRipple(
              width: 160,
              height: 90,
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              image: ApexImage.asset(BackgroundImages.bgBgInviteHome),
            ),
            SizedBox(height: 50.dp),
            ScaleAlphaButton(
              onTap: () {},

              child: Container(
                width: 300,
                height: 200,
                color: Colors.yellow,
                child: Text('点击'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
