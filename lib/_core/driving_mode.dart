// ignore_for_file: non_constant_identifier_names

class DrivingMode {
  static int DRIVING_SINGLE_DEFAULT = 0; // 速度优先，不考虑当时路况，返回耗时最短的路线，但是此路线不一定距离最短
  static int DRIVING_SINGLE_SAVE_MONEY = 1; //费用优先，不走收费路段，且耗时最少的路线
  static int DRIVING_SINGLE_SHORTEST = 2; //距离优先，不考虑路况，仅走距离最短的路线，但是可能存在穿越小路/小区的情况
  static int DRIVING_SINGLE_NO_EXPRESSWAYS = 3; //速度优先，不走快速路，例如京通快速路（因为策略迭代，建议使用13）
  static int DRIVING_SINGLE_AVOID_CONGESTION = 4; //躲避拥堵，但是可能会存在绕路的情况，耗时可能较长
  static int DRIVING_MULTI_STRATEGY_FASTEST_SAVE_MONEY_SHORTEST = 5; //多策略（同时使用速度优先、费用优先、距离优先三个策略计算路径）。其中必须说明，就算使用三个策略算路，会根据路况不固定的返回一到三条路径规划信息
  static int DRIVING_SINGLE_NO_HIGHWAY = 6; // 速度优先，不走高速，但是不排除走其余收费路段
  static int DRIVING_SINGLE_NO_HIGHWAY_SAVE_MONEY = 7; //费用优先，不走高速且避免所有收费路段
  static int DRIVING_SINGLE_SAVE_MONEY_AVOID_CONGESTION = 8; // 躲避拥堵和收费，可能存在走高速的情况，并且考虑路况不走拥堵路线，但有可能存在绕路和时间较长
  static int DRIVING_SINGLE_NO_HIGHWAY_SAVE_MONEY_AVOID_CONGESTION = 9; //躲避拥堵和收费，不走高速
  static int DRIVING_MULTI_STRATEGY_FASTEST_SHORTEST_AVOID_CONGESTION = 10; //返回结果会躲避拥堵，路程较短，尽量缩短时间，与高德地图的默认策略（也就是不进行任何勾选）一致
  static int DRIVING_MULTI_STRATEGY_FASTEST_SHORTEST = 11; //返回三个结果包含：时间最短；距离最短；躲避拥堵（由于有更优秀的算法，建议用10代替）
  static int DRIVING_MULTI_CHOICE_AVOID_CONGESTION = 12; //返回的结果考虑路况，尽量躲避拥堵而规划路径，与高德地图的“躲避拥堵”策略一致
  static int DRIVING_MULTI_CHOICE_NO_HIGHWAY = 13; //返回的结果不走高速，与高德地图“不走高速”策略一致
  static int DRIVING_MULTI_CHOICE_SAVE_MONEY = 14; //返回的结果尽可能规划收费较低甚至免费的路径，与高德地图“避免收费”策略一致
  static int DRIVING_MULTI_CHOICE_AVOID_CONGESTION_NO_HIGHWAY = 15; //返回的结果考虑路况，尽量躲避拥堵而规划路径，并且不走高速，与高德地图的“躲避拥堵&不走高速”策略一致
  static int DRIVING_MULTI_CHOICE_SAVE_MONEY_NO_HIGHWAY = 16; // 返回的结果尽量不走高速，并且尽量规划收费较低甚至免费的路径结果，与高德地图的“避免收费&不走高速”策略一致
  static int DRIVING_MULTI_CHOICE_AVOID_CONGESTION_SAVE_MONEY = 17; //返回路径规划结果会尽量的躲避拥堵，并且规划收费较低甚至免费的路径结果，与高德地图的“躲避拥堵&避免收费”策略一致
  static int DRIVING_MULTI_CHOICE_AVOID_CONGESTION_NO_HIGHWAY_SAVE_MONEY = 18; // 返回的结果尽量躲避拥堵，规划收费较低甚至免费的路径结果，并且尽量不走高速路，与高德地图的“避免拥堵&避免收费&不走高速”策略一致
  static int DRIVING_MULTI_CHOICE_HIGHWAY = 19; // 返回的结果会优先选择高速路，与高德地图的“高速优先”策略一致
  static int DRIVING_MULTI_CHOICE_HIGHWAY_AVOID_CONGESTION = 20; // 返回的结果会优先考虑高速路，并且会考虑路况躲避拥堵，与高德地图的“躲避拥堵&高速优先”策略一致
}
