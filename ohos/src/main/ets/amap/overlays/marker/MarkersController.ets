import { LogUtil } from '@amap/amap_lbs_common';
import { AMap, LatLng, Marker, MarkerOptions, OnMarkerDragListener, Poi } from '@amap/amap_lbs_map3d';
import { MethodCall, MethodChannel, MethodResult } from '@ohos/flutter_ohos';
import { MyMethodCallHandler } from '../../MyMethodCallHandler';
import Const from '../../util/Const';
import { ConvertUtil } from '../../util/ConvertUtil';
import { AbstractOverlayController } from '../AbstractOverlayController';
import { MarkerController } from './MarkerController';
import { MarkerOptionsBuilder } from './MarkerOptionsBuilder';
import { MarkerUtil } from './MarkerUtil';
import { ArrayList } from '@kit.ArkTS';

const _cache: Map<string, BitmapDescriptor> = new Map();

export class MarkersController
  extends AbstractOverlayController<MarkerController>
implements MyMethodCallHandler {
  private static readonly CLASS_NAME: string = 'MarkersController';
  private selectedMarkerDartId: string | null = null;

  constructor(methodChannel: MethodChannel, amap: AMap) {
    super(methodChannel, amap);

    amap?.setOnMarkerClickListener((marker: Marker): boolean => {
      const dartId = this.idMapByOverlyId.get(marker.getId());
      if (null == dartId) {
        return false;
      }
      const data = new Map<string, string>();
      data.set("markerId", dartId);
      this.selectedMarkerDartId = dartId;
      this.showMarkerInfoWindow(dartId);
      methodChannel.invokeMethod("marker#onTap", data);
      LogUtil.i(MarkersController.CLASS_NAME, "onMarkerClick==>" + data, "");

      return true;
    });
    amap?.setOnMarkerDragListener(new OnMarkerDragListener((marker) => {

    }, (marker: Marker) => {

    }, (marker: Marker) => {
      const markerId = marker.getId();
      const dartId = this.idMapByOverlyId.get(markerId);
      const latLng = marker.getPosition();
      if (null == dartId) {
        return;
      }
      const data = new Map<string, string | object | null>();
      data.set("markerId", dartId);
      data.set("position", ConvertUtil.latLngToList(latLng));
      methodChannel.invokeMethod("marker#onDragEnd", data);

      LogUtil.i(MarkersController.CLASS_NAME, "onMarkerDragEnd==>" + data, "");
    }));
    amap?.setOnMapClickListener((point: LatLng) => {
      this.hideMarkerInfoWindow(this.selectedMarkerDartId, null);
    })
    amap.addOnPOIClickListener((poi: Poi) => {
      const coordinate = poi?.getCoordinate()
      this.hideMarkerInfoWindow(this.selectedMarkerDartId, coordinate ?? null);
    });
  }

  getRegisterMethodIdArray(): string[] {
    return Const.METHOD_ID_LIST_FOR_MARKER;
  }

  doMethodCall(call: MethodCall, result: MethodResult): void {
    LogUtil.i(
      MarkersController.CLASS_NAME,
      'doMethodCall===>' + call.method, ""
    );

    switch (call.method) {
      case Const.METHOD_MARKER_UPDATE:
        this.invokeMarkerOptions(call, result);
        break;
    }
  }

  /**
   * 执行主动方法更新 marker
   */
  invokeMarkerOptions(
    methodCall: MethodCall,
    result: MethodResult
  ): void {
    if (methodCall == null) {
      return;
    }

    const markersToAdd = methodCall.argument('markersToAdd') as ArrayList<object>;
    this.addByList(markersToAdd);

    const markersToChange = methodCall.argument('markersToChange') as ArrayList<object>;
    this.updateByList(markersToChange);

    const markerIdsToRemove =
      methodCall.argument('markerIdsToRemove') as ArrayList<string>;
    this.removeByIdList(markerIdsToRemove);

    result.success(null);
  }

  addByList(markersToAdd: ArrayList<object>): void {
    if (markersToAdd != null) {
      markersToAdd.forEach(markerToAdd => {
        this.add(markerToAdd);
      });
    }
  }

  addMark(context:Context,latlng: LatLng): void {
    if (latlng != null) {
      let options: MarkerOptions = new MarkerOptions();
      options.setPosition(new LatLng(latlng.latitude, latlng.longitude));

      this.getIcon("icon_map_marker.png",context).then((bitmapDescriptor:BitmapDescriptor | undefined) => {
        if (bitmapDescriptor != undefined) {
          options.setIcon(bitmapDescriptor);
        }
      })
      this.amap?.addMarker(options);
    }
  }


  async getIcon(iconName: string, context?: Context): Promise<BitmapDescriptor | undefined> {
    // 1. 检查缓存
    if (_cache.has(iconName)) {
      return _cache.get(iconName)!;
    }

    // 2. 缓存中没有，尝试加载
    if (!context) {
      return undefined;
    }

    const bitmapDes = await BitmapDescriptorFactory.fromRawfilePath(context, iconName);
    if (bitmapDes != undefined) {
      _cache.set(iconName, bitmapDes);

      return bitmapDes
    }
    return undefined;
  }

  private add(markerObj: object): void {
    if (this.amap != null) {
      const builder = new MarkerOptionsBuilder();
      const dartMarkerId = MarkerUtil.interpretMarkerOptions(
        markerObj,
        builder
      );

      if (dartMarkerId && dartMarkerId.length > 0) {
        const markerOptions: MarkerOptions = builder.build();
        const marker: Marker | undefined = this.amap.addMarker(markerOptions);

        if (marker != undefined) {
          const clickable = ConvertUtil.getKeyValueFromMapObject(
            markerObj,
            'clickable'
          );
          if (clickable != null) {
            marker?.setClickable(ConvertUtil.toBoolean(clickable));
          }

          const markerController = new MarkerController(marker);
          this.controllerMapByDartId.set(dartMarkerId, markerController);
          this.idMapByOverlyId.set(marker?.getId(), dartMarkerId);
        }

      }
    }
  }

  private updateByList(markersToChange: ArrayList<object>): void {
    if (markersToChange != null) {
      markersToChange.forEach(markerToChange => {
        this.update(markerToChange);
      });
    }
  }

  private update(markerToChange: object): void {
    const dartMarkerId = ConvertUtil.getKeyValueFromMapObject(
      markerToChange,
      'id'
    );

    if (dartMarkerId != null) {
      const markerController =
        this.controllerMapByDartId.get(dartMarkerId as string);

      if (markerController != null) {
        MarkerUtil.interpretMarkerOptions(
          markerToChange,
          markerController
        );
      }
    }
  }

  private removeByIdList(markerIdsToRemove: ArrayList<string>): void {
    if (markerIdsToRemove == null) {
      return;
    }

    markerIdsToRemove.forEach(rawMarkerId => {
      if (rawMarkerId == null) {
        return;
      }

      const markerId = rawMarkerId as string;
      const markerController =
        this.controllerMapByDartId.get(markerId);

      if (markerController != null) {
        this.controllerMapByDartId.delete(markerId);
        this.idMapByOverlyId.delete(markerController.getMarkerId());
        markerController.remove();
      }
    });
  }

  private showMarkerInfoWindow(dartMarkerId: string): void {
    const markerController =
      this.controllerMapByDartId.get(dartMarkerId);

    if (markerController != null) {
      markerController.showInfoWindow();
    }
  }

  private hideMarkerInfoWindow(
    dartMarkerId: string | null,
    newPosition: LatLng | null
  ): void {
    if (!dartMarkerId) {
      return;
    }

    if (!this.controllerMapByDartId.has(dartMarkerId)) {
      return;
    }

    const markerController =
      this.controllerMapByDartId.get(dartMarkerId);

    if (markerController != null) {
      if (newPosition != null && markerController.getPosition() != null) {
        if (markerController.getPosition()!.equals(newPosition)) {
          return;
        }
      }
      markerController.hideInfoWindow();
    }
  }

  onMapClick(latLng: LatLng): void {
    this.hideMarkerInfoWindow(this.selectedMarkerDartId, null);
  }

  onMarkerClick(marker: Marker): boolean {
    const dartId = this.idMapByOverlyId.get(marker.getId());
    if (dartId == null) {
      return false;
    }

    const data: Map<string, string> = new Map();
    data.set('markerId', dartId);

    this.selectedMarkerDartId = dartId;
    this.showMarkerInfoWindow(dartId);

    this.methodChannel.invokeMethod('marker#onTap', data);
    LogUtil.i(
      MarkersController.CLASS_NAME,
      'onMarkerClick==>', "");

    return true;
  }

  onMarkerDragStart(marker: Marker): void {
  }

  onMarkerDrag(marker: Marker): void {
  }

  onMarkerDragEnd(marker: Marker): void {
    const markerId = marker.getId();
    const dartId = this.idMapByOverlyId.get(markerId);
    const latLng = marker.getPosition();

    if (dartId == null) {
      return;
    }

    const data: Map<string, object | null | string> = new Map();
    data.set('markerId', dartId);
    data.set('position', ConvertUtil.latLngToList(latLng));

    this.methodChannel.invokeMethod('marker#onDragEnd', data);

    LogUtil.i(
      MarkersController.CLASS_NAME, 'onMarkerDragEnd==>', "");
  }

  onPOIClick(poi: Poi): void {
    const coordinate = poi?.getCoordinate();

    this.hideMarkerInfoWindow(
      this.selectedMarkerDartId,
      coordinate ?? null
    );
  }
}
