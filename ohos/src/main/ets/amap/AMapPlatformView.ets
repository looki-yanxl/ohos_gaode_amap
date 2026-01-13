import { LogUtil } from '@amap/amap_lbs_common';
import { AMap, AMapOptions, MapView, MapViewComponent, MapViewManager } from '@amap/amap_lbs_map3d';
import {
  BinaryMessenger,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
  PlatformView,
} from '@ohos/flutter_ohos';
import MapController from './core/MapController';
import { MyMethodCallHandler } from './MyMethodCallHandler';
import { MarkersController } from './overlays/marker/MarkersController';
import { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { clauseComponent } from '../plugins/FlutterLocPlugin';

@Builder
export function WebBuilder(params: Params) {
  OhosWebView()
}

@Component
export struct OhosWebView {
  build() {
    Row() {
      MapViewComponent()
        .width('100%')
        .height('100%')
    }
  }
}
export class AMapPlatformView extends  PlatformView implements MethodCallHandler {


  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(WebBuilder);
  }



  private CLASS_NAME = "AMapPlatformView";
  public methodChannel: MethodChannel | undefined;
  private mapController: MapController | undefined;
  private markersController: MarkersController | undefined;
  // private polylinesController: PolylinesController;
  // private polygonsController: PolygonsController;
  private mapView: MapView | undefined;
  private disposed: boolean = false;
  private myMethodCallHandlerMap: Map<String, MyMethodCallHandler> | undefined;

  constructor(id: number, context: Context, binaryMessenger: BinaryMessenger, options: AMapOptions) {
    super();
    this.methodChannel = new MethodChannel(binaryMessenger, "xbr_amap_" + id);
    this.methodChannel.setMethodCallHandler(this);
    this.myMethodCallHandlerMap = new Map<String, MyMethodCallHandler>();
    try {
      /// todo mapview option 样式
      // mapView = new TextureMapView(context, options);
      MapViewManager.getInstance().registerMapViewCreatedCallback((mapview?: MapView, mapViewName?: string) => {
        if (!mapview) {
          return;
        }
        this.mapView = mapview;
      })

      if (this.mapView != null) {
        this.mapView?.onCreate();
        this.mapView.getMapAsync((amap: AMap) => {
          this.mapController = new MapController(this.methodChannel!, this.mapView!);
          this.markersController = new MarkersController(this.methodChannel!, amap);
          // this.polylinesController = new PolylinesController(methodChannel, amap);
          // this.polygonsController = new PolygonsController(methodChannel, amap);
          this.initMyMethodCallHandlerMap();
        })
      }
    } catch (e) {
      LogUtil.e(this.CLASS_NAME, "<init>", e);
    }
  }


  private initMyMethodCallHandlerMap(): void {
    let methodIdArray = this.mapController?.getRegisterMethodIdArray();
    if (null != methodIdArray && methodIdArray.length > 0) {
      for (let i = 0; i < methodIdArray.length; i++) {
        let methodId = methodIdArray[i]
        this.myMethodCallHandlerMap?.set(methodId, this.mapController!);
      }
    }
    methodIdArray = this.markersController?.getRegisterMethodIdArray();
    if (null != methodIdArray && methodIdArray.length > 0) {
      for (let i = 0; i < methodIdArray.length; i++) {
        let methodId = methodIdArray[i]
        this.myMethodCallHandlerMap?.set(methodId, this.markersController!);
      }

    }
    // methodIdArray = this.polylinesController.getRegisterMethodIdArray();
    // if (null != methodIdArray && methodIdArray.length > 0) {
    //   for (String methodId: methodIdArray){
    //     this.myMethodCallHandlerMap.set(methodId, this.polylinesController);
    //   }
    // }
    // methodIdArray = this.polygonsController.getRegisterMethodIdArray();
    // if (null != methodIdArray && methodIdArray.length > 0) {
    //   for (String:methodId: methodIdArray)
    //   {
    //     this.myMethodCallHandlerMap.set(methodId, this.polygonsController);
    //   }
    // }
  }

  public getMapController(): MapController | undefined {
    return this.mapController;
  }

  public getMarkersController(): MarkersController | undefined {
    return this.markersController;
  }

  // public getPolylinesController(): PolylinesController {
  //   return this.polylinesController;
  // }
  //
  // public getPolygonsController(): PolygonsController {
  //   return this.polygonsController;
  // }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    LogUtil.i(this.CLASS_NAME, "onMethodCall==>" + call.method, "arguments==> " + call.argument);
    let methodId = call.method;
    if (this.myMethodCallHandlerMap?.has(methodId)) {
      if (this.myMethodCallHandlerMap.get(methodId) != null) {
        this.myMethodCallHandlerMap.get(methodId)?.doMethodCall(call, result)
      }
    } else {
      LogUtil.w(this.CLASS_NAME, "onMethodCall, the methodId: " + call.method + ", not implemented", "");
      result.notImplemented();
    }
  }


  onPageShow(): void {
    LogUtil.i(this.CLASS_NAME, "onResume==>", "");
    try {
      if (this.disposed) {
        return;
      }
      if (null != this.mapView) {
        this.mapView.onResume();
      }
    } catch (e) {
      LogUtil.e(this.CLASS_NAME, "onResume", e);
    }
  }

  onPageHide(): void {

    LogUtil.i(this.CLASS_NAME, "onPause==>", "");
    try {
      if (this.disposed) {
        return;
      }
      this.mapView?.onPause();
    } catch (e) {
      LogUtil.e(this.CLASS_NAME, "onPause", "");
    }
  }

  aboutToAppear(): void {
    // MapViewManager.getInstance().registerMapViewCreatedCallback(this.mapViewCreateCallback);
  }

  aboutToDisappear(): void {
    // if (this.mapViewCreateCallback) {
    //   MapViewManager.getInstance().unregisterMapViewCreatedCallback(this.mapViewCreateCallback);
    // }

    if (this.mapView) {
      this.mapView.onDestroy();
      this.mapView = undefined;
      // this.aMap = undefined;
    }

  }




  public dispose(): void {
    LogUtil.i(this.CLASS_NAME, "dispose==>", "");
    try {
      if (this.disposed) {
        return;
      }
      this.methodChannel?.setMethodCallHandler(null);
      this.destroyMapViewIfNecessary();
      this.disposed = true;
    } catch (e) {
      LogUtil.e(this.CLASS_NAME, "dispose", e);
    }
  }

  private destroyMapViewIfNecessary(): void {
    if (this.mapView == null) {
      return;
    }
    this.mapView.onDestroy();
  }
}