# xbr_gaode_amap

#### 介绍，高德系列：
#####基础包
高德地图合包：xbr_gaode_map  ，包含地图+检索+定位
高德导航合包：xbr_gaode_navi_map  ，包含地图+检索+定位+内置导航
码云地址：https://gitee.com/mywentop/xbr_gaode_navi_amap

演示：

![](http://gzyl.oss-cn-shenzhen.aliyuncs.com/emergencyImg20220409_161315652tupianpinjie.jpg?Expires=1964941960&OSSAccessKeyId=LTAIbSwdJpv7vRhC&Signature=Vo0CvpUVDbz%2Ba4ghrxwORMqALR4%3D)

#### 主要功能

1.增加地图查询插件，查询功能如下

​    （1）关键子检索 POI

​    （2）POI详情

​    （3）线路规划

​    （4）货车线路规划（先去高德客服申请）

​    （5）查询输入提示 InputTips

​    （6）地理编码（地址转坐标）

​    （7）逆地理编码（坐标转地址）

2.定位功能

​    （1）原生部分完全使用官方提供的SDK：amap_flutter_location；未额外增加任何功能，可以使用官方SDK所有方法

​	（2）处理了定位返回数据：IOS和Android兼容（官方sdk只返回Map,而且IOS和Android返回的字段不一致）

​	（3）简化了定位回调，使用：XbrGaodeLocation.startLocation(callback:... )

3.地图功能在官方sdk（amap_flutter_map）做了以下调整

​	（1）原生部分完全使用官方提供的SDK：amap_flutter_map；未额外增加任何功能，但修复了一些BUG

​	（2）简化地图绘制流程，增加地图UI绘制器：AMapUIController()

​	（3）增加了利用多边形绘制圆的方法

​	（4）修复Marker不能平铺在地图上，使用 FMarker 增加了flat字段，为true时可以平铺在地图上

​	（5）协调了地图查询功能和地图的整合，可以一键绘制路线


#### 安装教程
```dart
  xbr_gaode_amap: ^6.0.0
```

#### 使用说明

1. ##### xbr_gaode_amap 已经集成 xbr_gaode_search和xbr_gaode_location ,导包：

   ```dart
   import 'package:xbr_gaode_search/xbr_gaode_search.dart'
   ```

2. ###### xbr_gaode_location 在官方sdk上重新封装过，如需使用，可单独引入：

   (1).定位权限配置，使用第三方 permission_handler 动态权限工具，  使用方法请移步 permission_handler
   (2).xbr_gaode_location使用

   ```dart
       //TODO:开始单次定位 定位成功自动销毁
       XbrGaodeLocation.instance().execOnceLocation(callback: (LocationInfo? location){
           //location 对IOS和Android数据 已兼容处理
   
       });
   
       //TODO:开启连续定位
       XbrGaodeLocation.instance().startTimeLocation(callback：(LocationInfo? location){
           //location 对IOS和Android数据 已兼容处理
       });
   
       @override
       void dispose() {
           mapController?.disponse();
           uiController.dispose();
           //销毁 连续定位
           XbrGaodeLocation.instance().destroyTimeLocation();
           super.dispose();
       }
   ```

3. ###### 地图使用:

   ```dart
    AMapUIController uiController = AMapUIController();
   ```
   //地图控件
   ```dart
   //简单使用，默认了地图部分功能，快速使用
    XbrAmapWidget(
       initCameraPosition: CameraPosition(target: LatLng(26.653841, 106.642904), bearing: 45, zoom: 12, tilt: 15),
       uiController: uiController,
       onMapCreated: (AMapController controller) {
           //地图加载完成
       },
       onCameraMove: (CameraPosition position) {
           //地图移动
       },
       onCameraMoveEnd: (CameraPosition position) {
           //地图移动结束
       }
   )
   //或者使用 需要满足地图所有功能时使用 绘制需要自己控制和刷新 uiController无法使用
   AMapWidget(
      privacyStatement: XbrGaodeAmap.instace().statement,
      apiKey: XbrGaodeAmap.instace().apikey,
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
    )
   ```
   //线路规划
   ```dart
    AmapSearchUtil.routePlanning(
         //最多支持18个点，第一个为起点，最后一个为终点，中间为途径点,
         wayPoints: list,
         callBack: (code, linePoints, bounds) {
               //code 1000为成功
               //linePoints 返回的线点集合，如果需要导航数据，使用方法：XbrAmapSearch.routeSearch() 返回全部数据
               //bounds 计算了一个包含线路所有点位的矩形坐标盒（最大可视面积），移动相机时可以直接使用，如下所示
   
               //绘制规划线 pathlineId 是唯一值 需自定义
               //customTexture：线路Texture图片，可以不设置，使用颜色
               uiController.savePolyline("pathlineId", Polyline(
                 customTexture: lineImgPath!=null?BitmapDescriptor.fromIconPath(lineImgPath):null,
                 joinType: JoinType.round,
                 capType: CapType.round,
                 points: linePoints,
                 color: lineColor??Colors.blueAccent,
                 width: 14,
               ));
               //利用MAP控制器移动相机到线路最大可视面积，边距50，时间1000毫秒，可自行更改
               mapController.moveCamera(CameraUpdate.newLatLngBounds(bounds, 50), duration: 1000);
               ...
               
              ///绘制完要刷新地图
              uiController.refeashUI();
         }
     )
   ```
   //地图绘制
   ```dart
       //1.绘制线
       uiController.savePolyline("pathlineId", Polyline(..));
       //2.绘制marker (flat:可将图片贴在地图上，随3d地图旋转)
       uiController.saveMarker("markerId", FlatMarker(flat:...));
       //3.绘制圆
       //获取圆数据：latLng中心点，radius圆的半径（真实半径:单位-米(m)，可以制作电子围栏））
       var points = AmapUtil.getCirclePoints(center:latLng,radiusMi: radius);
       //利用绘制多边形绘制圆
       uiController.savePolygon("polygonId",Polygon(points:points,...);
       
       ///绘制完要刷新地图
       uiController.refeashUI();
   ```

###### 4.更多使用，请点击Versions选择最新版下载example工程，内含示例：动态权限、关键字检索、地图中心坐标取地址（逆地理编码）、线路规划、电子围栏（模拟触发）、定位跟踪等等

#### 参与贡献

1.  版本内置 高德官方插件  amap_flutter_map，amap_flutter_location，使用前需参考高德API
2.  example中有动态权限功能，使用：permission_handler
3.  本控件由易林物流，XBR-小镖人团队开发并维护。
4.  XBR开发团队：从事物流软件开发、物流AI技术、智慧物流、网络货运


