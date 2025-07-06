// ignore_for_file: non_constant_identifier_names

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/flash%20deals%20banner/flash_deal_banner.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/home_presenter.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/build_app_bar.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/featured_products_list_sliver.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/feautured_category.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/menu_item_list.dart';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../custom/home_all_products_2.dart';
import '../../custom/home_banners_list.dart';
import '../../custom/home_carousel_slider.dart';
import '../../custom/pirated_widget.dart';
import '../../other_config.dart';
import '../../services/push_notification_service.dart';

HomePresenter homeData = HomePresenter();

class Home extends StatefulWidget {
  const Home({
    Key? key,
    this.title,
    this.show_back_button = false,
    this.go_back = true,
  }) : super(key: key);

  final String? title;
  final bool show_back_button;
  final bool go_back;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
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
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        return widget.go_back;
      },
      child: Directionality(
        textDirection:
            app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
        child: SafeArea(
          child: Scaffold(
            appBar: BuildAppBar(
              statusBarHeight: 34,
              context: context,
            ),
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
                      child:
                          //CustomScroll
                          CustomScrollView(
                        controller: homeData.mainScrollController,
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        slivers: <Widget>[
                          SliverList(
                            delegate: SliverChildListDelegate([
                              AppConfig.purchase_code == ""
                                  ? PiratedWidget(homeData: homeData)
                                  : const SizedBox(),
                              const SizedBox(height: 10),

                              //Header Search
                              // Padding(
                              //   padding:
                              //       const EdgeInsets.symmetric(horizontal: 20),
                              //   child: HomeSearchBox(),
                              // ),
                              // SizedBox(height: 8),
                              //Header Banner
                              HomeCarouselSlider(homeData: homeData),
                              const SizedBox(height: 16),

                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppDimensions.paddingDefault),
                                child: MenuItemList(),
                              ),
                              // SizedBox(height: 16),

                              //Home slider one
                              HomeBannersList(
                                bannersImagesList: homeData.bannerOneImageList,
                                isBannersInitial: homeData.isBannerOneInitial,
                              ),
                            ]),
                          ),

                          //Featured Categories
                          const CategoryList(),

                          if (homeData.isFlashDeal)
                            SliverList(
                                delegate: SliverChildListDelegate([
                              InkWell(
                                onTap: () =>
                                    GoRouter.of(context).go('/flash-deals'),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .flash_deals_ucf,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              FlashDealBanner(
                                context: context,
                                homeData: homeData,
                              ),
                            ])),

                          // SliverList(
                          //     delegate: SliverChildListDelegate([
                          //   FlashDealBanner(
                          //     context: context,
                          //     homeData: homeData,
                          //   ),
                          // ])),

                          //Featured Products
                          const FeaturedProductsListSliver(),
                          //Home Banner Slider Two
                          // SliverList(
                          //   delegate: SliverChildListDelegate([
                          //     HomeBannerTwo(
                          //       context: context,
                          //       homeData: homeData,
                          //     ),
                          //   ]),
                          // ),
                          SliverList(
                            delegate: SliverChildListDelegate([
                              SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          18.0, 20, 20.0, 0.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .all_products_ucf,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //Home All Product
                                    SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          HomeAllProducts2(
                                              context: context,
                                              homeData: homeData),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Container(
                              //   height: 80,
                              // ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: buildProductLoadingContainer(homeData),
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

  // Widget buildHomeMenu(BuildContext context, HomePresenter homeData) {
  //   // Check if the menu is loading (assuming both deals are false when data is not available)
  //   // if (!homeData.isFlashDeal && !homeData.isTodayDeal) {
  //   //   return Container(
  //   //     height: 40,
  //   //     child: ShimmerHelper().buildHorizontalGridShimmerWithAxisCount(
  //   //       crossAxisSpacing: 12.0,
  //   //       mainAxisSpacing: 12.0,
  //   //       item_count: 4, // Adjust as needed
  //   //       mainAxisExtent: 40.0, // Height of each item
  //   //     ),
  //   //   );
  //   // }

  //   final List<Map<String, dynamic>> menuItems = [
  //     if (homeData.isTodayDeal)
  //       {
  //         "title": AppLocalizations.of(context)!.todays_deal_ucf,
  //         "image": AppImages.todayDeal,
  //         "onTap": () {
  //           Navigator.push(context, MaterialPageRoute(builder: (context) {
  //             return TodaysDealProducts();
  //           }));
  //         },
  //         "textColor": Colors.white,
  //         "backgroundColor": const Color(0xffE62D05),
  //       },
  //     if (homeData.isFlashDeal)
  //       {
  //         "title": AppLocalizations.of(context)!.flash_deal_ucf,
  //         "image": AppImages.flashDeal,
  //         "onTap": () {
  //           Navigator.push(context, MaterialPageRoute(builder: (context) {
  //             return FlashDealList();
  //           }));
  //         },
  //         "textColor": Colors.white,
  //         "backgroundColor": const Color(0xffF6941C),
  //       },
  //     if(homeData.isBrands)
  //       {
  //         "title": AppLocalizations.of(context)!.brands_ucf,
  //         "image": AppImages.brands,
  //         "onTap": () {
  //           Navigator.push(context, MaterialPageRoute(builder: (context) {
  //             return const Filter(selected_filter: "brands");
  //           }));
  //         },
  //         "textColor": const Color(0xff263140),
  //         "backgroundColor": const Color(0xffE9EAEB),
  //       },
  //     // Ensure `AppConfig.businessSettingsData.classifiedProduct` is valid or properly defined
  //     if (AppConfig.businessSettingsData.vendorSystemActivation)
  //       {
  //         "title": AppLocalizations.of(context)!.top_sellers_ucf,
  //         "image": AppImages.TopSellers,
  //         "onTap": () {
  //           Navigator.push(context, MaterialPageRoute(builder: (context) {
  //             return const TopSellers();
  //           }));
  //         },
  //         "textColor": const Color(0xff263140),
  //         "backgroundColor": const Color(0xffE9EAEB),
  //       },
  //   ];

  //   if(menuItems.isEmpty) return const SizedBox();

  //   return Container(
  //     height: 40,
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal,
  //       padding: const EdgeInsets.symmetric(horizontal: 12),
  //       itemCount: menuItems.length,
  //       itemBuilder: (context, index) {
  //         final item = menuItems[index];

  //         return GestureDetector(
  //           onTap: item['onTap'],
  //           child: Container(
  //             margin: const EdgeInsetsDirectional.only(start: 8),
  //             height: 40,
  //             width: 106,
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(AppDimensions.radiusNormal),
  //               color: item['backgroundColor'],
  //             ),
  //             child: Center(
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Padding(
  //                     padding: const EdgeInsets.all(5.0),
  //                     child: Container(
  //                       height: 16,
  //                       width: 16,
  //                       alignment: Alignment.center,
  //                       child: Image.asset(
  //                         item['image'],
  //                         color: item['textColor'],
  //                       ),
  //                     ),
  //                   ),
  //                   Flexible(
  //                     child: Text(
  //                       item['title'],
  //                       textAlign: TextAlign.center,
  //                       style: TextStyle(
  //                         color: item['textColor'],
  //                         fontWeight: FontWeight.w300,
  //                         fontSize: 10,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  // AppBar buildAppBar(double statusBarHeight, BuildContext context) {
  //   return AppBar(
  //     automaticallyImplyLeading: false,
  //     backgroundColor: Colors.white,
  //     scrolledUnderElevation: 0.0,
  //     centerTitle: false,
  //     elevation: 0,
  //     flexibleSpace: Padding(
  //       padding:
  //           const EdgeInsets.only(top: 10.0, bottom: 10, left: 18, right: 18),
  //       child: GestureDetector(
  //           onTap: () {
  //             Navigator.of(context)
  //                 .push(MaterialPageRoute(builder: (context) => const Filter()));
  //           },
  //           child: HomeSearchBox(context: context)),
  //     ),
  //   );
  // }
  // AppBar buildAppBar(double statusBarHeight, BuildContext context) {
  //   return AppBar(
  //     automaticallyImplyLeading: false,
  //     // Don't show the leading button
  //     backgroundColor: Colors.white,
  //     centerTitle: false,
  //     elevation: 0,
  //     flexibleSpace: Padding(
  //       // padding:
  //       //     const EdgeInsets.only(top: 40.0, bottom: 22, left: 18, right: 18),
  //       padding:
  //           const EdgeInsets.only(top: 10.0, bottom: 10, left: 18, right: 18),
  //       child: GestureDetector(
  //         onTap: () {
  //           Navigator.push(context, MaterialPageRoute(builder: (context) {
  //             return Filter();
  //           }));
  //         },
  //         child: HomeSearchBox(context: context),
  //       ),
  //     ),
  //   );
  // }

  Container buildProductLoadingContainer(HomePresenter homeData) {
    return Container(
      height: homeData.showAllLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(
          homeData.totalAllProductData == homeData.allProductList.length
              ? AppLocalizations.of(context)!.no_more_products_ucf
              : AppLocalizations.of(context)!.loading_more_products_ucf,
        ),
      ),
    );
  }
}
