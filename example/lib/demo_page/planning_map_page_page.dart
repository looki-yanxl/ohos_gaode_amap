import 'package:flutter/material.dart';
import 'package:xbr_gaode_amap/_core/location_info.dart';
import 'package:xbr_gaode_amap/amap/amap_widget.dart';
import 'package:xbr_gaode_amap/amap/base/amap_flutter_base.dart';
import 'package:xbr_gaode_amap/amap/core/xbr_ui_controller.dart';
import 'package:xbr_gaode_amap/amap/map/amap_flutter_map.dart';
import 'package:xbr_gaode_amap/amap/map/src/types/bitmap.dart';
import 'package:xbr_gaode_amap/amap/map/src/types/camera.dart';
import 'package:xbr_gaode_amap/amap/map/src/types/marker.dart';
import 'package:xbr_gaode_amap/amap/map/src/types/polygon.dart';
import 'package:xbr_gaode_amap/amap/utils/amap_util.dart';
import 'package:xbr_gaode_amap/location/xbr_location_service.dart';
import 'package:xbr_gaode_amap/search/utils/search_util.dart';


///线路规划示例
class PlanningMapPage extends StatefulWidget {
  @override
  _PlanningPageState createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningMapPage> {
  AMapUIController uiController = AMapUIController();
  AMapController? mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("线路规划示例"),
      ),
      body: AmapWidget(
        initCameraPosition: CameraPosition(target: LatLng(26.653841, 106.642904), bearing: 45, zoom: 12, tilt: 15),
        uiController: uiController,
        onMapCreated: (AMapController controller) {
          mapController = controller;
          onMapCreated(controller);
        },
      ),
    );
  }

  ///地图创建完成
  void onMapCreated(AMapController controller) {

    //快速线路规划
    SearchUtil.routePlanningDraw(
      uiController: uiController,
      mapController: controller,
      lineImgPath: "res/traffic_texture_blue.png",
      pathlineId: "pathline",//线路绘制ID,地图唯一
      itemList: [
        PlanItem(
          latLng: LatLng(26.638016, 106.795478),
          iconPath: 'res/icon_start.png',
          showScope: true,
          scope: 500,//电子围栏触发距离 500米
          scopeId: "scope1",
        ),
        PlanItem(
          latLng: LatLng(26.641678, 106.786593),
          iconPath: 'res/icon_way.png',
          showScope: true,
          showConnecting: true,
          scopeId: "scope2",
        ),
        PlanItem(
          latLng: LatLng(26.630416, 106.765305),
          iconPath: 'res/icon_way.png',
          showScope: true,
          showConnecting: true,
          scopeId: "scope3",
        ),
        PlanItem(
          latLng: LatLng(26.556585, 106.768857),
          iconPath: 'res/icon_end.png',
          showScope: true,
          showConnecting: true,
          scopeId: "scope4",
        ),
      ],
      onComplete: (itemList ){
        ///开始定位：这里可以做一个电子围栏
        XbrLocation.instance().startTimeLocation(callback: (LocationInfo? location){
          if(location==null||location.latitude==null||location.longitude==null) return;
          ///利用UI控制器将定位绘制到地图上
          uiController.saveMarker("my_location", Marker(
            position: LatLng(location.latitude!,location.longitude!),
            flat: true, //flat是将图片贴在地图上，跟随真实方向旋转
            rotation: location.bearing ?? 0, //flat=true可跟随真实方向旋转，否则只是在UI上旋转
            icon: BitmapDescriptor.fromIconPath('res/icon_car.png'),
          ));
          ///模拟触发提交点位电子围栏
          for(int i=0;i< itemList.length;i++){
            Polygon? polygon = uiController.getPolygon!(itemList[i].scopeId??"scopePolygon$i");
            if(polygon != null){
              var polygonPointList = AmapUtil.getCirclePoints(center: itemList[i].latLng,radiusMi: itemList[i].scope);

              Polygon polygonNew;
              if(AMapTools.latLngIsInPolygon(LatLng(location.latitude!,location.longitude!),polygonPointList)){
                //定位在触发范围内 范围变绿
                polygonNew = polygon.copyWith(fillColorParam: Colors.green.withOpacity(0.3));
              }else{
                //定位不在触发范围内 范围变红
                polygonNew = polygon.copyWith(fillColorParam: Colors.red.withOpacity(0.3));
              }
              uiController.savePolygon(itemList[i].scopeId??"scopePolygon$i",polygonNew);
            }
          }
          ///刷新UI
          uiController.refreshUI();
        });
      }
    );
  }

  @override
  void dispose() {
    mapController?.disponse();
    uiController.dispose();
    //页面销毁时也要停止定位，如果需要后台定位，就不要吧定位数据显示在可销毁的页面UI上
    XbrLocation.instance().destroyBackgroundLocation();
    super.dispose();
  }
}
