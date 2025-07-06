import 'package:flutter/material.dart';

import '../../../custom/lang_text.dart';
import '../home.dart';
import 'custom_horizontal_products_list_widget.dart';

// TODO:# change to new products not featured

class NewProductsListSliver extends StatelessWidget {
  const NewProductsListSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ListenableBuilder(
          listenable: homeData,
          builder: (context, child) {
            if (!homeData.isFeaturedProductInitial &&
                homeData.featuredProductList.isEmpty) return const SizedBox();
            return CustomHorizontalProductsListSectionWidget(
              title: LangText(context).local.new_products,
              isProductInitial: homeData.isFeaturedProductInitial,
              productList: homeData.featuredProductList,
              numberOfTotalProducts: homeData.totalFeaturedProductData,
              onArriveTheEndOfList: homeData.fetchFeaturedProducts,
              //  nameTextStyle: ,
              //pricesTextStyle:
            );
          }),
    );
  }
}
