import { AMapLocation, AMapLocationMoreType } from "@amap/amap_lbs_location";
import { intl } from '@kit.LocalizationKit';

export default class LocationUtil {
  static buildLocationResultMap(location: AMapLocation): Map<String, Object> {
    let result: Map<String, Object> = new Map<String, Object>();
    result.set("callbackTime", LocationUtil.formatUTC(Date.now(), ""));
    if (null != location) {
      result.set("locationTime", LocationUtil.formatUTC(location.timeStamp, ""));
      result.set("locationType", location.locationType ?? AMapLocationMoreType.LOCATION_TYPE_AMAP);
      result.set("latitude", location.latitude);
      result.set("longitude", location.longitude);
      result.set("accuracy", location.accuracy);
      result.set("altitude", location.altitude);
      result.set("bearing", location.bearing ?? 0);
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
      result.set("description", location.locationDetail ?? "");
    } else {
      result.set("errorCode", -1);
      result.set("errorInfo", "location is null");
    }
    return result;
  }

  /**
   * 格式化时间
   */
  static formatUTC(time: number, strPattern: String): String {
    if (strPattern == "") {
      strPattern = "yyyy-MM-dd HH:mm:ss";
    }

    let dateFormat = new intl.DateTimeFormat();
    const date = new Date(time);

    return dateFormat.format(date);
  }
}