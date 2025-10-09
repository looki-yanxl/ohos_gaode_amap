
import '../map/src/types/marker.dart';
import '../map/src/types/polygon.dart';
import '../map/src/types/polyline.dart';

typedef SaveMarker = Function(String markerId, Marker marker);
typedef DeleteMarker = Function(String markerId);
typedef ClearMarkers = Function();
typedef GetMarker = Marker? Function(String markerId);

typedef SavePolyline = Function(String polylineId, Polyline polyline);
typedef DeletePolyline = Function(String polylineId);
typedef ClearPolylines = Function();
typedef GetPolyline = Polyline? Function(String polylineId);

typedef SavePolygon = Function(String polygonId, Polygon polygon);
typedef DeletePolygon = Function(String polygonId);
typedef ClearPolygons = Function();
typedef GetPolygon = Polygon? Function(String polygonId);

typedef RefreshUI = Function();

///强大的地图UI控制器
class AMapUIController {
  late SaveMarker saveMarker;
  late DeleteMarker deleteMarker;
  late ClearMarkers clearMarkers;
  GetMarker? getMarker;

  late SavePolyline savePolyline;
  late DeletePolyline deletePolyline;
  late ClearPolylines clearPolylines;
  GetPolyline? getPolyline;

  late SavePolygon savePolygon;
  late DeletePolygon deletePolygon;
  late ClearPolygons clearPolygons;
  GetPolygon? getPolygon;

  late RefreshUI refreshUI;

  AMapUIController({
    SaveMarker? addMarker,
    DeleteMarker? deleteMarker,
    ClearMarkers? clearMarkers,
    this.getMarker,
    SavePolyline? addPolyline,
    DeletePolyline? deletePolyline,
    ClearPolylines? clearPolylines,
    this.getPolyline,
    SavePolygon? addPolygon,
    DeletePolygon? deletePolygon,
    ClearPolygons? clearPolygons,
    this.getPolygon,
    RefreshUI? refreshUI,
  }) {
    saveMarker = addMarker ?? (String markerId, Marker marker) {};
    this.deleteMarker = deleteMarker ?? (String markerId) {};
    this.clearMarkers = clearMarkers ?? () {};

    savePolyline = addPolyline ?? (String polylineId, Polyline polyline) {};
    this.deletePolyline = deletePolyline ?? (String polylineId) {};
    this.clearPolylines = clearPolylines ?? () {};

    savePolygon = addPolygon ?? (String polygonId, Polygon polygon) {};
    this.deletePolygon = deletePolygon ?? (String polygonId) {};
    this.clearPolygons = clearPolygons ?? () {};

    this.refreshUI = refreshUI ?? () {};
  }

  bool isDispose = false;

  //页面结束不希望继续执行页面中的逻辑 释放
  void dispose() {
    saveMarker = (String markerId, Marker marker) {};
    deleteMarker = (String markerId) {};
    clearMarkers = () {};
    savePolyline = (String polylineId, Polyline polyline) {};
    deletePolyline = (String polylineId) {};
    clearPolylines = () {};
    savePolygon = (String polygonId, Polygon polygon) {};
    deletePolygon = (String polygonId) {};
    clearPolygons = () {};
    refreshUI = () {};
    isDispose = true;
  }
}
