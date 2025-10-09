import 'package:flutter/material.dart';
import 'package:xbr_gaode_amap/xbr_gaode_amap.dart';
import 'package:xbr_gaode_amap_example/core/confirm_dialog.dart';
import 'package:xbr_gaode_amap_example/core/permission_util.dart';

import 'demo_page/amap_search_page.dart';
import 'demo_page/location_map_page_page.dart';
import 'demo_page/planning_map_page_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    //测试时可以用下面的KEY,这是本人申请的个人账户，上线自己申请
    initKey(
      androidKey:"0d0a960349e6b9cfcbffa6bf5d8b553e",
      iosKey: "6576199a6c246345e57fee50d2edc8d1",
    );
  }

  //建议在工具类一键处理 key应该都一样
  void initKey({androidKey, iosKey}){
    //地图初始化
    XbrGaodeAmap.initKey(androidKey: androidKey, iosKey:iosKey);
    XbrGaodeAmap.updatePrivacy(hasContains: true,hasShow: true,hasAgree: true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

///测试页
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool permissionSuccess = false;
  String permissionMessage = "正在授权";

  @override
  void initState() {
    super.initState();
    initPermission();
  }

  ///动态权限
  initPermission() {
    PermissionUtil.requestPermissions(context, (success, msg) {
      setState(() {
        permissionSuccess = success;
        permissionMessage = msg;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('小镖人高德地图测试'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(permissionMessage),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("打开高德地图--显示定位，位置标注"),
              onPressed: () {
                if (permissionSuccess == false) {
                  ConfirmDialog.show(context, title: "授权未成功", text: "重新授权？", surePass: () {
                    initPermission();
                  });
                  return;
                }
                Navigator.push(context, MaterialPageRoute(builder: (context) => LocationMapPage()));
              },
            ),
            // ElevatedButton(
            //   child: Text("打开高德地图--地址搜索"),
            //   onPressed: () {
            //     Navigator.push(context, MaterialPageRoute(builder: (context) => AmapSearchPage()));
            //   },
            // ),
            ElevatedButton(
              child: Text("打开高德地图--线路规划"),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PlanningMapPage()));
              },
            ),
            ElevatedButton(
              child: Text("猎鹰轨迹--日志窗口"),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PlanningMapPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
