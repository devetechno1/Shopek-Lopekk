import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:animated_text_lerp/animated_text_lerp.dart';
import 'package:flutter/material.dart';

import '../data_model/cart_response.dart';
import '../my_theme.dart';
import '../presenter/cart_provider.dart';
import 'box_decorations.dart';
import 'device_info.dart';
import 'lang_text.dart';

class CartSellerItemCardWidget extends StatelessWidget {
  final int sellerIndex;
  final int itemIndex;
  final CartProvider cartProvider;
  final int index;

  const CartSellerItemCardWidget(
      {Key? key,
      required this.cartProvider,
      required this.sellerIndex,
      required this.itemIndex,
      required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall)),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              width: DeviceInfo(context).width! / 4,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadiusDirectional.horizontal(
                      start: Radius.circular(AppDimensions.radiusHalfSmall),
                      end: Radius.zero,
                    ),
                    child: FadeInImage.assetNetwork(
                      placeholder: AppImages.placeholder,
                      image: cartProvider.shopList[sellerIndex]
                          .cartItems![itemIndex].productThumbnailImage!,
                      fit: BoxFit.contain,
                    ),
                  ),
                  if (cartProvider.shopList[sellerIndex].cartItems![itemIndex]
                      .isNotAvailable)
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: const BorderRadiusDirectional.horizontal(
                          start: Radius.circular(
                            AppDimensions.radiusHalfSmall,
                          ),
                          end: Radius.zero,
                        ),
                      ),
                      child: Text(
                        LangText(context).local.notAvailable,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cartProvider.shopList[sellerIndex].cartItems![itemIndex]
                          .productName!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(
                          color: MyTheme.font_grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                    AnimatedNumberText<double>(
                      double.tryParse(
                            cartProvider.shopList[sellerIndex]
                                .cartItems![itemIndex].price!
                                .replaceAll(RegExp('[^0-9.]'), ''),
                          ) ??
                          0.0,
                      duration: const Duration(milliseconds: 500),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      formatter: (value) => '${value.toStringAsFixed(2)}',
                    ),
                    Builder(
                      builder: (context) {
                        String? text;
                        final CartItem item = cartProvider
                            .shopList[sellerIndex].cartItems![itemIndex];
                        if (item.quantity < item.minQuantity) {
                          text = LangText(context)
                              .local
                              .minimumOrderQuantity(item.minQuantity);
                        } else if (item.quantity > item.maxQuantity) {
                          text = LangText(context)
                              .local
                              .maxOrderQuantityLimit(item.maxQuantity);
                        }
                        if (text == null) return const SizedBox();
                        return Center(
                          child: Text(
                            text,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Visibility(
                  visible: cartProvider
                      .shopList[sellerIndex].cartItems![index].isLoading,
                  child: const Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),

                const Spacer(),
                ////////////////////////////////////////////////
                GestureDetector(
                  onTap: () async {
                    cartProvider.onPressDelete(
                        context,
                        cartProvider
                            .shopList[sellerIndex].cartItems![itemIndex].id
                            .toString(),
                        sellerIndex,
                        itemIndex);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingNormal),
                    child: Image.asset(
                      AppImages.trash,
                      height: 16,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingDefault),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (cartProvider.shopList[sellerIndex]
                              .cartItems![itemIndex].auctionProduct ==
                          0) {
                        cartProvider.onQuantityIncrease(
                            context, sellerIndex, itemIndex);
                      }
                      return;
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration:
                          BoxDecorations.buildCartCircularButtonDecoration(),
                      child: Icon(
                        Icons.add,
                        color: cartProvider.shopList[sellerIndex]
                                    .cartItems![itemIndex].auctionProduct ==
                                0
                            ? Theme.of(context).primaryColor
                            : MyTheme.grey_153,
                        size: 12,
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(
                        top: AppDimensions.paddingSmall,
                        bottom: AppDimensions.paddingSmall,
                      ),
                      child: Text(
                        "${int.tryParse(
                              cartProvider.shopList[sellerIndex]
                                      .cartItems?[itemIndex].quantity
                                      .toString() ??
                                  '0',
                            ) ?? 0}",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                        ),
                      )),
                  GestureDetector(
                    onTap: () {
                      if (cartProvider.shopList[sellerIndex]
                              .cartItems![itemIndex].auctionProduct ==
                          0) {
                        cartProvider.onQuantityDecrease(
                            context, sellerIndex, itemIndex);
                      }
                      return;
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration:
                          BoxDecorations.buildCartCircularButtonDecoration(),
                      child: Icon(
                        Icons.remove,
                        color: cartProvider.shopList[sellerIndex]
                                    .cartItems![itemIndex].auctionProduct ==
                                0
                            ? Theme.of(context).primaryColor
                            : MyTheme.grey_153,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ]),
    );
  }
}
