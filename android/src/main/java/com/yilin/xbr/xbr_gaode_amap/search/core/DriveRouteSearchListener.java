package com.yilin.xbr.xbr_gaode_amap.search.core;

import com.amap.api.services.route.BusRouteResult;
import com.amap.api.services.route.BusRouteResultV2;
import com.amap.api.services.route.DriveRouteResult;
import com.amap.api.services.route.DriveRouteResultV2;
import com.amap.api.services.route.RideRouteResult;
import com.amap.api.services.route.RideRouteResultV2;
import com.amap.api.services.route.RouteSearch;
import com.amap.api.services.route.RouteSearchV2;
import com.amap.api.services.route.WalkRouteResult;
import com.amap.api.services.route.WalkRouteResultV2;

//忽略掉公交/步行/骑行
public abstract class DriveRouteSearchListener implements RouteSearchV2.OnRouteSearchListener {

    @Override
    public void onBusRouteSearched(BusRouteResultV2 busRouteResult, int i) {

    }

    @Override
    abstract public void onDriveRouteSearched(DriveRouteResultV2 driveRouteResult, int i);

    @Override
    public void onWalkRouteSearched(WalkRouteResultV2 walkRouteResult, int i) {

    }

    @Override
    public void onRideRouteSearched(RideRouteResultV2 rideRouteResult, int i) {

    }
}
