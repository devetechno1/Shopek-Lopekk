import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:one_context/one_context.dart';

import '../app_config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> handleUrls(
    String? url, {
    BuildContext? context,
    FutureOr<void> Function()? callBackDeepLink,
    FutureOr<void> Function()? callBackURL,
    FutureOr<void> Function()? callBackError,
  }) async {
    if (url?.isNotEmpty != true) return;
    context ??= OneContext().context!;
    final Uri? uri = Uri.tryParse(url ?? '');
    try {
      if (uri?.hasAbsolutePath ?? false) {
        if (uri?.host == AppConfig.DOMAIN_PATH) {
          await callBackDeepLink?.call();
          context.push(uri!.path);
        } else {
          await callBackURL?.call();
          await launchUrl(uri!);
        }
      } else {
        throw AppLocalizations.of(context)!.invalidURL;
      }
    } catch (e) {
      await callBackError?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

/*

    Not using this as One context is used

    https://stackoverflow.com/questions/66139776/get-the-global-context-in-flutter/66140195

    Create the class. Here it named as NavigationService

    class NavigationService {
    static GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

    }

    Set the navigatorKey property of MaterialApp in the main.dart

    Widget build(BuildContext context) {
      return MaterialApp(
        navigatorKey: NavigationService.navigatorKey, // set property
      )
    }

    Great! Now you can use anywhere you want e.g.

    print("---print context:
      ${NavigationService.navigatorKey.currentContext}");


  */
}
