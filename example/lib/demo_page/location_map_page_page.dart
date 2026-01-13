import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ohos_gaode_amap/_core/location_info.dart';
import 'package:ohos_gaode_amap/amap/amap_widget.dart';
import 'package:ohos_gaode_amap/amap/base/amap_flutter_base.dart';
import 'package:ohos_gaode_amap/amap/core/xbr_ui_controller.dart';
import 'package:ohos_gaode_amap/amap/map/amap_flutter_map.dart';
import 'package:ohos_gaode_amap/amap/map/src/types/bitmap.dart';
import 'package:ohos_gaode_amap/amap/map/src/types/camera.dart';
import 'package:ohos_gaode_amap/amap/map/src/types/marker.dart';
import 'package:ohos_gaode_amap/location/xbr_location_service.dart';

///显示定位示例

class LocationMapPage extends StatefulWidget {
  @override
  _PlanningPageState createState() => _PlanningPageState();
}

class _PlanningPageState extends State<LocationMapPage> {
  AMapUIController uiController = AMapUIController();
  AMapController? mapController;

  String info = "等待开始定位";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("显示定位示例"),
      ),
      body: Column(
        children: [
          Expanded(child: AmapWidget(
            initCameraPosition: CameraPosition(target: LatLng(26.637456, 106.796132), bearing: 0, zoom: 16, tilt: 0),
            uiController: uiController,
            onMapCreated: (AMapController controller) {
              this.mapController = controller;

              //TODO:开始定位
              XbrLocation.instance().startTimeLocation(callback: (LocationInfo? location){
                if(location==null||location.latitude==null||location.longitude==null) return;
                ///利用地图控制器移动到定位点 2s动画
                LatLng latLng = LatLng(location.latitude!,location.longitude!);
                mapController?.moveCamera(CameraUpdate.newLatLngZoom(latLng, 16), duration: 2000);

                ///利用UI控制器将定位绘制到地图上
                uiController.saveMarker("my_location", Marker(
                  position: latLng,
                  flat: true, //flat是将图片贴在地图上，跟随真实方向旋转
                  rotation: location.bearing ?? 0, //flat=true可跟随真实方向旋转，否则只是在UI上旋转
                  icon: BitmapDescriptor.fromIconPath('res/icon_car.png'),
                  infoWindow: InfoWindow(
                    title: "当前位置:",
                    snippet: location.address
                  )
                ));
                ///刷新UI
                uiController.refreshUI();

                ///额外：打印定位JSON信息
                setState(() => info = "时间：${location.locationTime}"
                    "\n经纬：${json.encode(latLng)}"
                    "\n速度：${location.speed}"
                    "\n方向：${location.bearing}" //方向有问题，速度为0时方向为0，最好保存定位信息，方向和速度为0时，方向取上一次的数据
                    "\n地理：${location.address}");

              });
            },
          )),

          Container(
            height: 150,
            alignment: Alignment.center,
            child: Text(info),
          )
        ],
      ),
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
