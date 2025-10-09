package com.yilin.xbr.xbr_gaode_amap.location;

import android.content.Context;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationListener;
import com.yilin.xbr.xbr_gaode_amap.location.keep_alive_service.utils.LocationUtil;

import java.util.Map;
import io.flutter.plugin.common.EventChannel;

public class AMapLocationService implements AMapLocationListener {

    private Context mContext;
    private AMapLocationClientOption locationOption = new AMapLocationClientOption();
    private AMapLocationClient locationClient = null;
    private EventChannel.EventSink mEventSink;
    private String mPluginKey;

    public AMapLocationService(Context context, String pluginKey, EventChannel.EventSink eventSink) {
        mContext = context;
        mPluginKey = pluginKey;
        mEventSink = eventSink;
        try {
            if (null == locationClient) {
                locationClient = new AMapLocationClient(context);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 开始定位
     */
    public void startLocation() {
        try {
            if (null == locationClient) {
                locationClient = new AMapLocationClient(mContext);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (null != locationOption) {
            locationClient.setLocationOption(locationOption);
            locationClient.setLocationListener(this);
            locationClient.startLocation();
        }
    }

    /**
     * 停止定位
     */
    public void stopLocation() {
        if (null != locationClient) {
            locationClient.stopLocation();
            locationClient.onDestroy();
            locationClient = null;
        }
    }

    /**
     * 销毁定位
     */
    public void destroy() {
        if(null != locationClient) {
            locationClient.onDestroy();
            locationClient = null;
        }
    }

    /**
     * 定位回调
     */
    @Override
    public void onLocationChanged(AMapLocation location) {
        if (null == mEventSink) return;
        Map<String, Object> result = LocationUtil.buildLocationResultMap(location);
        result.put("pluginKey", mPluginKey);
        mEventSink.success(result);
    }

    /**
     * 设置定位参数
     */
    public void setLocationOption(Integer locationInterval,Boolean sensorEnable,Boolean needAddress,Integer geoLanguage,Boolean onceLocation,Integer locationMode) {
        if (null == locationOption) locationOption = new AMapLocationClientOption();
        if (null != locationInterval) locationOption.setInterval(locationInterval.longValue());
        if (null != sensorEnable) locationOption.setSensorEnable(sensorEnable);
        if (null != needAddress) locationOption.setNeedAddress(needAddress);
        if (null != geoLanguage) locationOption.setGeoLanguage(AMapLocationClientOption.GeoLanguage.values()[geoLanguage]);
        if (null != onceLocation) locationOption.setOnceLocation(onceLocation);
        if (null != locationMode) locationOption.setLocationMode(AMapLocationClientOption.AMapLocationMode.values()[locationMode]);
        if (null != locationClient) locationClient.setLocationOption(locationOption);
    }

}
