// ignore_for_file: dead_code

import 'dart:async';

import 'package:active_ecommerce_cms_demo_app/custom/aiz_route.dart';
import 'package:active_ecommerce_cms_demo_app/custom/box_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';
import 'package:active_ecommerce_cms_demo_app/custom/lang_text.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/auth_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/unRead_notification_counter.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/profile_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/address.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auction/auction_products.dart';
import 'package:active_ecommerce_cms_demo_app/screens/blog_list_screen.dart';
import 'package:active_ecommerce_cms_demo_app/screens/classified_ads/classified_ads.dart';
import 'package:active_ecommerce_cms_demo_app/screens/classified_ads/my_classified_ads.dart';
import 'package:active_ecommerce_cms_demo_app/screens/coupon/coupons.dart';
import 'package:active_ecommerce_cms_demo_app/screens/digital_product/digital_products.dart';
import 'package:active_ecommerce_cms_demo_app/screens/filter.dart';
import 'package:active_ecommerce_cms_demo_app/screens/flash_deal/flash_deal_list.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/home.dart';
import 'package:active_ecommerce_cms_demo_app/screens/product/last_view_product.dart';
import 'package:active_ecommerce_cms_demo_app/screens/product/top_selling_products.dart';
import 'package:active_ecommerce_cms_demo_app/screens/refund_request.dart';
import 'package:active_ecommerce_cms_demo_app/screens/wholesales_screen.dart';
import 'package:active_ecommerce_cms_demo_app/screens/wishlist/widgets/page_animation.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:one_context/one_context.dart';
import 'package:provider/provider.dart';
import 'package:route_transitions/route_transitions.dart';

import '../app_config.dart';
import '../custom/btn.dart';
import '../repositories/auth_repository.dart';
import 'auction/auction_bidded_products.dart';
import 'auction/auction_purchase_history.dart';
import 'change_language.dart';
import 'chat/messenger_list.dart';
import 'checkout/cart.dart';
import 'club_point.dart';
import 'common_webview_screen.dart';
import 'currency_change.dart';
import 'digital_product/purchased_digital_produts.dart';

import 'followed_sellers.dart';
import 'notification/notification_list.dart';
import 'orders/order_list.dart';
import 'profile_edit.dart';
import 'uploads/upload_file.dart';
import 'wallet.dart';
import 'wishlist/wishlist.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key, this.show_back_button = false}) : super(key: key);

  final bool show_back_button;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // ScrollController _mainScrollController = ScrollController();
  // final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _auctionExpand = false;
  int? _cartCounter = 0;
  String _cartCounterString = "00";
  int? _wishlistCounter = 0;
  String _wishlistCounterString = "00";
  int? _orderCounter = 0;
  String _orderCounterString = "00";
  late BuildContext loadingcontext;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (is_logged_in.$ == true) {
      fetchAll();
    }
  }

  // void dispose() {
  //   _mainScrollController.dispose();
  //   super.dispose();
  // }

  Future<void> _onPageRefresh() async {
    reset();
    fetchAll();
  }

  onPopped(value) async {
    reset();
    fetchAll();
  }

  void fetchAll() {
    fetchCounters();
    getNotificationCount();
  }

  Future<void> getNotificationCount() async {
    Provider.of<UnReadNotificationCounter>(context, listen: false).getCount();
  }

  Future<void> fetchCounters() async {
    final profileCountersResponse =
        await ProfileRepository().getProfileCountersResponse();

    _cartCounter = profileCountersResponse.cart_item_count;
    _wishlistCounter = profileCountersResponse.wishlist_item_count;
    _orderCounter = profileCountersResponse.order_count;

    _cartCounterString =
        counterText(_cartCounter.toString(), default_length: 2);
    _wishlistCounterString =
        counterText(_wishlistCounter.toString(), default_length: 2);
    _orderCounterString =
        counterText(_orderCounter.toString(), default_length: 2);

    setState(() {});
  }

  Future<void> deleteAccountReq() async {
    loading();
    final response = await AuthRepository().getAccountDeleteResponse();

    if (response.result) {
      AuthHelper().clearUserData();
      Navigator.pop(loadingcontext);
      context.go("/");
    }
    ToastComponent.showDialog(response.message);
  }

  String counterText(String txt, {default_length = 3}) {
    final blankZeros = default_length == 3 ? "000" : "00";
    var leadingZeros = "";
    if (default_length == 3 && txt.length == 1) {
      leadingZeros = "00";
    } else if (default_length == 3 && txt.length == 2) {
      leadingZeros = "0";
    } else if (default_length == 2 && txt.length == 1) {
      leadingZeros = "0";
    }

    var newtxt = (txt == "" || txt == null.toString()) ? blankZeros : txt;

    // print(txt + " " + default_length.toString());
    // print(newtxt);

    if (default_length > txt.length) {
      newtxt = leadingZeros + newtxt;
    }
    //print(newtxt);

    return newtxt;
  }

  void reset() {
    _cartCounter = 0;
    _cartCounterString = "00";
    _wishlistCounter = 0;
    _wishlistCounterString = "00";
    _orderCounter = 0;
    _orderCounterString = "00";
    // setState(() {});
  }

  List<int> listItem = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  onTapLogout(BuildContext context) async {
    AuthHelper().clearUserData();
    context.go("/");
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: buildView(context),
    );
  }

  Widget buildView(context) {
    return Container(
      color: Colors.white,
      height: DeviceInfo(context).height,
      child: Stack(
        children: [
          Container(
              height: DeviceInfo(context).height! / 1.6,
              width: DeviceInfo(context).width,
              color: Theme.of(context).primaryColor,
              alignment: Alignment.topRight,
              child: Image.asset(
                AppImages.backgroundOne,
              )),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: buildCustomAppBar(context),
            body: buildBody(),
          ),
        ],
      ),
    );
  }

  RefreshIndicator buildBody() {
    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      onRefresh: _onPageRefresh,
      displacement: 10,
      child: buildBodyChildren(),
    );
  }

  CustomScrollView buildBodyChildren() {
    return CustomScrollView(
      // controller: _mainScrollController,
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              buildCountersRow(),
              buildHorizontalSettings(),
              buildSettingAndAddonsHorizontalMenu(),
              buildBottomVerticalCardList(),
            ]),
          ),
        )
      ],
    );
  }

  PreferredSize buildCustomAppBar(context) {
    return PreferredSize(
      preferredSize: Size(DeviceInfo(context).width!, 92),
      child: Container(
        // color: Colors.green,
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: Padding(
                  padding:
                      const EdgeInsetsDirectional.only(end: 18, bottom: 12),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusVeryExtra),
                    child: const SizedBox(
                      height: 30,
                      width: 30,
                      child: Icon(
                        Icons.close,
                        color: MyTheme.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),

              // Container(
              //   margin: EdgeInsets.symmetric(vertical: 8),
              //   width: DeviceInfo(context).width,height: 1,color: MyTheme.medium_grey_50,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: buildAppbarSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBottomVerticalCardList() {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 120, top: AppDimensions.paddingNormal),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: BoxDecorations.buildBoxDecoration_1(),
      child: Column(
        children: [
          // if (false)
          //   // dead_code
          //   Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       buildBottomVerticalCardListItem(
          //           "assets/coupon.png", LangText(context).local.coupons_ucf,
          //           onPressed: () {}),
          //       Divider(
          //         thickness: 1,
          //         color: MyTheme.light_grey,
          //       ),
          //       buildBottomVerticalCardListItem("assets/favoriteseller.png",
          //           LangText(context).local.favorite_seller_ucf,
          //           onPressed: () {}),
          //       Divider(
          //         thickness: 1,
          //         color: MyTheme.light_grey,
          //       ),
          //     ],
          //   ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildBottomVerticalCardListItem(AppImages.products,
                  LangText(context).local.top_selling_products_ucf,
                  onPressed: () {
                AIZRoute.push(context, TopSellingProducts());
              }),
              Divider(
                thickness: 1,
                color: MyTheme.light_grey,
              ),
            ],
          ),
          if (whole_sale_addon_installed.$)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildBottomVerticalCardListItem(AppImages.wholeSale,
                    LangText(context).local.wholesale_product, onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WholesalesScreen()));
                }),
                Divider(
                  thickness: 1,
                  color: MyTheme.light_grey,
                ),
              ],
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildBottomVerticalCardListItem(
                  AppImages.blog, LangText(context).local.blog_list_ucf,
                  onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BlogListScreen()));
              }),
              Divider(
                thickness: 1,
                color: MyTheme.light_grey,
              ),
            ],
          ),

          buildBottomVerticalCardListItem(AppImages.download,
              LangText(context).local.all_digital_products_ucf, onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const DigitalProducts();
            }));
          }),
          Divider(
            thickness: 1,
            color: MyTheme.light_grey,
          ),
          buildBottomVerticalCardListItem(
              AppImages.coupon, LangText(context).local.coupons_ucf,
              onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const Coupons();
            }));
          }),
          Divider(
            thickness: 1,
            color: MyTheme.light_grey,
          ),
          //flash_deals
          Column(
            children: [
              if (homeData.isFlashDealInitial != false)
                buildBottomVerticalCardListItem(AppImages.flashDeal,
                    AppLocalizations.of(context)!.flash_deal_ucf,
                    onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return FlashDealList();
                  }));
                }),
            ],
          ),
          Divider(
            thickness: 1,
            color: MyTheme.light_grey,
          ),
          //flash_deals
          buildBottomVerticalCardListItem(
              AppImages.brands, AppLocalizations.of(context)!.brands_ucf,
              onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const Filter(selected_filter: "brands");
            }));
          }),
          Divider(
            thickness: 1,
            color: MyTheme.light_grey,
          ),

          // this is addon
          if (false)
            Column(
              children: [
                buildBottomVerticalCardListItem(AppImages.auction,
                    LangText(context).local.on_auction_products_ucf,
                    onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const AuctionProducts();
                  }));
                }),
                Divider(
                  thickness: 1,
                  color: MyTheme.light_grey,
                ),
              ],
            ),
          if (AppConfig.businessSettingsData.classifiedProduct)
            Column(
              children: [
                buildBottomVerticalCardListItem(AppImages.myClassified,
                    LangText(context).local.my_classified_ads_ucf,
                    onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const MyClassifiedAds();
                  }));
                }),
                Divider(
                  thickness: 1,
                  color: MyTheme.light_grey,
                ),
              ],
            ),
/////
          if (AppConfig.businessSettingsData.classifiedProduct)
            Column(
              children: [
                buildBottomVerticalCardListItem(AppImages.classifiedProduct,
                    LangText(context).local.all_classified_ads_ucf,
                    onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const ClassifiedAds();
                  }));
                }),
                Divider(
                  thickness: 1,
                  color: MyTheme.light_grey,
                ),
              ],
            ),

          if (AppConfig.businessSettingsData.lastViewedProductActivation &&
              is_logged_in.$)
            Column(
              children: [
                buildBottomVerticalCardListItem(AppImages.lastViewProduct,
                    LangText(context).local.last_view_product_ucf,
                    onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const LastViewProduct();
                  }));
                }),
                Divider(
                  thickness: 1,
                  color: MyTheme.light_grey,
                ),
              ],
            ),

          // this is addon auction product
          if (false)
            Column(
              children: [
                buildBottomVerticalCardListItem(AppImages.auction,
                    LangText(context).local.on_auction_products_ucf,
                    onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const AuctionProducts();
                  }));
                }),
                Divider(
                  thickness: 1,
                  color: MyTheme.light_grey,
                ),
              ],
            ),
          if (auction_addon_installed.$)
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _auctionExpand
                      ? is_logged_in.$
                          ? 150
                          : 80
                      : 40,
                  alignment: Alignment.topCenter,
                  padding:
                      const EdgeInsets.only(top: AppDimensions.paddingSupSmall),
                  child: InkWell(
                    onTap: () {
                      _auctionExpand = !_auctionExpand;
                      setState(() {});
                    },
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 24.0),
                                    child: Image.asset(
                                      AppImages.auction,
                                      height: 16,
                                      width: 16,
                                      color: MyTheme.dark_font_grey,
                                    ),
                                  ),
                                  Text(
                                    LangText(context).local.auction_ucf,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: MyTheme.dark_font_grey),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              _auctionExpand
                                  ? Icons.keyboard_arrow_down
                                  : Icons.navigate_next_rounded,
                              size: 20,
                              color: MyTheme.dark_font_grey,
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Flexible(
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 300),
                            scale: _auctionExpand ? 1 : 0,
                            alignment: app_language_rtl.$ == true
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              padding:
                                  const EdgeInsetsDirectional.only(start: 40),
                              width: double.infinity,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () => OneContext().push(
                                      MaterialPageRoute(
                                        builder: (_) => const AuctionProducts(),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '-',
                                          style: TextStyle(
                                            color: MyTheme.dark_font_grey,
                                          ),
                                        ),
                                        Text(
                                          " ${LangText(context).local.on_auction_products_ucf}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: MyTheme.dark_font_grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  if (is_logged_in.$)
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () => OneContext().push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const AuctionBiddedProducts(),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                '-',
                                                style: TextStyle(
                                                  color: MyTheme.dark_font_grey,
                                                ),
                                              ),
                                              Text(
                                                " ${LangText(context).local.bidded_products_ucf}",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: MyTheme.dark_font_grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        GestureDetector(
                                          onTap: () => OneContext().push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const AuctionPurchaseHistory(),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                '-',
                                                style: TextStyle(
                                                  color: MyTheme.dark_font_grey,
                                                ),
                                              ),
                                              Text(
                                                " ${LangText(context).local.purchase_history_ucf}",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: MyTheme.dark_font_grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: MyTheme.light_grey,
                ),
              ],
            ),
          if (AppConfig.businessSettingsData.classifiedProduct)
            Column(
              children: [
                buildBottomVerticalCardListItem(AppImages.shop,
                    LangText(context).local.browse_all_sellers_ucf,
                    onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const Filter(
                      selected_filter: "sellers",
                    );
                  }));
                }),
                Divider(
                  thickness: 1,
                  color: MyTheme.light_grey,
                ),
              ],
            ),

          if (is_logged_in.$ &&
              (AppConfig.businessSettingsData.classifiedProduct))
            Column(
              children: [
                buildBottomVerticalCardListItem(AppImages.followSeller,
                    LangText(context).local.followed_sellers_ucf,
                    onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const FollowedSellers();
                  }));
                }),
                Divider(
                  thickness: 1,
                  color: MyTheme.light_grey,
                ),
              ],
            ),

          buildBottomVerticalCardListItem(
              AppImages.delete, LangText(context).local.privacy_policy_ucf,
              onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CommonWebviewScreen(
                          page_name:
                              AppLocalizations.of(context)!.privacy_policy_ucf,
                          url:
                              "${AppConfig.RAW_BASE_URL}/mobile-page/privacy-policy",
                        )));
          }, icon: Icons.lock_outline_rounded),
          Divider(
            thickness: 1,
            color: MyTheme.light_grey,
          ),

          if (is_logged_in.$)
            Column(
              children: [
                buildBottomVerticalCardListItem(
                    AppImages.delete, LangText(context).local.delete_my_account,
                    onPressed: () {
                  deleteWarningDialog();
                }),
              ],
            ),
        ],
      ),
    );
  }

  SizedBox buildBottomVerticalCardListItem(String img, String label,
      {Function()? onPressed, bool isDisable = false, IconData? icon}) {
    return SizedBox(
      height: 40,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
            alignment: Alignment.center,
            padding: EdgeInsets.zero),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 24.0),
              child: icon == null
                  ? Image.asset(
                      img,
                      height: 16,
                      width: 16,
                      color:
                          isDisable ? MyTheme.grey_153 : MyTheme.dark_font_grey,
                    )
                  : Icon(
                      icon,
                      size: 18,
                      color:
                          isDisable ? MyTheme.grey_153 : MyTheme.dark_font_grey,
                    ),
            ),
            Text(
              label,
              style: TextStyle(
                  fontSize: 12,
                  color: isDisable ? MyTheme.grey_153 : MyTheme.dark_font_grey),
            ),
          ],
        ),
      ),
    );
  }

  // This section show after counter section
  // change Language, Edit Profile and Address section
  Widget buildHorizontalSettings() {
    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.paddingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildHorizontalSettingItem(true, AppImages.language,
              AppLocalizations.of(context)!.language_ucf, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const ChangeLanguage();
                },
              ),
            );
          }),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const CurrencyChange();
              }));
            },
            child: Column(
              children: [
                Image.asset(
                  AppImages.currency,
                  height: 16,
                  width: 16,
                  color: MyTheme.white,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  AppLocalizations.of(context)!.currency_ucf,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 10,
                      color: MyTheme.white,
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
          buildHorizontalSettingItem(
              is_logged_in.$,
              AppImages.edit,
              AppLocalizations.of(context)!.edit_profile_ucf,
              is_logged_in.$
                  ? () {
                      AIZRoute.push(context, ProfileEdit()).then((value) {
                        //onPopped(value);
                      });
                    }
                  : () => showLoginWarning()),
          buildHorizontalSettingItem(
              is_logged_in.$,
              AppImages.location,
              AppLocalizations.of(context)!.address_ucf,
              is_logged_in.$
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const Address();
                          },
                        ),
                      );
                    }
                  : () => showLoginWarning()),
        ],
      ),
    );
  }

  InkWell buildHorizontalSettingItem(
      bool isLogin, String img, String text, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(
            img,
            height: 16,
            width: 16,
            color: isLogin ? MyTheme.white : MyTheme.blue_grey,
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 10,
                color: isLogin ? MyTheme.white : MyTheme.blue_grey,
                fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }

  dynamic showLoginWarning() {
    return ToastComponent.showDialog(
      AppLocalizations.of(context)!.you_need_to_log_in,
    );
  }

  Future deleteWarningDialog() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                LangText(context).local.delete_account_warning_title,
                style: TextStyle(fontSize: 15, color: MyTheme.dark_font_grey),
              ),
              content: Text(
                LangText(context).local.delete_account_warning_description,
                style: TextStyle(fontSize: 13, color: MyTheme.dark_font_grey),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      pop(context);
                    },
                    child: Text(LangText(context).local.no_ucf)),
                TextButton(
                    onPressed: () {
                      pop(context);
                      deleteAccountReq();
                    },
                    child: Text(LangText(context).local.yes_ucf))
              ],
            ));
  }

  Widget buildSettingAndAddonsHorizontalMenu() {
    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.paddingNormal),
      width: DeviceInfo(context).width,
      height: 208,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall)),
      child: GridView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 25),
        physics: const PageScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 50.0,
          crossAxisSpacing: 0.0,
          crossAxisCount: 3,
        ),
        shrinkWrap: true,
        cacheExtent: 5.0,
        children: [
          if (AppConfig.businessSettingsData.walletSystem)
            Container(
              child: buildSettingAndAddonsHorizontalMenuItem(
                  AppImages.wallet, AppLocalizations.of(context)!.my_wallet_ucf,
                  () {
                Navigator.push(
                    context, PageAnimation.fadeRoute(const Wallet()));
              }),
            ),
          buildSettingAndAddonsHorizontalMenuItem(
              AppImages.orders,
              AppLocalizations.of(context)!.orders_ucf,
              is_logged_in.$
                  ? () {
                      Navigator.push(
                          context, PageAnimation.fadeRoute(const OrderList()));
                    }
                  : () => null),
          buildSettingAndAddonsHorizontalMenuItem(
              AppImages.heart,
              AppLocalizations.of(context)!.my_wishlist_ucf,
              is_logged_in.$
                  ? () {
                      Navigator.push(
                          context, PageAnimation.fadeRoute(Wishlist()));
                    }
                  : () => null),
          if (club_point_addon_installed.$)
            buildSettingAndAddonsHorizontalMenuItem(
                AppImages.points,
                AppLocalizations.of(context)!.club_point_ucf,
                is_logged_in.$
                    ? () {
                        Navigator.push(
                            context, PageAnimation.fadeRoute(Clubpoint()));
                      }
                    : () => null),
          Container(
            child: badges.Badge(
              showBadge: is_logged_in.$,
              position: badges.BadgePosition.topEnd(
                  top: 2, end: AppDimensions.paddingLarge),
              badgeStyle: badges.BadgeStyle(
                shape: badges.BadgeShape.circle,
                badgeColor: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(AppDimensions.radiusNormal),
                padding: const EdgeInsets.all(AppDimensions.paddingSmallExtra),
              ),
              ignorePointer: true,
              badgeContent: Consumer<UnReadNotificationCounter>(
                builder: (context, notification, child) {
                  return Text(
                    "${notification.unReadNotificationCounter}",
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  );
                },
              ),
              child: buildSettingAndAddonsHorizontalMenuItem(
                  AppImages.notification,
                  AppLocalizations.of(context)!.notification_ucf,
                  is_logged_in.$
                      ? () {
                          Navigator.push(
                                  context,
                                  PageAnimation.fadeRoute(
                                      const NotificationList()))
                              .then((value) {
                            onPopped(value);
                          });
                        }
                      : () => null),
            ),
          ),
          if (refund_addon_installed.$)
            buildSettingAndAddonsHorizontalMenuItem(
                AppImages.refund,
                AppLocalizations.of(context)!.refund_requests_ucf,
                is_logged_in.$
                    ? () {
                        Navigator.push(
                            context, PageAnimation.fadeRoute(RefundRequest()));
                      }
                    : () => null),
          if (AppConfig.businessSettingsData.conversationSystem)
            buildSettingAndAddonsHorizontalMenuItem(
                AppImages.messages,
                AppLocalizations.of(context)!.messages_ucf,
                is_logged_in.$
                    ? () {
                        Navigator.push(
                            context, PageAnimation.fadeRoute(MessengerList()));
                      }
                    : () => null),
          // if (auction_addon_installed.$)
          if (false)
            if (AppConfig.businessSettingsData.classifiedProduct)
              buildSettingAndAddonsHorizontalMenuItem(
                  AppImages.classifiedProduct,
                  AppLocalizations.of(context)!.classified_products,
                  is_logged_in.$
                      ? () {
                          Navigator.push(context,
                              PageAnimation.fadeRoute(const MyClassifiedAds()));
                        }
                      : () => null),

          buildSettingAndAddonsHorizontalMenuItem(
              AppImages.download,
              AppLocalizations.of(context)!.downloads_ucf,
              is_logged_in.$
                  ? () {
                      Navigator.push(
                          context,
                          PageAnimation.fadeRoute(
                              const PurchasedDigitalProducts()));
                    }
                  : () => null),
          buildSettingAndAddonsHorizontalMenuItem(
              AppImages.upload,
              AppLocalizations.of(context)!.upload_file_ucf,
              is_logged_in.$
                  ? () {
                      Navigator.push(
                          context, PageAnimation.fadeRoute(const UploadFile()));
                    }
                  : () => null),
          // notification and badge contents
        ],
      ),
    );
  }

  Container buildSettingAndAddonsHorizontalMenuItem(
      String img, String text, Function() onTap) {
    return Container(
      alignment: Alignment.center,
      //color: Colors.red,
      // width: DeviceInfo(context).width / 4,
      child: InkWell(
        onTap: is_logged_in.$
            ? onTap
            : () {
                showLoginWarning();
              },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              img,
              width: 16,
              height: 16,
              color: is_logged_in.$
                  ? MyTheme.dark_font_grey
                  : MyTheme.medium_grey_50,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                  color: is_logged_in.$
                      ? MyTheme.dark_font_grey
                      : MyTheme.medium_grey_50,
                  fontSize: 11.5),
            )
          ],
        ),
      ),
    );
  }

  Widget buildCountersRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildCountersRowItem(
          _cartCounterString,
          AppLocalizations.of(context)!.in_your_cart_all_lower,
          onTap: () => Navigator.push(context,
              PageAnimation.fadeRoute(const Cart(has_bottomnav: false))),
        ),
        buildCountersRowItem(
          _wishlistCounterString,
          AppLocalizations.of(context)!.in_your_wishlist_all_lower,
          onTap: () =>
              Navigator.push(context, PageAnimation.fadeRoute(Wishlist())),
        ),
        buildCountersRowItem(
          _orderCounterString,
          AppLocalizations.of(context)!.your_ordered_all_lower,
          onTap: () => Navigator.push(
              context, PageAnimation.fadeRoute(const OrderList())),
        ),
      ],
    );
  }

  Widget buildCountersRowItem(String counter, String title,
      {Future<void> Function()? onTap}) {
    return InkWell(
      onTap: is_logged_in.$ && onTap != null
          ? () => onTap.call().then((_) => onPopped(null))
          : null,
      borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
      child: Container(
        margin: const EdgeInsets.only(top: AppDimensions.paddingLarge),
        padding: const EdgeInsets.symmetric(vertical: 14),
        width: DeviceInfo(context).width! / 3.5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
          color: MyTheme.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              counter,
              maxLines: 2,
              style: TextStyle(
                  fontSize: 18,
                  color: MyTheme.dark_font_grey,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              title,
              maxLines: 2,
              style: const TextStyle(
                color: Color(0xff3E4447),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAppbarSection() {
    return Container(
      // color: Colors.amber,
      alignment: Alignment.center,
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /* Container(
            child: InkWell(
              //padding: EdgeInsets.zero,
              onTap: (){
              Navigator.pop(context);
            } ,child:Icon(Icons.arrow_back,size: 25,color: MyTheme.white,), ),
          ),*/
          // SizedBox(width: 10,),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 14.0),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusVeryExtra),
                border: Border.all(color: MyTheme.white, width: 1),
                //shape: BoxShape.rectangle,
              ),
              child: is_logged_in.$
                  ? ClipRRect(
                      clipBehavior: Clip.hardEdge,
                      borderRadius: const BorderRadius.all(
                          Radius.circular(AppDimensions.radiusVeryExtra)),
                      child: FadeInImage.assetNetwork(
                        placeholder: AppImages.placeholder,
                        image: "${avatar_original.$}",
                        fit: BoxFit.fill,
                      ))
                  : Image.asset(
                      AppImages.profilePlaceholder,
                      height: 48,
                      width: 48,
                      fit: BoxFit.fitHeight,
                    ),
            ),
          ),
          buildUserInfo(),
          const Spacer(),
          Btn.basic(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            // 	rgb(50,205,50)
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusHalfSmall),
                side: const BorderSide(color: MyTheme.white)),
            child: Text(
              is_logged_in.$
                  ? AppLocalizations.of(context)!.logout_ucf
                  : LangText(context).local.login_ucf,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              if (is_logged_in.$)
                onTapLogout(context);
              else
                context.push("/users/login");
            },
          ),
        ],
      ),
    );
  }

  Widget buildUserInfo() {
    return is_logged_in.$
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${user_name.$}",
                style: const TextStyle(
                    fontSize: 14,
                    color: MyTheme.white,
                    fontWeight: FontWeight.w600),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    //if user email is not available then check user phone if user phone is not available use empty string
                    "${user_email.$ != "" ? user_email.$ : user_phone.$ != "" ? user_phone.$ : ''}",
                    style: TextStyle(
                      color: MyTheme.light_grey,
                    ),
                  )),
            ],
          )
        : Text(
            LangText(context).local.login_or_reg,
            style: const TextStyle(
                fontSize: 14,
                color: MyTheme.white,
                fontWeight: FontWeight.bold),
          );
  }

  loading() {
    showDialog(
        context: context,
        builder: (context) {
          loadingcontext = context;
          return AlertDialog(
              content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(
                width: 10,
              ),
              Text("${AppLocalizations.of(context)!.please_wait_ucf}"),
            ],
          ));
        });
  }
}
