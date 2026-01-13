

export default class Const{
  /**
   * map
   */
  public static METHOD_MAP_WAIT_FOR_MAP:string = "map#waitForMap";
  public static METHOD_MAP_CONTENT_APPROVAL_NUMBER:string = "map#contentApprovalNumber";
  public static METHOD_MAP_SATELLITE_IMAGE_APPROVAL_NUMBER = "map#satelliteImageApprovalNumber";
  public static METHOD_MAP_UPDATE = "map#update";
  public static METHOD_MAP_MOVE_CAMERA = "camera#move";
  public static METHOD_MAP_SET_RENDER_FPS = "map#setRenderFps";
  public static METHOD_MAP_TAKE_SNAPSHOT = "map#takeSnapshot";
  public static METHOD_MAP_CLEAR_DISK = "map#clearDisk";

  public static METHOD_ID_LIST_FOR_MAP:string[] = [
    this.METHOD_MAP_CONTENT_APPROVAL_NUMBER,
    this.METHOD_MAP_SATELLITE_IMAGE_APPROVAL_NUMBER,
    this.METHOD_MAP_WAIT_FOR_MAP,
    this.METHOD_MAP_UPDATE,
    this.METHOD_MAP_MOVE_CAMERA,
    this.METHOD_MAP_SET_RENDER_FPS,
    this.METHOD_MAP_TAKE_SNAPSHOT,
    this.METHOD_MAP_CLEAR_DISK
  ];


  /**
   * markers
   */
  public static METHOD_MARKER_UPDATE = "markers#update";
  public static  METHOD_ID_LIST_FOR_MARKER:string[] = [this.METHOD_MARKER_UPDATE];

  /**
   * polygons
   */
  public static METHOD_POLYGON_UPDATE = "polygons#update";
  public static METHOD_ID_LIST_FOR_POLYGON:string[] = [this.METHOD_POLYGON_UPDATE];

  /**
   * polylines
   */
  public static METHOD_POLYLINE_UPDATE = "polylines#update";
  public static METHOD_ID_LIST_FOR_POLYLINE:string[] = [this.METHOD_POLYLINE_UPDATE];
}