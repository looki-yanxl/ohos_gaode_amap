import 'base/amap_flutter_base.dart';
typedef QueryBack = Function(int? code, dynamic data);

class XbrAmap {

  ///自制自实例化工厂对象
  static XbrAmap? _init;
  XbrAmap();
  AMapApiKey? apikey;
  AMapPrivacyStatement? statement;
  ///自制自实例化工厂对象
  factory XbrAmap.instance() {
    _init ??= XbrAmap();
    return _init!;
  }

  ///初始化KAY
  static void initKey({required String androidKey,required String iosKey}){
    XbrAmap.instance().apikey = AMapApiKey(androidKey:androidKey,iosKey:iosKey);
  }

  ///更新协议
  static void updatePrivacy({required bool hasContains,required bool hasShow,required bool hasAgree}){
    XbrAmap.instance().statement = AMapPrivacyStatement(hasContains: hasContains,hasShow: hasShow, hasAgree: hasAgree);
  }

}