package com.yilin.xbr.xbr_gaode_amap.amap.utils;

import android.util.Log;

public class LogUtil {
    public static boolean isDebugMode = false;
    private static final String TAG = "AMapFlutter_";
    public static void i(String className, String message) {
        if(isDebugMode) {
            Log.i(TAG+className, message);
        }
    }
    public static void d(String className, String message) {
        if(isDebugMode) {
            Log.d(TAG+className, message);
        }
    }

    public static void w(String className, String message) {
        if(isDebugMode) {
            Log.w(TAG+className, message);
        }
    }


    public static void e(String className, String methodName, Throwable e) {
        if (isDebugMode) {
            Log.e(TAG+className, methodName + " exception!!", e);
        }
    }

}
