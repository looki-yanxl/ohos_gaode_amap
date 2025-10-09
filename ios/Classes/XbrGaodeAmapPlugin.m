#import "XbrGaodeAmapPlugin.h"
#import "AMapFlutterFactory.h"
#import "AMapFlutterStreamManager.h"
#import "XbrGaodeSearchPlugin.h"
#import "XbrGaodeLocationPlugin.h"
// AMap iOS SDK headers
#import <MAMapKit/MAMapKit.h>            // MAMapView, MAMapVersionNumber
#import <AMapSearchKit/AMapSearchKit.h>  // AMapSearchAPI
#import <AMapLocationKit/AMapLocationKit.h> // AMapLocationManager
#import <AMapFoundationKit/AMapFoundationKit.h> // AMapServices

@implementation XbrGaodeAmapPlugin{
//    NSObject<FlutterPluginRegistrar>* _registrar;
//    FlutterMethodChannel* _channel;
//    NSMutableDictionary* _mapControllers;
//
    XbrGaodeSearchPlugin* searchPlugin;
    XbrGaodeLocationPlugin* locationPlugin;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  //#### 公共方法注册通道
  FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"xbr_gaode_amap" binaryMessenger:[registrar messenger]];
  XbrGaodeAmapPlugin* instance = [[XbrGaodeAmapPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  //#### 地图：注册视图控件
  AMapFlutterFactory* aMapFactory = [[AMapFlutterFactory alloc] initWithRegistrar:registrar];
  [registrar registerViewFactory:aMapFactory withId:@"com.yilin.xbr.amap" gestureRecognizersBlockingPolicy: FlutterPlatformViewGestureRecognizersBlockingPolicyWaitUntilTouchesEnded];
  //#### 定位：設置事件通道
  FlutterEventChannel *eventChanel = [FlutterEventChannel eventChannelWithName:@"xbr_gaode_location_stream" binaryMessenger:[registrar messenger]];
  [eventChanel setStreamHandler:[[AMapFlutterStreamManager sharedInstance] streamHandler]];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"updatePrivacyStatement" isEqualToString:call.method]) {
      [self updatePrivacyStatement:call.arguments];
    } else if ([@"setApiKey" isEqualToString:call.method]){
      NSString *apiKey = call.arguments[@"ios"];
      if (apiKey && [apiKey isKindOfClass:[NSString class]]) {
          [AMapServices sharedServices].apiKey = apiKey;
          [[AMapServices sharedServices] setEnableHTTPS:YES];
          result(@YES);
      }else {
          result(@NO);
      }
    }else if ([@"startLocation" isEqualToString:call.method] || [@"stopLocation" isEqualToString:call.method] ||
              [@"setLocationOption" isEqualToString:call.method] ||[@"destroy" isEqualToString:call.method] ||
              [@"getSystemAccuracyAuthorization" isEqualToString:call.method] ){
        if(locationPlugin==nil) locationPlugin = [[XbrGaodeLocationPlugin alloc]init];
        [locationPlugin handleMethodCall:call result:result];
    }else if ([@"keywordsSearch" isEqualToString:call.method] || [@"boundSearch" isEqualToString:call.method]||
              [@"getPOIById" isEqualToString:call.method] ||[@"inputTips" isEqualToString:call.method] ||
              [@"routeSearch" isEqualToString:call.method] ||[@"truckRouteSearch" isEqualToString:call.method] ||
              [@"geocoding" isEqualToString:call.method] ||[@"reGeocoding" isEqualToString:call.method] ){
        if(searchPlugin==nil) searchPlugin = [[XbrGaodeSearchPlugin alloc]init];
        [searchPlugin handleMethodCall:call result:result];
    }else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)updatePrivacyStatement:(NSDictionary *)arguments {
    if ((MAMapVersionNumber) < 80100) {
        NSLog(@"当前地图SDK版本没有隐私合规接口，请升级地图SDK到8.1.0及以上版本");
        return;
    }
    if (arguments == nil)  return;
    if (arguments[@"hasContains"] != nil && arguments[@"hasShow"] != nil) {
        [MAMapView updatePrivacyShow:[arguments[@"hasShow"] integerValue] privacyInfo:[arguments[@"hasContains"] integerValue]];
        [AMapSearchAPI updatePrivacyShow:[arguments[@"hasShow"] integerValue] privacyInfo:[arguments[@"hasContains"] integerValue]];
        [AMapLocationManager updatePrivacyShow:[arguments[@"hasShow"] integerValue] privacyInfo:[arguments[@"hasContains"] integerValue]];
    }
    if (arguments[@"hasAgree"] != nil) {
        [MAMapView updatePrivacyAgree:[arguments[@"hasAgree"] integerValue]];
        [AMapSearchAPI updatePrivacyAgree:[arguments[@"hasAgree"] integerValue]];
        [AMapLocationManager updatePrivacyAgree:[arguments[@"hasAgree"] integerValue]];
    }
}

@end
