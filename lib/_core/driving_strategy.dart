// ignore_for_file: non_constant_identifier_names

class DrivingStrategy {
  static int DEFAULT = 32;//默认，高德推荐，同高德地图APP默认
  static int AVOID_CONGESTION = 33;//躲避拥堵
  static int HIGHWAY_PRIORITY = 34;//高速优先
  static int AVOID_HIGHWAY = 35;//不走高速
  static int LESS_CHARGE = 36;//少收费
  static int ROAD_PRIORITY = 37;//大路优先
  static int SPEED_PRIORITY = 38;//速度最快
  static int AVOID_CONGESTION_HIGHWAY_PRIORITY = 39;//躲避拥堵＋高速优先
  static int AVOID_CONGESTION_AVOID_HIGHWAY = 40;//躲避拥堵＋不走高速
  static int AVOID_CONGESTION_LESS_CHARGE = 41;//躲避拥堵＋少收费
  static int LESS_CHARGE_AVOID_HIGHWAY = 42;//少收费＋不走高速
  static int AVOID_CONGESTION_LESS_CHARGE_AVOID_HIGHWAY = 43;//躲避拥堵＋少收费＋不走高速
  static int AVOID_CONGESTION_ROAD_PRIORITY = 44;//躲避拥堵＋大路优先
  static int AVOID_CONGESTION_SPEED_PRIORITY = 45;//躲避拥堵＋速度最快
}
