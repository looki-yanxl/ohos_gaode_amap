import { AMap } from "@amap/amap_lbs_map3d";
import { MethodChannel } from "@ohos/flutter_ohos";

export abstract class AbstractOverlayController<T> {
  protected controllerMapByDartId: Map<string, T>;
  protected idMapByOverlyId: Map<string, string>;
  protected methodChannel: MethodChannel;
  protected amap: AMap;

  constructor(methodChannel: MethodChannel, amap: AMap) {
    this.methodChannel = methodChannel;
    this.amap = amap;

    this.controllerMapByDartId = new Map<string, T>();
    this.idMapByOverlyId = new Map<string, string>();
  }
}
