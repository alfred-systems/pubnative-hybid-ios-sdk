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

#import "PNLiteMRAIDBannerPresenter.h"
#import "PNMRAIDView.h"
#import "PNMRAIDServiceDelegate.h"
#import "PNMRAIDServiceProvider.h"
#import "UIApplication+PNLiteTopViewController.h"

CGFloat const kPNLiteMRAIDBannerWidth = 320.0f;
CGFloat const kPNLiteMRAIDBannerHeight = 50.0f;

@interface PNLiteMRAIDBannerPresenter () <PNMRAIDViewDelegate, PNMRAIDServiceDelegate>

@property (nonatomic, strong) PNMRAIDServiceProvider *serviceProvider;
@property (nonatomic, retain) PNMRAIDView *mraidView;
@property (nonatomic, strong) PNLiteAd *adModel;

@end

@implementation PNLiteMRAIDBannerPresenter

- (void)dealloc
{
    self.serviceProvider = nil;
    self.adModel = nil;
}

- (instancetype)initWithAd:(PNLiteAd *)ad
{
    self = [super init];
    if (self) {
        self.adModel = ad;
    }
    return self;
}

- (PNLiteAd *)ad
{
    return self.adModel;
}

- (void)load
{
    self.serviceProvider = [[PNMRAIDServiceProvider alloc] init];
    self.mraidView = [[PNMRAIDView alloc] initWithFrame:CGRectMake(0, 0, kPNLiteMRAIDBannerWidth, kPNLiteMRAIDBannerHeight)
                                           withHtmlData:self.adModel.htmlData
                                            withBaseURL:[NSURL URLWithString:self.adModel.htmlUrl]
                                      supportedFeatures:@[MRAIDSupportsSMS, MRAIDSupportsTel, MRAIDSupportsCalendar, MRAIDSupportsStorePicture, MRAIDSupportsInlineVideo]
                                          isInterstital:NO
                                               delegate:self
                                        serviceDelegate:self
                                     rootViewController:[UIApplication sharedApplication].topViewController];
}

#pragma mark PNMRAIDViewDelegate

- (void)mraidViewAdReady:(PNMRAIDView *)mraidView
{
    [self.delegate bannerPresenter:self didLoadWithBanner:mraidView];
}

- (void)mraidViewAdFailed:(PNMRAIDView *)mraidView
{
    NSError *error = [NSError errorWithDomain:@"PNLiteMRAIDBannerPresenter - MRAID View  Failed" code:0 userInfo:nil];
    [self.delegate bannerPresenter:self didFailWithError:error];
}

- (void)mraidViewWillExpand:(PNMRAIDView *)mraidView
{
    NSLog(@"PNMRAIDViewDelegate - MRAID will expand!");
    [self.delegate bannerPresenterDidClick:self];
}

- (void)mraidViewDidClose:(PNMRAIDView *)mraidView
{
    NSLog(@"PNMRAIDViewDelegate - MRAID did close!");
}

- (void)mraidViewNavigate:(PNMRAIDView *)mraidView withURL:(NSURL *)url
{
    NSLog(@"PNMRAIDViewDelegate - MRAID navigate with URL:%@",url);
    [self.serviceProvider openBrowser:url.absoluteString];
    [self.delegate bannerPresenterDidClick:self];
}

- (BOOL)mraidViewShouldResize:(PNMRAIDView *)mraidView toPosition:(CGRect)position allowOffscreen:(BOOL)allowOffscreen
{
    return NO;
}

#pragma mark PNMRAIDServiceDelegate

- (void)mraidServiceCallNumberWithUrlString:(NSString *)urlString
{
    [self.serviceProvider callNumber:urlString];
}

- (void)mraidServiceSendSMSWithUrlString:(NSString *)urlString
{
    [self.serviceProvider sendSMS:urlString];
}

- (void)mraidServiceCreateCalendarEventWithEventJSON:(NSString *)eventJSON
{
    [self.serviceProvider createEvent:eventJSON];
}

- (void)mraidServiceOpenBrowserWithUrlString:(NSString *)urlString
{
    [self.delegate bannerPresenterDidClick:self];
    [self.serviceProvider openBrowser:urlString];
}

- (void)mraidServicePlayVideoWithUrlString:(NSString *)urlString
{
    [self.serviceProvider playVideo:urlString];
}

- (void)mraidServiceStorePictureWithUrlString:(NSString *)urlString
{
    [self.serviceProvider storePicture:urlString];
}

@end