package com.yilin.xbr.xbr_gaode_amap.location.keep_alive_service.utils;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.PowerManager;

import java.lang.reflect.Method;
import java.util.concurrent.ThreadFactory;

/**
 * 获得PARTIAL_WAKE_LOCK	， 保证在息屏状体下，CPU可以正常运行
 */

public class PowerManagerUtil {
    private static class Holder {
        public static PowerManagerUtil instance = new PowerManagerUtil();
    }

    private PowerManager pm = null;
    private PowerManager.WakeLock pmLock = null;

    /**
     * 上次唤醒屏幕的触发时间
     */
    private long mLastWakupTime = System.currentTimeMillis();

    /**
     * 最小的唤醒时间间隔，防止频繁唤醒。默认5分钟
     */
    private final long mMinWakupInterval = 5 * 60 * 1000;

    /**
     * 内部线程工厂
     */
    private InnerThreadFactory mInnerThreadFactory = null;

    public static PowerManagerUtil getInstance() {
        return Holder.instance;
    }

    /**
     * 判断屏幕是否处于点亮状态
     */
    public boolean isScreenOn(final Context context) {
        try {
            Method isScreenMethod = PowerManager.class.getMethod("isScreenOn");
            if (pm == null) pm = (PowerManager) context.getSystemService(Context.POWER_SERVICE);
            return (boolean) (Boolean) isScreenMethod.invoke(pm);
        } catch (Exception e) {
            return true;
        }
    }

    /**
     * 唤醒屏幕
     */
    public void wakeUpScreen(final Context context) throws Exception {
        try {
            acquirePowerLock(context, PowerManager.ACQUIRE_CAUSES_WAKEUP | PowerManager.SCREEN_DIM_WAKE_LOCK);
        } catch (Exception e) {
            throw e;
        }
    }

    /**
     * 根据levelAndFlags，获得PowerManager的WaveLock
     * 利用worker thread去获得锁，以免阻塞主线程
     */
    private void acquirePowerLock(final Context context, final int levelAndFlags) {
        if (context == null) {
            throw new NullPointerException("when invoke aquirePowerLock ,  context is null which is unacceptable");
        }
        long currentMills = System.currentTimeMillis();
        if (currentMills - mLastWakupTime < mMinWakupInterval) return;
        mLastWakupTime = currentMills;
        if (mInnerThreadFactory == null) mInnerThreadFactory = new InnerThreadFactory();
        mInnerThreadFactory.newThread(new Runnable() {
            @SuppressLint("InvalidWakeLockTag")
            @Override
            public void run() {
                if (pm == null) {
                    pm = (PowerManager) context.getSystemService(Context.POWER_SERVICE);
                }
                if (pmLock != null) { // release
                    pmLock.release();
                    pmLock = null;
                }
                pmLock = pm.newWakeLock(levelAndFlags, "MyTag");
                pmLock.acquire(10*60*1000L /*10 minutes*/); //锁自动在10分钟后释放
                pmLock.release();
            }
        }).start();
    }

    /**
     * 线程工厂
     */
    private static class InnerThreadFactory implements ThreadFactory {
        @Override
        public Thread newThread(Runnable runnable) {
            return new Thread(runnable);
        }
    }
}
