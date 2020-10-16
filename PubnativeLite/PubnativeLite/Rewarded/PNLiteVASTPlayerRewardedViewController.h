//
//  PNLiteVASTPlayerRewardedViewController.h
//  HyBid
//
//  Created by Orkhan Alizada on 16.10.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNLiteVASTPlayerInterstitialViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PNLiteVASTPlayerRewardedViewController : UIViewController

- (void)loadFullScreenPlayerWithPresenter:(HyBidInterstitialPresenter *)interstitialPresenter withAd:(HyBidAd *)ad;

@end

NS_ASSUME_NONNULL_END
