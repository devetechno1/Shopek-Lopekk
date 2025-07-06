import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/custom/home_search_box.dart';
import 'package:active_ecommerce_cms_demo_app/screens/filter.dart';
import 'package:flutter/material.dart';

class BuildAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BuildAppBar({
    super.key,
    required this.statusBarHeight,
    required this.context,
  });

  final double statusBarHeight;
  final BuildContext context;

  AppBar get appBar => AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0.0,
        centerTitle: false,
        elevation: 0,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(
              top: AppDimensions.paddingSupSmall,
              bottom: AppDimensions.paddingSupSmall,
              left: 18,
              right: 18),
          child: GestureDetector(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => const Filter())),
            child: HomeSearchBox(context: context),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return appBar;
  }

  @override
  Size get preferredSize => appBar.preferredSize;
}
