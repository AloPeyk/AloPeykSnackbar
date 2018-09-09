//
//  SnackBarBridge.m
//  Tests
//
//  Created by Mohammad Ali on 9/3/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(Snackbar, NSObject)

RCT_EXTERN_METHOD(show:(NSDictionary)options withCallback:(RCTResponseSenderBlock)callback)
RCT_EXTERN_METHOD(dismiss)

@end
