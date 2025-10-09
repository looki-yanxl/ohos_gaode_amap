
import 'dart:async';

import 'package:flutter/services.dart';


class XbrGaodeAmap {
  static const MethodChannel channel = MethodChannel('xbr_gaode_amap');

  static Future<String?> get platformVersion async {
    final String? version = await channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static void initKey({
    required String? androidKey,
    required String? iosKey,
  }) {
    channel.invokeMethod('setApiKey', {'android': androidKey, 'ios': iosKey});
  }

  static void updatePrivacyShow(bool hasContains, bool hasShow) {
    channel.invokeMethod('updatePrivacyStatement', {'hasContains': hasContains, 'hasShow': hasShow});
  }

  static void updatePrivacyAgree(bool hasAgree) {
    channel.invokeMethod('updatePrivacyStatement', {'hasAgree': hasAgree});
  }

  ///隐私合规
  static void updatePrivacy({required bool hasContains, required bool hasShow, required bool hasAgree}) {
    updatePrivacyShow(hasContains, hasShow);
    updatePrivacyAgree(hasAgree);
  }


}
