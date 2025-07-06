import "package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart";
import "package:active_ecommerce_cms_demo_app/my_theme.dart";
import "package:flutter/material.dart";

class Btn {
  static Widget basic(
      {

        Color color = const Color.fromARGB(0, 0, 0, 0),
      OutlinedBorder shape = const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(AppDimensions.radiusNormal))),
      Widget child = const SizedBox(),
      EdgeInsetsGeometry padding =
          const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      double? minWidth,
      void Function()? onPressed}) {
    //if (width != null && height != null)
    return TextButton(
      style: TextButton.styleFrom(
          padding: padding,
          backgroundColor: color,
          // primary: MyTheme.noColor,
          minimumSize: minWidth == null ? null : Size(minWidth, 10),
          shape: shape),
      child: child,
      onPressed: () => onPressed?.call(),
    );
  }

  static Widget minWidthFixHeight(
      {required minWidth,
      required double height,
      color,
      shape,
      required child,
      dynamic onPressed}) {
    return TextButton(
      style: TextButton.styleFrom(
          foregroundColor: MyTheme.noColor,
          minimumSize: Size(minWidth.toDouble(), height.toDouble()),
          backgroundColor: onPressed != null ? color : MyTheme.grey_153,
          shape: shape,
          disabledForegroundColor: Colors.blue),
      child: child,
      onPressed: onPressed,
    );
  }

  static Widget maxWidthFixHeight(
      {required maxWidth,
      required height,
      color,
      shape,
      required child,
      dynamic onPressed}) {
    return TextButton(
      style: TextButton.styleFrom(
          // primary: MyTheme.noColor,
          maximumSize: Size(maxWidth, height),
          backgroundColor: color,
          shape: shape),
      child: child,
      onPressed: onPressed,
    );
  }
}
