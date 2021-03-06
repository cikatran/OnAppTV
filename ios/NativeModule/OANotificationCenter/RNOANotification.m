//
//  RNNotificationCenter.m
//  OnAppTV
//
//  Created by Chuong Huynh on 4/2/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "RNOANotification.h"
#import "OnAppTV-Swift.h"

@implementation RNOANotification

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(requestPermission: (RCTResponseSenderBlock)callback) {
    [[OANotificationCenter sharedInstance] requestPermissionWithCallback:^{
        callback(@[]);
    }];
}

RCT_EXPORT_METHOD(updateBadge: (NSNumber * __nonnull)  number) {
    [OANotificationCenter.sharedInstance updateBadgeWithNumber: number];
}

@end
