package com.yilin.xbr.xbr_gaode_amap.search.core;

import com.amap.api.services.geocoder.GeocodeResult;
import com.amap.api.services.geocoder.GeocodeSearch;
import com.amap.api.services.geocoder.RegeocodeResult;

public abstract class OnReGeocodeSearchListener implements  GeocodeSearch.OnGeocodeSearchListener{
    @Override
    public abstract void onRegeocodeSearched(RegeocodeResult regeocodeResult, int i);

    @Override
    public  void onGeocodeSearched(GeocodeResult geocodeResult, int i)  {

    }
}
