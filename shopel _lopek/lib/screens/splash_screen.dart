import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: DeviceInfo(context).height,
        height: DeviceInfo(context).height,
        color: Theme.of(context).primaryColor,
        child: InkWell(
          child: Stack(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Hero(
                  tag: "backgroundImageInSplash",
                  child: Container(
                    child: Image.asset(
                        AppImages.splash_loginRegistrationBackgroundImage),
                  ),
                ),
                radius: 140.0,
              ),
              Positioned.fill(
                top: DeviceInfo(context).height! / 2 - 72,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSupSmall,
                      ),
                      child: Hero(
                        tag: "splashscreenImage",
                        child: Container(
                          height: 100,
                          width: 100,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: MyTheme.white,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusSmall,
                            ),
                          ),
                          child: Image.asset(
                            AppImages.splashScreenLogo,
                            filterQuality: FilterQuality.low,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingSmallExtra),
                      child: Text(
                        AppConfig.appNameOnAppLang(context),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      "V ${AppConfig.version}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
