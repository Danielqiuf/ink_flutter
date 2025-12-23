import 'package:flutter/material.dart';
import 'package:ink_self_projects/__assets__/resources.dart';
import 'package:ink_self_projects/__locale__/translations.g.dart';
import 'package:ink_self_projects/core/ext/sizing_ext.dart';
import 'package:ink_self_projects/shared/ui/button/scale_alpha_button.dart';
import 'package:ink_self_projects/shared/ui/images/apex_image.dart';
import 'package:ink_self_projects/shared/ui/ripple/tap_ripple_tone.dart';

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
            Text(
              context.t.page.home.title,
              style: const TextStyle(fontSize: 30, color: Colors.red),
            ),
            SizedBox(height: 12.dp),
            TapImageRipple(
              width: 160,
              height: 90,
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              image: ApexImage.asset(BackgroundImages.bgInviteHome),
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
