import 'package:active_ecommerce_cms_demo_app/custom/home_all_products_2.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/home_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AllProducts extends StatelessWidget {
  final HomePresenter homeData;

  const AllProducts({
    super.key,
    required this.homeData,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18.0, 20, 20.0, 0.0),
                child: Text(
                  AppLocalizations.of(context)!.all_products_ucf,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              HomeAllProducts2(homeData: homeData),
            ],
          ),
        ),
      ]),
    );
  }
}
