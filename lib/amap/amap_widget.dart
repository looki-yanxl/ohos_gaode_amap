import 'package:flutter/material.dart';
import 'package:ohos_gaode_amap/amap/xbr_amap.dart';
import 'base/amap_flutter_base.dart';
import 'core/xbr_ui_controller.dart';
import 'map/amap_flutter_map.dart';
import 'map/src/types/camera.dart';
import 'map/src/types/marker.dart';
import 'map/src/types/polygon.dart';
import 'map/src/types/polyline.dart';
import 'map/src/types/ui.dart';

typedef PlanningCallBack = Function(int? code,List<LatLng> linePoints,LatLngBounds bounds);
typedef CalculateCallBack = Function(int distance,int duration);

class AmapWidget extends StatefulWidget {
  final CameraPosition initCameraPosition;
  final MapType? mapType;
  ///小镖人地图操作控制器
  final AMapUIController? uiController;

  ///地图创建完成回调
  final MapCreatedCallback? onMapCreated;

  ///地图移动回调
  final ArgumentCallback<CameraPosition>? onCameraMove;

  ///地图移动完成回调
  final ArgumentCallback<CameraPosition>? onCameraMoveEnd;

  ///是否锁定中心缩放
  final bool gestureScaleByMapCenter;

  const AmapWidget({
    Key? key,
    required this.initCameraPosition,
    this.uiController,
    this.onMapCreated,
    this.onCameraMove,
    this.onCameraMoveEnd,
    this.mapType,
    this.gestureScaleByMapCenter = false,
  }) : super(key: key);

  @override
  _AmapWidgetState createState() => _AmapWidgetState();
}

class _AmapWidgetState extends State<AmapWidget> {

  //用map去存值，保证绘制的唯一性
  final Map<String, Marker> markers = <String, Marker>{};
  final Map<String, Polyline> polylines = <String, Polyline>{};
  final Map<String, Polygon> polygons = <String, Polygon>{};

  @override
  void initState() {
    super.initState();
    controllerOperate();
  }

  ///地图控件
  /// 再封装地图控件，可以直接使用XbrAmapWidget，刷新只在AMapWidget
  /// 如果有更多的需求，可以直接使用AMapWidget
  ///
  @override
  Widget build(BuildContext context) {
    ///所有操作都是通过刷新这个控件实现的
    return AMapWidget(
      privacyStatement: XbrAmap.instance().statement,
      apiKey: XbrAmap.instance().apikey,
      mapType: widget.mapType??MapType.normal,
      markers: Set<Marker>.of(markers.values),
      polylines: Set<Polyline>.of(polylines.values),
      polygons: Set<Polygon>.of(polygons.values),
      initialCameraPosition: widget.initCameraPosition,
      gestureScaleByMapCenter: widget.gestureScaleByMapCenter,
      onCameraMove: widget.onCameraMove,
      onCameraMoveEnd: widget.onCameraMoveEnd,
      onMapCreated: widget.onMapCreated,
      scaleEnabled:false,
    );
  }

  ///
  void controllerOperate() {
    if (widget.uiController == null) return;
    //添加Marker
    widget.uiController?.saveMarker = (String markerId, Marker marker) {
      markers[markerId] = marker;
    };
    //删除Marker
    widget.uiController?.deleteMarker = (String markerId) {
      markers.remove(markerId);
    };
    widget.uiController?.clearMarkers = () {
      markers.clear();
    };
    widget.uiController?.getMarker = (id){
      return markers[id];
    };

    //添加线
    widget.uiController?.savePolyline = (String polylineId, Polyline polyline) {
      polylines[polylineId] = polyline;
    };
    //删除线
    widget.uiController?.deletePolyline = (String polylineId) {
      polylines.remove(polylineId);
    };
    widget.uiController?.clearPolylines = () {
      polylines.clear();
    };
    widget.uiController?.getPolyline = (id){
      return polylines[id];
    };

    //添加多边型
    widget.uiController?.savePolygon = (String polygonId, Polygon polygon) {
      polygons[polygonId] = polygon;
    };
    //删除多边形
    widget.uiController?.deletePolygon = (String polygonId) {
      polygons.remove(polygonId);
    };
    widget.uiController?.clearPolygons = () {
      polygons.clear();
    };
    widget.uiController?.getPolygon = (id){
      return polygons[id];
    };

    //刷新
    widget.uiController?.refreshUI = () {
      setState(() {});
    };
  }

  @override
  void dispose() {
   
    super.dispose();
  }
}
