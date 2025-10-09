
import '../../amap/base/amap_flutter_base.dart';

class InputTipResult {
  String? district;
  String? address;
  String? typecode;
  String? uid;
  LatLng? location;
  String? adcode;
  String? name;

  InputTipResult(
      {this.district,
        this.address,
        this.typecode,
        this.uid,
        this.location,
        this.adcode,
        this.name});

  InputTipResult.fromJson(Map<String, dynamic> json) {
    district = json['district'];
    address = json['address'];
    typecode = json['typecode'];
    uid = json['uid'];
    location = json['location'] != null
        ?  LatLng.fromJsonMap(json['location'])
        : null;
    adcode = json['adcode'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['district'] = district;
    data['address'] = address;
    data['typecode'] = typecode;
    data['uid'] = uid;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['adcode'] =adcode;
    data['name'] = name;
    return data;
  }
}
