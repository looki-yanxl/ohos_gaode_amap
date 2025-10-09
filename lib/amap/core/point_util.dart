
import '../base/amap_flutter_base.dart';

///点位工具类
class PointUtil {
  ///listmap转list<LatLng>
  // static List<LatLng> listCover(List<dynamic> list) {
  //   List<LatLng> list2 = list.map((e) {
  //     if (e == null) throw ErrorDescription("LatLng is null");
  //     if (e['latitude'] == null) throw ErrorDescription("LatLng.latitude is null");
  //     if (e['longitude'] == null) throw ErrorDescription("LatLng.longitude is null");
  //     return LatLng(e['latitude'], e['longitude']);
  //   }).toList();
  //   return list2;
  // }
  ///将定位数据的字符串转为坐标集合
  static List<LatLng> listCover(String? polyline) {
    List<LatLng> polylineList = [];
    if (polyline == null) return polylineList;
    List<String> list = polyline.split(";");
    for (int i = 0; i < list.length; i++) {
      List<String> point = list[i].split(',');
      polylineList.add(LatLng(double.parse(point[1]), double.parse(point[0])));
    }
    return polylineList;
  }

  ///取到最大最小值构造容纳线上所有点的矩形
  static LatLngBounds lineBounds(List<LatLng> polyline) {
    double? minLng, minLat, maxLng, maxLat;
    for (var latLng in polyline) {
      double cLng = latLng.longitude;
      double cLat = latLng.latitude;
      if (minLng == null || cLng < minLng) minLng = cLng;
      if (minLat == null || cLat < minLat) minLat = cLat;
      if (maxLng == null || cLng > maxLng) maxLng = cLng;
      if (maxLat == null || cLat > maxLat) maxLat = cLat;
    }
    LatLng southwest = LatLng(minLat!, minLng!);
    LatLng northeast = LatLng(maxLat!, maxLng!);
    return LatLngBounds(southwest: southwest, northeast: northeast);
  }
}
