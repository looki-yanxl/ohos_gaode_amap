package com.yilin.xbr.xbr_gaode_amap.search.core;

import com.amap.api.services.core.LatLonPoint;
import com.amap.api.services.route.RouteSearch;

import java.util.List;

//忽略掉 避让区域/避让道路 起始点途径终点合并到一个list
public class DriveRouteQuery {
    private final List<LatLonPoint> wayPoints;
    private final RouteSearch.FromAndTo myFromAndTo;
    private final int mode;

    public DriveRouteQuery(List<LatLonPoint> allPoints, int mode) {
        this.myFromAndTo = new RouteSearch.FromAndTo(allPoints.get(0), allPoints.get(allPoints.size() - 1));
        this.wayPoints = allPoints.subList(1, allPoints.size() - 1);
        this.mode = mode;
    }

    public RouteSearch.DriveRouteQuery build() {
        return new RouteSearch.DriveRouteQuery(myFromAndTo,mode,wayPoints,null,null);
    }

    public RouteSearch.TruckRouteQuery build(TruckInfo truckInfo) {
        //设置车牌
        myFromAndTo.setPlateProvince("京");
        myFromAndTo.setPlateNumber("A000XXX");
        RouteSearch.TruckRouteQuery query = new RouteSearch.TruckRouteQuery(myFromAndTo,mode,null, RouteSearch.TRUCK_SIZE_LIGHT);
        //设置车辆信息
        query.setTruckAxis(truckInfo.getTruckAxis());//轴
        query.setTruckHeight(truckInfo.getTruckHeight());//高
        query.setTruckWidth(truckInfo.getTruckWidth());//宽
        query.setTruckLoad(truckInfo.getTruckLoad());//核载
        query.setTruckWeight(truckInfo.getTruckWeight());//总质量
        return query;
    }
}
