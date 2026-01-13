import { MethodCall, MethodChannel, MethodResult } from '@ohos/flutter_ohos';

export interface MyMethodCallHandler{
  doMethodCall(call:MethodCall,result:MethodResult):void;
  getRegisterMethodIdArray():String[];
}