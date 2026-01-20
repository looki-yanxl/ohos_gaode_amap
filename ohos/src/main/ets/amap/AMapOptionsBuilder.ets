import { LogUtil } from '@amap/amap_lbs_common';
import {
  AMapOptions,
  CameraPosition,
  CustomMapStyleOptions,
  LatLng,
  LatLngBounds,
  MyLocationStyle
} from '@amap/amap_lbs_map3d';
import { BinaryMessenger } from '@ohos/flutter_ohos';
import { AMapPlatformView } from './AMapPlatformView';
import { AMapOptionsSink } from './core/AMapOptionsSink';
import { ArrayList } from '@kit.ArkTS';
import MapController from './core/MapController';

export default class AMapOptionsBuilder implements AMapOptionsSink {
  private CLASS_NAME: string = "AMapOptionsBuilder";
  private options = new AMapOptions();
  public  customMapStyleOptions:CustomMapStyleOptions | undefined;
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
  private initialMarkers: LatLng | undefined;
  private initialPolylines: object | undefined;
  private initialPolygons: object | undefined;

  build(id: number, context: Context, binaryMessenger: BinaryMessenger): AMapPlatformView{

    this.options.zoomControlsEnabled(false);
    let  aMapPlatformView = new AMapPlatformView(id, context, binaryMessenger, this.options,
      (mapController: MapController | null) => {
        if (null != this.customMapStyleOptions) {
          mapController?.setCustomMapStyleOptions(this.customMapStyleOptions);
        }
        if (null != this.myLocationStyle) {
          mapController?.setMyLocationStyle(this.myLocationStyle);
        }
        if (this.anchorX >= 0 && this.anchorX <= 1.0 && this.anchorY <= 1.0 && this.anchorY >= 0) {
          mapController?.setScreenAnchor(this.anchorX, this.anchorY);
        }
        mapController?.setMinZoomLevel(this.minZoomLevel);
        mapController?.setMaxZoomLevel(this.maxZoomLevel);
        if (null != this.latLngBounds) {
          mapController?.setLatLngBounds(this.latLngBounds);
        }
        mapController?.setTrafficEnabled(this.trafficEnabled);
        mapController?.setTouchPoiEnabled(this.touchPoiEnabled);
        mapController?.setBuildingsEnabled(this.buildingsEnabled);
        mapController?.setLabelsEnabled(this.labelsEnabled);
        mapController?.setGestureScaleByMapCenter(this.gestureScaleByMapCenter);
        if (null != this.initialMarkers) {
          let marker = this.initialMarkers;
          aMapPlatformView?.getMarkersController()?.addMark(marker);
        }
        // if (null != this.initialPolylines) {
        //   let markerList = this.initialPolylines as ArrayList <Object>;
        //   aMapPlatformView?.getPolylinesController()?.addByList(markerList);
        // }
        // if (null != this.initialPolygons) {
        //   let polygonList = this.initialPolygons as ArrayList <Object>;
        //   aMapPlatformView?.getPolygonsController()?.addByList(polygonList);
        // }
      });
    return aMapPlatformView;
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
    this.options.tiltGesturesEnabled(tiltGesturesEnabled);
  }

  setInitialMarkers(initialMarkers: LatLng): void {
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
