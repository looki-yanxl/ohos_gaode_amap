class RouteResult {
  List<Path>? paths;

  RouteResult({this.paths});

  RouteResult.fromJson(Map<String, dynamic> json) {
    if (json['paths'] != null) {
      paths = <Path>[];
      json['paths'].forEach((v) {
        paths!.add(Path.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (paths != null) {
      data['paths'] = paths!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Path {
  num? restriction;
  String? polyline;
  num? distance;
  List<Steps>? steps;
  num? totalTrafficLights;
  num? duration;
  String? strategy;
  num? tollDistance;
  num? tolls;

  Path(
      {this.restriction,
        this.polyline,
        this.distance,
        this.steps,
        this.totalTrafficLights,
        this.duration,
        this.strategy,
        this.tollDistance,
        this.tolls});

  Path.fromJson(Map<String, dynamic> json) {
    restriction = json['restriction'];
    polyline = json['polyline'];
    distance = json['distance'];
    if (json['steps'] != null) {
      steps = <Steps>[];
      json['steps'].forEach((v) {
        steps!.add(Steps.fromJson(v));
      });
    }
    totalTrafficLights = json['totalTrafficLights'];
    duration = json['duration'];
    strategy = json['strategy'];
    tollDistance = json['tollDistance'];
    tolls = json['tolls'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['restriction'] = restriction;
    data['polyline'] = polyline;
    data['distance'] = distance;
    if (steps != null) {
      data['steps'] = steps!.map((v) => v.toJson()).toList();
    }
    data['totalTrafficLights'] = totalTrafficLights;
    data['duration'] = duration;
    data['strategy'] = strategy;
    data['tollDistance'] = tollDistance;
    data['tolls'] = tolls;
    return data;
  }
}

class Steps {
  String? orientation;
  String? assistantAction;
  List<Cities>? cities;
  num? tollDistance;
  String? tollRoad;
  String? road;
  String? action;
  String? instruction;
  List<Tmcs>? tmcs;
  String? polyline;
  num? duration;
  num? distance;
  num? tolls;

  Steps(
      {this.orientation,
        this.assistantAction,
        this.cities,
        this.tollDistance,
        this.tollRoad,
        this.road,
        this.action,
        this.instruction,
        this.tmcs,
        this.polyline,
        this.duration,
        this.distance,
        this.tolls});

  Steps.fromJson(Map<String, dynamic> json) {
    orientation = json['orientation'];
    assistantAction = json['assistantAction'];
    if (json['cities'] != null) {
      cities = <Cities>[];
      json['cities'].forEach((v) {
        cities!.add(Cities.fromJson(v));
      });
    }
    tollDistance = json['tollDistance'];
    tollRoad = json['tollRoad'];
    road = json['road'];
    action = json['action'];
    instruction = json['instruction'];
    if (json['tmcs'] != null) {
      tmcs = <Tmcs>[];
      json['tmcs'].forEach((v) {
        tmcs!.add(Tmcs.fromJson(v));
      });
    }
    polyline = json['polyline'];
    duration = json['duration'];
    distance = json['distance'];
    tolls = json['tolls'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orientation'] = orientation;
    data['assistantAction'] = assistantAction;
    if (cities != null) {
      data['cities'] = cities!.map((v) => v.toJson()).toList();
    }
    data['tollDistance'] = tollDistance;
    data['tollRoad'] = tollRoad;
    data['road'] = road;
    data['action'] = action;
    data['instruction'] =instruction;
    if (tmcs != null) {
      data['tmcs'] = tmcs!.map((v) => v.toJson()).toList();
    }
    data['polyline'] = polyline;
    data['duration'] = duration;
    data['distance'] = distance;
    data['tolls'] = tolls;
    return data;
  }
}

class Cities {
  String? citycode;
  int? num;
  List<Districts>? districts;
  String? city;
  String? adcode;

  Cities({this.citycode, this.num, this.districts, this.city, this.adcode});

  Cities.fromJson(Map<String, dynamic> json) {
    citycode = json['citycode'];
    num = json['num'];
    if (json['districts'] != null) {
      districts = <Districts>[];
      json['districts'].forEach((v) {
        districts!.add(Districts.fromJson(v));
      });
    }
    city = json['city'];
    adcode = json['adcode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['citycode'] = citycode;
    data['num'] = num;
    if (districts != null) {
      data['districts'] = districts!.map((v) => v.toJson()).toList();
    }
    data['city'] = city;
    data['adcode'] = adcode;
    return data;
  }
}

class Districts {
  dynamic center;
  String? adcode;
  dynamic polylines;
  String? citycode;
  String? level;
  dynamic districts;
  String? name;

  Districts(
      {this.center,
        this.adcode,
        this.polylines,
        this.citycode,
        this.level,
        this.districts,
        this.name});

  Districts.fromJson(Map<String, dynamic> json) {
    center = json['center'];
    adcode = json['adcode'];
    polylines = json['polylines'];
    citycode = json['citycode'];
    level = json['level'];
    districts = json['districts'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['center'] = center;
    data['adcode'] = adcode;
    data['polylines'] = polylines;
    data['citycode'] = citycode;
    data['level'] = level;
    data['districts'] = districts;
    data['name'] = name;
    return data;
  }
}

class Tmcs {
  String? status;
  num? distance;
  String? polyline;

  Tmcs({this.status, this.distance, this.polyline});

  Tmcs.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    distance = json['distance'];
    polyline = json['polyline'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['distance'] = distance;
    data['polyline'] = polyline;
    return data;
  }
}