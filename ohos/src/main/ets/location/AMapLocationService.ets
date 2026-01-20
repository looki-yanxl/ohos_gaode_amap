import {
  AMapLocation,
  AMapLocationErrorInfo,
  AMapLocationManager,
  AMapLocationManagerImpl,
  AMapLocationOption,
  AMapLocationType,
  IAMapLocationListener
} from '@amap/amap_lbs_location';
import { EventSink } from '@ohos/flutter_ohos';
import { geoLocationManager } from '@kit.LocationKit';
import LocationUtil from './util/LocationUtil';

export default class AMapLocationService implements IAMapLocationListener {
  private mContext: Context | null = null
  private mPluginKey: string
  private mEventSink: EventSink | null = null
  public locationOption: AMapLocationOption| null = null;
  private locationClient: AMapLocationManager | null = null;

  constructor(context: Context, pluginKey: string, eventSink: EventSink) {
    this.mContext = context;
    this.mPluginKey = pluginKey;
    this.mEventSink = eventSink;
    if (null == this.locationClient) {
      this.locationClient = new AMapLocationManagerImpl(context)
    }

  }

  /**
   * 设置定位参数
   *
   */
  setLocationOption(locationInterval: number, sensorEnable: boolean, needAddress: boolean, geoLanguage: number,
    onceLocation: boolean, locationMode: number): void {

    if (locationMode == 1) {
      //单次定位
      this.locationOption = {
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX, //定位优先配置选项
        scenario: geoLocationManager.LocationRequestScenario.UNSET, //定位场景设置
        maxAccuracy: 0, //定位精度 单位：米
        singleLocationTimeout: 3000, //指定单次定位超时时间
        locatingWithReGeocode: false, //定位是否返回逆地理信息
        reGeocodeLanguage: geoLanguage, //逆地址语言类型
        isOffset: false //是否加偏
      }
    }else if (locationMode == 2) {
      //连续定位
      this.locationOption = {
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX, //定位优先配置选项
        scenario: geoLocationManager.LocationRequestScenario.UNSET, //定位场景设置
        timeInterval: locationInterval, //定位时间间隔
        distanceInterval: 0, //位置报告距离间隔
        maxAccuracy: 20, //定位精度 单位：米
        allowsBackgroundLocationUpdates: true, //是否允许后台定位
        locatingWithReGeocode: needAddress, //定位是否返回逆地理信息
        reGeocodeLanguage: geoLanguage, //逆地址语言类型
        isOffset: true //是否加偏
      }
    }

    if (null != this.locationClient) {
      this.locationClient.setLocationOption(onceLocation ? 1 : 2, this.locationOption);
    }
  }

  /**
   * 开始定位
   */
  public startLocation(locationMode: number):void {
    try {
      if (null == this.locationClient) {
        this.locationClient = new AMapLocationManagerImpl(this.mContext!.getApplicationContext());
      }
    }catch (e) {

    }
    if (null != this.locationOption) {
      if (1 == locationMode) {
        this.locationClient?.setLocationListener(AMapLocationType.Single,this) //设置定位信息监听
        this.locationClient?.setLocationOption(AMapLocationType.Single,this.locationOption) //设置定位配置项
        this.locationClient?.requestSingleLocation() //单次定位
      }else if (2 == locationMode) {
        this.locationClient?.setLocationOption(locationMode,this.locationOption);
        this.locationClient?.setLocationListener(AMapLocationType.Updating,this);
        this.locationClient?.startUpdatingLocation();
      }

    }
  }

  /**
   * 停止定位
   */
  public stopLocation(locationMode: number):void{
    if (null != this.locationClient) {
      if (1 == locationMode) {
        this.locationClient = null;
      }else if (2 == locationMode) {
        this.locationClient.stopUpdatingLocation();
        this.locationClient = null;
      }

    }
  }

  /**
   * 销毁定位
   */
  public destroy():void {
    if(null != this.locationClient) {
      this.locationClient = null;
    }
  }



  public onLocationChanged(location: AMapLocation):void{
    if(null == this.mEventSink)return;
    let result = LocationUtil.buildLocationResultMap(location);
    result.set("pluginKey", this.mPluginKey);
    this.mEventSink.success(result);
  };

  public onLocationChangedSuccess(location: geoLocationManager.Location):void{
    if(null == this.mEventSink)return;
    let result: Map<String, Object> = new Map<String, Object>();
    result.set("callbackTime", LocationUtil.formatUTC(Date.now(), ""));
    if (null != location) {
      result.set("locationTime", LocationUtil.formatUTC(location.timeStamp, ""));
      result.set("latitude", location.latitude);
      result.set("longitude", location.longitude);
      result.set("accuracy", location.accuracy);
      result.set("altitude", location.altitude);
      result.set("speed", location.speed);

      /// todo 省市区
      // result.set("country", location.getCountry());
      // result.set("province", location.getProvince());
      // result.set("city", location.getCity());
      // result.set("district", location.getDistrict());
      // result.set("street", location.getStreet());
      // result.set("streetNumber", location.getStreetNum());
      // result.set("cityCode", location.getCityCode());
      // result.set("adCode", location.getAdCode());
      // result.set("address", location.getAddress());
    } else {
      result.set("errorCode", -1);
      result.set("errorInfo", "location is null");
    }
    result.set("pluginKey", this.mPluginKey);
    this.mEventSink.success(result);
  };

  public onLocationError(locationErrorInfo: AMapLocationErrorInfo):void{
    if(null == this.mEventSink)return;
    this.mEventSink?.error(locationErrorInfo.errorCode.toString(),locationErrorInfo.errorMsg,null);
  };
}
