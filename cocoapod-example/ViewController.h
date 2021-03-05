//
//  ViewController.h
//  cocoapod-example
//
//  Created by Matthew Wheatley on 10/15/18.
//  Copyright © 2018 Diamond Fortress Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OnyxCamera/OnyxConfigurationBuilder.h>
#import <OnyxCamera/Onyx.h>
#import "OnyxResultViewController.h"

@interface ViewController : UIViewController {
    UIView* spinnerView;
    UIActivityIndicatorView* activityIndicatorView;
}

@property OnyxResult* onyxResult;

- (IBAction)capture:(UIButton *)sender;

-(void(^)(OnyxResult* onyxResult))onyxSuccessCallback;

-(void(^)(OnyxError* onyxError)) onyxErrorCallback;

-(void(^)(Onyx* configuredOnyx))onyxCallback;

@end

