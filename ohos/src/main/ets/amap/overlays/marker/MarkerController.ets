import { BitmapDescriptor, LatLng, Marker } from "@amap/amap_lbs_map3d";
import { MarkerOptionsSink } from "./MarkerOptionsSink";

export class MarkerController implements MarkerOptionsSink {
  private marker: Marker;
  private markerId: string;

  constructor(marker: Marker) {
    this.marker = marker;
    this.markerId = marker.getId();
  }

  getMarkerId(): string {
    return this.markerId;
  }

  remove(): void {
    if (this.marker != null) {
      this.marker.remove();
    }
  }

  getPosition(): LatLng | null {
    if (this.marker != null) {
      return this.marker.getPosition();
    }
    return null;
  }

  setAlpha(alpha: number): void {
    this.marker.setAlpha(alpha);
  }

  setAnchor(u: number, v: number): void {
    this.marker.setAnchor(u, v);
  }

  setDraggable(draggable: boolean): void {
    this.marker.setDraggable(draggable);
  }

  setFlat(flat: boolean): void {
    this.marker.setFlat(flat);
  }

  setIcon(bitmapDescriptor: BitmapDescriptor): void {
    this.marker.setIcon(bitmapDescriptor);
  }

  setTitle(title: string): void {
    this.marker.setTitle(title);
  }

  setSnippet(snippet: string): void {
    this.marker.setSnippet(snippet);
  }

  setPosition(position: LatLng): void {
    this.marker.setPosition(position);
  }

  setRotation(rotation: number): void {
    this.marker.setRotateAngle(rotation);
  }

  setVisible(visible: boolean): void {
    this.marker.setVisible(visible);
  }

  setZIndex(zIndex: number): void {
    this.marker.setZIndex(zIndex);
  }

  setInfoWindowEnable(enable: boolean): void {
    this.marker.setInfoWindowEnable(enable);
  }

  setClickable(clickable: boolean): void {
    this.marker.setClickable(clickable);
  }

  showInfoWindow(): void {
    this.marker.showInfoWindow();
  }

  hideInfoWindow(): void {
    this.marker.hideInfoWindow();
  }
}
