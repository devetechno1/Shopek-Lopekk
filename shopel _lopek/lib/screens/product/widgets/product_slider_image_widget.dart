import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/constants/app_images.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../../helpers/shimmer_helper.dart';
import '../../../my_theme.dart';

// ignore: must_be_immutable
class ProductSliderImageWidget extends StatefulWidget {
  final List? productImageList;
  final CarouselSliderController? carouselController;
  int? currentImage;
  ProductSliderImageWidget({
    Key? key,
    this.productImageList,
    this.carouselController,
    this.currentImage,
  }) : super(key: key);

  @override
  State<ProductSliderImageWidget> createState() =>
      _ProductSliderImageWidgetState();
}

class _ProductSliderImageWidgetState extends State<ProductSliderImageWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.productImageList!.isEmpty) {
      return ShimmerHelper().buildBasicShimmer(height: 190.0);
    } else {
      return Stack(
        children: [
          Positioned.fill(
            child: CarouselSlider(
              carouselController: widget.carouselController,
              options: CarouselOptions(
                  aspectRatio: 355 / 375,
                  viewportFraction: 1,
                  initialPage: 0,
                  autoPlay: widget.productImageList!.length > 1,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                  autoPlayCurve: Curves.easeInExpo,
                  enlargeCenterPage: false,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index, reason) {
                    print(index);
                    setState(() {
                      widget.currentImage = index;
                    });
                  }),
              items: widget.productImageList!.map(
                (i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        child: InkWell(
                          onTap: () {
                            openPhotoDialog(
                              context,
                              widget.productImageList![widget.currentImage!],
                            );
                          },
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            child: FadeInImage.assetNetwork(
                              placeholder: AppImages.placeholderRectangle,
                              image: i,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ).toList(),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFB7B2B2).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingSmallExtra),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    widget.productImageList!.length,
                    (index) => Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.currentImage == index
                            ? Colors.black.withValues(alpha: 0.9)
                            : const Color(0xff484848).withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Future openPhotoDialog(BuildContext context, path) => showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
                child: Stack(
              children: [
                PhotoView(
                  enableRotation: true,
                  heroAttributes: const PhotoViewHeroAttributes(tag: "someTag"),
                  imageProvider: NetworkImage(path),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: ShapeDecoration(
                      color: MyTheme.medium_grey_50,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(AppDimensions.radius),
                          bottomRight: Radius.circular(AppDimensions.radius),
                          topRight: Radius.circular(AppDimensions.radius),
                          topLeft: Radius.circular(AppDimensions.radius),
                        ),
                      ),
                    ),
                    width: 40,
                    height: 40,
                    child: IconButton(
                      icon: const Icon(Icons.clear, color: MyTheme.white),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                    ),
                  ),
                ),
              ],
            )),
          );
        },
      );
}
