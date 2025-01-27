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

#import "HyBidGADRewardedCustomEvent.h"
#import "HyBidGADUtils.h"

typedef id<GADMediationRewardedAdEventDelegate> _Nullable(^HyBidGADRewardedCustomEventCompletionBlock)(_Nullable id<GADMediationRewardedAd> ad,
                                                                                                                  NSError *_Nullable error);

@interface HyBidGADRewardedCustomEvent() <HyBidRewardedAdDelegate, GADMediationRewardedAd>
@property (nonatomic, strong) HyBidRewardedAd *rewardedAd;
@property(nonatomic, weak, nullable) id<GADMediationRewardedAdEventDelegate> delegate;
@property(nonatomic, copy) HyBidGADRewardedCustomEventCompletionBlock completionBlock;
@end

@implementation HyBidGADRewardedCustomEvent

- (void)dealloc {
    self.rewardedAd = nil;
}

- (void)invokeFailWithMessage:(NSString *)message {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:message];
    self.completionBlock(nil, [NSError errorWithDomain:message code:0 userInfo:nil]);
    [self.delegate didFailToPresentWithError:[NSError errorWithDomain:message code:0 userInfo:nil]];
}

- (void)presentFromViewController:(nonnull UIViewController *)viewController {
    if (self.rewardedAd.isReady) {
        [self.delegate willPresentFullScreenView];
        if ([self.rewardedAd respondsToSelector:@selector(showFromViewController:)]) {
            [self.rewardedAd showFromViewController:viewController];
        } else {
            [self.rewardedAd show];
        }
    } else {
        [self.delegate didFailToPresentWithError:[NSError errorWithDomain:@"Ad is not ready... Please wait." code:0 userInfo:nil]];
    }
}

- (void)loadRewardedAdForAdConfiguration:(GADMediationRewardedAdConfiguration *)adConfiguration
                       completionHandler:(GADMediationRewardedLoadCompletionHandler)completionHandler {
    self.completionBlock = completionHandler;
    NSString *serverParameter = [adConfiguration.credentials.settings objectForKey:@"parameter"];
    if ([HyBidGADUtils areExtrasValid:serverParameter]) {
        if ([HyBidGADUtils appToken:serverParameter] != nil && [[HyBidGADUtils appToken:serverParameter] isEqualToString:[HyBidSettings sharedInstance].appToken]) {
            self.rewardedAd = [[HyBidRewardedAd alloc] initWithZoneID:[HyBidGADUtils zoneID:serverParameter] andWithDelegate:self];
            self.rewardedAd.isMediation = YES;
            [self.rewardedAd load];
        } else {
            [self invokeFailWithMessage:@"The provided app token doesn't match the one used to initialise HyBid."];
            return;
        }
    } else {
        [self invokeFailWithMessage:@"Failed rewarded ad fetch. Missing required server extras."];
        return;
    }
}

#pragma mark - HyBidRewardedAdDelegate

- (void)onReward {
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:0] decimalValue]];
    GADAdReward *reward = [[GADAdReward alloc] initWithRewardType:@"hybid_reward" rewardAmount:amount];
    [self.delegate didRewardUserWithReward:reward];
}

- (void)rewardedDidDismiss {
    [self.delegate willDismissFullScreenView];
    [self.delegate didDismissFullScreenView];
}

- (void)rewardedDidFailWithError:(NSError *)error {
    [self invokeFailWithMessage:error.localizedDescription];
}

- (void)rewardedDidLoad {
    self.delegate = self.completionBlock(self, nil);
}

- (void)rewardedDidTrackClick {
    [self.delegate reportClick];
}

- (void)rewardedDidTrackImpression {
    [self.delegate reportImpression];
}

#pragma mark - GADMediationAdapter

// v: 2.9.1
+ (GADVersionNumber)adSDKVersion {
    GADVersionNumber version = {0};
    version.majorVersion = 2;
    version.minorVersion = 9;
    version.patchVersion = 1;
    return version;
}

+ (GADVersionNumber)adapterVersion {
    GADVersionNumber version = {0};
    version.majorVersion = 2;
    version.minorVersion = 9;
    version.patchVersion = 1;
    return version;
}

+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass {
    return nil;
}

@end
