import 'package:flutter/material.dart';

import '../../../custom/lang_text.dart';
import '../home.dart';
import 'custom_horizontal_products_list_widget.dart';

class FeaturedProductsListSliver extends StatelessWidget {
  const FeaturedProductsListSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ListenableBuilder(
          listenable: homeData,
          builder: (context, child) {
            if (!homeData.isFeaturedProductInitial &&
                homeData.featuredProductList.isEmpty) return const SizedBox();
            return CustomHorizontalProductsListSectionWidget(
              title: LangText(context).local.featured_products_ucf,
              isProductInitial: homeData.isFeaturedProductInitial,
              productList: homeData.featuredProductList,
              numberOfTotalProducts: homeData.totalFeaturedProductData,
              onArriveTheEndOfList: homeData.fetchFeaturedProducts,
            );
          }),
    );
  }
}
