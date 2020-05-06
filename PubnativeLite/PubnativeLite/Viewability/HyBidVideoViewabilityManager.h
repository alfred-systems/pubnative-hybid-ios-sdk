//
//  Copyright © 2020 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@class OMIDPubnativenetAdSession;

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HyBidVideoViewabilityManager : NSObject

@property (nonatomic, assign) BOOL viewabilityMeasurementEnabled;

+ (instancetype)sharedInstance;
- (NSString *)getOMIDJS;
- (OMIDPubnativenetAdSession*)createOMIDAdSessionforNativeVideo:(UIView *)view withScript:(NSMutableArray *)scripts;
- (void)startOMIDAdSession:(OMIDPubnativenetAdSession *)omidAdSession;
- (void)stopOMIDAdSession:(OMIDPubnativenetAdSession *)omidAdSession;
- (void)fireOMIDAdLoadEvent;
- (void)fireOMIDImpressionOccuredEvent:(OMIDPubnativenetAdSession*)omidAdSession;
- (void)fireOMIDStartEventWithDuration:(CGFloat)duration withVolume:(CGFloat)volume;
- (void)fireOMIDFirstQuartileEvent;
- (void)fireOMIDMidpointEvent;
- (void)fireOMIDThirdQuartileEvent;
- (void)fireOMIDCompleteEvent;
- (void)fireOMIDPauseEvent;
- (void)fireOMIDResumeEvent;
- (void)fireOMIDBufferStartEvent;
- (void)fireOMIDBufferFinishEvent;
- (void)fireOMIDVolumeChangeEventWithVolume:(CGFloat)volume;
- (void)fireOMIDSkippedEvent;
- (void)fireOMIDPlayerStateEventWithFullscreenInfo:(BOOL)isFullScreen;
- (void)addFriendlyObstruction:(UIView *)view toOMIDAdSession:(OMIDPubnativenetAdSession*)omidAdSession withReason:(NSString *)reasonForFriendlyObstruction isInterstitial:(BOOL)isInterstitial;
@end

NS_ASSUME_NONNULL_END
