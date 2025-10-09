import 'dart:math' as math;
import '../base/amap_flutter_base.dart';

///地图工具类
class AmapUtil {

  ///获取一串正圆坐标，可以利用多边形绘制圆
  //@radiusMi:半径（米）
  static List<LatLng> getCirclePoints({required LatLng center, required double radiusMi,int pointLen = 10}) {
    List<LatLng> points = [];//此参数用于存储多边形的经纬度，
    //地球周长
    double perimeter =  2*math.pi*6371000;
    //纬度latitude的地球周长：latitude
    double perimeterLatitude = perimeter*math.cos(math.pi * center.latitude / 180);
    //一米对应的经度（东西方向）1M实际度
    double lngRate = 360 / perimeterLatitude;
    double latRate = 360 / perimeter;
    //10度转角度
    double phase = (2 * math.pi/360) * pointLen;
    for (int i = 0; i <= 360/pointLen; i++) {
      points.add(LatLng(
          center.latitude + math.sin(phase*i)*latRate* radiusMi ,
          center.longitude - math.cos(phase*i)*lngRate* radiusMi
      ));
    }
    return points;
  }
}

///search MLatLng 自动转 LatLng
class ToLatLng extends LatLng{
  ToLatLng(double latitude, double longitude) : super(latitude, longitude);
  factory ToLatLng.from(LatLng mLatLng) {
    return ToLatLng(mLatLng.latitude,mLatLng.longitude);
  }
}
///LatLng 自动转  search MLatLng
class ToMLatLng extends LatLng{
  ToMLatLng(double latitude, double longitude) : super(latitude, longitude);
  factory ToMLatLng.from(LatLng latLng) {
    return ToMLatLng(latLng.latitude,latLng.longitude);
  }
}