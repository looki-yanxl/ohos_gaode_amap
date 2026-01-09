import {
  EventChannel,
  EventSink,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
  StreamHandler
} from '@ohos/flutter_ohos';
import { AMapLocationClientOption, AMapLocationManagerImpl } from '@amap/amap_lbs_location';
import { AMapPrivacyAgreeStatus, AMapPrivacyInfoStatus, AMapPrivacyShowStatus } from '@amap/amap_lbs_common';
import AMapLocationService from '../location/AMapLocationService';


export default class FlutterLocPlugin implements FlutterPlugin, MethodCallHandler, StreamHandler {
  private channel: MethodChannel | null = null;
  private xbr_gaode_background_location_key: String = "xbr_gaode_background_location";
  private backgroundLocationOption: AMapLocationClientOption = new AMapLocationClientOption();
  public locationClientMap: Map<String, AMapLocationService> = new Map();
  private mEventSink?: EventSink;
  private eventChannel?: EventChannel;
  private mContext:Context|undefined;

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    let pluginKey: string = "";

    switch (call.method) {
      case "updatePrivacyStatement":
        //初始化隐私政策
        let hasContains: boolean | null = null;
        let hasShow: boolean | null = null;
        let hasAgree: boolean | null = null;

        if (call.hasArgument("hasContains")) {
          hasContains = call.argument("hasContains")
        }
        if (call.hasArgument("hasShow")) {
          hasShow = call.argument("hasShow");
        }
        if (call.hasArgument("hasAgree")) {
          hasAgree = call.argument("hasAgree");
        }
        if (hasContains != null && hasShow != null) {
          AMapLocationManagerImpl.updatePrivacyShow(AMapPrivacyShowStatus.DidShow, AMapPrivacyInfoStatus.DidContain,
            getContext(this))
        }
        if (hasAgree) {
          AMapLocationManagerImpl.updatePrivacyAgree(AMapPrivacyAgreeStatus.DidAgree, getContext(this))
        }
        result.success("SUCCESS");
        break;

      case "setApiKey":
        let androidKey = null;
        if (call.hasArgument("android")) {
          androidKey = call.argument("android");
          AMapLocationManagerImpl.setApiKey(androidKey);
          result.success("SUCCESS");
        }
        result.success("SUCCESS");
        break;

      case "setLocationOption":
        let locationInterval = 0, geoLanguage = 0, locationMode = 1;
        let sensorEnable = false, needAddress = false, onceLocation = false;
        if (call.hasArgument("locationInterval")) {
          locationInterval = call.argument("locationInterval");
        }
        if (call.hasArgument("geoLanguage")) {
          geoLanguage = call.argument("geoLanguage");
        }
        if (call.hasArgument("locationMode")) {
          locationMode = call.argument("locationMode");
        }
        if (call.hasArgument("sensorEnable")) {
          sensorEnable = call.argument("sensorEnable");
        }
        if (call.hasArgument("needAddress")) {
          needAddress = call.argument("needAddress");
        }
        if (call.hasArgument("onceLocation")) {
          onceLocation = call.argument("onceLocation");
        }
        if (call.hasArgument("pluginKey")) {
          pluginKey = call.argument("pluginKey");
        }
        this.setLocationOption(pluginKey, locationInterval, sensorEnable, needAddress, geoLanguage, onceLocation,
          locationMode);
        break;
      case "startLocation":

        if (call.hasArgument("pluginKey")) {
          pluginKey = call.argument("pluginKey");
        }
        this.startLocation(pluginKey);
        break;
      case "stopLocation":
        if (call.hasArgument("pluginKey")) {
          pluginKey = call.argument("pluginKey");
        }
        this.stopLocation(pluginKey);
        break;
      case "destroy":
        if (call.hasArgument("pluginKey")) {
          pluginKey = call.argument("pluginKey");
        }
        this.destroy(pluginKey);
        break;
      case "keywordsSearch":
      case "boundSearch":
      case "inputTips":
      case "getPOIById":
      case "routeSearch":
      case "truckRouteSearch":
      case "geocoding":
      case "reGeocoding":
        /// todo getSearchPlugin
        break;
      default:

        break;

    }
  }


  getUniqueClassName(): string {
    return "FlutterLocPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.mContext = binding.getApplicationContext();
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "flutter_harmony_channel");
    this.channel.setMethodCallHandler(this)

    this.eventChannel = new EventChannel(binding.getBinaryMessenger(), "flutter_harmony_channel")
    this.eventChannel.setStreamHandler(this)

  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }



  onListen(args: object, events: EventSink): void {
    this.mEventSink = events
  }

  onCancel(args: object): void {
    for (let valuesElement of this.locationClientMap.values()) {
      valuesElement.stopLocation(2)
    }
  }

  /**
   * 设置定位参数
   */
  setLocationOption(pluginKey: string, locationInterval: number, sensorEnable: boolean, needAddress: boolean,
    geoLanguage: number, onceLocation: boolean, locationMode: number): void {
    if (this.xbr_gaode_background_location_key == pluginKey) {
      if (null != locationInterval) {
        this.backgroundLocationOption.setInterval(locationInterval);
      }
      // if (null != sensorEnable) this.backgroundLocationOption.setSensorEnable(sensorEnable);
      if (null != needAddress) {
        this.backgroundLocationOption.setNeedAddress(needAddress);
      }
      if (null != geoLanguage) {
        this.backgroundLocationOption.d24(geoLanguage);
      }
      if (null != onceLocation) {
        this.backgroundLocationOption.setOnceLocation(onceLocation);
      }
      if (null != locationMode) {
        this.backgroundLocationOption.setLocationMode(locationMode);
      }
      //注册广播
      /// todo 后台定位 广播
      // registerReceiver();
      return;
    }
    let locationClientImp = this.getLocationClientImp(pluginKey);
    if (null != locationClientImp) {
      locationClientImp.setLocationOption(locationInterval, sensorEnable, needAddress, geoLanguage, onceLocation,
        locationMode);
    }
  }

  private getLocationClientImp(pluginKey: string): AMapLocationService | undefined {
    if (null == this.locationClientMap) {
      this.locationClientMap = new Map<String, AMapLocationService>();
    }
    if (pluginKey == null || "" == pluginKey) {
      return undefined;
    }
    if (!this.locationClientMap.has(pluginKey)) {

      let locationClientImp = new AMapLocationService(this.mContext!, pluginKey!, this.mEventSink!);
      this.locationClientMap.set(pluginKey, locationClientImp);
    }
    return this.locationClientMap.get(pluginKey);
  }


  /**
   * 开始定位
   */
  startLocation(pluginKey: string): void {
    if (this.xbr_gaode_background_location_key === pluginKey) {
      /// todo 后台定位服务
      // startLocationService();
      return;
    }
    let locationClientImp = this.getLocationClientImp(pluginKey);
    if (null != locationClientImp) {
      locationClientImp.startLocation(2);
    }
  }

  /**
   * 停止定位
   */
  stopLocation(pluginKey: string): void {
    if (this.xbr_gaode_background_location_key == pluginKey) {
      /// todo 停止后台定位服务
      // stopLocationService();
      return;
    }
    let locationClientImp = this.getLocationClientImp(pluginKey);
    if (null != locationClientImp) {
      locationClientImp.stopLocation(2);
    }
  }

  /**
   * 销毁
   */
  destroy(pluginKey: string): void {
    if (this.xbr_gaode_background_location_key == pluginKey) {
      /// todo 后台定位 注销广播
      // unRegisterReceiver();
      return;
    }
    let locationClientImp = this.getLocationClientImp(pluginKey);
    if (null != locationClientImp) {
      locationClientImp.destroy();
      this.locationClientMap.delete(pluginKey);
    }
  }
}


@Builder
export function clauseComponent(): void {
  Image($r('app.media.icon'))
    .width('80vp')
    .height('80vp')
    .margin({ top: 120 })
    .alignRules({
      middle: { anchor: '__container__', align: HorizontalAlign.Center },
      top: { anchor: '__container__', align: VerticalAlign.Top },
    })
}