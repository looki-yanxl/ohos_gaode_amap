import '../_core/location_info.dart';
import '../_core/location_option.dart';
import 'gaode_location.dart';

typedef LocationCallback = Function(LocationInfo locationInfo);

enum PsMode { high, middle, low }

class XbrLocation {
  ///工厂对象
  LocationInfo? currentLocation;
  String? fullAccuracyPurposeKey;

  XbrLocation({this.fullAccuracyPurposeKey});

  static XbrLocation? _instance;

  static XbrLocation instance() {
    _instance ??= XbrLocation();
    return _instance!;
  }

  Map<String, GaodeLocation> clientMap = <String, GaodeLocation>{};
  GaodeLocation? backgroundGaodeLocation;

  ///开始定位
  //优化 多线程回调 clientName 多个地方同时使用后台定位，这里可以同时返回多个回调通道
  void startTimeLocation(
      {String clientKey = "singleTimeLocation",
      int interval = 2000,
      double distance = -1,
      AMapLocationMode locationMode = AMapLocationMode.Hight_Accuracy,
      DesiredAccuracy desiredAccuracy = DesiredAccuracy.Best,
      required LocationCallback callback}) {
    //注意：定位已经在启动，不摧毁不要反复执行
    if (!clientMap.containsKey(clientKey)) {
      GaodeLocation? location = GaodeLocation(backgroundService: false);
      //监听定位返回
      location.onLocationChanged().listen((Map<String, Object> result) {
        currentLocation = LocationInfo.fromJson(result);
        callback(currentLocation!);
      });
      clientMap[clientKey] = location;
    }
    LocationOption locationOption = LocationOption(
      onceLocation: false,
      locationInterval: interval,
      distanceFilter: distance,
      locationMode: locationMode,
      desiredAccuracy: desiredAccuracy,
      sensorEnable: true,
    );
    //适配ios14及以上 精准定位权限
    locationOption.fullAccuracyPurposeKey = fullAccuracyPurposeKey ?? "purposeKey";
    clientMap[clientKey]?.setLocationOption(locationOption);
    clientMap[clientKey]?.startLocation();
  }

  ///开启后台进程定位
  void startBackgroundLocation(
      {int interval = 2000,
      double distance = -1,
      AMapLocationMode locationMode = AMapLocationMode.Hight_Accuracy,
      DesiredAccuracy desiredAccuracy = DesiredAccuracy.Best,
      required LocationCallback callback}) {
    if (backgroundGaodeLocation == null) {
      GaodeLocation? location = GaodeLocation(backgroundService: true);
      location.onLocationChanged().listen((Map<String, Object> result) {
        currentLocation = LocationInfo.fromJson(result);
        callback(currentLocation!);
      });
      backgroundGaodeLocation = location;
    }
    clientMap["xbr_background_time_location"] = backgroundGaodeLocation!;
    LocationOption locationOption = LocationOption(
      onceLocation: false,
      locationInterval: interval,
      distanceFilter: distance,
      locationMode: locationMode,
      desiredAccuracy: desiredAccuracy,
      sensorEnable: true,
    );
    //适配ios14及以上 精准定位权限
    locationOption.fullAccuracyPurposeKey = fullAccuracyPurposeKey ?? "purposeKey";
    backgroundGaodeLocation?.setLocationOption(locationOption);
    backgroundGaodeLocation?.startLocation();
  }

  ///摧毁后台进程定位
  void destroyBackgroundLocation() {
    destroyLocation(clientKey: "xbr_background_time_location");
    backgroundGaodeLocation = null;
  }

  ///摧毁持续定位
  void destroyLocation({required String clientKey}) {
    //地图上开启定位（持续定位）必须跟随销毁，否则UI显示时会报错
    if (clientMap.containsKey(clientKey)) {
      clientMap[clientKey]?.stopLocation();
      clientMap[clientKey]?.destroy();
      currentLocation = null;
      clientMap.remove(clientKey);
    }
  }

  ///获取一次定位
  void execOnceLocation({
    String clientKey = "onceLocation",
    AMapLocationMode locationMode = AMapLocationMode.Hight_Accuracy,
    DesiredAccuracy desiredAccuracy = DesiredAccuracy.Best,
    required LocationCallback callback,
  }) {
    //已在后台定位中，直接返回定位
    if (currentLocation != null) {
      callback(currentLocation!);
      return;
    }
    if (!clientMap.containsKey(clientKey)) {
      GaodeLocation? location = GaodeLocation();
      //监听定位返回
      location.onLocationChanged().listen((Map<String, Object> result) {
        LocationInfo location = LocationInfo.fromJson(result);
        callback(location);
        destroyLocation(clientKey: clientKey);
      });
      clientMap[clientKey] = location;
    }
    LocationOption option = LocationOption(
      onceLocation: true,
      locationMode: locationMode,
      desiredAccuracy: desiredAccuracy,
    );
    //适配ios14及以上 精准定位权限
    option.fullAccuracyPurposeKey = fullAccuracyPurposeKey ?? "purposeKey";
    clientMap[clientKey]?.setLocationOption(option);
    clientMap[clientKey]?.startLocation();
  }
}
