// import statements
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
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
import '../../../app_config.dart';
import '../../../custom/home_banners_list.dart';
import '../../../custom/home_carousel_slider.dart';
import '../../../custom/pirated_widget.dart';
import '../../../other_config.dart';
import '../../../services/push_notification_service.dart';
import '../home.dart';
import '../widgets/featured_products_list_sliver.dart';
import '../widgets/whatsapp_floating_widget.dart';

class MegamartScreen extends StatefulWidget {
  const MegamartScreen({
    Key? key,
    this.title,
    this.show_back_button = false,
    this.go_back = true,
  }) : super(key: key);

  final String? title;
  final bool show_back_button;
  final bool go_back;

  @override
  _MegamartScreenState createState() => _MegamartScreenState();
}

class _MegamartScreenState extends State<MegamartScreen>
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
            appBar: BuildAppBar(statusBarHeight: 34, context: context),
            floatingActionButton: whatsappFloatingButtonWidget,
            backgroundColor: Colors.white,
            body: ListenableBuilder(
              listenable: homeData,
              builder: (context, child) {
                return Stack(
                  children: [
                    RefreshIndicator(
                      color: MyTheme.primaryColor,
                      backgroundColor: Colors.white,
                      onRefresh: homeData.onRefresh,
                      displacement: 0,
                      child: CustomScrollView(
                        controller: homeData.mainScrollController,
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        slivers: <Widget>[
                          //Featured category-----------------------
                          const CategoryList(),
                          SliverList(
                            delegate: SliverChildListDelegate([
                              AppConfig.purchase_code == ""
                                  ? PiratedWidget(homeData: homeData)
                                  : const SizedBox(),
                              const SizedBox(height: 10),
                              // Header Banner
                              HomeCarouselSlider(homeData: homeData),
                              const SizedBox(height: 10),

                              // Flash Sale Section
                              const FlashSale(iscircle: false),
                            ]),
                          ),
                          //move banner
                          SliverList(
                            delegate: SliverChildListDelegate([
                              TodaysDealProductsWidget(
                                homePresenter: homeData,
                              ),
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

                          //Brand List ---------------------------
                          if (homeData.isBrandsInitial ||
                              homeData.brandsList.isNotEmpty)
                            BrandListSectionSliver(
                                homeData: homeData, showViewAllButton: false),
                          //auctionProducts------------
                          AuctionProductsSectionSliver(
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
                          context: context, homeData: homeData),
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
}
