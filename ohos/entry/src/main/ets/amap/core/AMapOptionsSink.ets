import { CameraPosition, CustomMapStyleOptions, LatLngBounds, MyLocationStyle } from "@amap/amap_lbs_map3d";

export interface AMapOptionsSink{
  setCamera(camera:CameraPosition):void;

  setMapType(mapType:number):void;

  setCustomMapStyleOptions(customMapStyleOptions:CustomMapStyleOptions):void;

  setMyLocationStyle(myLocationStyle:MyLocationStyle):void;

  setScreenAnchor(x:number, y:number):void;

  setMinZoomLevel(minZoomLevel:number):void;

  setMaxZoomLevel(maxZoomLevel:number):void;

  setLatLngBounds(latLngBounds:LatLngBounds):void;

  setTrafficEnabled(trafficEnabled:boolean):void;

  setTouchPoiEnabled(touchPoiEnabled:boolean):void;

  setBuildingsEnabled(buildingsEnabled:boolean):void;

  setLabelsEnabled(labelsEnabled:boolean):void;

  setCompassEnabled(compassEnabled:boolean):void;

  setScaleEnabled(scaleEnabled:boolean):void;

  setZoomGesturesEnabled(zoomGesturesEnabled:boolean):void;

  setScrollGesturesEnabled(scrollGesturesEnabled:boolean):void;

  setRotateGesturesEnabled(rotateGesturesEnabled:boolean):void;

  setTiltGesturesEnabled(tiltGesturesEnabled:boolean):void;

  setInitialMarkers(initialMarkers:Object):void;

  setInitialPolylines(initialPolylines:Object):void;

  setInitialPolygons(initialPolygons:Object):void;

  setGestureScaleByMapCenter(gestureScaleByMapCenter:boolean):void;
}

