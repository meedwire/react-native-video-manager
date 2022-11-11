#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(VideoManager, NSObject)

RCT_EXTERN_METHOD(getFramesVideo:(NSString *)source options:(NSDictionary *)options withResolver:(RCTPromiseResolveBlock)resolve withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(compress:(NSString *)source options:(NSDictionary *)options withResolver:(RCTPromiseResolveBlock)resolve withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(cropVideo:(NSString *)source options:(NSDictionary *)options withResolver:(RCTPromiseResolveBlock)resolve withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getVideoInfo:(NSString *)source withResolver:(RCTPromiseResolveBlock)resolve withRejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end



