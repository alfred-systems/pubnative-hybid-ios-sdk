//
//  Copyright © 2018 PubNative. All rights reserved.
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

#import "HyBidMoPubMediationNativeAdCustomEvent.h"
#import "HyBidMoPubMediationNativeAdAdapter.h"
#import "HyBidMoPubUtils.h"
#import "MPNativeAd.h"
#import "MPLogging.h"

@interface HyBidMoPubMediationNativeAdCustomEvent() <HyBidNativeAdLoaderDelegate>

@property (nonatomic, strong) HyBidNativeAdLoader *nativeAdLoader;

@end

@implementation HyBidMoPubMediationNativeAdCustomEvent

- (void)dealloc
{
    self.nativeAdLoader = nil;
}

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info
{
    if ([HyBidMoPubUtils areExtrasValid:info]) {
        if ([HyBidMoPubUtils appToken:info] != nil || [[HyBidMoPubUtils appToken:info] isEqualToString:[HyBidSettings sharedInstance].appToken]) {
            self.nativeAdLoader = [[HyBidNativeAdLoader alloc] init];
            [self.nativeAdLoader loadNativeAdWithDelegate:self withZoneID:[HyBidMoPubUtils zoneID:info]];
        } else {
            [self invokeFailWithMessage:@"HyBid - The provided app token doesn't match the one used to initialise HyBid."];
            return;
        }
    } else {
        [self invokeFailWithMessage:@"HyBid - Error: Failed native ad fetch. Missing required server extras."];
        return;
    }
}

- (void)invokeFailWithMessage:(NSString*)message
{
    MPLogError(message);
    [self.delegate nativeCustomEvent:self
            didFailToLoadAdWithError:[NSError errorWithDomain:message
                                                         code:0
                                                     userInfo:nil]];
}

#pragma mark - HyBidNativeAdLoaderDelegate

- (void)nativeLoaderDidLoadWithNativeAd:(HyBidNativeAd *)nativeAd
{
    __block HyBidMoPubMediationNativeAdCustomEvent *strongSelf = self;
    __block HyBidNativeAd *blockAd = nativeAd;
    NSString *bannerURLString = nativeAd.bannerUrl;
    NSString *iconURLString = nativeAd.iconUrl;
    
    NSURL *bannerURL = [NSURL URLWithString:bannerURLString];
    NSURL *iconURL = [NSURL URLWithString:iconURLString];
    
    [self precacheImagesWithURLs:@[bannerURL, iconURL] completionBlock:^(NSArray *errors) {
        if(errors && errors.count > 0) {
            [self invokeFailWithMessage:@"HyBid - Error: error caching resources"];
        } else {
            HyBidMoPubMediationNativeAdAdapter *adapter = [[HyBidMoPubMediationNativeAdAdapter alloc] initWithNativeAd:blockAd];
            MPNativeAd* result = [[MPNativeAd alloc] initWithAdAdapter:adapter];
            [strongSelf.delegate nativeCustomEvent:strongSelf didLoadAd:result];
        }
        blockAd = nil;
        strongSelf = nil;
    }];
}

- (void)nativeLoaderDidFailWithError:(NSError *)error
{
    [self invokeFailWithMessage:error.localizedDescription];
}

@end
