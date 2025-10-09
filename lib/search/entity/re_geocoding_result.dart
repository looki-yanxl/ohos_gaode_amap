import '../../amap/base/amap_flutter_base.dart';

class ReGeocodingResult {
  RegeocodeAddress? regeocodeAddress;

  ReGeocodingResult({this.regeocodeAddress});

  ReGeocodingResult.fromJson(Map<String, dynamic> json) {
    regeocodeAddress = json['regeocodeAddress'] != null
        ? RegeocodeAddress.fromJson(json['regeocodeAddress'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (regeocodeAddress != null) {
      data['regeocodeAddress'] = regeocodeAddress!.toJson();
    }
    return data;
  }
}

class RegeocodeAddress {
  dynamic roadinters;
  dynamic roads;
  AddressComponent? addressComponent;
  String? formattedAddress;
  dynamic pois;
  dynamic aois;

  RegeocodeAddress(
      {this.roadinters,
        this.roads,
        this.addressComponent,
        this.formattedAddress,
        this.pois,
        this.aois});

  RegeocodeAddress.fromJson(Map<String, dynamic> json) {
    roadinters = json['roadinters'];
    roads = json['roads'];
    addressComponent = json['addressComponent'] != null
        ? AddressComponent.fromJson(json['addressComponent'])
        : null;
    formattedAddress = json['formattedAddress'];
    pois = json['pois'];
    aois = json['aois'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['roadinters'] = roadinters;
    data['roads'] = roads;
    if (addressComponent != null) {
      data['addressComponent'] = addressComponent!.toJson();
    }
    data['formattedAddress'] = formattedAddress;
    data['pois'] = pois;
    data['aois'] = aois;
    return data;
  }
}

class AddressComponent {
  String? neighborhood;
  String? building;
  String? province;
  String? countryCode;
  String? city;
  String? citycode;
  String? district;
  String? adcode;
  StreetNumber? streetNumber;
  String? country;
  String? township;
  String? towncode;

  AddressComponent(
      {this.neighborhood,
        this.building,
        this.province,
        this.countryCode,
        this.city,
        this.citycode,
        this.district,
        this.adcode,
        this.streetNumber,
        this.country,
        this.township,
        this.towncode});

  AddressComponent.fromJson(Map<String, dynamic> json) {
    neighborhood = json['neighborhood'];
    building = json['building'];
    province = json['province'];
    countryCode = json['countryCode'];
    city = json['city'];
    citycode = json['citycode'];
    district = json['district'];
    adcode = json['adcode'];
    streetNumber = json['streetNumber'] != null
        ? StreetNumber.fromJson(json['streetNumber'])
        : null;
    country = json['country'];
    township = json['township'];
    towncode = json['towncode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['neighborhood'] = neighborhood;
    data['building'] = building;
    data['province'] = province;
    data['countryCode'] = countryCode;
    data['city'] = city;
    data['citycode'] = citycode;
    data['district'] = district;
    data['adcode'] = adcode;
    if (streetNumber != null) {
      data['streetNumber'] = streetNumber!.toJson();
    }
    data['country'] = country;
    data['township'] = township;
    data['towncode'] = towncode;
    return data;
  }
}

class StreetNumber {
  String? direction;
  String? number;
  String? street;
  LatLng? location;
  num? distance;

  StreetNumber(
      {this.direction, this.number, this.street, this.location, this.distance});

  StreetNumber.fromJson(Map<String, dynamic> json) {
    direction = json['direction'];
    number = json['number'];
    street = json['street'];
    location = json['location'] != null
        ? LatLng.fromJson(json['location'])
        : null;
    distance = json['distance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['direction'] = direction;
    data['number'] = number;
    data['street'] = street;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['distance'] = distance;
    return data;
  }
}
