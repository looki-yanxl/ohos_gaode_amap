package com.yilin.xbr.xbr_gaode_amap.location.keep_alive_service;

import android.content.Intent;
import android.os.Bundle;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationListener;
import com.yilin.xbr.xbr_gaode_amap._code.GsonUtil;
import com.yilin.xbr.xbr_gaode_amap.location.XbrAMapLocationPlugin;
import com.yilin.xbr.xbr_gaode_amap.location.keep_alive_service.delegate.IWifiAutoCloseDelegate;
import com.yilin.xbr.xbr_gaode_amap.location.keep_alive_service.utils.LocationUtil;
import com.yilin.xbr.xbr_gaode_amap.location.keep_alive_service.utils.NetUtil;
import com.yilin.xbr.xbr_gaode_amap.location.keep_alive_service.utils.PowerManagerUtil;
import java.util.Map;

/**
 * 类说明：后台服务定位
 * 1. 只有在由息屏造成的网络断开造成的定位失败时才点亮屏幕
 * 2. 利用notification机制增加进程优先级
 * </p>
 */
public class LocationService extends NotifyService {
    /**
     * 处理息屏关掉wifi的delegate类
     */
    private final IWifiAutoCloseDelegate mWifiAutoCloseDelegate = new WifiAutoCloseDelegate();
    private AMapLocationClient mLocationClient;
    private AMapLocationClientOption mLocationOption;

    /**
     * 记录是否需要对息屏关掉wifi的情况进行处理
     */
    private boolean mIsWifiCloseable = false;
    AMapLocationListener locationListener = new AMapLocationListener() {
        @Override
        public void onLocationChanged(AMapLocation aMapLocation) {
            //发送结果的通知
            sendLocationBroadcast(aMapLocation);
            if (!mIsWifiCloseable) {
                return;
            }
            if (aMapLocation.getErrorCode() == AMapLocation.LOCATION_SUCCESS) {
                mWifiAutoCloseDelegate.onLocateSuccess(getApplicationContext(), PowerManagerUtil.getInstance().isScreenOn(getApplicationContext()),
                    NetUtil.getInstance().isMobileAva(getApplicationContext()));
            } else {
                mWifiAutoCloseDelegate.onLocateFail(getApplicationContext(), aMapLocation.getErrorCode(), PowerManagerUtil.getInstance().isScreenOn(getApplicationContext()),
                    NetUtil.getInstance().isWifiCon(getApplicationContext()));
            }
        }

        private void sendLocationBroadcast(AMapLocation aMapLocation) {
            Map<String, Object> result = LocationUtil.buildLocationResultMap(aMapLocation);
            Intent mIntent = new Intent(XbrAMapLocationPlugin.RECEIVER_ACTION);
            mIntent.putExtra("result", GsonUtil.toJson(result));
            //发送广播
            sendBroadcast(mIntent);
        }
    };

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        super.onStartCommand(intent, flags, startId);
        applyNotiKeepMech(); //开启利用notification提高进程优先级的机制
        if (mWifiAutoCloseDelegate.isUseful(getApplicationContext())) {
            mIsWifiCloseable = true;
            mWifiAutoCloseDelegate.initOnServiceStarted(getApplicationContext());
        }
        startLocation(intent.getExtras());
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        unApplyNotiKeepMech();
        stopLocation();
        super.onDestroy();
    }

    /**
     * 启动定位
     */
    void startLocation(Bundle bundle) {
        stopLocation();
        if (null == mLocationClient) {
            try {
                mLocationClient = new AMapLocationClient(this.getApplicationContext());
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        mLocationOption = new AMapLocationClientOption();
        // 使用连续
        mLocationOption.setOnceLocation(false);
        mLocationOption.setLocationCacheEnable(false);
        // 每4秒定位一次
        mLocationOption.setInterval(bundle.getLong("locationInterval",4000));
        // 地址信息
        mLocationOption.setNeedAddress(bundle.getBoolean("needAddress",false));
        // 定位模式
        mLocationOption.setLocationMode(AMapLocationClientOption.AMapLocationMode.values()[bundle.getInt("locationMode",2)]);
        // 传感器
        mLocationOption.setSensorEnable(bundle.getBoolean("sensorEnable",true));
        mLocationClient.setLocationOption(mLocationOption);
        mLocationClient.setLocationListener(locationListener);
        mLocationClient.startLocation();
    }

    /**
     * 停止定位
     */
    void stopLocation() {
        if (null != mLocationClient) {
            mLocationClient.stopLocation();
            mLocationClient.onDestroy();
            mLocationClient = null;
        }
    }

}
