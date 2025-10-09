

class TruckInfo{

  String?  plateProvince;
  String?  plateNumber;
  double? truckAxis;
  double? truckHeight;
  double? truckWidth;
  double? truckLoad;
  double? truckWeight;

  TruckInfo({this.plateProvince, this.plateNumber, this.truckAxis, this.truckHeight, this.truckWidth, this.truckLoad, this.truckWeight});

  factory TruckInfo.fromJson(Map<String, dynamic> json) {
    return TruckInfo(
      plateProvince: json['plateProvince'] as String?,
      plateNumber: json['plateNumber'] as String?,
      truckAxis: json['truckAxis'] as double?,
      truckHeight: json['truckHeight'] as double?,
      truckWidth: json['truckWidth'] as double?,
      truckLoad: json['truckLoad'] as double?,
      truckWeight: json['truckWeight'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'plateProvince': plateProvince,
      'plateNumber': plateNumber,
      'truckAxis': truckAxis,
      'truckHeight': truckHeight,
      'truckWidth': truckWidth,
      'truckLoad': truckLoad,
      'truckWeight': truckWeight,
    };
  }


}