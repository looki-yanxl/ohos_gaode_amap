package com.yilin.xbr.xbr_gaode_amap.search.core;

import com.amap.api.services.core.PoiItemV2;
import com.amap.api.services.poisearch.PoiResultV2;
import com.amap.api.services.poisearch.PoiSearchV2;

//忽略掉IDS搜索
public abstract class PoiQueryListener implements PoiSearchV2.OnPoiSearchListener {

    @Override
    public void onPoiSearched(PoiResultV2 poiResultV2, int i) {

    }

    @Override
    public void onPoiItemSearched(PoiItemV2 poiItemV2, int i) {

    }
}
