// import statements
import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/all_products.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/auction_products.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/best_selling_section_sliver.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/brand_list.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/build_app_bar.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/feautured_category.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/flash_sale.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/new_products_list_sliver.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/product_loading_container.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/today_deal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../custom/home_banners_list.dart';
import '../../../custom/home_carousel_slider.dart';
import '../../../custom/pirated_widget.dart';
import '../../../other_config.dart';
import '../../../services/push_notification_service.dart';
import '../home.dart';
import '../widgets/featured_products_list_sliver.dart';
import '../widgets/whatsapp_floating_widget.dart';

class ReClassicScreen extends StatefulWidget {
  const ReClassicScreen({
    Key? key,
    this.title,
    this.show_back_button = false,
    this.go_back = true,
  }) : super(key: key);

  final String? title;
  final bool show_back_button;
  final bool go_back;

  @override
  _ReClassicScreenState createState() => _ReClassicScreenState();
}

class _ReClassicScreenState extends State<ReClassicScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) {
      if (OtherConfig.USE_PUSH_NOTIFICATION)
        PushNotificationService.updateDeviceToken();
      change();
    });
    super.initState();
  }

  void change() {
    homeData.onRefresh();
    homeData.mainScrollListener(context);
    homeData.initPiratedAnimation(this);
  }

  @override
  void dispose() {
    homeData.pirated_logo_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return widget.go_back;
      },
      child: Directionality(
        textDirection:
            app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
        child: SafeArea(
          child: Scaffold(
            floatingActionButton: whatsappFloatingButtonWidget,
            appBar: BuildAppBar(statusBarHeight: 34, context: context),
            backgroundColor: Colors.white,
            body: ListenableBuilder(
              listenable: homeData,
              builder: (context, child) {
                return Stack(
                  children: [
                    RefreshIndicator(
                      color: Theme.of(context).primaryColor,
                      backgroundColor: Colors.white,
                      onRefresh: homeData.onRefresh,
                      displacement: 0,
                      child: CustomScrollView(
                        controller: homeData.mainScrollController,
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        slivers: <Widget>[
                          SliverList(
                              delegate: SliverChildListDelegate([
                            HomeCarouselSlider(homeData: homeData),
                          ])),
                          const CategoryList(),
                          SliverList(
                              delegate: SliverChildListDelegate([
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: AppDimensions.paddingLarge, bottom: 10),
                              child: Text(
                                  AppLocalizations.of(context)!.todays_deal_ucf,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                            ),
                            TodaysDealProductsWidget(
                              homePresenter: homeData,
                            ),
                          ])),
                          //BannerList---------------------
                          SliverToBoxAdapter(
                            child: HomeBannersList(
                              bannersImagesList: homeData.bannerOneImageList,
                              isBannersInitial: homeData.isBannerOneInitial,
                            ),
                          ),

                          SliverList(
                            delegate: SliverChildListDelegate([
                              AppConfig.purchase_code == ""
                                  ? PiratedWidget(homeData: homeData)
                                  : const SizedBox(),
                              const SizedBox(height: 10),
                              //featured

                              // Header Banner

                              const SizedBox(height: 16),

                              // Flash Sale Section
                              const FlashSale(iscircle: false)
                            ]),
                          ),
                          //featuredProducts-----------------------------
                          const FeaturedProductsListSliver(),

//BannerList---------------------
                          SliverToBoxAdapter(
                            child: HomeBannersList(
                              bannersImagesList: homeData.bannerTwoImageList,
                              isBannersInitial: homeData.isBannerTwoInitial,
                            ),
                          ),

//Best Selling-------------------
                          // if(homeData.isFeaturedProductInitial || homeData.featuredProductList.isNotEmpty)
                          const BestSellingSectionSliver(),
//newProducts-----------------------------
                          const NewProductsListSliver(),
//BannerList---------------------
                          SliverToBoxAdapter(
                            child: HomeBannersList(
                              bannersImagesList: homeData.bannerThreeImageList,
                              isBannersInitial: homeData.isBannerThreeInitial,
                            ),
                          ),
//auctionProducts------------
                          AuctionProductsSectionSliver(
                            homeData: homeData,
                          ),

//Brand List ---------------------------
                          if (homeData.isBrandsInitial ||
                              homeData.brandsList.isNotEmpty)
                            BrandListSectionSliver(
                              homeData: homeData,
                            ),

//all products --------------------------
                          AllProducts(
                            homeData: homeData,
                          ),

                          ///
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: ProductLoadingcontainer(
                        context: context,
                        homeData: homeData,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

// Widget buildTimerRow(CurrentRemainingTime time) {
//   return Container(
//     height: 35,
//     margin: const EdgeInsets.symmetric(horizontal: 5.0),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(AppDimensions.radiusSmallExtra)
//     ),
//     child: SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       padding: const EdgeInsets.symmetric(horizontal: 10),
//       child: Container(
//         color: Colors.white,
//         child: Row(
//           children: [
//             Container(
//               width: 50,
//               color: Theme.of(context).primaryColor,
//               child: RowTimeDataWidget(time: "${time.days}", timeType: LangText(context).local.days, isFirst: true)),
//             const  SizedBox(width: 20,),
//             Container(
//               width: 50,
//               color: Theme.of(context).primaryColor,
//               child: RowTimeDataWidget(time: "${time.hours}", timeType: LangText(context).local.hours, isFirst: true)),
//            const   SizedBox(width: 20,),
//             Container(
//               width: 60,
//               color: Theme.of(context).primaryColor,child: RowTimeDataWidget(time: "${time.min}", timeType: LangText(context).local.minutes, isFirst: true)),
//          const   SizedBox(width: 20,),
//             Container(
//               width: 60,
//               color: Theme.of(context).primaryColor,child: RowTimeDataWidget(time: "${time.sec}", timeType: LangText(context).local.seconds, isFirst: true)),

//           ],
//         ),
//       ),
//     ),
//   );
// }
//   String timeText(String val, {int default_length = 2}) {
//     return val.padLeft(default_length, '0');
  // }
}
