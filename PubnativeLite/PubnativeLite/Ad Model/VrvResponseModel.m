//
//  VrvResponseModel.m
//  HyBid
//
//  Created by Eros Garcia Ponte on 23.03.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import "VrvResponseModel.h"

@implementation VrvResponseModel

- (void)dealloc {
    self.dictionary = nil;
    self.status = nil;
    self.ads = nil;
}

- (instancetype)initWithXml:(NSDictionary *)dictionary {
    if (self) {
        self.status = @"ok";
    }
    return self;
}

@end
