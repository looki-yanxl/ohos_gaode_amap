import 'package:flutter/material.dart';
import 'package:xbr_gaode_amap/_core/show_fields.dart';
import '../../_core/driving_strategy.dart';
import '../../amap/amap_widget.dart';
import '../../amap/base/amap_flutter_base.dart';
import '../../amap/core/point_util.dart';
import '../../amap/core/xbr_ui_controller.dart';
import '../../amap/map/amap_flutter_map.dart';
import '../../amap/map/src/types/bitmap.dart';
import '../../amap/map/src/types/camera.dart';
import '../../amap/map/src/types/marker.dart';
import '../../amap/map/src/types/polygon.dart';
import '../../amap/map/src/types/polyline.dart';
import '../../amap/utils/amap_util.dart';
import '../entity/route_result.dart';
import '../entity/truck.dart';
import '../xbr_search.dart';
import 'dart:math' as math;
typedef OnComplete = Function(List<PlanItem> itemList);

///地图查询工具类 再封装
class SearchUtil {

  ///线路规划 一键绘制
  ///不建议使用一键绘制，最好使用线路规划接口获取点位后参考下面自己绘制
  static void routePlanningDraw({
    required List<PlanItem> itemList,
    String? lineImgPath,
    Color? lineColor,
    String? pathlineId,
    required AMapUIController uiController,
    required AMapController mapController,
    OnComplete? onComplete,
  }) {
    List<LatLng> list = [];
    for(int i =0;i<itemList.length;i++){
      list.add(ToMLatLng.from(itemList[i].latLng));
    }
    //线路规划示例
    SearchUtil.planning(
      //最多支持18个点，第一个为起点，最后一个为终点，中间为途径点,
      wayPoints: list,
      planningBack: (code, linePoints, bounds) {
        //处理返回码不是1000的逻辑
        if (code != 1000) return;
        //code返回码==1000：成功
        ///绘制规划线
        uiController.savePolyline(pathlineId??"planningLine", Polyline(
          customTexture: lineImgPath!=null?BitmapDescriptor.fromIconPath(lineImgPath):null,
          joinType: JoinType.round,
          capType: CapType.round,
          points: linePoints,
          color: lineColor??Colors.blueAccent,
          width: 6,
        ));
        ///利用MAP控制器移动相机到线路最大可视面积，边距50
        mapController.moveCamera(CameraUpdate.newLatLngBounds(bounds, 50), duration: 1000);
        ///绘制关键点
        for(int i=0;i< itemList.length;i++){
          uiController.saveMarker(itemList[i].markerId??"planningPoint$i", Marker(
            icon: itemList[i].iconPath==null?null:BitmapDescriptor.fromIconPath(itemList[i].iconPath!),
            position: itemList[i].latLng,
            infoWindow: InfoWindow(title: "第${i+1}个")
          ));
          if(itemList[i].showScope){
            ///绘制一个scope米的电子围栏
            uiController.savePolygon(itemList[i].scopeId??"scopePolygon$i", Polygon(
              points: AmapUtil.getCirclePoints(center: itemList[i].latLng, radiusMi: itemList[i].scope),
              joinType: JoinType.round,
              fillColor: Colors.deepOrange.withOpacity(0.4),
              strokeColor: Colors.cyan.withOpacity(0.6),
              strokeWidth: 1,
            ));
          }
          if(i > 0 && itemList[i].showConnecting){
            ///绘制一条方向线 起终点连线
            uiController.savePolyline(itemList[i].conineId??"connectingLine$i", Polyline(
              joinType: JoinType.round,
              capType: CapType.round,
              points: [itemList[i-1].latLng, itemList[i].latLng],
              color: Colors.red,
              width: 1,
            ));
          }
        }
        ///绘制结束，刷新UI
        uiController.refreshUI();
        if(onComplete!=null) onComplete(itemList);
      },
    );
  }

  // 线路规划 ShowFields.POLINE,
  static void planning({required List<LatLng> wayPoints, int? strategy, PlanningCallBack? planningBack}) {
    if (wayPoints.length < 2) return;
    routeSearchPage(
      wayPoints: wayPoints,
      strategy: strategy ?? DrivingStrategy.DEFAULT,
      showFields: ShowFields.POLINE,
      back: (code, data) {
        if (code != 1000) {
          ToLatLng southwest, northeast;
          if (wayPoints[0].latitude < wayPoints[0].latitude) {
            southwest = ToLatLng.from(wayPoints[0]);
            northeast = ToLatLng.from(wayPoints[1]);
          } else {
            southwest = ToLatLng.from(wayPoints[1]);
            northeast = ToLatLng.from(wayPoints[0]);
          }
          if (planningBack != null) planningBack((code), [], LatLngBounds(southwest: southwest, northeast: northeast));
          return;
        }
        if(data.paths==null|| data.paths!.isEmpty) return;
        if (planningBack != null) {
          List<LatLng> points = PointUtil.listCover(data.paths![0].polyline);
          planningBack(1000, points, PointUtil.lineBounds(points));
        }
      },
    );
  }

  // 线路計算 ShowFields.COST,
  static void calculate({required List<LatLng> wayPoints, int? strategy, CalculateCallBack? calculateBack}) {
    routeSearchPage(
      wayPoints: wayPoints,
      strategy: strategy ?? DrivingStrategy.DEFAULT,
      showFields: ShowFields.COST,
      back: (code, data) {
        if (code != 1000) return;
        if(data.paths==null|| data.paths!.isEmpty) return;
        if(calculateBack != null){
          calculateBack(data.paths![0].distance?.toInt()??0,data.paths![0].duration?.toInt()??0);
        }
      },
    );
  }

  //线路规划+计算
  static void route({required List<LatLng> wayPoints, int? strategy, PlanningCallBack? planningBack, CalculateCallBack? calculateBack}) {
    routeSearchPage(
      wayPoints: wayPoints,
      strategy: strategy ?? DrivingStrategy.DEFAULT,
      showFields: ShowFields.POLINE+ShowFields.COST,
      back: (code, data) {
        if (code != 1000) {
          ToLatLng southwest, northeast;
          if (wayPoints[0].latitude < wayPoints[0].latitude) {
            southwest = ToLatLng.from(wayPoints[0]);
            northeast = ToLatLng.from(wayPoints[1]);
          } else {
            southwest = ToLatLng.from(wayPoints[1]);
            northeast = ToLatLng.from(wayPoints[0]);
          }
          if (planningBack != null) planningBack((code), [], LatLngBounds(southwest: southwest, northeast: northeast));
          if (calculateBack != null) calculateBack(0,0);
          return;
        }
        if(data.paths==null|| data.paths!.isEmpty) return;
        if (planningBack != null) {
          List<LatLng> points = PointUtil.listCover(data.paths![0].polyline);
          planningBack(1000, points, PointUtil.lineBounds(points));
        }
        if(calculateBack != null){
          calculateBack(data.paths![0].distance?.toInt()??0,data.paths![0].duration?.toInt()??0);
        }
      },
    );
  }

  static Future<void> routeSearchPage({
    required List<LatLng> wayPoints,
    int? strategy,
    int? showFields,//ShowFields.
    RouteResultBack? back,
  }) async {
    if(wayPoints.length<2) return;
    int pageLimit = 7; // 最大6个途经点即8个点，预留上一个连接点，正好每页7个
    //需要采集的数据，分页只返回一條綫路
    List<String> polylineList = [];
    num distance = 0;
    num duration = 0;
    //开始分页采集
    nextPage(page,limit) async {
      List<LatLng> pagePoints = paging<LatLng>(wayPoints, page, pageLimit);
      if(pagePoints.isEmpty){
        if(back!=null) back(1000,RouteResult(paths: [Path(polyline:polylineList.join(";"),distance: distance,duration: duration)]));
        return;
      }
      if(page>1) pagePoints.insert(0,pagingLast<LatLng>(wayPoints, page-1, pageLimit));//加入上一页的最后一个点，插在首位
      XbrSearch.routeSearch(wayPoints:pagePoints,strategy:strategy,showFields:showFields, back:(int? code, RouteResult data){
        if(code != 1000) {
          if(back!=null) back(code,data);//只要有一页报错，线路中断，就不要继续了
          return;
        }
        if(data.paths==null || data.paths!.isEmpty) {
          nextPage(page+1, pageLimit);
          return;
        }
        List<String>? pointStr = data.paths?[0].polyline?.split(";");
        if(pointStr!=null) polylineList.addAll(pointStr);
        duration += data.paths?[0].duration??0;
        distance += data.paths?[0].distance??0;
        nextPage(page+1, pageLimit);
      });
    }
    nextPage(1,pageLimit);
  }

  static Future<void> truckRouteSearchPage({
    required List<LatLng> wayPoints,
    int? drivingMode,
    TruckInfo? truckInfo,
    int? showFields,//ShowFields.
    RouteResultBack? back,
  }) async {
    if(wayPoints.length<2) return;
    int pageLimit = 7; // 最大6个途经点即8个点，预留上一个连接点，正好每页7个
    //需要采集的数据，分页只返回一條綫路
    List<String> polylineList = [];
    num distance = 0;
    num duration = 0;
    //开始分页采集
    nextPage(page,limit) async {
      List<LatLng> pagePoints = paging<LatLng>(wayPoints, page, pageLimit);
      if(pagePoints.isEmpty){
        if(back!=null) back(1000,RouteResult(paths: [Path(polyline:polylineList.join(";"),distance: distance,duration: duration)]));
        return;
      }
      if(page>1) pagePoints.insert(0,pagingLast<LatLng>(wayPoints, page-1, pageLimit));//加入上一页的最后一个点，插在首位
      XbrSearch.truckRouteSearch(wayPoints:pagePoints,drivingMode:drivingMode,showFields:showFields,truckInfo:truckInfo, back:(int? code, RouteResult data){
        if(code != 1000) {
          if(back!=null) back(code,data);//只要有一页报错，线路中断，就不要继续了
          return;
        }
        if(data.paths==null || data.paths!.isEmpty) {
          nextPage(page+1, pageLimit);
          return;
        }
        List<String>? pointStr = data.paths?[0].polyline?.split(";");
        if(pointStr!=null) polylineList.addAll(pointStr);
        duration += data.paths?[0].duration??0;
        distance += data.paths?[0].distance??0;
        nextPage(page+1, pageLimit);
      });
    }
    nextPage(1,pageLimit);
  }

  /// 分页page 1 开始
  static List<T> paging<T>(List<T> list, int page, int limit) {
    List<T> listSort = [];
    int size = list.length;
    int pageStart = page == 1 ? 0 : (page - 1) * limit;//截取的开始位置
    int pageEnd = math.min(size, page * limit);//截取的结束位置
    if (size > pageStart) listSort = list.sublist(pageStart, pageEnd);
    return listSort;
  }

  static T pagingLast<T>(List<T> list, int page, int limit) {
    var pagingList = paging<T>(list, page, limit);
    return pagingList.last;
  }

}


class PlanItem {
  final LatLng latLng;
  final String? iconPath;
  final bool showScope;
  final double scope;
  final bool showConnecting;

  final String? markerId;
  final String? scopeId;
  final String? conineId;

  PlanItem({
    required this.latLng,
    this.iconPath,
    this.showScope = false,
    this.scope = 300,
    this.showConnecting = false,
    this.markerId,
    this.scopeId,
    this.conineId,
  });
}
