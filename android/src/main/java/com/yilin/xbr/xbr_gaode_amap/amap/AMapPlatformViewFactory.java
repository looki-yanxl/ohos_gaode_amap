package com.yilin.xbr.xbr_gaode_amap.amap;

import android.content.Context;

import com.amap.api.maps.model.CameraPosition;
import com.yilin.xbr.xbr_gaode_amap.amap.utils.ConvertUtil;
import com.yilin.xbr.xbr_gaode_amap.amap.utils.LogUtil;

import java.util.Map;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class AMapPlatformViewFactory extends PlatformViewFactory {
    private static final String CLASS_NAME = "AMapPlatformViewFactory";
    private final BinaryMessenger binaryMessenger;
    private final LifecycleProvider lifecycleProvider;
    public AMapPlatformViewFactory(BinaryMessenger binaryMessenger, LifecycleProvider lifecycleProvider) {
        super(StandardMessageCodec.INSTANCE);
        this.binaryMessenger = binaryMessenger;
        this.lifecycleProvider = lifecycleProvider;
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        final AMapOptionsBuilder builder = new AMapOptionsBuilder();
        Map<String, Object> params;
        try {
            ConvertUtil.density = context.getResources().getDisplayMetrics().density;
            params = (Map<String, Object>) args;
            LogUtil.i(CLASS_NAME,"create params==>" + params);
            if (params.containsKey("privacyStatement")) {
                ConvertUtil.setPrivacyStatement(context, params.get("privacyStatement"));
            }
            Object options = ((Map<String, Object>) args).get("options");
            if(null != options) {
                ConvertUtil.interpretAMapOptions(options, builder);
            }
            if (params.containsKey("initialCameraPosition")) {
                CameraPosition cameraPosition = ConvertUtil.toCameraPosition(params.get("initialCameraPosition"));
                builder.setCamera(cameraPosition);
            }
            if (params.containsKey("markersToAdd")) {
                builder.setInitialMarkers(params.get("markersToAdd"));
            }
            if (params.containsKey("polylinesToAdd")) {
                builder.setInitialPolylines(params.get("polylinesToAdd"));
            }
            if (params.containsKey("polygonsToAdd")) {
                builder.setInitialPolygons(params.get("polygonsToAdd"));
            }
            if (params.containsKey("apiKey")) {
                ConvertUtil.checkApiKey(params.get("apiKey"));
            }
            if (params.containsKey("debugMode")) {
                LogUtil.isDebugMode = ConvertUtil.toBoolean(params.get("debugMode"));
            }
        } catch (Throwable e) {
            LogUtil.e(CLASS_NAME, "create", e);
        }
        return builder.build(viewId, context, binaryMessenger, lifecycleProvider);
    }
}
