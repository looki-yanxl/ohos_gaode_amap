import { LogUtil } from '@amap/amap_lbs_common';
import {
  AMapOptions,
  CameraPosition,
  CustomMapStyleOptions,
  LatLngBounds,
  MyLocationStyle
} from '@amap/amap_lbs_map3d';
import { BinaryMessenger } from '@ohos/flutter_ohos';
import { AMapPlatformView } from './AMapPlatformView';
import { AMapOptionsSink } from './core/AMapOptionsSink';
import { ArrayList } from '@kit.ArkTS';

export default class AMapOptionsBuilder implements AMapOptionsSink {
  private CLASS_NAME: string = "AMapOptionsBuilder";
  private options = new AMapOptions();
  private customMapStyleOptions:CustomMapStyleOptions | undefined;
  private myLocationStyle:MyLocationStyle|undefined;
  private minZoomLevel: number = 3;
  private maxZoomLevel: number = 20;
  private latLngBounds:LatLngBounds|undefined;
  private trafficEnabled: boolean = true;
  private touchPoiEnabled: boolean = true;
  private buildingsEnabled: boolean = true;
  private labelsEnabled: boolean = true;
  private gestureScaleByMapCenter: boolean = false;
  private anchorX: number = 2.0;
  private anchorY: number = 2.0;
  private initialMarkers: object | undefined;
  private initialPolylines: object | undefined;
  private initialPolygons: object | undefined;

  build(id: number, context: Context, binaryMessenger: BinaryMessenger): AMapPlatformView{

    this.options.zoomControlsEnabled(false);
    let  aMapPlatformView = new AMapPlatformView(id, context, binaryMessenger, this.options);
    try {
      //iOS端没有放大缩小UI, Android端强制隐藏

      if (null != this.customMapStyleOptions) {
        aMapPlatformView?.getMapController()?.setCustomMapStyleOptions(this.customMapStyleOptions);
      }
      if (null != this.myLocationStyle) {
        aMapPlatformView?.getMapController()?.setMyLocationStyle(this.myLocationStyle);
      }
      if (this.anchorX >= 0 && this.anchorX <= 1.0 && this.anchorY <= 1.0 && this.anchorY >= 0) {
        aMapPlatformView?.getMapController()?.setScreenAnchor(this.anchorX, this.anchorY);
      }
      aMapPlatformView?.getMapController()?.setMinZoomLevel(this.minZoomLevel);
      aMapPlatformView?.getMapController()?.setMaxZoomLevel(this.maxZoomLevel);
      if (null != this.latLngBounds) {
        aMapPlatformView?.getMapController()?.setLatLngBounds(this.latLngBounds);
      }
      aMapPlatformView?.getMapController()?.setTrafficEnabled(this.trafficEnabled);
      aMapPlatformView?.getMapController()?.setTouchPoiEnabled(this.touchPoiEnabled);
      aMapPlatformView?.getMapController()?.setBuildingsEnabled(this.buildingsEnabled);
      aMapPlatformView?.getMapController()?.setLabelsEnabled(this.labelsEnabled);
      aMapPlatformView?.getMapController()?.setGestureScaleByMapCenter(this.gestureScaleByMapCenter);
      if (null != this.initialMarkers) {
        let markerList = this.initialMarkers as ArrayList <Object>;
        aMapPlatformView?.getMarkersController()?.addByList(markerList);
      }
      // if (null != this.initialPolylines) {
      //   let markerList = this.initialPolylines as ArrayList <Object>;
      //   aMapPlatformView?.getPolylinesController()?.addByList(markerList);
      // }
      // if (null != this.initialPolygons) {
      //   let polygonList = this.initialPolygons as ArrayList <Object>;
      //   aMapPlatformView?.getPolygonsController()?.addByList(polygonList);
      // }
    } catch (e) {
      LogUtil.e(this.CLASS_NAME, "build", "");
    }finally {
      return aMapPlatformView;
    }
  }


  setCamera(camera: CameraPosition): void {
    this.options.camera(camera);
  }

  setMapType(mapType: number): void {
    this.options.mapType(mapType);  }

  setCustomMapStyleOptions(customMapStyleOptions: CustomMapStyleOptions): void {
    this.customMapStyleOptions = customMapStyleOptions;
  }

  setMyLocationStyle(myLocationStyle: MyLocationStyle): void {
    this.myLocationStyle = myLocationStyle;
  }

  setScreenAnchor(x: number, y: number): void {
    this.anchorX = x;
    this.anchorY = y;  }

  setMinZoomLevel(minZoomLevel: number): void {
    this.minZoomLevel = minZoomLevel;  }

  setMaxZoomLevel(maxZoomLevel: number): void {
    this.maxZoomLevel = maxZoomLevel;
  }

  setLatLngBounds(latLngBounds: LatLngBounds): void {
    this.latLngBounds = latLngBounds;
  }

  setTrafficEnabled(trafficEnabled: boolean): void {
    this.trafficEnabled = trafficEnabled;
  }

  setTouchPoiEnabled(touchPoiEnabled: boolean): void {
    this.touchPoiEnabled = touchPoiEnabled;
  }

  setBuildingsEnabled(buildingsEnabled: boolean): void {
    this.buildingsEnabled = buildingsEnabled;
  }

  setLabelsEnabled(labelsEnabled: boolean): void {
    this.labelsEnabled = labelsEnabled;
  }

  setCompassEnabled(compassEnabled: boolean): void {
    this.options.compassEnabled(compassEnabled);
  }

  setScaleEnabled(scaleEnabled: boolean): void {
    this.options.scaleControlsEnabled(scaleEnabled);
  }

  setZoomGesturesEnabled(zoomGesturesEnabled: boolean): void {
    this.options.zoomGesturesEnabled(zoomGesturesEnabled);
  }

  setScrollGesturesEnabled(scrollGesturesEnabled: boolean): void {
    this.options.scrollGesturesEnabled(scrollGesturesEnabled);  }

  setRotateGesturesEnabled(rotateGesturesEnabled: boolean): void {
    this.options.rotateGesturesEnabled(rotateGesturesEnabled);  }

  setTiltGesturesEnabled(tiltGesturesEnabled: boolean): void {
    this.options.tiltGesturesEnabled(tiltGesturesEnabled);  }

  setInitialMarkers(initialMarkers: Object): void {
    this.initialMarkers = initialMarkers;
  }

  setInitialPolylines(initialPolylines: Object): void {
    this.initialPolylines = initialPolylines;
  }

  setInitialPolygons(initialPolygons: Object): void {
    this.initialPolygons = initialPolygons;
  }

  setGestureScaleByMapCenter(gestureScaleByMapCenter: boolean): void {
    this.gestureScaleByMapCenter= gestureScaleByMapCenter;
  }
}
