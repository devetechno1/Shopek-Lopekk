import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_dimensions.dart';
import '../custom/lang_text.dart';

class CloseAppDialogWidget extends StatelessWidget {
  const CloseAppDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingDefault,
        vertical: AppDimensions.paddingSmall,
      ),
      contentPadding: const EdgeInsets.only(
        left: AppDimensions.paddingDefault,
        right: AppDimensions.paddingDefault,
        top: AppDimensions.paddingVeryExtraLarge,
      ),
      icon: Icon(Icons.logout, color: Theme.of(context).primaryColor, size: 50),
      content: Text(
        LangText(context).local.do_you_want_close_the_app,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      actions: [
        TextButton(
          onPressed: Platform.isAndroid ? SystemNavigator.pop : () => exit(0),
          child: Text(LangText(context).local.yes_ucf),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(LangText(context).local.no_ucf),
        ),
      ],
    );
  }
}