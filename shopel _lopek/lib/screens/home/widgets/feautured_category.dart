import 'package:active_ecommerce_cms_demo_app/custom/feature_categories_widget.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: homeData,
      builder: (context, child) {
        if (!homeData.isCategoryInitial &&
            homeData.featuredCategoryList.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        return SliverToBoxAdapter(
          child: SizedBox(
            height: 220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                      top: 10, start: 20, bottom: 1),
                  child: Text(
                    AppLocalizations.of(context)!.featured_categories_ucf,
                    style: const TextStyle(
                      color: Color(0xff000000),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: FeaturedCategoriesWidget(homeData: homeData),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
