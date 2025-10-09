package com.yilin.xbr.xbr_gaode_amap._code;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.util.Map;

public class GsonUtil {
    public static String toJson(Object o){
        if (o==null) return null;
        try {
            return new Gson().toJson(o);
        }catch (Exception e){
            return null;
        }
    }

    public static <T> T fromJson(String json, TypeToken<T> typeToken){
        if (json==null) return null;
        try {
            return new Gson().fromJson(json,typeToken.getType());
        }catch (Exception e){
            return null;
        }
    }

}
