package com.yilin.xbr.xbr_gaode_amap.location;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.amap.api.location.AMapLocationClientOption;
import com.google.gson.reflect.TypeToken;
import com.yilin.xbr.xbr_gaode_amap._code.GsonUtil;
import com.yilin.xbr.xbr_gaode_amap.location.keep_alive_service.LocationService;
import com.yilin.xbr.xbr_gaode_amap.location.keep_alive_service.LocationStatusManager;
import com.yilin.xbr.xbr_gaode_amap.location.keep_alive_service.utils.Utils;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * 高德地图定位sdkFlutterPlugin
 */
public class XbrAMapLocationPlugin implements EventChannel.StreamHandler {
    public static final String RECEIVER_ACTION = "location_in_background";
    public static final String xbr_gaode_background_location_key = "xbr_gaode_background_location";
    public Map<String, AMapLocationService> locationClientMap = new ConcurrentHashMap<>(8);
    private BroadcastReceiver locationChangeBroadcastReceiver;
    public static EventChannel.EventSink mEventSink = null;
    private final AMapLocationClientOption backgroundLocationOption = new AMapLocationClientOption();
    private final Activity activity;

    public XbrAMapLocationPlugin(Activity activity) {
        this.activity = activity;
    }

    public void onMethodCall(MethodCall call, @NonNull Result result) {
        String pluginKey = null;
        switch (call.method) {
            case "setLocationOption":
                Integer locationInterval = null, geoLanguage = null, locationMode = null;
                Boolean sensorEnable = null, needAddress = null, onceLocation = null;
                if (call.hasArgument("locationInterval")) locationInterval = call.argument("locationInterval");
                if (call.hasArgument("geoLanguage")) geoLanguage = call.argument("geoLanguage");
                if (call.hasArgument("locationMode")) locationMode = call.argument("locationMode");
                if (call.hasArgument("sensorEnable")) sensorEnable = call.argument("sensorEnable");
                if (call.hasArgument("needAddress")) needAddress = call.argument("needAddress");
                if (call.hasArgument("onceLocation")) onceLocation = call.argument("onceLocation");
                if (call.hasArgument("pluginKey")) pluginKey = call.argument("pluginKey");
                setLocationOption(pluginKey,locationInterval, sensorEnable, needAddress, geoLanguage, onceLocation, locationMode);
                break;
            case "startLocation":
                if (call.hasArgument("pluginKey")) pluginKey = call.argument("pluginKey");
                startLocation(pluginKey);
                break;
            case "stopLocation":
                if (call.hasArgument("pluginKey")) pluginKey = call.argument("pluginKey");
                stopLocation( pluginKey);
                break;
            case "destroy":
                if (call.hasArgument("pluginKey")) pluginKey = call.argument("pluginKey");
                destroy(pluginKey);
                break;
        }
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        mEventSink = eventSink;
    }

    @Override
    public void onCancel(Object o) {
        for (Map.Entry<String, AMapLocationService> entry : locationClientMap.entrySet()) {
            entry.getValue().stopLocation();
        }
    }

    /**
     * 注册广播 new
     */
    protected void registerReceiver() {
        if (locationChangeBroadcastReceiver == null) {
            locationChangeBroadcastReceiver = new BroadcastReceiver() {
                @Override
                public void onReceive(Context context, Intent intent) {
                    String action = intent.getAction();
                    assert action != null;
                    if (action.equals(RECEIVER_ACTION)) {
                        String json = intent.getStringExtra("result");
                        Map<String, Object> result = GsonUtil.fromJson(json,new TypeToken<Map<String, Object>>(){});
                        assert result != null;
                        result.put("pluginKey", xbr_gaode_background_location_key);
                        mEventSink.success(result);
                    }
                }
            };
        }
        /// 注册广播
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(RECEIVER_ACTION);
        activity.registerReceiver(locationChangeBroadcastReceiver, intentFilter);
    }

    /**
     * 取消注册广播 new
     */
    protected void unRegisterReceiver() {
        if (locationChangeBroadcastReceiver != null) {
            activity.unregisterReceiver(locationChangeBroadcastReceiver);
            locationChangeBroadcastReceiver = null;
        }
    }

    /**
     * 启动后台定位服务 new
     */
    public void startLocationService() {
        Intent intent = new Intent(activity, LocationService.class);
        Bundle bundle = new Bundle();
        bundle.putLong("locationInterval", backgroundLocationOption.getInterval());
        bundle.putBoolean("sensorEnable", backgroundLocationOption.isSensorEnable());//传感器
        bundle.putBoolean("needAddress", backgroundLocationOption.isNeedAddress());//需求地址
        bundle.putInt("geoLanguage", backgroundLocationOption.getGeoLanguage().ordinal());//
        bundle.putBoolean("onceLocation", false);//后台定位不可能使用
        bundle.putInt("locationMode", backgroundLocationOption.getLocationMode().ordinal());//
        intent.putExtras(bundle);
        activity.getApplicationContext().startService(intent);
        LocationStatusManager.getInstance().resetToInit(activity.getApplicationContext());
    }

    /**
     * 关闭后台定位服务 new
     */
    public void stopLocationService() {
        activity.sendBroadcast(Utils.getCloseBrodecastIntent());
        LocationStatusManager.getInstance().resetToInit(activity.getApplicationContext());
    }

    /**
     * 设置定位参数
     */
    public void setLocationOption(String pluginKey,Integer locationInterval, Boolean sensorEnable, Boolean needAddress,
                                   Integer geoLanguage, Boolean onceLocation, Integer locationMode) {
        if (xbr_gaode_background_location_key.equals(pluginKey)) {
            if (null != locationInterval) backgroundLocationOption.setInterval(locationInterval.longValue());
            if (null != sensorEnable) backgroundLocationOption.setSensorEnable(sensorEnable);
            if (null != needAddress) backgroundLocationOption.setNeedAddress(needAddress);
            if (null != geoLanguage) backgroundLocationOption.setGeoLanguage(AMapLocationClientOption.GeoLanguage.values()[geoLanguage]);
            if (null != onceLocation) backgroundLocationOption.setOnceLocation(onceLocation);
            if (null != locationMode) backgroundLocationOption.setLocationMode(AMapLocationClientOption.AMapLocationMode.values()[locationMode]);
            //注册广播
            registerReceiver();
            return;
        }
        AMapLocationService locationClientImp = getLocationClientImp(pluginKey);
        if (null != locationClientImp) {
            locationClientImp.setLocationOption(locationInterval, sensorEnable, needAddress, geoLanguage, onceLocation, locationMode);
        }
    }

    /**
     * 开始定位
     */
    public void startLocation(String pluginKey) {
        if (xbr_gaode_background_location_key.equals(pluginKey)) {
            startLocationService();
            return;
        }
        AMapLocationService locationClientImp = getLocationClientImp(pluginKey);
        if (null != locationClientImp) {
            locationClientImp.startLocation();
        }
    }

    /**
     * 停止定位
     */
    public void stopLocation(String pluginKey) {
        if (xbr_gaode_background_location_key.equals(pluginKey)) {
            stopLocationService();
            return;
        }
        AMapLocationService locationClientImp = getLocationClientImp(pluginKey);
        if (null != locationClientImp) {
            locationClientImp.stopLocation();
        }
    }

    /**
     * 销毁
     */
    public void destroy(String pluginKey) {
        if (xbr_gaode_background_location_key.equals(pluginKey)) {
            unRegisterReceiver();
            return;
        }
        AMapLocationService locationClientImp = getLocationClientImp(pluginKey);
        if (null != locationClientImp) {
            locationClientImp.destroy();
            locationClientMap.remove(pluginKey);
        }
    }

    private AMapLocationService getLocationClientImp(String pluginKey) {
        if (null == locationClientMap) locationClientMap = new ConcurrentHashMap<>(8);
        if (TextUtils.isEmpty(pluginKey)) return null;
        if (!locationClientMap.containsKey(pluginKey)) {
            AMapLocationService locationClientImp = new AMapLocationService(activity.getApplicationContext(), pluginKey, mEventSink);
            locationClientMap.put(pluginKey, locationClientImp);
        }
        return locationClientMap.get(pluginKey);
    }

}
