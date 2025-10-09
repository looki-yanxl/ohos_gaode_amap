package com.yilin.xbr.xbr_gaode_amap.search.utils;

import com.amap.api.services.core.LatLonPoint;

import java.util.List;

public class LatLngUtil {

    public static String objListJoin(List<LatLonPoint> list) {
        if (list == null) return null;
        StringBuilder arraysStr = new StringBuilder();
        for (int i = 0; i < list.size(); i++) {
            LatLonPoint lonPoint = list.get(i);
            String point = lonPoint.getLongitude() + "," + lonPoint.getLatitude();
            arraysStr.append(point);
            if (i < list.size() - 1) arraysStr.append(";");
        }
        return arraysStr.toString();
    }

}
