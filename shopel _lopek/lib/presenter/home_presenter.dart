import 'dart:async';
import 'dart:math';
import 'package:active_ecommerce_cms_demo_app/data_model/brand_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/flash_deal_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/product_mini_response.dart'
    as productMini;
import 'package:active_ecommerce_cms_demo_app/data_model/slider_response.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auction_products_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/brand_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/category_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/flash_deal_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/product_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/sliders_repository.dart';
import 'package:active_ecommerce_cms_demo_app/single_banner/model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:one_context/one_context.dart';
import '../data_model/category_response.dart';
import '../data_model/popup_banner_model.dart';
import '../helpers/shared_value_helper.dart';
import '../status/execute_and_handle_remote_errors.dart';
import '../status/status.dart';
import '../ui_elements/pop_up_banner.dart';

class HomePresenter extends ChangeNotifier {
  CurrentRemainingTime flashDealRemainingTime =
      CurrentRemainingTime(days: 0, hours: 0, min: 0, sec: 0);
  FlashDealResponseDatum? flashDeal;

  Timer? _flashDealTimer;
  DateTime? _flashDealEndTime;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int current_slider = 0;
  ScrollController? allProductScrollController;
  ScrollController? featuredCategoryScrollController;
  ScrollController mainScrollController = ScrollController();

  late AnimationController pirated_logo_controller;
  late Animation pirated_logo_animation;

  List<AIZSlider> carouselImageList = [];
  List<AIZSlider> bannerOneImageList = [];
  List<AIZSlider> bannerTwoImageList = [];
  List<AIZSlider> bannerThreeImageList = [];
  List<AIZSlider> flashDealBannerImageList = [];
  List<FlashDealResponseDatum> _banners = [];
  List<FlashDealResponseDatum> get banners => [..._banners];
  List<productMini.Product> bestSellingProductList = [];
  List<productMini.Product> auctionProductList = [];
  List<Brands> brandsList = [];
  List<productMini.Product> TodayDealList = [];

  final List<SingleBanner> _singleBanner = [];
  List<SingleBanner> get singleBanner => _singleBanner;

  List<Category> featuredCategoryList = [];

  bool isCategoryInitial = true;
  bool isCarouselInitial = true;
  bool isBannerOneInitial = true;
  bool isBannerTwoInitial = true;
  bool isBannerThreeInitial = true;
  bool isFlashDealInitial = true;
  bool isBannerFlashDeal = true;
  bool isBrandsInitial = true;
  bool isTodayDwal = true;

  bool isBestSellingProductInitial = true;
  int totalBestSellingProductData = 0;
  bool showBestSellingLoadingContainer = false;

  bool isauctionProductInitial = true;
  int? totalauctionProductData;
  int bestauctionroductPage = 1;
  bool showauctionLoadingContainer = false;

  bool isTodayDealInitial = true;
  int? totalatodayDealData;
  int todayDealPage = 1;
  bool showTodayDealContainer = false;

  List<productMini.Product> featuredProductList = [];
  bool isFeaturedProductInitial = true;
  int totalFeaturedProductData = 0;
  int featuredProductPage = 1;
  bool showFeaturedLoadingContainer = false;
  int totalCategoryProductData = 0;
  int totalAllBrandsData = 0;

  bool isTodayDeal = false;
  bool isFlashDeal = false;

  bool isBrands = false;

  var allProductList = [];
  bool isAllProductInitial = true;
  int? totalAllProductData = 0;
  int allProductPage = 1;
  bool showAllLoadingContainer = false;
  int cartCount = 0;

  fetchAll() {
    fetchCarouselImages();
    fetchBannerOneImages();
    fetchBannerTwoImages();
    fetchBannerThreeImags();
    fetchFeaturedCategories();
    fetchFeaturedProducts();
    fetchAllProducts();
    fetchTodayDealData();
    fetchFlashDealData();
    fetchBannerFlashDeal();
    fetchFlashDealBannerImages();
    fetchBrands();
    fetchBestSellingProducts();
    fetchAuctionProducts();
    fetchBrandsProducts();
    fetchTodayDealProducts();
  }

  void fetchBrands() {
    BrandRepository().getBrands().then(
      (value) {
        isBrands = !value.noBrandsAvailable;
        notifyListeners();
      },
    );
  }

  Future<void> fetchBannerFlashDeal() async {
    final banners = await SlidersRepository().fetchBanners();
    _banners = banners;
    notifyListeners();
  }

  fetchTodayDealData() async {
    productMini.ProductMiniResponse? deal;
    await executeAndHandleErrors(
        () async => deal = await ProductRepository().getTodaysDealProducts());

    // print(deal.products!.length);
    // if (deal.success! && deal.products!.isNotEmpty) {
    //   isTodayDeal = true;
    //   notifyListeners();
    // }
    if (deal?.success == true &&
        deal?.products != null &&
        deal?.products?.isNotEmpty == true) {
      isTodayDeal = true;
      notifyListeners();
    } else {
      isTodayDeal = false;
    }
  }

  Future<void> fetchFlashDealData() async {
    FlashDealResponse? deal;
    await executeAndHandleErrors(
        () async => deal = await FlashDealRepository().getFlashDeals());

    if (deal?.success == true &&
        deal?.flashDeals != null &&
        deal?.flashDeals!.isNotEmpty == true) {
      isFlashDeal = true;
      _banners.clear();
      _banners.addAll(deal?.flashDeals ?? []);
      FlashDealResponseDatum? tempFlashDeal;
      for (FlashDealResponseDatum e in deal!.flashDeals!) {
        if (e.isFeatured) {
          tempFlashDeal = e;
          break;
        }
      }
      flashDeal = tempFlashDeal;

      if (flashDeal?.date != null) {
        final DateTime end =
            DateTime.fromMillisecondsSinceEpoch(flashDeal!.date! * 1000);
        final DateTime now = DateTime.now();
        final int diff = end.difference(now).inMilliseconds;
        final int endTime = diff + now.millisecondsSinceEpoch;
        startFlashDealCountdown(endTime);
      }

      notifyListeners();
    } else {
      isFlashDeal = false;
    }
  }

  void startFlashDealCountdown(
    int endTime,
  ) {
    _flashDealEndTime = DateTime.fromMillisecondsSinceEpoch(endTime);

    _flashDealTimer?.cancel();
    _flashDealTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final remaining = _flashDealEndTime!.difference(now);

      if (remaining.isNegative) {
        _flashDealTimer?.cancel();
        flashDealRemainingTime =
            CurrentRemainingTime(days: 0, hours: 0, min: 0, sec: 0);
        isFlashDeal = false;
        notifyListeners();
        return;
      }

      flashDealRemainingTime = CurrentRemainingTime(
        days: remaining.inDays,
        hours: remaining.inHours % 24,
        min: remaining.inMinutes % 60,
        sec: remaining.inSeconds % 60,
      );

      notifyListeners();
    });
    //   // flashDealRemainingTime = CurrentRemainingTime(
    //   //   days: remaining.inDays,
    //   //   hours: remaining.inHours % 24,
    //   //   min: remaining.inMinutes % 60,
    //   //   sec: remaining.inSeconds % 60,
    //   // );
    // }
    notifyListeners();
  }

  fetchCarouselImages() async {
    SliderResponse? carouselResponse;
    await executeAndHandleErrors(
        () async => carouselResponse = await SlidersRepository().getSliders());

    carouselImageList.clear();
    carouselImageList.addAll(carouselResponse?.sliders ?? []);
    isCarouselInitial = false;

    notifyListeners();
  }

  Future<void> fetchBestSellingProducts() async {
    if (showBestSellingLoadingContainer) return;

    showBestSellingLoadingContainer = true;
    productMini.ProductMiniResponse? bestselling;
    await executeAndHandleErrors(() async =>
        bestselling = await ProductRepository().getBestSellingProducts());
    bestSellingProductList.clear();
    bestSellingProductList.addAll(bestselling?.products ?? []);
    showBestSellingLoadingContainer = false;
    isBestSellingProductInitial = false;

    notifyListeners();
  }

  fetchAuctionProducts() async {
    productMini.ProductMiniResponse? auction;
    await executeAndHandleErrors(() async => auction =
        await AuctionProductsRepository().getAuctionProducts(page: 1));

    auctionProductList.clear();
    auctionProductList.addAll(auction?.products ?? []);

    isauctionProductInitial = false;
    notifyListeners();
  }

  fetchBrandsProducts() async {
    BrandResponse? brandsRes;
    await executeAndHandleErrors(
        () async => brandsRes = await BrandRepository().getBrands());

    brandsList.clear();
    if (brandsRes?.brands != null) {
      brandsList.addAll(brandsRes?.brands ?? []);
    }

    if (brandsRes?.brands != null) {
      totalAllBrandsData = brandsRes?.meta?.total ?? 0;
    }
    showAllLoadingContainer = false;

    isBrandsInitial = false;

    notifyListeners();
  }

  fetchTodayDealProducts() async {
    productMini.ProductMiniResponse? deals;
    await executeAndHandleErrors(
        () async => deals = await ProductRepository().getTodaysDealProducts());
    TodayDealList.clear();
    TodayDealList.addAll(deals?.products ?? []);
    isTodayDealInitial = false;
    notifyListeners();
  }

  Future<void> showPopupBanner([BuildContext? cntx]) async {
    final BuildContext? context = cntx ?? OneContext().context;
    if(context == null || GoRouter.of(context).state?.path != "/" || _isOpenedBefore) return;
    _isOpenedBefore = true;
    
    final Status<List<PopupBannerModel>> bannersStatus = await executeAndHandleErrors(() => SlidersRepository().fetchBannerPopupData());

    if (bannersStatus is Success<List<PopupBannerModel>>){
      final List<PopupBannerModel> banners = List.unmodifiable(bannersStatus.data);
      if (banners.isNotEmpty) {
        await lastIndexPopupBanner.load();
        int index = lastIndexPopupBanner.$ + 1;
        if (index >= banners.length) index = 0;

        lastIndexPopupBanner.$ = index;
        lastIndexPopupBanner.save();

        
        showDialog(
          context: context,
          builder: (context) => PopupBannerDialog(popupBannerModel: banners[index]),
        );
      }
    }
  }

  Future<void> fetchBannerOneImages() async {
    SliderResponse? bannerOneResponse;
    await executeAndHandleErrors(() async =>
        bannerOneResponse = await SlidersRepository().getBannerOneImages());

    bannerOneImageList.clear();
    bannerOneImageList.addAll(bannerOneResponse?.sliders ?? []);

    isBannerOneInitial = false;
    notifyListeners();
  }

  Future<void> fetchFlashDealBannerImages() async {
    SliderResponse? flashDealBannerResponse;
    await executeAndHandleErrors(() async => flashDealBannerResponse =
        await SlidersRepository().getFlashDealBanner());

    flashDealBannerImageList.clear();
    flashDealBannerImageList.addAll(flashDealBannerResponse?.sliders ?? []);
    isFlashDealInitial = false;
    notifyListeners();
  }

  Future<void> fetchBannerTwoImages() async {
    SliderResponse? bannerTwoResponse;
    await executeAndHandleErrors(() async =>
        bannerTwoResponse = await SlidersRepository().getBannerTwoImages());

    bannerTwoImageList.clear();
    bannerTwoImageList.addAll(bannerTwoResponse?.sliders ?? []);
    isBannerTwoInitial = false;

    notifyListeners();
  }

  Future<void> fetchBannerThreeImags() async {
    SliderResponse? bannerThreeResponse;
    await executeAndHandleErrors(() async =>
        bannerThreeResponse = await SlidersRepository().getBannerThreeImages());
    bannerThreeImageList.clear();
    bannerThreeImageList.addAll(bannerThreeResponse?.sliders ?? []);
    isBannerThreeInitial = false;

    notifyListeners();
  }

  Future<void> fetchFeaturedCategories() async {
    CategoryResponse? categoryResponse;
    await executeAndHandleErrors(() async =>
        categoryResponse = await CategoryRepository().getFeturedCategories());
    featuredCategoryList.clear();
    featuredCategoryList.addAll(categoryResponse?.categories ?? []);
    isCategoryInitial = false;

    notifyListeners();
  }

  Future<void> fetchFeaturedProducts() async {
    if (showFeaturedLoadingContainer) return;

    showFeaturedLoadingContainer = true;
    productMini.ProductMiniResponse? productResponse;
    await executeAndHandleErrors(() async =>
        productResponse = await ProductRepository().getFeaturedProducts(
          page: featuredProductPage,
        ));

    featuredProductPage++;

    if (productResponse?.products != null) {
      featuredProductList.addAll(productResponse?.products ?? []);
    }

    isFeaturedProductInitial = false;

    if (productResponse?.meta != null) {
      totalFeaturedProductData =
          productResponse?.meta!.total ?? featuredProductList.length;
    }

    showFeaturedLoadingContainer = false;
    notifyListeners();
  }

  fetchAllProducts() async {
    productMini.ProductMiniResponse? productResponse;
    await executeAndHandleErrors(() async => productResponse =
        await ProductRepository().getFilteredProducts(page: allProductPage));

    if (productResponse?.products != null) {
      allProductList.addAll(productResponse?.products ?? []);
    }
    isAllProductInitial = false;
    if (productResponse?.meta != null) {
      totalAllProductData = productResponse?.meta!.total;
    }
    showAllLoadingContainer = false;

    notifyListeners();
  }

  resetBestSellingProducts() {
    bestSellingProductList.clear();
    isBestSellingProductInitial = true;
    totalBestSellingProductData = 0;
    showBestSellingLoadingContainer = false;
  }

  resetAuctionProducts() {
    auctionProductList.clear();
    isauctionProductInitial = true;
    bestauctionroductPage = 1;
    totalauctionProductData = 0;
    showauctionLoadingContainer = false;
  }

  resetTodayDeals() {
    TodayDealList.clear();
    isTodayDealInitial = true;
    todayDealPage = 1;
    totalatodayDealData = 0;
    showTodayDealContainer = false;
  }

  reset() {
    carouselImageList.clear();
    bannerOneImageList.clear();
    bannerTwoImageList.clear();
    bannerThreeImageList.clear();
    featuredCategoryList.clear();

    isCarouselInitial = true;
    isBannerOneInitial = true;
    isBannerTwoInitial = true;
    isBannerThreeInitial = true;
    isCategoryInitial = true;
    cartCount = 0;

    resetFeaturedProductList();
    resetAllProductList();
    flashDealBannerImageList.clear();
    resetBestSellingProducts();
    resetAuctionProducts();
    resetTodayDeals();
  }

  Future<void> onRefresh() async {
    reset();
    fetchAll();
  }

  resetFeaturedProductList() {
    featuredProductList.clear();
    isFeaturedProductInitial = true;
    totalFeaturedProductData = 0;
    featuredProductPage = 1;
    showFeaturedLoadingContainer = false;
    notifyListeners();
  }

  resetAllProductList() {
    allProductList.clear();
    isAllProductInitial = true;
    totalAllProductData = 0;
    allProductPage = 1;
    showAllLoadingContainer = false;
    notifyListeners();
  }

  mainScrollListener(BuildContext context) {
    mainScrollController.addListener(() {
      if (mainScrollController.positions.isNotEmpty &&
          mainScrollController.positions.first.pixels ==
              mainScrollController.positions.first.maxScrollExtent &&
          (totalAllProductData ?? 10000) > allProductList.length) {
        allProductPage++;
        // ToastComponent.showDialog(LangText(context).local.loading_more_products_ucf);
        showAllLoadingContainer = true;
        fetchAllProducts();
      }
    });
  }

  initPiratedAnimation(vnc) {
    pirated_logo_controller = AnimationController(
        vsync: vnc, duration: const Duration(milliseconds: 2000));
    pirated_logo_animation = Tween(begin: 40.0, end: 60.0).animate(
      CurvedAnimation(
        curve: Curves.bounceOut,
        parent: pirated_logo_controller,
      ),
    );

    pirated_logo_controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        pirated_logo_controller.repeat();
      }
    });

    pirated_logo_controller.forward();
  }

  incrementCurrentSlider(index) {
    current_slider = index;
    notifyListeners();
  }

  @override
  void dispose() {
    pirated_logo_controller.dispose();
    _flashDealTimer?.cancel();
    super.dispose();
  }
}

class CurrentRemainingTime {
  final int days;
  final int hours;
  final int min;
  final int sec;

  CurrentRemainingTime({
    required this.days,
    required this.hours,
    required this.min,
    required this.sec,
  });
}
  bool _isOpenedBefore = false;
