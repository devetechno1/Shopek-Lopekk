import 'package:active_ecommerce_cms_demo_app/data_model/business_setting_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/business_setting_repository.dart';

import '../app_config.dart';
import '../data_model/business_settings/business_settings.dart';
import '../data_model/language_list_response.dart';
import '../repositories/language_repository.dart';

class BusinessSettingHelper {
  Future<void> setBusinessSettingData() async {
    final BusinessSettingListResponse businessLists =
        await BusinessSettingRepository().getBusinessSettingList();
    final Map<String, dynamic> map = {};

    businessLists.data
        ?.forEach((element) => map[element.type!] = element.value);

    AppConfig.businessSettingsData = BusinessSettingsData.fromMap(map);
  }

  static Future<void> setInitLang() async {
    final LanguageListResponse langs =
        await LanguageRepository().getLanguageList();

    if (langs.success != true) return;

    if (langs.languages?.length == 1) {
      await _setLangConfig(langs.languages!.first);
      return;
    }
    await app_language.load();
    if (app_language.$ == null) {
      for (Language lang in langs.languages ?? []) {
        if (lang.is_default ?? false) {
          await _setLangConfig(lang);
          return;
        }
      }
    }
  }

  static Future<void> _setLangConfig(Language lang) async {
    AppConfig.default_language = lang.code ?? AppConfig.default_language;
    AppConfig.mobile_app_code =
        lang.mobile_app_code ?? AppConfig.mobile_app_code;
    AppConfig.app_language_rtl = lang.rtl ?? AppConfig.app_language_rtl;
    app_language.$ = lang.code;
    app_mobile_language.$ = lang.mobile_app_code;
    app_language_rtl.$ = lang.rtl;
    await Future.wait([
      app_language.save(),
      app_mobile_language.save(),
      app_language_rtl.save(),
    ]);
  }
}
