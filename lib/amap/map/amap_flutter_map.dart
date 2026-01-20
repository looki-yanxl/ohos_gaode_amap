/// 高德地图Flutter插件入口文件
library amap_flutter_map;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ohos_gaode_amap/amap/map/src/core/amap_flutter_platform.dart';
import 'package:ohos_gaode_amap/amap/map/src/core/map_event.dart';
import 'package:ohos_gaode_amap/amap/map/src/core/method_channel_amap_flutter_map.dart';
import 'package:ohos_gaode_amap/amap/map/src/types/base_overlay.dart';
import 'package:ohos_gaode_amap/amap/map/src/types/camera.dart';
import 'package:ohos_gaode_amap/amap/map/src/types/marker.dart';
import 'package:ohos_gaode_amap/amap/map/src/types/marker_updates.dart';
import 'package:ohos_gaode_amap/amap/map/src/types/polygon.dart';
import 'package:ohos_gaode_amap/amap/map/src/types/polygon_updates.dart';
import 'package:ohos_gaode_amap/amap/map/src/types/polyline.dart';
import 'package:ohos_gaode_amap/amap/map/src/types/polyline_updates.dart';
import 'package:ohos_gaode_amap/amap/map/src/types/ui.dart';

import '../base/amap_flutter_base.dart';

part 'src/amap_controller.dart';
part 'src/amap_widget.dart';
