import 'package:xbr_gaode_amap/amap/base/amap_flutter_base.dart';

class PoiResult {
  List<Pois>? pois;
  num? count;

  PoiResult(
      {this.count, this.pois});

  PoiResult.fromJson(Map<String, dynamic> json) {
    if (json['pois'] != null) {
      pois = <Pois>[];
      json['pois'].forEach((v) {
        pois!.add(Pois.fromJson(v));
      });
    }
    count = json['count']??0;
  }

}

class Pois {
  LatLng? enterLocation;
  LatLng? location;
  String? district;
  String? province;
  String? typecode;
  String? tel;
  bool? hasIndoorMap;
  String? businessArea;
  List<Images>? images;
  String? parkingType;
  String? city;
  dynamic exitLocation;
  String? adcode;
  String? name;
  String? type;
  List<SubPOIs>? subPOIs;
  String? shopID;
  String? gridcode;
  String? uid;
  String? website;
  String? pcode;
  num? distance;
  String? email;
  ExtensionInfo? extensionInfo;
  String? direction;
  String? citycode;
  String? postcode;
  String? address;
  dynamic indoorData;

  Pois(
      {this.enterLocation,
        this.location,
        this.district,
        this.province,
        this.typecode,
        this.tel,
        this.hasIndoorMap,
        this.businessArea,
        this.images,
        this.parkingType,
        this.city,
        this.exitLocation,
        this.adcode,
        this.name,
        this.type,
        this.subPOIs,
        this.shopID,
        this.gridcode,
        this.uid,
        this.website,
        this.pcode,
        this.distance,
        this.email,
        this.extensionInfo,
        this.direction,
        this.citycode,
        this.postcode,
        this.address,
        this.indoorData});

  Pois.fromJson(Map<String, dynamic> json) {
    enterLocation = json['enterLocation'] != null
        ? LatLng.fromJsonMap(json['enterLocation'])
        : null;
    location = json['location'] != null
        ? LatLng.fromJsonMap(json['location'])
        : null;
    district = json['district'];
    province = json['province'];
    typecode = json['typecode'];
    tel = json['tel'];
    hasIndoorMap = json['hasIndoorMap'];
    businessArea = json['businessArea'];
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(Images.fromJson(v));
      });
    }
    parkingType = json['parkingType'];
    city = json['city'];
    exitLocation = json['exitLocation'];
    adcode = json['adcode'];
    name = json['name'];
    type = json['type'];
    if (json['subPOIs'] != null) {
      subPOIs = <SubPOIs>[];
      json['subPOIs'].forEach((v) {
        subPOIs!.add(SubPOIs.fromJson(v));
      });
    }
    shopID = json['shopID'];
    gridcode = json['gridcode'];
    uid = json['uid'];
    website = json['website'];
    pcode = json['pcode'];
    distance = json['distance'];
    email = json['email'];
    extensionInfo = json['extensionInfo'] != null
        ? ExtensionInfo.fromJson(json['extensionInfo'])
        : null;
    direction = json['direction'];
    citycode = json['citycode'];
    postcode = json['postcode'];
    address = json['address'];
    indoorData = json['indoorData'];
  }
}


class Images {
  String? title;
  String? url;

  Images({this.title, this.url});

  Images.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    url = json['url'];
  }

}

class SubPOIs {
  String? address;
  String? uid;
  num? distance;
  LatLng? location;
  String? sname;
  String? subtype;
  String? name;

  SubPOIs(
      {this.address,
        this.uid,
        this.distance,
        this.location,
        this.sname,
        this.subtype,
        this.name});

  SubPOIs.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    uid = json['uid'];
    distance = json['distance'];
    location = json['location'] != null
        ? LatLng.fromJsonMap(json['location'])
        : null;
    sname = json['sname'];
    subtype = json['subtype'];
    name = json['name'];
  }

}

class ExtensionInfo {
  num? cost;
  dynamic openTime;
  num? rating;

  ExtensionInfo({this.cost, this.openTime, this.rating});

  ExtensionInfo.fromJson(Map<String, dynamic> json) {
    cost = json['cost'];
    openTime = json['openTime'];
    rating = json['rating'];
  }

}

class SearchSuggestionCity {
  String? city;
  String? citycode;
  String? adcode;

  SearchSuggestionCity({this.city, this.citycode, this.adcode});

  SearchSuggestionCity.fromJson(Map<String, dynamic> json) {
    city = json['city'];
    citycode = json['citycode'];
    adcode = json['adcode'];
  }

}