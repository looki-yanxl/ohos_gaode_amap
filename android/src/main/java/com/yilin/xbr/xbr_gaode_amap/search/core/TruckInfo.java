package com.yilin.xbr.xbr_gaode_amap.search.core;

import java.io.Serializable;

public class TruckInfo implements Serializable {

    private String plateProvince;
    private String plateNumber;
    private Float truckAxis;
    private Float truckHeight;
    private Float truckWidth;
    private Float truckLoad;
    private Float truckWeight;

    public TruckInfo(String plateProvince, String plateNumber, float truckAxis, float truckHeight, float truckWidth, float truckLoad, float truckWeight) {
        this.plateProvince = plateProvince;
        this.plateNumber = plateNumber;
        this.truckAxis = truckAxis;
        this.truckHeight = truckHeight;
        this.truckWidth = truckWidth;
        this.truckLoad = truckLoad;
        this.truckWeight = truckWeight;
    }

    public String getPlateProvince() {
        return plateProvince;
    }

    public void setPlateProvince(String plateProvince) {
        this.plateProvince = plateProvince;
    }

    public String getPlateNumber() {
        return plateNumber;
    }

    public void setPlateNumber(String plateNumber) {
        this.plateNumber = plateNumber;
    }

    public Float getTruckAxis() {
        return truckAxis;
    }

    public void setTruckAxis(Float truckAxis) {
        this.truckAxis = truckAxis;
    }

    public Float getTruckHeight() {
        return truckHeight;
    }

    public void setTruckHeight(Float truckHeight) {
        this.truckHeight = truckHeight;
    }

    public Float getTruckWidth() {
        return truckWidth;
    }

    public void setTruckWidth(Float truckWidth) {
        this.truckWidth = truckWidth;
    }

    public Float getTruckLoad() {
        return truckLoad;
    }

    public void setTruckLoad(Float truckLoad) {
        this.truckLoad = truckLoad;
    }

    public Float getTruckWeight() {
        return truckWeight;
    }

    public void setTruckWeight(Float truckWeight) {
        this.truckWeight = truckWeight;
    }
}
