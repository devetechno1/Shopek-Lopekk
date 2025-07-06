import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:flutter/material.dart';

import '../presenter/home_presenter.dart';
import 'lang_text.dart';

class PiratedWidget extends StatelessWidget {
  final HomePresenter? homeData;
  const PiratedWidget({Key? key, required this.homeData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        9.0,
        16.0,
        9.0,
        0.0,
      ),
      child: Container(
        height: 140,
        color: Colors.black,
        child: Stack(
          children: [
            Positioned(
                left: 20,
                top: 0,
                child: AnimatedBuilder(
                    animation: homeData!.pirated_logo_animation,
                    builder: (context, child) {
                      return Image.asset(
                        AppImages.piratedSquare,
                        height: homeData!.pirated_logo_animation.value,
                        color: Colors.white,
                      );
                    })),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: AppDimensions.paddingMaxLarge,
                    left: AppDimensions.paddingMaxLarge,
                    right: AppDimensions.paddingMaxLarge),
                child: Text(
                  LangText(context).local.pirated_app,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
