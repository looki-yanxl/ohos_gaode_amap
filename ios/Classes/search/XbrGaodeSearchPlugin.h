#import <Flutter/Flutter.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

@interface XbrGaodeSearchPlugin : NSObject<FlutterPlugin>

@property (nonatomic,retain) AMapSearchAPI* search;
@property (nonatomic,retain) FlutterResult result;
@property (nonatomic,retain) id onlyOne;
@property (nonatomic,retain) id simplify;
@property (nonatomic,retain) NSNumber* showFields;
@end
