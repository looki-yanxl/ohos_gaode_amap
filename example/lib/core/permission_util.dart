import 'package:flutter/cupertino.dart';
import 'package:open_apps_settings/open_apps_settings.dart';
import 'package:open_apps_settings/settings_enum.dart';
import 'package:permission_handler/permission_handler.dart';

import 'confirm_dialog.dart';

typedef CallBack = Function(bool success, String msg);

///动态授权工具
///取消授权，可以重新开启
///授权失败，可以引导开启
class PermissionUtil {
  static requestPermissions(BuildContext context, CallBack callBack) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.location,
      Permission.locationAlways,
    ].request();
    List deniedNames = [];
    List pDeniedNames = [];
    statuses.forEach((key, value) {
      if (value.isDenied) {
        deniedNames = _addNames(deniedNames, key);
      } else if (value.isPermanentlyDenied) {
        pDeniedNames = _addNames(pDeniedNames, key);
      }
    });
    if (deniedNames.isNotEmpty) {
      List list1 = _listContains(deniedNames, ["存储权限", "定位权限", "后台定位权限"]);
      if (list1.isNotEmpty) {
        bool al = list1.contains("后台定位权限");
        ConfirmDialog.show(
          context,
          title: "已取消授权",
          text: "您取消了授权:${list1.join("、")}，将导致程序功能无法使用，请重新开启${al ? "，定位/位置信息 请选择“始终允许”" : ""}",
          backDismissible: false,
          sureBtnTx: "重新开启",
          cancelBtnTx: "取消",
          surePass: () async {
            requestPermissions(context, callBack);
          },
          cancelPass: () {
            callBack(false, "您取消了授权");
          },
        );
      }
    } else if (pDeniedNames.isNotEmpty) {
      List list1 = _listContains(pDeniedNames, ["存储权限", "定位权限", "后台定位权限"]);
      if (list1.isNotEmpty) {
        bool al = list1.contains("后台定位权限");
        ConfirmDialog.show(
          context,
          title: "您拒绝了授权",
          text: "您拒绝了${list1.join("、")}，将导致程序功能无法使用，请【打开设置】>【权限管理】开启上诉权限${al ? "，定位/位置信息 请选择“始终允许”" : ""}",
          backDismissible: false,
          sureBtnTx: "打开设置",
          cancelBtnTx: "退出",
          surePass: () {
            OpenAppsSettings.openAppsSettings(
              settingsCode: SettingsCode.APP_SETTINGS,
              onCompletion: () {
                requestPermissions(context, callBack);
              },
            );
          },
          cancelPass: () {
            callBack(false, "您拒绝了授权,需要手动开启");
          },
        );
      }
    } else {
      callBack(true, "已完成授权");
    }
  }

  static List _addNames(names, key) {
    if (key == Permission.storage) {
      names.add("存储权限");
    } else if (key == Permission.location) {
      names.add("定位权限");
    } else if (key == Permission.locationAlways) {
      names.add("后台定位权限");
    }
    return names;
  }

  static List _listContains(List listA, List listC) {
    List listD = [];
    if (listA.isEmpty) return listD;
    for (var o in listC) {
      if (listA.contains(o)) listD.add(o);
    }
    return listD;
  }
}
