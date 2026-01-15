import {
  AMapPrivacyAgreeStatus,
  AMapPrivacyInfoStatus,
  AMapPrivacyShowStatus,
  LogUtil,
  TextUtils
} from '@amap/amap_lbs_common';
import {
  BitmapDescriptor,
  BitmapDescriptorFactory,
  CameraPosition,
  CameraUpdate,
  CameraUpdateFactory,
  CustomMapStyleOptions,
  LatLng,
  LatLngBounds,
  MapsInitializer,
  MapType,
  MyLocationStyle,
  Poi,
  Point
} from '@amap/amap_lbs_map3d';
import { AMapException, ServiceSettings } from '@amap/amap_lbs_search';
import { FlutterInjector } from '@ohos/flutter_ohos';
import { AMapOptionsSink } from '../core/AMapOptionsSink';
import { ArrayList } from '@kit.ArkTS';
import { geoLocationManager } from '@kit.LocationKit';
import { image } from '@kit.ImageKit';

export class ConvertUtil {
  private static CLASS_NAME = "ConvertUtil";
  public static density: number;
  private static apiKey: string;

  public static setPrivacyStatement(context: Context, object: Object): void {
    if (null == object) {
      return;
    }

    let privacyStatementMap = ConvertUtil.toMap(object);
    let hasContainsObj = privacyStatementMap.get("hasContains");
    let hasShowObj = privacyStatementMap.get("hasShow");
    let hasAgreeObj = privacyStatementMap.get("hasAgree");

    if (null != hasContainsObj && null != hasShowObj) {
      let hasContains = ConvertUtil.toBoolean(hasContainsObj);
      let hasShow = ConvertUtil.toBoolean(hasShowObj);

      ServiceSettings.updatePrivacyShow(hasShow ? AMapPrivacyShowStatus.DidShow : AMapPrivacyShowStatus.NotShow,
        hasContains ? AMapPrivacyInfoStatus.DidContain : AMapPrivacyInfoStatus.NotContain, getContext())
    }

    if (null != hasAgreeObj) {
      let hasAgree = ConvertUtil.toBoolean(hasAgreeObj);

      ServiceSettings.updatePrivacyAgree(hasAgree ? AMapPrivacyAgreeStatus.DidAgree : AMapPrivacyAgreeStatus.NotAgree,
        getContext())

    }
  }

  public static checkApiKey(object: Object): void {
    if (null == object) {
      return;
    }
    let keyMap = ConvertUtil.toMap(object);
    let keyObject = keyMap.get("ohosKey");
    if (null != keyObject) {
      const aKey = ConvertUtil.toString(keyObject);
      if (ConvertUtil.apiKey != null && TextUtils.isEmpty(ConvertUtil.apiKey) || aKey != ConvertUtil.apiKey) {
        ConvertUtil.apiKey = aKey;
        MapsInitializer.setApiKey(ConvertUtil.apiKey);
      }
    }
  }

  public static toLocalMapType(dartMapIndex: number): number {

    let localTypeArray: number[] =
      [MapType.MAP_TYPE_NORMAL, MapType.MAP_TYPE_SATELLITE, MapType.MAP_TYPE_NIGHT, MapType.MAP_TYPE_NAVI,
        MapType.MAP_TYPE_BUS];
    if (dartMapIndex > localTypeArray.length) {
      return localTypeArray[0];
    }
    return localTypeArray[dartMapIndex];
  }

  public static toCameraUpdate(o: Object): CameraUpdate {

    const data = ConvertUtil.toList(o);
    switch (ConvertUtil.toString(data[0])) {
      case "newCameraPosition":
        return CameraUpdateFactory.newCameraPosition(ConvertUtil.toCameraPosition(data[1]));
      case "newLatLng":
        return CameraUpdateFactory.newLatLng(ConvertUtil.toLatLng(data[1]));
      case "newLatLngBounds":
        return CameraUpdateFactory.newLatLngBounds(
          ConvertUtil.toLatLngBounds(data[1]), ConvertUtil.toPixels(data[2]));
      case "newLatLngZoom":
        return CameraUpdateFactory.newLatLngZoom(ConvertUtil.toLatLng(data[1]), ConvertUtil.toFloat(data[2]));
      case "scrollBy":
        return CameraUpdateFactory.scrollBy(//
          ConvertUtil.toFloatPixels(data[1]), //
          ConvertUtil.toFloatPixels(data[2]));
      case "zoomBy":
        if (data.length == 2) {
          return CameraUpdateFactory.zoomBy(ConvertUtil.toFloat(data[1]));
        } else {
          return CameraUpdateFactory.zoomBy(ConvertUtil.toFloat(data[1]), ConvertUtil.toPoint(data[2]));
        }
      case "zoomIn":
        return CameraUpdateFactory.zoomIn();
      case "zoomOut":
        return CameraUpdateFactory.zoomOut();
      case "zoomTo":
        return CameraUpdateFactory.zoomTo(ConvertUtil.toFloat(data[1]));
      default:
        throw new AMapException("Cannot interpret " + o + " as CameraUpdate");
    }
  }


  private static toPoint(o: Object): Point {
    const data = ConvertUtil.toList(o);
    return new Point(ConvertUtil.toPixels(data[0]), ConvertUtil.toPixels(data[1]));
  }

  public static toFloatPixels(o: Object): number {
    return ConvertUtil.toFloat(o) * ConvertUtil.density;
  }

  public static toPixels(o: Object): number {
    return ConvertUtil.toFloatPixels(o);
  }

  public static toCameraPosition(o: Object): CameraPosition {
    const data = o as Map<string, object>;
    let builder = CameraPosition.builder();

    const bearing: object | undefined = data.get('bearing');
    const target: object | undefined = data.get('target');
    const tilt: object | undefined = data.get('tilt');
    const zoom: object | undefined = data.get('zoom');

    if (target != undefined) {
      builder.target(ConvertUtil.toLatLng(target));
    }
    if (bearing != undefined) {
      builder.bearing(ConvertUtil.toFloat(bearing));
    }
    if (tilt != undefined) {
      builder.tilt(ConvertUtil.toFloat(tilt));
    }
    if (zoom != undefined) {
      builder.zoom(ConvertUtil.toFloat(zoom));
    }
    return builder.build();
  }

  public static cameraPositionToMap(position: CameraPosition): Object | undefined {
    if (position == null) {
      return undefined;
    }
    let data = new Map<string, object | null | number>();
    data.set("bearing", position.bearing);
    data.set("target", ConvertUtil.latLngToList(position.target));
    data.set("tilt", position.tilt);
    data.set("zoom", position.zoom);
    return data;
  }

  public static interpretAMapOptions(o: Object, sink: AMapOptionsSink): void {
    try {
      const data = ConvertUtil.toMap(o)
      const mapType = data.get("mapType");
      if (mapType != null) {
        sink.setMapType(ConvertUtil.toLocalMapType(ConvertUtil.toInt(mapType)));
      }

      const buildingsEnabled = data.get("buildingsEnabled");
      if (null != buildingsEnabled) {
        sink.setBuildingsEnabled(ConvertUtil.toBoolean(buildingsEnabled));
      }


      const customMapStyleOptions = data.get("customStyleOptions");
      if (null != customMapStyleOptions) {
        const customMapStyleOptions1 = ConvertUtil.toCustomMapStyleOptions(customMapStyleOptions);
        sink.setCustomMapStyleOptions(customMapStyleOptions1);
      }

      const myLocationStyleData = data.get("myLocationStyle");
      if (null != myLocationStyleData) {
        sink.setMyLocationStyle(ConvertUtil.toMyLocationStyle(myLocationStyleData));
      }

      const screenAnchor = data.get("screenAnchor");
      if (null != screenAnchor) {
        const anchorData = ConvertUtil.toList(screenAnchor);
        sink.setScreenAnchor(ConvertUtil.toFloat(anchorData[0]), ConvertUtil.toFloat(anchorData[1]));
      }

      const compassEnabled = data.get("compassEnabled");
      if (null != compassEnabled) {
        sink.setCompassEnabled(ConvertUtil.toBoolean(compassEnabled));
      }

      const labelsEnabled = data.get("labelsEnabled");
      if (null != labelsEnabled) {
        sink.setLabelsEnabled(ConvertUtil.toBoolean(labelsEnabled));
      }

      const limitBounds = data.get("limitBounds");
      if (null != limitBounds) {
        const targetData = ConvertUtil.toList(limitBounds);
        let latLngBounds = ConvertUtil.toLatLngBounds(targetData)
        if (latLngBounds != null) {
          sink.setLatLngBounds(latLngBounds);
        }
      }

      const minMaxZoomPreference = data.get("minMaxZoomPreference");
      if (null != minMaxZoomPreference) {
        const targetData = ConvertUtil.toList(minMaxZoomPreference);
        sink.setMinZoomLevel(ConvertUtil.toFloatWrapperWithDefault(targetData[0], 3));
        sink.setMaxZoomLevel(ConvertUtil.toFloatWrapperWithDefault(targetData[1], 20));
      }

      const scaleEnabled = data.get("scaleEnabled");
      if (null != scaleEnabled) {
        sink.setScaleEnabled(ConvertUtil.toBoolean(scaleEnabled));
      }

      const touchPoiEnabled = data.get("touchPoiEnabled");
      if (null != touchPoiEnabled) {
        sink.setTouchPoiEnabled(ConvertUtil.toBoolean(touchPoiEnabled));
      }

      const trafficEnabled = data.get("trafficEnabled");
      if (null != trafficEnabled) {
        sink.setTrafficEnabled(ConvertUtil.toBoolean(trafficEnabled));
      }

      const rotateGesturesEnabled = data.get("rotateGesturesEnabled");
      if (null != rotateGesturesEnabled) {
        sink.setRotateGesturesEnabled(ConvertUtil.toBoolean(rotateGesturesEnabled));
      }

      const scrollGesturesEnabled = data.get("scrollGesturesEnabled");
      if (null != scrollGesturesEnabled) {
        sink.setScrollGesturesEnabled(ConvertUtil.toBoolean(scrollGesturesEnabled));
      }

      const tiltGesturesEnabled = data.get("tiltGesturesEnabled");
      if (null != tiltGesturesEnabled) {
        sink.setTiltGesturesEnabled(ConvertUtil.toBoolean(tiltGesturesEnabled));
      }

      const zoomGesturesEnabled = data.get("zoomGesturesEnabled");
      if (null != zoomGesturesEnabled) {
        sink.setZoomGesturesEnabled(ConvertUtil.toBoolean(zoomGesturesEnabled));
      }

      const gestureScaleByMapCenter = data.get("gestureScaleByMapCenter");
      if (null != gestureScaleByMapCenter) {
        sink.setGestureScaleByMapCenter(ConvertUtil.toBoolean(gestureScaleByMapCenter));
      }
    } catch (e
    ) {
      LogUtil.e(ConvertUtil.CLASS_NAME, "interpretAMapOptions", e);
    }
  }

  private static toCustomMapStyleOptions(o: Object): CustomMapStyleOptions {
    let map = ConvertUtil.toMap(o);
    const customMapStyleOptions: CustomMapStyleOptions = new CustomMapStyleOptions();
    let enableData: Object = map.get("enabled") as object;
    if (null != enableData) {
      customMapStyleOptions.setEnable(ConvertUtil.toBoolean(enableData));
    }
    let styleData = map.get("styleData") as Uint8Array;
    if (null != styleData) {
      customMapStyleOptions.setStyleData(styleData);
    }
    const styleExtraData = map.get("styleExtraData") as Uint8Array;
    if (null != styleExtraData) {
      customMapStyleOptions.setStyleExtraData(styleExtraData);
    }
    return customMapStyleOptions;
  }

  private static toMyLocationStyle(o: Object): MyLocationStyle {

    const map = ConvertUtil.toMap(o);

    const myLocationStyle = new MyLocationStyle();

    const enableData = map.get("enabled") as object;
    if (null != enableData) {
      myLocationStyle.showMyLocation(ConvertUtil.toBoolean(enableData));
    }

    //两端差异比较大，Android端设置成跟随但是不移动到中心点模式，与iOS端兼容
    myLocationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_FOLLOW_NO_CENTER);

    let circleFillColorData = map.get("circleFillColor") as object;
    if (null != circleFillColorData) {
      myLocationStyle.radiusFillColor(ConvertUtil.toInt(circleFillColorData));
    }
    let circleStrokeColorData = map.get("circleStrokeColor") as object;
    if (null != circleStrokeColorData) {
      myLocationStyle.strokeColor(ConvertUtil.toInt(circleStrokeColorData));
    }

    const circleStrokeWidthData = map.get("circleStrokeWidth") as object;
    if (null != circleStrokeWidthData) {
      myLocationStyle.strokeWidth(ConvertUtil.toPixels(circleStrokeWidthData));
    }

    const iconDta = map.get("icon") as object;
    if (null != iconDta) {
      myLocationStyle.myLocationIcon(ConvertUtil.toBitmapDescriptor(iconDta));
    }
    return myLocationStyle;
  }

  public static location2Map(location: geoLocationManager.Location): Object | null {
    if (null == location) {
      return null;
    }

    if (location.altitude > 90 ||
      location.altitude < -90 ||
      location.longitude > 180 ||
      location.longitude < -180) {
      return null;
    }

    const object = new Map<string, object | number>();
    const list = new ArrayList<number>();
    list.add(location.latitude);
    list.add(location.longitude);
    // object.set("provider", location.getProvider());
    object.set("latLng", list);
    object.set("accuracy", location.accuracy);
    object.set("altitude", location.altitude);
    // object.set("bearing", location.getBearing());
    object.set("speed", location.speed);
    object.set("time", location.timeStamp);
    return object;
  };

  public static toBitmapDescriptor(o: Object): BitmapDescriptor | undefined {
    let flutterLoader = FlutterInjector.getInstance().getFlutterLoader();
    const data = ConvertUtil.toList(o);
    switch (ConvertUtil.toString(data[0])) {
      case "defaultMarker":
        if (data.length == 1) {
          return BitmapDescriptorFactory.defaultMarker();
        } else {
          return BitmapDescriptorFactory.defaultMarker(ConvertUtil.toFloat(data[1]));
        }
      case "fromAsset":
        if (data.length == 2) {
          return BitmapDescriptorFactory.fromAsset(
            flutterLoader.getLookupKeyForAsset(ConvertUtil.toString(data[1])));
        } else {
          return BitmapDescriptorFactory.fromAsset(
            flutterLoader.getLookupKeyForAsset(ConvertUtil.toString(data[1]), ConvertUtil.toString(data[2])));
        }
      case "fromAssetImage":
        if (data.length == 3) {
          return BitmapDescriptorFactory.fromAsset(
            flutterLoader.getLookupKeyForAsset(ConvertUtil.toString(data[1])));
        } else {
          throw new AMapException(
            "'fromAssetImage' Expected exactly 3 arguments, got: " + data.length);
        }
      case "fromBytes":
        return ConvertUtil.getBitmapFromBytes(data);
      default:
        throw new AMapException("Cannot interpret " + o + " as BitmapDescriptor");
    }
  }

  public static toBitmapDescriptorList(o: Object): ArrayList<BitmapDescriptor> {

    let rawList = ConvertUtil.toList(o);

    let bitmapDescriptorList = new ArrayList<BitmapDescriptor>();

    for (let i = 0; i < rawList.length; i++) {
      let obj = rawList[i]
      bitmapDescriptorList.add(ConvertUtil.toBitmapDescriptor(obj));
    }
    return bitmapDescriptorList;
  }

  private static getBitmapFromBytes(data: ArrayList<object>): BitmapDescriptor | undefined {
    if (data.length == 2) {
      try {
        let bitmap = ConvertUtil.toBitmap(data[1]);
        return BitmapDescriptorFactory.fromPixelMapSync(bitmap);
      } catch (e) {
        throw new AMapException("Unable to interpret bytes as a valid image.", e);
      }
    } else {
      throw new AMapException(
        "fromBytes should have exactly one argument, the bytes. Got: " + data.length);
    }
  }

  private static toBitmap(o: Object): PixelMap {
    let bmpData = o as Uint8Array

    const imageSource = image.createImageSource(bmpData.buffer);
    return imageSource.createPixelMapSync({
      desiredPixelFormat: image.PixelMapFormat.RGBA_8888
    });

    // let bitmap = BitmapFactory.decodeByteArray(bmpData, 0, bmpData.length);
    // if (bitmap == null) {
    //   throw new AMapException("Unable to decode bytes as a valid bitmap.");
    // } else {
    //   return bitmap;
    // }
  }

  public static poiToMap(poi: Poi): Object | null {
    if (null == poi) {
      return null;
    }
    let data = new Map<string, object | string | null>();
    data.set("id", poi.getPoiId());
    data.set("name", poi.getName());
    if (poi.getCoordinate() != undefined) {
      data.set("latLng", ConvertUtil.latLngToList(poi.getCoordinate()!));
    }
    return data;
  }

  public static latLngToList(latLng: LatLng): ArrayList<number> | null {
    if (null == latLng) {
      return null;
    }
    let number = new ArrayList<number>();
    number.add(latLng.latitude)
    number.add(latLng.longitude)
    return number;
  }

  public static toLatLng(o: Object): LatLng {
    const data = o as ArrayList<number>;
    return new LatLng(data[0], data[1]);
  }

  public static toPoints(o: Object): ArrayList<LatLng> {
    const data = ConvertUtil.toList(o);
    const points = new ArrayList<LatLng>();

    for (let i = 0; i < data.length; i++) {
      const point = ConvertUtil.toList(data[i])
      points.add(new LatLng(ConvertUtil.toFloat(point[0]), ConvertUtil.toFloat(point[1])));
    }
    return points;
  }

  public static toLatLngBounds(o: Object): LatLngBounds | null {
    if (o == null) {
      return null;
    }

    const data = ConvertUtil.toList(o);
    return new LatLngBounds(ConvertUtil.toLatLng(data[0]), ConvertUtil.toLatLng(data[1]));
  }

  public static toFloatWrapperWithDefault(o: Object, defaultValue: number): number {
    return (o == null) ? defaultValue : ConvertUtil.toFloat(o);
  }

  public static toBoolean(o: Object): boolean {
    return o as boolean;
  }

  public static toInt(o: Object): number {
    return o as number;
  }

  static toFloat(o: Object): number {
    return o as number;
  }

  public static toList(o: Object): ArrayList<object> {
    return o as ArrayList<object>;
  }

  public static toMap(o: Object): Map<string | object, object> {
    return o as Map<object, object>;
  }

  public static toString(o: Object): string {
    return o as string;
  }

  public static getKeyValueFromMapObject(object: Object, keyStr: String): Object | undefined {
    if (null == object) {
      return undefined;
    }
    try {
      let mapData = ConvertUtil.toMap(object);
      return mapData.get(keyStr);
    } catch (e) {
      LogUtil.e("ConvertUtil", "setPrivacyStatement", e);
    }
    return undefined;
  }
}