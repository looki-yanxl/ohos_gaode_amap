package com.yilin.xbr.xbr_gaode_amap.search;

import android.content.Context;
import com.amap.api.services.core.AMapException;
import com.amap.api.services.core.LatLonPoint;
import com.amap.api.services.core.PoiItemV2;
import com.amap.api.services.help.Inputtips;
import com.amap.api.services.help.InputtipsQuery;
import com.amap.api.services.help.Tip;
import com.amap.api.services.poisearch.PoiResultV2;
import com.amap.api.services.poisearch.PoiSearchV2;
import com.amap.api.services.route.District;
import com.amap.api.services.route.DrivePathV2;
import com.amap.api.services.route.DriveRouteResultV2;
import com.amap.api.services.route.DriveStepV2;
import com.amap.api.services.route.RouteSearch;
import com.amap.api.services.route.RouteSearchCity;
import com.amap.api.services.route.RouteSearchV2;
import com.amap.api.services.route.TMC;
import com.amap.api.services.route.TruckPath;
import com.amap.api.services.route.TruckRouteRestult;
import com.amap.api.services.route.TruckStep;
import com.yilin.xbr.xbr_gaode_amap.amap.utils.LogUtil;
import com.yilin.xbr.xbr_gaode_amap.search.core.DriveRouteQuery;
import com.yilin.xbr.xbr_gaode_amap.search.core.DriveRouteSearchListener;
import com.yilin.xbr.xbr_gaode_amap.search.core.PoiIdQueryListener;
import com.yilin.xbr.xbr_gaode_amap.search.core.PoiQueryListener;
import com.yilin.xbr.xbr_gaode_amap.search.core.TruckInfo;
import com.yilin.xbr.xbr_gaode_amap.search.utils.LatLngUtil;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AmapSearchClient {

    private final Context context;

    public AmapSearchClient(Context context) {
        this.context = context;
    }

    /**
     * 关键之搜索
     */
    public void keywordsSearch(String keyWord, String cityCode, int page, int limit, final SearchBack searchBack) {
        try {
            PoiSearchV2.Query query = new PoiSearchV2.Query(keyWord, "", cityCode);
            query.setPageSize(limit);// 设置每页最多返回多少条poiitem
            query.setPageNum(page);//设置查询页码
            query.setCityLimit(cityCode!=null);
            PoiSearchV2 poiSearch = new PoiSearchV2(context, query);
            poiSearch.setOnPoiSearchListener(new PoiQueryListener() {
                @Override
                public void onPoiSearched(PoiResultV2 poiResult, int i) {
                    Map<String,Object> map = new HashMap<>();
                    List<Map<String,Object>> pois = new ArrayList<>();
                    //本人较ios熟悉android，这里按照ios字段返回，保证json解析一致
                    for (PoiItemV2 poiItem:poiResult.getPois()){
                        Map<String,Object> poiItemMap = new HashMap<>();
                        Map<String,Object> locationMap = new HashMap<>();
                        if (poiItem.getLatLonPoint()!=null){
                            locationMap.put("latitude",poiItem.getLatLonPoint().getLatitude());
                            locationMap.put("longitude",poiItem.getLatLonPoint().getLongitude());
                            poiItemMap.put("location",locationMap);
                        }
                        poiItemMap.put("uid",poiItem.getPoiId());
                        poiItemMap.put("name",poiItem.getTitle());//"北京大学"
                        poiItemMap.put("address",poiItem.getSnippet());//颐和园路5号
                        poiItemMap.put("province",poiItem.getProvinceName());
                        poiItemMap.put("pcode",poiItem.getProvinceCode());
                        poiItemMap.put("city",poiItem.getCityName());
                        poiItemMap.put("citycode",poiItem.getCityCode());
                        poiItemMap.put("district",poiItem.getAdName());
                        poiItemMap.put("adcode",poiItem.getAdCode());
                        poiItemMap.put("type",poiItem.getTypeDes());//"科教文化服务;学校;高等院校"
                        poiItemMap.put("typeCode",poiItem.getTypeCode());
                        poiItemMap.put("tel",poiItem.getBusiness().getTel());
                        pois.add(poiItemMap);
                    }
                    map.put("count",poiResult.getCount());
                    map.put("pois",pois);
                    searchBack.back(i,map);
                }
            });
            poiSearch.searchPOIAsyn();
        } catch (AMapException e) {
            LogUtil.e("AmapSearchClient","keywordsSearch",e);
        }
    }

    /**
     * 周边搜索
     */
    public void boundSearch(LatLonPoint latLonPoint,String keyWord,Integer scope, int page, int limit, final SearchBack searchBack) {
        try {
            PoiSearchV2.Query query = new PoiSearchV2.Query(keyWord, "");
            query.setPageSize(limit);// 设置每页最多返回多少条poiitem
            query.setPageNum(page);//设置查询页码
            PoiSearchV2 poiSearch = new PoiSearchV2(context, query);
            poiSearch.setBound(new PoiSearchV2.SearchBound(latLonPoint, scope));//设置周边搜索的中心点以及半径
            poiSearch.setOnPoiSearchListener(new PoiQueryListener() {
                @Override
                public void onPoiSearched(PoiResultV2 poiResult, int i) {
                    Map<String,Object> map = new HashMap<>();
                    List<Map<String,Object>> pois = new ArrayList<>();
                    //本人较ios熟悉android，这里按照ios字段返回，保证json解析一致
                    for (PoiItemV2 poiItem:poiResult.getPois()){
                        Map<String,Object> poiItemMap = new HashMap<>();
                        Map<String,Object> locationMap = new HashMap<>();
                        if (poiItem.getLatLonPoint()!=null){
                            locationMap.put("latitude",poiItem.getLatLonPoint().getLatitude());
                            locationMap.put("longitude",poiItem.getLatLonPoint().getLongitude());
                            poiItemMap.put("location",locationMap);
                        }
                        poiItemMap.put("uid",poiItem.getPoiId());
                        poiItemMap.put("name",poiItem.getTitle());//"北京大学"
                        poiItemMap.put("address",poiItem.getSnippet());//颐和园路5号
                        poiItemMap.put("province",poiItem.getProvinceName());
                        poiItemMap.put("pcode",poiItem.getProvinceCode());
                        poiItemMap.put("city",poiItem.getCityName());
                        poiItemMap.put("citycode",poiItem.getCityCode());
                        poiItemMap.put("district",poiItem.getAdName());
                        poiItemMap.put("adcode",poiItem.getAdCode());
                        poiItemMap.put("type",poiItem.getTypeDes());//"科教文化服务;学校;高等院校"
                        poiItemMap.put("typeCode",poiItem.getTypeCode());
                        poiItemMap.put("tel",poiItem.getBusiness().getTel());
                        pois.add(poiItemMap);
                    }
                    map.put("count",poiResult.getCount());
                    map.put("pois",pois);
                    searchBack.back(i,map);
                }
            });
            poiSearch.searchPOIAsyn();
        } catch (AMapException e) {
            LogUtil.e("AmapSearchClient","boundSearch",e);
        }
    }

    /**
     * 输入内容自动提示
     */
    public void inputTips(String newText, String city,boolean cityLimit, final SearchListBack searchBack) {
        try {
            if (newText==null|| newText.trim().isEmpty()) return;
            if (city == null || city.trim().isEmpty()){
                city = null;
                cityLimit = false;
            }
            InputtipsQuery query = new InputtipsQuery(newText, city);
            query.setCityLimit(cityLimit);//限制在当前城市
            Inputtips inputTips = new Inputtips(context, query);
            inputTips.setInputtipsListener((list, i) -> {
                if (list == null) return;
                List<Map<String, Object>> mapList = new ArrayList<>();
                for (Tip tip : list) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("adcode", tip.getAdcode());
                    map.put("typecode", tip.getTypeCode());
                    map.put("district", tip.getDistrict());
                    map.put("address", tip.getAddress());
                    map.put("uid", tip.getPoiID());

                    Map<String, Object> locationMap = new HashMap<>();
                    if (tip.getPoint() != null) {
                        locationMap.put("latitude", tip.getPoint().getLatitude());
                        locationMap.put("longitude", tip.getPoint().getLongitude());
                        map.put("location", locationMap);
                    }
                    map.put("name", tip.getName());
                    mapList.add(map);
                }
                searchBack.back(i, mapList);
            });
            inputTips.requestInputtipsAsyn();
        } catch (Exception e) {
            LogUtil.e("AmapSearchClient","inputTips",e);
        }
    }

    /**
     * ID检索POI
     */
    PoiSearchV2 poiSearch;

    public PoiSearchV2 getPoiSearch() throws AMapException {
        if (poiSearch == null) poiSearch = new PoiSearchV2(context, null);
        return poiSearch;
    }

    public void getPOIById(String id, final SearchBack searchBack) {
        try {
            getPoiSearch().setOnPoiSearchListener(new PoiIdQueryListener() {
                @Override
                public void onPoiItemSearched(PoiItemV2 poiItem, int i) {
                    Map<String,Object> map = new HashMap<>();
                    List<Map<String,Object>> pois = new ArrayList<>();
                    //IOS详情也是按列表返回的，这里也按列表返回，在dart中处理
                    Map<String,Object> poiItemMap = new HashMap<>();
                    Map<String,Object> locationMap = new HashMap<>();
                    if (poiItem.getLatLonPoint()!=null){
                        locationMap.put("latitude",poiItem.getLatLonPoint().getLatitude());
                        locationMap.put("longitude",poiItem.getLatLonPoint().getLongitude());
                        poiItemMap.put("location",locationMap);
                    }
                    poiItemMap.put("city",poiItem.getCityName());
                    poiItemMap.put("citycode",poiItem.getCityCode());
                    poiItemMap.put("district",poiItem.getAdName());
                    poiItemMap.put("provinceName",poiItem.getProvinceName());
                    poiItemMap.put("adcode",poiItem.getAdCode());
                    poiItemMap.put("address",poiItem.getSnippet());
                    poiItemMap.put("type",poiItem.getTypeDes());
                    poiItemMap.put("typeCode",poiItem.getTypeCode());
                    poiItemMap.put("uid",poiItem.getPoiId());
                    poiItemMap.put("tel",poiItem.getBusiness().getTel());
                    pois.add(poiItemMap);
                    map.put("count",1);
                    map.put("pois",pois);
                    searchBack.back(i,map);
                }
            });
            getPoiSearch().searchPOIIdAsyn(id);// 异步搜索
        } catch (Exception e) {
            LogUtil.e("AmapSearchClient","getPOIById",e);
        }
    }

    /**
     * 普通线路规划
     */
    RouteSearchV2 routeSearchV2;

    public RouteSearchV2 getRouteSearchV2() throws AMapException {
        if (routeSearchV2 == null) routeSearchV2 = new RouteSearchV2(context);
        return routeSearchV2;
    }

    public void routeSearch(List<LatLonPoint> wayPoints, Integer drivingStrategy, final Integer showFields, final boolean onlyOne, final boolean simplify, final SearchBack searchBack) {
        try {
            RouteSearchV2.DrivingStrategy strategy = RouteSearchV2.DrivingStrategy.fromValue(drivingStrategy);
            RouteSearchV2.FromAndTo fromAndTo = new RouteSearchV2.FromAndTo(wayPoints.get(0),wayPoints.get(wayPoints.size()-1));
            RouteSearchV2.DriveRouteQuery query = new RouteSearchV2.DriveRouteQuery(fromAndTo,strategy,wayPoints,null,null);
            if (showFields!=null) query.setShowFields(17);
            getRouteSearchV2().setRouteSearchListener(new DriveRouteSearchListener() {
                @Override
                public void onDriveRouteSearched(DriveRouteResultV2 driveRouteResult, int code) {
                    Map<String,Object> map = new HashMap<>();
                    List<DrivePathV2> drivePaths = driveRouteResult.getPaths();
                    List<Map<String,Object>> paths = new ArrayList<>();
                    //选出三种常用业务简化数据
                    if (showFields!=null && simplify && RouteSearchV2.ShowFields.POLINE == showFields ){
                        for (DrivePathV2 drivePath:drivePaths){
                            Map<String,Object> pathMap = new HashMap<>();
                            pathMap.put("polyline",LatLngUtil.objListJoin(drivePath.getPolyline()));
                            paths.add(pathMap);
                        }
                    } else if (showFields!=null && simplify &&  RouteSearchV2.ShowFields.COST == showFields){
                        for (DrivePathV2 drivePath:drivePaths){
                            Map<String,Object> pathMap = new HashMap<>();
                            pathMap.put("distance",drivePath.getDistance());
                            if (drivePath.getCost()!=null){
                                pathMap.put("tolls",drivePath.getCost().getTolls());
                                pathMap.put("duration",drivePath.getCost().getDuration());
                                pathMap.put("tollDistance",drivePath.getCost().getTollDistance());
                                pathMap.put("totalTrafficLights",drivePath.getCost().getTrafficLights());
                            }
                            paths.add(pathMap);
                        }
                    }  else if (showFields!=null && simplify && (RouteSearchV2.ShowFields.COST+RouteSearchV2.ShowFields.POLINE) == showFields){
                        for (DrivePathV2 drivePath:drivePaths){
                            Map<String,Object> pathMap = new HashMap<>();
                            pathMap.put("polyline",LatLngUtil.objListJoin(drivePath.getPolyline()));
                            pathMap.put("distance",drivePath.getDistance());
                            if (drivePath.getCost()!=null){
                                pathMap.put("tolls",drivePath.getCost().getTolls());
                                pathMap.put("duration",drivePath.getCost().getDuration());
                                pathMap.put("tollDistance",drivePath.getCost().getTollDistance());
                                pathMap.put("totalTrafficLights",drivePath.getCost().getTrafficLights());
                            }
                            paths.add(pathMap);
                        }
                    } else {
                        for (DrivePathV2 drivePath:drivePaths){
                            Map<String, Object> pathMap = new HashMap<>();
                            String polyline = LatLngUtil.objListJoin(drivePath.getPolyline());
                            pathMap.put("polyline",polyline);
                            pathMap.put("distance",drivePath.getDistance());
                            pathMap.put("restriction",drivePath.getRestriction());
                            pathMap.put("strategy",drivePath.getStrategy());
                            if (drivePath.getCost()!=null){
                                pathMap.put("tolls",drivePath.getCost().getTolls());
                                pathMap.put("duration",drivePath.getCost().getDuration());
                                pathMap.put("tollDistance",drivePath.getCost().getTollDistance());
                                pathMap.put("totalTrafficLights",drivePath.getCost().getTrafficLights());
                            }
                            List<Map<String,Object>> steps = new ArrayList<>();
                            for (DriveStepV2 step : drivePath.getSteps()){
                                Map<String, Object> stepMap = new HashMap<>();
                                stepMap.put("orientation",step.getOrientation());
                                stepMap.put("tollDistance",step.getCostDetail().getTollDistance());
                                stepMap.put("tollRoad",step.getCostDetail().getTollRoad());
                                stepMap.put("road",step.getRoad());
                                stepMap.put("instruction",step.getInstruction());
                                stepMap.put("distance",step.getStepDistance());
                                stepMap.put("polyline",LatLngUtil.objListJoin(step.getPolyline()));
                                if (step.getNavi()!=null){
                                    stepMap.put("assistantAction",step.getNavi().getAssistantAction());
                                    stepMap.put("action",step.getNavi().getAction());
                                }
                                if (step.getCostDetail()!=null){
                                    stepMap.put("duration",step.getCostDetail().getDuration());
                                    stepMap.put("tolls",step.getCostDetail().getTolls());
                                }
                                List<Map<String,Object>> citys = new ArrayList<>();
                                for (RouteSearchCity city:step.getRouteSearchCityList()){
                                    Map<String, Object> cityMap = new HashMap<>();
                                    cityMap.put("city",city.getSearchCityName());
                                    cityMap.put("adcode",city.getSearchCityAdCode());
                                    cityMap.put("citycode",city.getSearchCitycode());
                                    List<Map<String,Object>> districts = new ArrayList<>();
                                    for (District district:city.getDistricts()){
                                        Map<String, Object> districtMap = new HashMap<>();
                                        districtMap.put("adcode",district.getDistrictAdcode());
                                        districtMap.put("name",district.getDistrictName());
                                        districts.add(districtMap);
                                    }
                                    cityMap.put("district",districts);
                                    citys.add(cityMap);
                                }
                                stepMap.put("cities",citys);
                                List<Map<String,Object>> tmcs = new ArrayList<>();
                                for (TMC tmc:step.getTMCs()){
                                    Map<String, Object> tmcMap = new HashMap<>();
                                    tmcMap.put("polyline",LatLngUtil.objListJoin(tmc.getPolyline()));
                                    tmcMap.put("status",tmc.getStatus());
                                    tmcMap.put("distance",tmc.getDistance());
                                    tmcs.add(tmcMap);
                                }
                                stepMap.put("tmcs",tmcs);
                                steps.add(stepMap);
                            }
                            pathMap.put("steps",steps);
                            paths.add(pathMap);
                        }
                    }
                    if (onlyOne && !paths.isEmpty()) map.put("paths",initList(paths.get(0)));
                    else map.put("paths",paths);
                    searchBack.back(code,map);
                }
            });
            getRouteSearchV2().calculateDriveRouteAsyn(query);
        } catch (AMapException e) {
            LogUtil.e("AmapSearchClient","routeSearch",e);
        }
    }

    /**
     * 货车线路规划
     */
    RouteSearch routeSearch;

    public RouteSearch getRouteSearch() throws AMapException {
        if (routeSearch == null) routeSearch = new RouteSearch(context);
        return routeSearch;
    }

    public void truckRouteSearch(List<LatLonPoint> wayPoints, Integer truckMode, TruckInfo truckInfo, final Integer showFields, final boolean onlyOne, final boolean simplify, final SearchBack searchBack) {
        try {
            RouteSearch.TruckRouteQuery query = new DriveRouteQuery(wayPoints, truckMode).build(truckInfo);
            getRouteSearch().setOnTruckRouteSearchListener(new RouteSearch.OnTruckRouteSearchListener() {
                @Override
                public void onTruckRouteSearched(TruckRouteRestult truckRouteRestult, int code) {
                    Map<String, Object> map = new HashMap<>();
                    List<TruckPath> drivePaths = truckRouteRestult.getPaths();
                    List<Map<String, Object>> paths = new ArrayList<>();
                    //选出三种常用业务简化数据
                    if (showFields != null && simplify && RouteSearchV2.ShowFields.POLINE == showFields) {
                        for (TruckPath truckPath : drivePaths) {
                            Map<String, Object> pathMap = new HashMap<>();
                            StringBuilder polylineStr = new StringBuilder();
                            for (int i = 0; i < truckPath.getSteps().size(); i++) {
                                polylineStr.append(LatLngUtil.objListJoin(truckPath.getSteps().get(i).getPolyline()));
                                if (i < truckPath.getSteps().size() - 1) polylineStr.append(";");
                            }
                            pathMap.put("polyline", polylineStr.toString());
                            paths.add(pathMap);
                        }
                    } else if (showFields != null && simplify && RouteSearchV2.ShowFields.COST == showFields) {
                        for (TruckPath drivePath : drivePaths) {
                            Map<String, Object> pathMap = new HashMap<>();
                            pathMap.put("tolls", drivePath.getTolls());
                            pathMap.put("duration", drivePath.getDuration());
                            pathMap.put("tollDistance", drivePath.getTollDistance());
                            pathMap.put("totalTrafficLights", drivePath.getTotalTrafficlights());
                            paths.add(pathMap);
                        }
                    } else if (showFields != null && simplify && (RouteSearchV2.ShowFields.POLINE + RouteSearchV2.ShowFields.COST) == showFields) {
                        for (TruckPath truckPath : drivePaths) {
                            Map<String, Object> pathMap = new HashMap<>();
                            StringBuilder polylineStr = new StringBuilder();
                            for (int i = 0; i < truckPath.getSteps().size(); i++) {
                                polylineStr.append(LatLngUtil.objListJoin(truckPath.getSteps().get(i).getPolyline()));
                                if (i < truckPath.getSteps().size() - 1) polylineStr.append(";");
                            }
                            pathMap.put("polyline", polylineStr.toString());
                            pathMap.put("tolls", truckPath.getTolls());
                            pathMap.put("duration", truckPath.getDuration());
                            pathMap.put("tollDistance", truckPath.getTollDistance());
                            pathMap.put("totalTrafficLights", truckPath.getTotalTrafficlights());
                            paths.add(pathMap);
                        }
                    } else {
                        for (TruckPath truckPath : drivePaths) {
                            Map<String, Object> pathMap = new HashMap<>();
                            pathMap.put("distance", truckPath.getDistance());
                            pathMap.put("restriction", truckPath.getRestriction());
                            pathMap.put("tolls", truckPath.getTolls());
                            pathMap.put("totalTrafficLights", truckPath.getTotalTrafficlights());
                            pathMap.put("duration", truckPath.getDuration());
                            pathMap.put("strategy", truckPath.getStrategy());
                            pathMap.put("tollDistance", truckPath.getTollDistance());
                            List<Map<String, Object>> steps = new ArrayList<>();
                            for (int i = 0; i < truckPath.getSteps().size(); i++) {
                                TruckStep step = truckPath.getSteps().get(i);
                                Map<String, Object> stepMap = new HashMap<>();
                                stepMap.put("orientation", step.getOrientation());
                                stepMap.put("assistantAction", step.getAssistantAction());
                                stepMap.put("tollDistance", step.getTollDistance());
                                stepMap.put("tollRoad", step.getTollRoad());
                                stepMap.put("road", step.getRoad());
                                stepMap.put("action", step.getAction());
                                stepMap.put("instruction", step.getInstruction());
                                stepMap.put("duration", step.getDuration());
                                stepMap.put("distance", step.getDistance());
                                stepMap.put("tolls", step.getTolls());
                                stepMap.put("polyline", LatLngUtil.objListJoin(step.getPolyline()));
                                List<Map<String, Object>> citys = new ArrayList<>();
                                for (RouteSearchCity city : step.getRouteSearchCityList()) {
                                    Map<String, Object> cityMap = new HashMap<>();
                                    cityMap.put("city", city.getSearchCityName());
                                    cityMap.put("adcode", city.getSearchCityAdCode());
                                    cityMap.put("citycode", city.getSearchCitycode());
                                    List<Map<String, Object>> districts = new ArrayList<>();
                                    for (District district : city.getDistricts()) {
                                        Map<String, Object> districtMap = new HashMap<>();
                                        districtMap.put("adcode", district.getDistrictAdcode());
                                        districtMap.put("name", district.getDistrictName());
                                        districts.add(districtMap);
                                    }
                                    cityMap.put("district", districts);
                                    citys.add(cityMap);
                                }
                                stepMap.put("cities", citys);
                                List<Map<String, Object>> tmcs = new ArrayList<>();
                                for (TMC tmc : step.getTMCs()) {
                                    Map<String, Object> tmcMap = new HashMap<>();
                                    tmcMap.put("polyline", LatLngUtil.objListJoin(tmc.getPolyline()));
                                    tmcMap.put("status", tmc.getStatus());
                                    tmcMap.put("distance", tmc.getDistance());
                                    tmcs.add(tmcMap);
                                }
                                stepMap.put("tmcs", tmcs);
                                steps.add(stepMap);
                            }
                            pathMap.put("steps", steps);
                            paths.add(pathMap);
                        }
                    }
                    if (onlyOne && !paths.isEmpty()) map.put("paths", initList(paths.get(0)));
                    else map.put("paths", paths);
                    searchBack.back(code, map);
                }
            });
            getRouteSearch().calculateTruckRouteAsyn(query);
        } catch (AMapException e) {
            LogUtil.e("AmapSearchClient","truckRouteSearch",e);
        }
    }


    /**
     * 生成数据集合
     */
    @SafeVarargs
    public static <T> List<T> initList(T... objects) {
        List<T> asList = Arrays.asList(objects);
        return new ArrayList<>(asList);
    }
}
