package com.yilin.xbr.xbr_gaode_amap.search.utils;

import java.util.HashMap;
import java.util.Map;

public class MapUtil {

    public interface Put{
        void put(Map<String, Object> map);
    }

    /**
     * 生成MAP参数
     * */
    public static Map<String,Object> generate(Put put){
        HashMap<String, Object> hashMap = new HashMap<>();
        put.put(hashMap);
        return hashMap;
    }




}


