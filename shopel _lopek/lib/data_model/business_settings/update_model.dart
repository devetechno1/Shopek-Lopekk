import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

enum StoreType {
  appGallery,
  playStore,
  appleStore,
  unknown;

  const StoreType();

  static Future<StoreType> thisDeviceType() async {
    if (Platform.isIOS) return appleStore;

    final AndroidDeviceInfo deviceInfo = await DeviceInfoPlugin().androidInfo;

    if (deviceInfo.manufacturer.toLowerCase() == 'huawei') return appGallery;
    return playStore;
  }
}

class UpdateDataModel {
  final bool mustUpdate;
  final String? version;
  final String? storeLink;

  const UpdateDataModel({
    required this.mustUpdate,
    required this.version,
    required this.storeLink,
  });
}
