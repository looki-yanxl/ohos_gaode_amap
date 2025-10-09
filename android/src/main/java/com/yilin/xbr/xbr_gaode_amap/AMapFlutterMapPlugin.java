package com.yilin.xbr.xbr_gaode_amap;

import androidx.annotation.NonNull;
import androidx.lifecycle.Lifecycle;

import com.amap.api.location.AMapLocationClient;
import com.amap.api.maps.MapsInitializer;
import com.amap.api.services.core.ServiceSettings;
import com.yilin.xbr.xbr_gaode_amap.amap.AMapPlatformViewFactory;
import com.yilin.xbr.xbr_gaode_amap.amap.LifecycleProvider;
import com.yilin.xbr.xbr_gaode_amap.amap.utils.LogUtil;
import com.yilin.xbr.xbr_gaode_amap.location.AMapLocationService;
import com.yilin.xbr.xbr_gaode_amap.location.XbrAMapLocationPlugin;
import com.yilin.xbr.xbr_gaode_amap.search.XbrAMapSearchPlugin;

import java.util.Map;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;


/** XbrGaodeNaviAmapPlugin */
public class AMapFlutterMapPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler, EventChannel.StreamHandler  {
  private static final String CLASS_NAME = "XbrGaodeAmapPlugin";
  private static final String VIEW_TYPE = "com.yilin.xbr.amap";

  private static final String CHANNEL_METHOD_LOCATION = "xbr_gaode_amap";
  private static final String CHANNEL_STREAM_LOCATION = "xbr_gaode_location_stream";
  private ActivityPluginBinding binding;
  private Lifecycle lifecycle;

  XbrAMapLocationPlugin _locationPlugin;
  XbrAMapSearchPlugin _searchPlugin;
  public XbrAMapLocationPlugin getLocationPlugin() {
    if (_locationPlugin==null) _locationPlugin = new XbrAMapLocationPlugin(binding.getActivity());
    return _locationPlugin;
  }
  public XbrAMapSearchPlugin getSearchPlugin() {
    if (_searchPlugin==null) _searchPlugin = new XbrAMapSearchPlugin(binding.getActivity());
    return _searchPlugin;
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    LogUtil.i(CLASS_NAME, "onAttachedToEngine==>");
    //视图工厂注册【地图】
    AMapPlatformViewFactory factory = new AMapPlatformViewFactory(binding.getBinaryMessenger(), new LifecycleProvider() {
      @Override
      public Lifecycle getLifecycle() {
        return lifecycle;
      }
    });
    binding.getPlatformViewRegistry().registerViewFactory(VIEW_TYPE,factory);
    //方法调用通道
    final MethodChannel channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_METHOD_LOCATION);
    channel.setMethodCallHandler(this);
    //回调监听通道
    final EventChannel eventChannel = new EventChannel(binding.getBinaryMessenger(), CHANNEL_STREAM_LOCATION);
    eventChannel.setStreamHandler(this);
  }


  @Override
  public void onListen(Object o, EventChannel.EventSink eventSink) {
    XbrAMapLocationPlugin.mEventSink = eventSink;
  }

  @Override
  public void onCancel(Object o) {
    for (Map.Entry<String, AMapLocationService> entry : getLocationPlugin().locationClientMap.entrySet()) {
      entry.getValue().stopLocation();
    }
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "updatePrivacyStatement":
        Boolean hasContains = null, hasShow = null, hasAgree = null;
        if (call.hasArgument("hasContains")) hasContains = call.argument("hasContains");
        if (call.hasArgument("hasShow")) hasShow = call.argument("hasShow");
        if (call.hasArgument("hasAgree")) hasAgree = call.argument("hasAgree");
        updatePrivacyStatement(hasContains, hasShow, hasAgree);
        result.success("SUCCESS");
        break;
      case "setApiKey":
        String androidKey = null;
        if (call.hasArgument("android")) androidKey = call.argument("android");
        setApiKey(androidKey);
        result.success("SUCCESS");
        break;
      //定位区
      case "setLocationOption":
      case "startLocation":
      case "stopLocation":
      case "destroy":
        getLocationPlugin().onMethodCall(call,result);
        break;
      //搜索区
      case "keywordsSearch":
      case "boundSearch":
      case "inputTips":
      case "getPOIById":
      case "routeSearch":
      case "truckRouteSearch":
      case "geocoding":
      case "reGeocoding":
        getSearchPlugin().onMethodCall(call,result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  /**
   * 隐私协议
   */
  private void updatePrivacyStatement(Boolean hasContains, Boolean hasShow, Boolean hasAgree) {
    try {
      if (hasContains!=null && hasShow!=null){
        MapsInitializer.updatePrivacyShow(binding.getActivity().getApplicationContext(),hasContains,hasShow);
        ServiceSettings.updatePrivacyShow(binding.getActivity().getApplicationContext(),hasContains,hasShow);
        AMapLocationClient.updatePrivacyShow(binding.getActivity().getApplicationContext(),hasContains,hasShow);
      }
      if (hasAgree!=null){
        MapsInitializer.updatePrivacyAgree(binding.getActivity().getApplicationContext(),hasAgree);
        ServiceSettings.updatePrivacyAgree(binding.getActivity().getApplicationContext(),hasAgree);
        AMapLocationClient.updatePrivacyAgree(binding.getActivity().getApplicationContext(),hasAgree);
      }
    } catch (Throwable e) {
      LogUtil.e("AMapFlutterMapPlugin","updatePrivacyStatement",e);
    }
  }

  /**
   * 设置apikey
   */
  private void setApiKey(String androidKey) {
    if (null != androidKey) {
      MapsInitializer.setApiKey(androidKey);
      ServiceSettings.getInstance().setApiKey(androidKey);
      AMapLocationClient.setApiKey(androidKey);
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    LogUtil.i(CLASS_NAME, "onDetachedFromEngine==>");
    for (Map.Entry<String, AMapLocationService> entry : getLocationPlugin().locationClientMap.entrySet()) {
      entry.getValue().destroy();
    }
  }

  // ActivityAware
  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    LogUtil.i(CLASS_NAME, "onAttachedToActivity==>");
    lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding);
    this.binding = binding;
  }

  @Override
  public void onDetachedFromActivity() {
    LogUtil.i(CLASS_NAME, "onDetachedFromActivity==>");
    lifecycle = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    LogUtil.i(CLASS_NAME, "onReattachedToActivityForConfigChanges==>");
    onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    LogUtil.i(CLASS_NAME, "onDetachedFromActivityForConfigChanges==>");
    this.onDetachedFromActivity();
  }
}
