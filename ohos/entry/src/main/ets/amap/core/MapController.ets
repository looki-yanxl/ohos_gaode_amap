import { LogUtil } from '@amap/amap_lbs_common';
import {
  AMap,
  CameraPosition,
  CameraUpdate,
  CameraUpdateFactory,
  CustomMapStyleOptions,
  LatLngBounds,
  MapView,
  MyLocationStyle,
  OnCameraChangeListener
} from '@amap/amap_lbs_map3d';
import { MethodCall, MethodChannel, MethodResult } from '@ohos/flutter_ohos';
import Const from '../util/Const';
import image from '@ohos.multimedia.image';
import { ConvertUtil } from '../util/ConvertUtil';
import { geoLocationManager } from '@kit.LocationKit';
import { MyMethodCallHandler } from '../MyMethodCallHandler';

export default class MapController implements MyMethodCallHandler{
  private hasStarted: boolean = false;
  private methodChannel: MethodChannel | undefined;
  private amap: AMap | undefined;
  private mapView: MapView | undefined;
  private mapReadyResult: MethodResult | undefined;
  protected myArray: number[] = [];
  public CLASS_NAME = "MapController";
  private mapLoaded: boolean = false;
  private myLocationShowing: boolean = false;

  constructor(methodChannel: MethodChannel, mapView: MapView) {

    this.methodChannel = methodChannel;
    this.mapView = mapView;


    this.mapView.getMapAsync((amap: AMap) => {
      this.amap = amap;
      this.amap?.setOnMapLoadedListener(() => this.onMapLoaded());
      this.amap?.setOnMyLocationChangeListener((location: geoLocationManager.Location) => this.onMyLocationChange(location));
      this.amap?.setOnCameraChangeListener(new OnCameraChangeListener((position: CameraPosition) => {
        if (null != this.methodChannel) {
          const cameraChangeMap = new Map<String, Object | null>();
          cameraChangeMap.set("position", ConvertUtil.cameraPositionToMap(position));
          this.methodChannel?.invokeMethod("camera#onMove", cameraChangeMap);
          LogUtil.i(this.CLASS_NAME, "onCameraChange===>" + cameraChangeMap, "");
        }
      }, (position: CameraPosition) => {
        if (null != this.methodChannel) {
          const cameraChangeFinishMap = new Map<String, Object | null>();
          cameraChangeFinishMap.set("position", ConvertUtil.cameraPositionToMap(position));
          this.methodChannel.invokeMethod("camera#onMoveEnd", cameraChangeFinishMap);
          LogUtil.i(this.CLASS_NAME, "onCameraChangeFinish===>" + cameraChangeFinishMap, "");
        }
      }));
      this.amap?.setOnMapLongClickListener((latLng) => {
        if (null != methodChannel) {
          const longClickMap = new Map<String, Object | null>();
          longClickMap.set("latLng", ConvertUtil.latLngToList(latLng));
          methodChannel.invokeMethod("map#onLongPress", longClickMap);
          LogUtil.i(this.CLASS_NAME, "onMapLongClick===>" + longClickMap, "");
        }
      });
      this.amap?.setOnMapClickListener((latLng) => {
        if (null != methodChannel) {
          const mapClick = new Map<String, Object | null>();
          mapClick.set("latLng", ConvertUtil.latLngToList(latLng));
          methodChannel.invokeMethod("map#onTap", mapClick);
          LogUtil.i(this.CLASS_NAME, "onMapClick===>" + mapClick, "");
        }
      });
      this.amap?.addOnPOIClickListener((poi) => {
        if (null != methodChannel) {
          const poiMap = new Map<String, Object | null>();
          poiMap.set("poi", ConvertUtil.poiToMap(poi));
          methodChannel.invokeMethod("map#onPoiTouched", poiMap);
          LogUtil.i(this.CLASS_NAME, "onPOIClick===>" + poiMap, "");
        }
      });
    })
  }


  public getRegisterMethodIdArray(): String[] {
    return Const.METHOD_ID_LIST_FOR_MAP;
  }

  public doMethodCall(call: MethodCall, result: MethodResult): void {

    LogUtil.i(this.CLASS_NAME, "doMethodCall===>" + call.method, "");
    if (null == this.amap) {
      LogUtil.w(this.CLASS_NAME, "onMethodCall amap is null!!!", "");
      return;
    }
    switch (call.method) {
      case Const.METHOD_MAP_WAIT_FOR_MAP:
        if (this.mapLoaded) {
          result.success(null);
          return;
        }
        this.mapReadyResult = result;
        break;
      case Const.METHOD_MAP_SATELLITE_IMAGE_APPROVAL_NUMBER:
        result.success(this.amap.getSatelliteImageApprovalNumber());
        break;
      case Const.METHOD_MAP_CONTENT_APPROVAL_NUMBER:
        result.success(this.amap.getMapContentApprovalNumber());
        break;
      case Const.METHOD_MAP_UPDATE:
        ConvertUtil.interpretAMapOptions(call.argument("options"), this);
        let cameraPosition = this.getCameraPosition()
        if (cameraPosition != undefined) {
          result.success(ConvertUtil.cameraPositionToMap(cameraPosition));
        }
        break;
      case Const.METHOD_MAP_MOVE_CAMERA:
        const cameraUpdate = ConvertUtil.toCameraUpdate(call.argument("cameraUpdate"));
        const animatedObject = call.argument("animated") as boolean;
        const durationObject = call.argument("duration") as number;

        this.moveCamera(cameraUpdate, animatedObject, durationObject);
        break;
      case Const.METHOD_MAP_SET_RENDER_FPS:
        this.amap.setRenderFps(call.argument("fps") as number);
        result.success(null);
        break;
      case Const.METHOD_MAP_TAKE_SNAPSHOT:
        const _result = result;
        this.amap?.getMapScreenShot({
          onMapScreenShot: (mapScreenShot: PixelMap | undefined, status: number) => {

            if (mapScreenShot) {
              LogUtil.i(this.CLASS_NAME, "截屏完成", "");

              const byteArray = pixelMapToByteArray(mapScreenShot)
              _result.success(byteArray);
            } else {
              LogUtil.i(this.CLASS_NAME, "截屏失败, 请等待地图加载完成", "");

            }
          }
        });


        break;
      case Const.METHOD_MAP_CLEAR_DISK:
        this.amap?.clear(true)
        result.success(null);
        break;
      default:
        LogUtil.w(this.CLASS_NAME, "onMethodCall not find methodId:" + call.method, "");
        break;
    }
  }


  public onMapLoaded(): void {
    LogUtil.i(this.CLASS_NAME, "onMapLoaded==>", "");
    try {
      this.mapLoaded = true;
      if (null != this.mapReadyResult) {
        this.mapReadyResult.success(null);
        this.mapReadyResult = undefined;
      }
    } catch (e) {
      LogUtil.e(this.CLASS_NAME, "onMapLoaded", e);
    }
    // if (LogUtil.isDebugMode && !this.hasStarted) {
    //   this.hasStarted = true;
    // }
  }


  onMyLocationChange(location: geoLocationManager.Location): void {
    if (null != this.methodChannel && this.myLocationShowing) {
      const locationMap = new Map<String, Object | null>();
      locationMap.set("location", ConvertUtil.location2Map(location));
      this.methodChannel.invokeMethod("location#changed", locationMap);
      LogUtil.i(this.CLASS_NAME, "onMyLocationChange===>" + locationMap, "");
    }
  }


  moveCamera(cameraUpdate: CameraUpdate, animatedObject: Object, durationObject: Object): void {
    let animated = false;
    let duration = 250;
    if (null != animatedObject) {
      animated = animatedObject as boolean;
    }
    if (null != durationObject) {
      duration = durationObject as number;
    }
    if (null != this.amap) {
      if (animated) {
        this.amap?.animateCamera(cameraUpdate, null, duration);
      } else {
        this.amap?.moveCamera(cameraUpdate);
      }
    }
  }

  getCameraPosition(): CameraPosition | undefined {
    if (null != this.amap) {
      return this.amap.getCameraPosition();
    }
    return undefined;
  }


  setCamera(camera: CameraPosition): void {
    this.amap?.moveCamera(CameraUpdateFactory.newCameraPosition(camera));
  }

  setMapType(mapType: number): void {
    this.amap?.setMapType(mapType)
  }

  setCustomMapStyleOptions(customMapStyleOptions: CustomMapStyleOptions): void {
    if (null != this.amap) {
      this.amap.setCustomMapStyle(customMapStyleOptions);
    }
  }

  setMyLocationStyle(myLocationStyle: MyLocationStyle): void {
    if (null != this.amap) {
      this.myLocationShowing = myLocationStyle.isMyLocationShowing();
      this.amap.setMyLocationEnabled(this.myLocationShowing);
      this.amap.setMyLocationStyle(myLocationStyle);
    }
  }

  setScreenAnchor(x: number, y: number): void {
    this.amap?.setPointToCenter(0.5, 0.5);
  }

  setMinZoomLevel(minZoomLevel: number): void {
    this.amap?.setMinZoomLevel(minZoomLevel);
  }

  setMaxZoomLevel(maxZoomLevel: number): void {
    this.amap?.setMaxZoomLevel(maxZoomLevel);
  }


  setLatLngBounds(latLngBounds: LatLngBounds): void {
    this.amap?.setMapStatusLimits(latLngBounds);
  }

  setTrafficEnabled(trafficEnabled: boolean): void {
    this.amap?.setTrafficEnabled(trafficEnabled);
  }

  setTouchPoiEnabled(touchPoiEnabled: boolean): void {
    this.amap?.setTouchPoiEnable(touchPoiEnabled);
  }

  setBuildingsEnabled(buildingsEnabled: boolean): void {
    this.amap?.showBuildings(buildingsEnabled);
  }

  setLabelsEnabled(labelsEnabled: boolean): void {
    this.amap?.showMapText(labelsEnabled);
  }

  setCompassEnabled(compassEnabled: boolean): void {
    this.amap?.getUiSettings()?.setCompassEnabled(compassEnabled);
  }

  setScaleEnabled(scaleEnabled: boolean): void {
    this.amap?.getUiSettings()?.setScaleControlsEnabled(scaleEnabled);
  }

  setZoomGesturesEnabled(zoomGesturesEnabled: boolean): void {
    this.amap?.getUiSettings()?.setZoomGesturesEnabled(zoomGesturesEnabled);
  }

  setScrollGesturesEnabled(scrollGesturesEnabled: boolean): void {
    this.amap?.getUiSettings()?.setScrollGesturesEnabled(scrollGesturesEnabled);
  }

  setRotateGesturesEnabled(rotateGesturesEnabled: boolean): void {
    this.amap?.getUiSettings()?.setRotateGesturesEnabled(rotateGesturesEnabled)
  }

  setTiltGesturesEnabled(tiltGesturesEnabled: boolean): void {
    this.amap?.getUiSettings()?.setTiltGesturesEnabled(tiltGesturesEnabled);
  }

  setInitialMarkers(initialMarkers: Object): void {
  }

  setInitialPolylines(initialPolylines: Object): void {
  }

  setInitialPolygons(initialPolygons: Object): void {
  }

  setGestureScaleByMapCenter(gestureScaleByMapCenter: boolean): void {
    this.amap?.getUiSettings()?.setGestureScaleByMapCenter(gestureScaleByMapCenter);
  }
}


async function pixelMapToByteArray(pixelMap: image.PixelMap): Promise<Uint8Array> {
  // 创建ImagePacker
  const imagePackerApi = image.createImagePacker();

  try {
    // 将PixelMap打包为PNG格式
    const packingOptions: image.PackingOption = {
      format: "image/png",
      quality: 100
    };

    // 打包图像数据
    const arrayBuffer = await imagePackerApi.packing(pixelMap, packingOptions);

    // 转换为Uint8Array
    const uint8Array = new Uint8Array(arrayBuffer);

    return uint8Array;
  } finally {
    // 释放资源
    imagePackerApi.release();
  }
}
