// import 'package:flutter/material.dart';
// import 'package:material_floating_search_bar/material_floating_search_bar.dart';
// import 'package:xbr_gaode_amap/_core/location_info.dart';
// import 'package:xbr_gaode_amap/amap/amap_widget.dart';
// import 'package:xbr_gaode_amap/amap/base/amap_flutter_base.dart';
// import 'package:xbr_gaode_amap/amap/core/xbr_ui_controller.dart';
// import 'package:xbr_gaode_amap/amap/map/amap_flutter_map.dart';
// import 'package:xbr_gaode_amap/amap/map/src/types/bitmap.dart';
// import 'package:xbr_gaode_amap/amap/map/src/types/camera.dart';
// import 'package:xbr_gaode_amap/amap/map/src/types/marker.dart';
// import 'package:xbr_gaode_amap/amap/utils/amap_util.dart';
// import 'package:xbr_gaode_amap/location/xbr_location_service.dart';
// import 'package:xbr_gaode_amap/search/entity/input_tip_result.dart';
// import 'package:xbr_gaode_amap/search/xbr_search.dart';
//
//
// class AmapSearchPage extends StatefulWidget {
//   @override
//   State<AmapSearchPage> createState() => _AmapSearchPageState();
// }
//
// class _AmapSearchPageState extends State<AmapSearchPage> {
//   AMapUIController uiController = AMapUIController();
//   AMapController? mapController;
//
//   String uiCurrentPoint = "";
//   String? uiCurrentAddress;
//   String? uiCurrentCity;
//   List<InputTipResult>? list;//下拉数据 最好用provider局部刷新
//   ////mapController?.moveCamera(CameraUpdate.newLatLngZoom(location.latLng!, 18));
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           AmapWidget(
//             initCameraPosition: CameraPosition(target: LatLng(26.653841, 106.642904), bearing: 45, zoom: 12, tilt: 15),
//             uiController: uiController,
//             gestureScaleByMapCenter: true,
//             onMapCreated: (AMapController controller) {
//               mapController = controller;
//               //创建完成时，可以将地图移动到当前位置
//               //TODO:开始定位 单次定位，结束自毁
//               XbrLocation.instance().execOnceLocation(callback: (LocationInfo? location){
//                 if(location==null||location.latitude==null||location.longitude==null) return;
//                 mapController?.moveCamera(CameraUpdate.newLatLngZoom(LatLng(location.latitude!,location.longitude!), 16), duration: 2000);
//               });
//             },
//             onCameraMove: (CameraPosition position) {
//               //地图移动时，获取屏幕中心位置 将poi_pin始终移动到屏幕中心
//               //saveMarker重复操作同一KEY不会增加,只会更新
//               uiController.saveMarker("poi_pin", Marker(
//                 position: position.target,
//                 icon: BitmapDescriptor.fromIconPath('res/pin_red.png'),
//               ));
//               uiController.refreshUI();
//
//               ///UI调试 坐标显示
//               setState(() {
//                 uiCurrentPoint = "${position.target.toJson().toString()}";
//               });
//             },
//             onCameraMoveEnd: (CameraPosition position) {
//               uiController.saveMarker("poi_pin", Marker(
//                 position: position.target,
//                 icon: BitmapDescriptor.fromIconPath('res/pin_blue.png'),
//               ));
//               uiController.refreshUI();
//
//               //移动结束时 去请求逆地理编码 获取位置POI信息
//               XbrSearch.reGeocoding(point: ToMLatLng.from(position.target), back: (code, data) {
//                 setState(() {
//                   uiCurrentAddress = data.regeocodeAddress?.formattedAddress;
//                   uiCurrentCity = data.regeocodeAddress?.addressComponent?.city;
//                 });
//               });
//             },
//           ),
//           Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 color: Colors.white,
//                 alignment: Alignment.center,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text("当前中心坐标：$uiCurrentPoint"),
//                     SizedBox(height: 20),
//                     Text(uiCurrentAddress ?? "正在获取地理位置"),
//                     SizedBox(height: 20),
//                   ],
//                 ),
//               )),
//           buildFloatingSearchBar(
//             onQueryChanged:(query) {
//               XbrSearch.inputTips(newText: query, back: (code, list) {
//                 setState(() {
//                   this.list = list;
//                 });
//               });
//             },
//             onDataBack:(InputTipResult result){
//               if(result.location!=null){
//                 controller.close();
//                 mapController?.moveCamera(CameraUpdate.newLatLngZoom(ToLatLng.from(result.location!), 18));
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   ///这是一个可以自动填充数据的输入框
//   ///第三方插件地址 https://pub.dev/packages/material_floating_search_bar ❤ 1211
//   ///测试用，也可以自己写
//   FloatingSearchBarController controller = FloatingSearchBarController();
//   Widget buildFloatingSearchBar({onQueryChanged,onDataBack}) {
//     final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
//     return FloatingSearchBar(
//       hint: '关键词检索示例...',
//       scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
//       transitionDuration: const Duration(milliseconds: 800),
//       transitionCurve: Curves.easeInOut,
//       physics: const BouncingScrollPhysics(),
//       axisAlignment: isPortrait ? 0.0 : -1.0,
//       openAxisAlignment: 0.0,
//       controller:controller,
//       width: isPortrait ? 600 : 500,
//       debounceDelay: const Duration(milliseconds: 500),
//       onQueryChanged: onQueryChanged,
//       // Specify a custom transition to be used for
//       // animating between opened and closed stated.
//       transition: CircularFloatingSearchBarTransition(),
//       actions: [
//         FloatingSearchBarAction(
//           showIfOpened: false,
//           child: CircularButton(
//             icon: const Icon(Icons.place),
//             onPressed: () {},
//           ),
//         ),
//         FloatingSearchBarAction.searchToClear(
//           showIfClosed: false,
//         ),
//       ],
//       builder: (context, transition) {
//         return ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: Material(
//             color: Colors.white,
//             elevation: 4.0,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: function(() {
//                 if (list == null) return <Widget>[];
//                 List<Widget> widgetList = [];
//                 for (InputTipResult data in list!) {
//                   widgetList.add(SizedBox(
//                     width: double.infinity,
//                     child: TextButton(
//                       style: TextButton.styleFrom(padding: EdgeInsets.all(16)),
//                       child: SizedBox(
//                         width:double.infinity,
//                         child:Row(
//                           children: [
//                             Expanded(child: Text(data.name??"-",style:TextStyle(fontSize: 16))),
//                             if(data.location!=null) Icon(Icons.near_me),
//                           ],
//                         ),
//                       ),
//                       onPressed: () {
//                         if(onDataBack!=null)onDataBack(data);
//                       },
//                     ),
//                   ));
//                 }
//                 return widgetList;
//               }),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
// }
//
// T function<T>(dynamic a) {
//   return a();
// }
