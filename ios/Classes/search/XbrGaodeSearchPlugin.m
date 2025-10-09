#import "XbrGaodeSearchPlugin.h"
#import <objc/runtime.h>

@implementation XbrGaodeSearchPlugin
- (instancetype)init {
    if ([super init] == self) {
        self.search = [[AMapSearchAPI alloc] init];
        self.search.delegate=(id)self;
    }
    return self;
}
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary<NSString*, id>* args = call.arguments;
    self.result = result;
    if ( ([@"keywordsSearch" isEqualToString:call.method])) {
        NSString* keyWord = args[@"keyWord"];
        NSString* cityCode = args[@"cityCode"];
        NSNumber* page =args[@"page"];
        NSNumber* limit =args[@"limit"];
        //构造查询
        AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
        request.keywords            = keyWord;
        request.city                = cityCode;
        //request.requireExtension    = YES;
        //搜索SDK 3.2.0 中新增加的功能，只搜索本城市的POI
        request.cityLimit           = YES;
        //request.requireSubPOIs      = YES;
        if(![page isEqual:[NSNull null]]){
            request.page = page.intValue;
        }
        if(![limit isEqual:[NSNull null]]){
            request.offset = limit.intValue;
        }
        //发送请求
        [self.search AMapPOIKeywordsSearch:request];
        
    } else if ( ([@"boundSearch" isEqualToString:call.method])) {
        NSString* pointJson = args[@"pointJson"];
        NSNumber* scope = args[@"scope"];
        NSString* keyWord = args[@"keyWord"];
        NSNumber* page =args[@"page"];
        NSNumber* limit =args[@"limit"];
        //JSON转
        NSData *data = [pointJson dataUsingEncoding:NSUTF8StringEncoding];
        NSArray<NSNumber *>* point = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //构造查询
        AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
        request.location            = [AMapGeoPoint locationWithLatitude:point[0].doubleValue longitude:point[1].doubleValue];
        request.keywords            = keyWord;
        request.radius               = scope.intValue;
        //request.requireExtension    = YES;
        //搜索SDK 3.2.0 中新增加的功能，只搜索本城市的POI
        //request.requireSubPOIs      = YES;
        if(![page isEqual:[NSNull null]]){
            request.page = page.intValue;
        }
        if(![limit isEqual:[NSNull null]]){
            request.offset = limit.intValue;
        }
        //发送请求
        [self.search AMapPOIAroundSearch:request];
        
    } else  if ( ([@"getPOIById" isEqualToString:call.method])) {
        NSString* poiId = args[@"id"];
        //构造查询
        AMapPOIIDSearchRequest *request = [[AMapPOIIDSearchRequest alloc] init];
        request.uid                 = poiId;
        //request.requireExtension    = YES;
        //发送请求
        [self.search AMapPOIIDSearch:request];
    } else if ( ([@"inputTips" isEqualToString:call.method])) {
        NSString* newText = args[@"newText"];
        NSString* city = args[@"city"];
        id cityLimit = args[@"cityLimit"];
        //构造查询
        AMapInputTipsSearchRequest *tips = [[AMapInputTipsSearchRequest alloc] init];
        tips.keywords = newText;
        tips.city     = city;
        if(![cityLimit isEqual:[NSNull null]]){
            tips.cityLimit = (BOOL) cityLimit; //是否限制城市
        }
        //发送请求
        [self.search AMapInputTipsSearch:tips];
    } else if ( ([@"routeSearch" isEqualToString:call.method])) {
        NSNumber* strategy = args[@"strategy"];
        NSString* wayPointsJson = args[@"wayPointsJson"];
        self.onlyOne = args[@"onlyOne"];
        self.simplify = args[@"simplify"];
        self.showFields = args[@"showFields"];
        //JSON转
        NSData *data = [wayPointsJson dataUsingEncoding:NSUTF8StringEncoding];
        //佣数组来接收
        NSArray *pointArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //点位也是一个数组 起点数组
        NSArray<NSNumber *>* sp = [pointArr firstObject];
        //点位也是一个数组 终点 [0-lat,1-lon]
        NSArray<NSNumber *>* ep = [pointArr lastObject];
        //起点对象
        AMapGeoPoint* origin =[AMapGeoPoint locationWithLatitude:sp[0].doubleValue longitude:sp[1].doubleValue];
        //终点对象
        AMapGeoPoint* destination =[AMapGeoPoint locationWithLatitude:ep[0].doubleValue longitude:ep[1].doubleValue];
        //构造途径点对象集合
        NSMutableArray<AMapGeoPoint *> *waypoints = [NSMutableArray arrayWithCapacity:pointArr.count-2];
        if (pointArr.count > 2) {
            //遍历跳开起点和终点
            for (NSInteger i=1; i<pointArr.count-1;i++) {
                NSArray<NSNumber *>* wp = [pointArr objectAtIndex:i];
                AMapGeoPoint* wc =[AMapGeoPoint locationWithLatitude:wp[0].doubleValue longitude:wp[1].doubleValue];
                [waypoints addObject:wc];
            }
        }
        //构造高德地图检索请求
        AMapDrivingCalRouteSearchRequest *searchRequest = [[AMapDrivingCalRouteSearchRequest alloc] init];
        //searchRequest.requireExtension = YES;
        if (![self.showFields isEqual:[NSNull null]] && self.showFields.intValue==-1) {
            searchRequest.showFieldType = AMapDrivingRouteShowFieldTypeAll;
        }else if(![self.showFields isEqual:[NSNull null]] && self.showFields.intValue!=0){
            //这里的算法是安卓端的两倍，默认传值为安卓端
            searchRequest.showFieldType = self.showFields.intValue * 2;
        }
        if(![strategy isEqual:[NSNull null]]){
            searchRequest.strategy = strategy.intValue;
        }
        searchRequest.origin = origin;
        searchRequest.destination = destination;
        searchRequest.waypoints = waypoints;
        //发送请求
        [self.search AMapDrivingV2RouteSearch:searchRequest];
    } else if ( ([@"truckRouteSearch" isEqualToString:call.method])) {
        NSNumber* drivingMode = args[@"drivingMode"];
        NSString* wayPointsJson = args[@"wayPointsJson"];
        NSString* truckInfoJson = args[@"truckInfoJson"];
        self.onlyOne = args[@"onlyOne"];
        self.simplify = args[@"simplify"];
        self.showFields = args[@"showFields"];
        //JSON转
        NSData *data = [wayPointsJson dataUsingEncoding:NSUTF8StringEncoding];
        NSData *tData = [truckInfoJson dataUsingEncoding:NSUTF8StringEncoding];
        //用数组来接收
        NSArray *pointArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //点位也是一个数组 起点数组
        NSArray<NSNumber *>* sp = [pointArr firstObject];
        //点位也是一个数组 终点 [0-lat,1-lon]
        NSArray<NSNumber *>* ep = [pointArr lastObject];
        //起点对象
        AMapGeoPoint* origin =[AMapGeoPoint locationWithLatitude:sp[0].doubleValue longitude:sp[1].doubleValue];
        //终点对象
        AMapGeoPoint* destination =[AMapGeoPoint locationWithLatitude:ep[0].doubleValue longitude:ep[1].doubleValue];
        //构造途径点对象集合
        NSMutableArray<AMapGeoPoint *> *waypoints = [NSMutableArray arrayWithCapacity:pointArr.count-2];
        if (pointArr.count > 2) {
            //遍历跳开起点和终点
            for (NSInteger i=1; i<pointArr.count-1;i++) {
                NSArray<NSNumber *>* wp = [pointArr objectAtIndex:i];
                AMapGeoPoint* wc =[AMapGeoPoint locationWithLatitude:wp[0].doubleValue longitude:wp[1].doubleValue];
                [waypoints addObject:wc];
            }
        }
        //TRUCK用字典接收
        NSDictionary *truck = [NSJSONSerialization JSONObjectWithData:tData options:NSJSONReadingMutableContainers error:nil];
        NSString* plateProvince = [truck objectForKey:@"plateProvince"];
        NSString* plateNumber = [truck objectForKey:@"plateNumber"];
        NSNumber* width = [truck objectForKey:@"truckWidth"];
        NSNumber* height = [truck objectForKey:@"truckHeight"];
        NSNumber* axis = [truck objectForKey:@"truckAxis"];
        NSNumber* load = [truck objectForKey:@"truckLoad"];
        NSNumber* weight = [truck objectForKey:@"truckWeight"];
        //构造高德地图检索请求
        AMapTruckRouteSearchRequest *searchRequest = [[AMapTruckRouteSearchRequest alloc] init];
        searchRequest.requireExtension = YES;
        if(![drivingMode isEqual:[NSNull null]]){
            searchRequest.strategy = drivingMode.intValue;
        }
        searchRequest.origin = origin;
        searchRequest.destination = destination;
        searchRequest.waypoints = waypoints;
        //货车数据
        searchRequest.plateProvince = plateProvince;
        searchRequest.plateNumber = plateNumber;
        if(![width isEqual:[NSNull null]]){
            searchRequest.width = width.doubleValue;
        }
        if(![height isEqual:[NSNull null]]){
            searchRequest.height = height.doubleValue;
        }
        if(![axis isEqual:[NSNull null]]){
            searchRequest.axis = axis.intValue;
        }
        if(![weight isEqual:[NSNull null]]){
            searchRequest.weight =  weight.doubleValue;
        }
        if(![load isEqual:[NSNull null]]){
            searchRequest.load =  load.doubleValue;
        }
        
        //发送请求
        [self.search AMapTruckRouteSearch:searchRequest];
    } else if ( ([@"geocoding" isEqualToString:call.method])) {
        NSString* address = args[@"address"];
        NSString* cityOrAdcode = args[@"cityOrAdcode"];
        //构造查询
        AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
        geo.address = address;
        geo.city = cityOrAdcode;
        //发送请求
        [self.search AMapGeocodeSearch:geo];
    }  else if ( ([@"reGeocoding" isEqualToString:call.method])) {
        NSString* pointJson = args[@"pointJson"];
        NSNumber* scope = args[@"scope"];
        //JSON转
        NSData *data = [pointJson dataUsingEncoding:NSUTF8StringEncoding];
        NSArray<NSNumber *>* point = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //构造查询
        AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
        regeo.location  = [AMapGeoPoint locationWithLatitude:point[0].doubleValue longitude:point[1].doubleValue];
        if(![scope isEqual:[NSNull null]]){
            regeo.radius = scope.intValue;
        }
        //发送请求
        [self.search AMapReGoecodeSearch:regeo];
    } 
}

/* POI和POI详情 .搜索回调 */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    //ios对象和android对象不同，这里重新构造，对比android将需要的数据返回
    
    //第一个：如果关键词明显输入有误，提供建议搜索词
    NSArray<NSString *> *searchSuggestionKeywords = [[response suggestion] keywords];
    //第一个：如果关键词明显输入有误，提供建议搜索城市
    NSArray<AMapCity *> *searchCtArr = [[response suggestion] cities];
    NSMutableArray<NSDictionary *> *searchSuggestionCitys = [NSMutableArray arrayWithCapacity:searchCtArr.count];
    for(AMapCity* city in searchCtArr){
        [searchSuggestionCitys addObject:[XbrGaodeSearchPlugin getObjectData:city]];
    }
    //第三个：pois 列表 只挑几个常用的
    NSArray<AMapPOI *>* poiArr = [response pois];
    NSMutableArray<NSDictionary *> *pois = [NSMutableArray arrayWithCapacity:poiArr.count];
    for(AMapPOI* poi in poiArr){
        [pois addObject:[XbrGaodeSearchPlugin getObjectData:poi]];
    }
    //重新构造完成 数据为配合android已调整
    NSDictionary* map = @{
        @"code":@1000,
        @"data":@{
            @"count": [NSNumber numberWithInt:(int)response.count],
            @"pois":pois
        }
    };
    //转 json 字符串
    NSData* jsonData =[NSJSONSerialization dataWithJSONObject:map options:NSJSONWritingPrettyPrinted error:nil];
    NSString* jsonStr =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (self.result != nil) {
        self.result(jsonStr);
    }
}

/* 搜索公共错误回调 */
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    NSDictionary* map = @{
        @"code":[NSNumber numberWithInt:(int)error.code],
        @"msg":error.domain
    };
    //转 json 字符串
    NSData* jsonData =[NSJSONSerialization dataWithJSONObject:map options:NSJSONWritingPrettyPrinted error:nil];
    NSString* jsonStr =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    self.result(jsonStr);
}

/* 输入提示回调. */
- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response{
    //直接取list
    NSArray<AMapTip *> *tipArr = [response tips] ;
    NSMutableArray<NSDictionary *> *tipList = [NSMutableArray arrayWithCapacity:tipArr.count];
    for(AMapTip* tip in tipArr){
        [tipList addObject:[XbrGaodeSearchPlugin getObjectData:tip]];
    }
    //重新构造完成 数据为配合android已调整
    NSDictionary* map = @{
        @"code":@1000,
        @"data":tipList
    };
    //转 json 字符串
    NSData* jsonData =[NSJSONSerialization dataWithJSONObject:map options:NSJSONWritingPrettyPrinted error:nil];
    NSString* jsonStr =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    self.result(jsonStr);
}

/* 路径规划(含货车)搜索回调. AMapDrivingV2RouteSearch*/
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response{
    AMapRoute *route = [response route];
    //只返回驾车路径信息
    NSArray<AMapPath *>* pathArr = [route paths];
    NSMutableArray<NSDictionary *> *paths = [NSMutableArray arrayWithCapacity:pathArr.count];
    //选出三种常用的业务简化数据，增加Flutter访问速度
    if ([self.showFields isEqual:[NSNull null]] && self.simplify && self.showFields.intValue == 16) {
        //第一种，只返回线路点
        for(AMapPath* path in pathArr){
            NSDictionary* pathMap = @{
                @"polyline": path.polyline,
            };
            [paths addObject: pathMap];
        }
    }else if([self.showFields isEqual:[NSNull null]] && self.simplify && self.showFields.intValue == 1){
        //第二种，只返回费用信息
        for(AMapPath* path in pathArr){
            NSDictionary* pathMap = @{
                @"distance": [NSNumber numberWithDouble:path.distance],
                @"duration": [NSNumber numberWithDouble:path.duration],
                @"tolls": [NSNumber numberWithDouble:path.tolls],
                @"tollDistance": [NSNumber numberWithDouble:path.tollDistance],
                @"totalTrafficLights": [NSNumber numberWithDouble:path.totalTrafficLights]
            };
            [paths addObject: pathMap];
        }
    }else if([self.showFields isEqual:[NSNull null]] && self.simplify && self.showFields.intValue == 17){
        //第三种，返回线路+费用信息
        for(AMapPath* path in pathArr){
            NSDictionary* pathMap = @{
                @"polyline": path.polyline,
                @"distance": [NSNumber numberWithDouble:path.distance],
                @"duration": [NSNumber numberWithDouble:path.duration],
                @"tolls": [NSNumber numberWithDouble:path.tolls],
                @"tollDistance": [NSNumber numberWithDouble:path.tollDistance],
                @"totalTrafficLights": [NSNumber numberWithDouble:path.totalTrafficLights]
            };
            [paths addObject: pathMap];
        }
    }else{
        for(AMapPath* path in pathArr){
            [paths addObject:[XbrGaodeSearchPlugin getObjectData:path]];
        }
    }
    if(self.onlyOne && paths.count > 0){
        paths = @[paths[0]].mutableCopy;
    }
    //重新构造完成 数据为配合android已调整
    NSDictionary* map = @{
        @"code":@1000,
        @"data":@{
            @"paths":paths
        }
    };
    //转 json 字符串
    NSData* jsonData =[NSJSONSerialization dataWithJSONObject:map options:NSJSONWritingPrettyPrinted error:nil];
    NSString* jsonStr =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    self.result(jsonStr);
}

/* 地理编码*/
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response{
    NSArray<AMapGeocode *> *geocodes = [response geocodes];
    NSMutableArray<NSDictionary *> *geocodeAddressList = [NSMutableArray arrayWithCapacity:geocodes.count];
    for(AMapGeocode* gc in geocodes){
        [geocodeAddressList addObject:[XbrGaodeSearchPlugin getObjectData:gc]];
    }
    //重新构造完成 数据为配合android已调整
    NSDictionary* map = @{
        @"code":@1000,
        @"data":@{
            @"geocodeAddressList":geocodeAddressList
        }
    };
    //转 json 字符串
    NSData* jsonData =[NSJSONSerialization dataWithJSONObject:map options:NSJSONWritingPrettyPrinted error:nil];
    NSString* jsonStr =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    self.result(jsonStr);
}

/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    AMapReGeocode *regeocode = [response regeocode];
    NSDictionary* regeocodeAddress = [XbrGaodeSearchPlugin getObjectData:regeocode];
    //重新构造完成 数据为配合android已调整
    NSDictionary* map = @{
        @"code":@1000,
        @"data":@{
            @"regeocodeAddress":regeocodeAddress
        }
    };
    //转 json 字符串
    NSData* jsonData =[NSJSONSerialization dataWithJSONObject:map options:NSJSONWritingPrettyPrinted error:nil];
    NSString* jsonStr =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    self.result(jsonStr);
}

//转NSMutableDictionary
+ (NSDictionary*)getObjectData:(id)obj{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([obj class], &propsCount);//获得属性列表
    for(int i = 0;i < propsCount; i++){
        objc_property_t prop = props[i];
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];//获得属性的名称
        id value = [obj valueForKey:propName];//kvc读值
        if(value == nil){
            value = [NSNull null];
        }else{
            value = [self getObjectInternal:value];//自定义处理数组，字典，其他类
        }
        [dic setObject:value forKey:propName];
    }
    return dic;
}
 
+ (id)getObjectInternal:(id)obj{
    if([obj isKindOfClass:[NSString class]]
       || [obj isKindOfClass:[NSNumber class]]
       || [obj isKindOfClass:[NSNull class]])
    {
        return obj;
    }
    
    if([obj isKindOfClass:[NSArray class]])
    {
        NSArray *objarr = obj;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        for(int i = 0;i < objarr.count; i++)
        {
            [arr setObject:[self getObjectInternal:[objarr objectAtIndex:i]] atIndexedSubscript:i];
        }
        return arr;
    }
    
    if([obj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *objdic = obj;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        for(NSString *key in objdic.allKeys)
        {
            [dic setObject:[self getObjectInternal:[objdic objectForKey:key]] forKey:key];
        }
        return dic;
    }
    return [self getObjectData:obj];
}


@end
