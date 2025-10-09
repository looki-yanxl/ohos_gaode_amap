package com.yilin.xbr.xbr_gaode_amap.search.core;

import com.amap.api.services.core.PoiItem;
import com.amap.api.services.core.PoiItemV2;
import com.amap.api.services.poisearch.PoiResult;
import com.amap.api.services.poisearch.PoiResultV2;
import com.amap.api.services.poisearch.PoiSearch;
import com.amap.api.services.poisearch.PoiSearchV2;

//忽略掉List搜索
public abstract class PoiIdQueryListener implements PoiSearchV2.OnPoiSearchListener {
    @Override
    public void onPoiSearched(PoiResultV2 poiResult, int i) {

    }

    @Override
    abstract public void onPoiItemSearched(PoiItemV2 poiItem, int i);
}
