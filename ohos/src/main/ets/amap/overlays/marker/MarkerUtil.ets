import { ConvertUtil } from '../../util/ConvertUtil';
import { MarkerOptionsSink } from './MarkerOptionsSink';
import { ArrayList } from '@kit.ArkTS';

export class MarkerUtil {

  static interpretMarkerOptions(
    o: Object | null,
    sink: MarkerOptionsSink
  ): string | null {
    if (o == null) {
      return null;
    }

    const data: Map<string | object, object | string> = ConvertUtil.toMap(o);

    const alpha = data.get('alpha') as object;
    if (alpha != null) {
      sink.setAlpha(ConvertUtil.toFloat(alpha));
    }

    const anchor = data.get('anchor') as object;
    if (anchor != null) {
      const anchorData: ArrayList<object> = ConvertUtil.toList(anchor);
      sink.setAnchor(
        ConvertUtil.toFloat(anchorData[0]),
        ConvertUtil.toFloat(anchorData[1])
      );
    }

    const consumeTapEvents = data.get('consumeTapEvents') as object;
    // 原代码未使用，保持一致（可按需补充）

    const draggable = data.get('draggable') as object;
    if (draggable != null) {
      sink.setDraggable(ConvertUtil.toBoolean(draggable));
    }

    const flat = data.get('flat') as object;
    if (flat != null) {
      sink.setFlat(ConvertUtil.toBoolean(flat));
    }

    const icon = data.get('icon') as object;
    if (icon != null) {
      const bitmapDescriptor = ConvertUtil.toBitmapDescriptor(icon)
      if (bitmapDescriptor != undefined) {
        sink.setIcon(bitmapDescriptor);
      }
    }

    const infoWindow = data.get('infoWindow') as object;
    if (infoWindow != null) {
      MarkerUtil.interpretInfoWindowOptions(
        sink,
        infoWindow as Map<string, string>
      );
    }

    const position = data.get('position') as object;
    if (position != null) {
      sink.setPosition(ConvertUtil.toLatLng(position));
    }

    const rotation = data.get('rotation') as object;
    if (rotation != null) {
      sink.setRotation(Math.abs(360 - ConvertUtil.toFloat(rotation)));
    }

    const visible = data.get('visible') as object;
    if (visible != null) {
      sink.setVisible(ConvertUtil.toBoolean(visible));
    }

    const zIndex = data.get('zIndex') as object;
    if (zIndex != null) {
      sink.setZIndex(ConvertUtil.toFloat(zIndex));
    }

    const infoWindowEnable = data.get('infoWindowEnable') as object;
    if (infoWindowEnable != null) {
      sink.setInfoWindowEnable(ConvertUtil.toBoolean(infoWindowEnable));
    }

    const clickable = data.get('clickable');
    if (clickable != null) {
      sink.setClickable(ConvertUtil.toBoolean(clickable));
    }

    const markerId = data.get('id') as string;
    if (markerId == null) {
      throw new Error('markerId was null');
    } else {
      return markerId;
    }
  }

  private static interpretInfoWindowOptions(
    sink: MarkerOptionsSink,
    infoWindow: Map<string, string>
  ): void {
    const title = infoWindow.get('title');
    const snippet = infoWindow.get('snippet');

    if (title && title.length > 0) {
      sink.setTitle(title);
    }

    if (snippet && snippet.length > 0) {
      sink.setSnippet(snippet);
    }
  }
}
