class LocationInfo {
  String? callbackTime;
  String? locationTime;
  int? locationType;
  double? latitude;
  double? longitude;
  double? accuracy;
  double? altitude;
  double? bearing;
  double? speed;
  String? country;
  String? province;
  String? city;
  String? district;
  String? street;
  String? streetNumber;
  String? cityCode;
  String? adCode;
  String? address;
  String? description;

  int? errorCode;
  String? errorInfo;

  LocationInfo(
      {this.callbackTime,
        this.locationTime,
        this.locationType,
        this.latitude,
        this.longitude,
        this.accuracy,
        this.altitude,
        this.bearing,
        this.speed,
        this.country,
        this.province,
        this.city,
        this.district,
        this.street,
        this.streetNumber,
        this.cityCode,
        this.adCode,
        this.address,
        this.description});

  LocationInfo.fromJson(Map<String, dynamic> json) {
    callbackTime = json['callbackTime'];
    locationTime = json['locationTime']??json['locTime'];
    locationType = (json['locationType'] as num?)?.toInt();
    latitude = parseDouble(json['latitude']);
    longitude = parseDouble(json['longitude']);
    accuracy =  (json['accuracy'] as num?)?.toDouble();
    altitude = (json['altitude'] as num?)?.toDouble();
    bearing = (json['bearing'] as num?)?.toDouble();
    speed = (json['speed'] as num?)?.toDouble();
    country = json['country'] as String?;
    province = json['province'] as String?;
    city = json['city'] as String?;
    district = json['district'] as String?;
    street = json['street'] as String?;
    streetNumber = json['streetNumber'] as String?;
    cityCode = json['cityCode'] as String?;
    adCode = json['adCode'] as String?;
    address = json['address'] as String?;
    description = json['description'] as String?;
    errorCode = (json['errorCode'] as num?)?.toInt();
    errorInfo = json['errorInfo'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['callbackTime'] = callbackTime;
    data['locationTime'] = locationTime;
    data['locationType'] = locationType;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['accuracy'] = accuracy;
    data['altitude'] = altitude;
    data['bearing'] = bearing;
    data['speed'] = speed;
    data['country'] = country;
    data['province'] = province;
    data['city'] = city;
    data['district'] = district;
    data['street'] = street;
    data['streetNumber'] = streetNumber;
    data['cityCode'] = cityCode;
    data['adCode'] = adCode;
    data['address'] = address;
    data['description'] = description;
    data['errorCode'] = errorCode;
    data['errorInfo'] = errorInfo;
    return data;
  }

  static double? parseDouble(dynamic value){
    if(value==null) return null;
    if(value is int) return value.toDouble();
    if(value is double) return value;
    try{
      if(value is String) return double.parse(value);
    }catch(e){
      return null;
    }
    return null;
  }
}
