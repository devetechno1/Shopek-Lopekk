import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../helpers/shimmer_helper.dart';
import '../presenter/home_presenter.dart';
import '../ui_elements/product_card_black.dart';

class HomeAllProducts2 extends StatelessWidget {
  final BuildContext? context;
  final HomePresenter? homeData;
  const HomeAllProducts2({
    Key? key,
    this.context,
    this.homeData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (homeData!.isAllProductInitial) {
      return SingleChildScrollView(
          child: ShimmerHelper().buildProductGridShimmer(
              scontroller: homeData!.allProductScrollController));
    } else if (homeData!.allProductList.isNotEmpty) {
      final bool isLoadingMore = homeData!.allProductList.length <
          (homeData!.totalAllProductData ?? 0);
      return MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          itemCount: isLoadingMore
              ? homeData!.allProductList.length + 2
              : homeData!.allProductList.length,
          shrinkWrap: true,
          padding: const EdgeInsets.only(
              top: AppDimensions.paddingLarge,
              bottom: AppDimensions.paddingSupSmall,
              left: 18,
              right: 18),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            if (index > homeData!.allProductList.length - 1) {
              return ShimmerHelper().buildBasicShimmer(height: 200);
            }
            return ProductCardBlack(
              id: homeData!.allProductList[index].id,
              slug: homeData!.allProductList[index].slug,
              image: homeData!.allProductList[index].thumbnail_image,
              name: homeData!.allProductList[index].name,
              main_price: homeData!.allProductList[index].main_price,
              stroked_price: homeData!.allProductList[index].stroked_price,
              has_discount: homeData!.allProductList[index].has_discount,
              discount: homeData!.allProductList[index].discount,
              isWholesale: homeData!.allProductList[index].isWholesale,
            );
          });
    } else if (homeData!.totalAllProductData == 0) {
      return Center(
          child: Text(AppLocalizations.of(context)!.no_product_is_available));
    } else {
      return Container(); // should never be happening
    }
  }
}
