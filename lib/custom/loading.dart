import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:flutter/material.dart';

class Loading {
  static BuildContext? _context;

  static Future<Future> show(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        Loading._context = context;
        return AlertDialog(
            content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(
              width: 10,
            ),
            Text('please_wait_ucf'.tr(context: context)),
          ],
        ));
      },
    );
  }

  static close() {
    if (Loading._context != null) {
      Navigator.of(Loading._context!).pop();
    }
  }

  static Widget bottomLoading(bool value) {
    return value
        ? Container(
            alignment: Alignment.center,
            child: const SizedBox(
                height: 20, width: 20, child: CircularProgressIndicator()),
          )
        : const SizedBox(
            height: 5,
            width: 5,
          );
  }
}
