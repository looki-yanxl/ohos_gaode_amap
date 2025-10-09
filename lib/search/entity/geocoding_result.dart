
import '../../amap/base/amap_flutter_base.dart';

class GeocodingResult {
  List<GeocodeAddress>? geocodeAddressList;

  GeocodingResult({this.geocodeAddressList});

  GeocodingResult.fromJson(Map<String, dynamic> json) {
    if (json['geocodeAddressList'] != null) {
      geocodeAddressList = <GeocodeAddress>[];
      json['geocodeAddressList'].forEach((v) {
        geocodeAddressList!.add(GeocodeAddress.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (geocodeAddressList != null) {
      data['geocodeAddressList'] =
          geocodeAddressList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GeocodeAddress {
  String? neighborhood;
  String? postcode;
  String? building;
  String? province;
  String? level;
  String? formattedAddress;
  LatLng? location;
  String? city;
  String? citycode;
  String? district;
  String? adcode;
  String? township;
  String? country;

  GeocodeAddress(
      {this.neighborhood,
        this.postcode,
        this.building,
        this.province,
        this.level,
        this.formattedAddress,
        this.location,
        this.city,
        this.citycode,
        this.district,
        this.adcode,
        this.township,
        this.country});

  GeocodeAddress.fromJson(Map<String, dynamic> json) {
    neighborhood = json['neighborhood'];
    postcode = json['postcode'];
    building = json['building'];
    province = json['province'];
    level = json['level'];
    formattedAddress = json['formattedAddress'];
    location = json['location'] != null
        ? LatLng.fromJson(json['location'])
        : null;
    city = json['city'];
    citycode = json['citycode'];
    district = json['district'];
    adcode = json['adcode'];
    township = json['township'];
    country = json['country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['neighborhood'] = neighborhood;
    data['postcode'] = postcode;
    data['building'] = building;
    data['province'] = province;
    data['level'] = level;
    data['formattedAddress'] = formattedAddress;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['city'] = city;
    data['citycode'] = citycode;
    data['district'] = district;
    data['adcode'] = adcode;
    data['township'] = township;
    data['country'] = country;
    return data;
  }
}
