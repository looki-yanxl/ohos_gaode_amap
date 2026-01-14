import { LogUtil } from "@amap/amap_lbs_common";
import { CameraPosition } from "@amap/amap_lbs_map3d";
import { BinaryMessenger, PlatformView, PlatformViewFactory, StandardMessageCodec } from "@ohos/flutter_ohos";
import AMapOptionsBuilder from "./amap/AMapOptionsBuilder";
import { ConvertUtil } from "./amap/util/ConvertUtil";
import display from "@ohos.display";
import { ConfigurationConstant } from '@kit.AbilityKit';
import util from "@ohos.util";
import { collections } from "@kit.ArkTS";


export class AMapPlatformViewFactory extends PlatformViewFactory {
  private static readonly CLASS_NAME: string = 'AMapPlatformViewFactory';

  private binaryMessenger: BinaryMessenger;

  constructor(
    binaryMessenger: BinaryMessenger,
  ) {
    super(StandardMessageCodec.INSTANCE);
    this.binaryMessenger = binaryMessenger;
  }

  create(
    context: Context,
    viewId: number,
    args: Object | null
  ): PlatformView {
    const builder = new AMapOptionsBuilder();
    let params: Record<string, ESObject>;

    try {
      // density

      getDensity().then(density => {
        ConvertUtil.density = density
        console.log('屏幕密度:', density);
      });


      params = args as Record<string, ESObject>;
      LogUtil.i(
        AMapPlatformViewFactory.CLASS_NAME,
        'create params==>' + JSON.stringify(params),""
      );

      if (params.get('privacyStatement') != null) {
        ConvertUtil.setPrivacyStatement(
          context,
          params['privacyStatement']
        );
      }


      const options = params.get('options') as Record<string, ESObject>;


      if (options != null) {
        ConvertUtil.interpretAMapOptions(options, builder);
      }

      if (params.get('initialCameraPosition') != null) {
        const cameraPosition: CameraPosition =
          ConvertUtil.toCameraPosition(params.get('initialCameraPosition'));
        builder.setCamera(cameraPosition);
      }

      if (params.get('markersToAdd') != null) {
        builder.setInitialMarkers(params.get('markersToAdd'));
      }

      if (params.get('polylinesToAdd') != null) {
        builder.setInitialPolylines(params.get('polylinesToAdd'));
      }

      if (params.get('polygonsToAdd') != null) {
        builder.setInitialPolygons(params.get('polygonsToAdd'));
      }

      if (params.get('apiKey') != null) {
        ConvertUtil.checkApiKey(params.get('apiKey'));
      }

      // if (params['debugMode'] != null) {
      //   LogUtil.isDebugMode = ConvertUtil.toBoolean(params['debugMode']);
      // }
    } catch (e) {
      LogUtil.e(
        AMapPlatformViewFactory.CLASS_NAME,
        'create',
        e
      );
    }

    return builder.build(
      viewId,
      context,
      this.binaryMessenger,
    );
  }
}

async function getDensity(): Promise<number> {
  try {
    const info = await display.getDefaultDisplay(); // 返回 Display 对象
    return info.densityDPI; // 屏幕密度（float）
  } catch (err) {
    console.error('获取屏幕密度失败:', err);
    return 1; // 默认值
  }
}
