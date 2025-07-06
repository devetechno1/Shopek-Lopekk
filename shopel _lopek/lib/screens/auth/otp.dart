import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/input_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/auth_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/num_ex.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';

import '../../main.dart';

class Otp extends StatefulWidget {
  final String? title;
  final bool fromRegistration;
  const Otp({Key? key, this.title, required this.fromRegistration})
      : super(key: key);

  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  //controllers
  final TextEditingController _verificationCodeController =
      TextEditingController();
  CountdownController countdownController =
      CountdownController(autoStart: true);
  bool canResend = false;
  @override
  void initState() {
    //on Splash Screen hide statusbar
    if (!widget.fromRegistration) AuthRepository().getResendCodeResponse();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  void dispose() {
    countdownController.pause();
    _verificationCodeController.dispose();
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onTapResend() async {
    setState(() {
      canResend = false;
    });
    final resendCodeResponse = await AuthRepository().getResendCodeResponse();

    if (resendCodeResponse.result == false) {
      ToastComponent.showDialog(
        resendCodeResponse.message!,
      );
    } else {
      ToastComponent.showDialog(
        resendCodeResponse.message!,
      );
    }
  }

  Future<void> onPressConfirm() async {
    final code = _verificationCodeController.text.toString();

    if (code == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.enter_verification_code,
      );
      return;
    }

    final confirmCodeResponse =
        await AuthRepository().getConfirmCodeResponse(code);

    if (!(confirmCodeResponse.result)) {
      ToastComponent.showDialog(
        confirmCodeResponse.message,
      );
    } else {
      if (SystemConfig.systemUser != null) {
        SystemConfig.systemUser!.emailVerified = true;
      }
      if (widget.fromRegistration) {
        context.go("/");
      } else {
        context.pop();
      }
      ToastComponent.showDialog(confirmCodeResponse.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double _screen_width = MediaQuery.sizeOf(context).width;
    final double _screen_height = MediaQuery.sizeOf(context).height;
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(
              color: MyTheme.soft_accent_color,
              width: _screen_width,
              height: 200,
              child: Image.asset(AppImages.splashLoginRegisterationBackground),
            ),
            Container(
              width: double.infinity,
              child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.title != null)
                    Text(
                      widget.title!,
                      style: const TextStyle(
                          fontSize: 25, color: MyTheme.font_grey),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0, bottom: 15),
                    child: Container(
                      width: 75,
                      height: 75,
                      child: Image.asset(AppImages.loginRegisteration),
                    ),
                  ),
                  Container(
                    width: _screen_width * 0.7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppDimensions.paddingSmall),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                height: 36,
                                child: TextField(
                                  controller: _verificationCodeController,
                                  autofocus: false,
                                  textAlign: TextAlign.center,
                                  decoration:
                                      InputDecorations.buildInputDecoration_1(
                                          hint_text: "A X B 4 J H"),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: _screen_height * 0.2),
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: MyTheme.textfield_grey, width: 1),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(
                                        AppDimensions.radiusNormal))),
                            child: Btn.basic(
                              minWidth: MediaQuery.of(context).size.width,
                              color: Theme.of(context).primaryColor,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          AppDimensions.radiusNormal))),
                              child: Text(
                                AppLocalizations.of(context)!.confirm_ucf,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                              onPressed: () {
                                onPressConfirm();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: AppDimensions.paddingLarge),
                    child: Text(
                        AppLocalizations.of(context)!
                            .check_your_WhatsApp_messages_to_retrieve_the_verification_code,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).disabledColor,
                            fontSize: 13)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: InkWell(
                      onTap: canResend ? onTapResend : null,
                      child: Text(AppLocalizations.of(context)!.resend_code_ucf,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: canResend
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).disabledColor,
                              decoration: TextDecoration.underline,
                              fontSize: 13)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: AppDimensions.paddingVeryExtraLarge, bottom: 60),
                    child: Visibility(
                      visible: !canResend,
                      child: TimerWidget(
                        duration: const Duration(seconds: 20),
                        callback: () {
                          setState(() {
                            countdownController.restart();
                            canResend = true;
                          });
                        },
                        controller: countdownController,
                      ),
                    ),
                  ),
                  // SizedBox(height: 15,),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: AppDimensions.paddingVeryExtraLarge),
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          onTapLogout(context);
                        },
                        child: Text(AppLocalizations.of(context)!.logout_ucf,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                decoration: TextDecoration.underline,
                                fontSize: 13)),
                      ),
                    ),
                  ),
                ],
              )),
            )
          ],
        ),
      ),
    );
  }

  onTapLogout(context) {
    try {
      AuthHelper().clearUserData(); // Ensure this clears user data properly
      routes.push("/");
    } catch (e) {
      print('Error navigating to Main: $e');
    }
  }
}

class TimerWidget extends StatelessWidget {
  const TimerWidget({
    required this.duration,
    required this.callback,
    required this.controller,
  });
  final CountdownController? controller;

  final Duration duration;
  final void Function() callback;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 6, bottom: 2, left: 12, right: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppDimensions.radiusNormal),
      ),
      child: Countdown(
        controller: controller,
        seconds: duration.inSeconds,
        onFinished: callback,
        build: (BuildContext context, double seconds) =>
            Text(seconds.fromSeconds ?? ''),
      ),
    );
  }
}
