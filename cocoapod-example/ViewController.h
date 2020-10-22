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

@interface ViewController : UIViewController <UIScrollViewDelegate, UITextFieldDelegate> {
    UIView* spinnerView;
    UIActivityIndicatorView* activityIndicatorView;
}
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UISwitch *returnRawImage;
@property (strong, nonatomic) IBOutlet UISwitch *returnGrayRawImage;
@property (strong, nonatomic) IBOutlet UISwitch *returnProcessedImage;
@property (strong, nonatomic) IBOutlet UISwitch *returnEnhancedImage;
@property (strong, nonatomic) IBOutlet UISwitch *returnBlackWhiteProcessedImage;
@property (strong, nonatomic) IBOutlet UISwitch *returnGrayRawWsq;
@property (strong, nonatomic) IBOutlet UISwitch *returnFingerprintTemplate;
@property (strong, nonatomic) IBOutlet UISwitch *returnWsq;
@property (strong, nonatomic) IBOutlet UISwitch *useOnyxLive;
@property (strong, nonatomic) IBOutlet UISwitch *useFlash;
@property (strong, nonatomic) IBOutlet UISwitch *useManualCapture;
@property (strong, nonatomic) IBOutlet UISwitch *showSpinner;
@property (strong, nonatomic) IBOutlet UISegmentedControl *reticleOrientation;
@property (strong, nonatomic) IBOutlet UITextField *backgroundColorHexString;
@property (strong, nonatomic) IBOutlet UISegmentedControl *imageRotation;
@property (strong, nonatomic) IBOutlet UITextField *LEDBrightness;
@property (strong, nonatomic) IBOutlet UITextField *cropFactor;
@property (strong, nonatomic) IBOutlet UITextField *cropSizeWidth;
@property (strong, nonatomic) IBOutlet UITextField *cropSizeHeight;
@property (strong, nonatomic) IBOutlet UISwitch *showManualCaptureText;
@property (strong, nonatomic) IBOutlet UITextField *backButtonText;
@property (strong, nonatomic) IBOutlet UITextField *manualCaptureText;
@property (strong, nonatomic) IBOutlet UITextField *infoText;
@property (strong, nonatomic) IBOutlet UITextField *infoTextColorHexString;
@property (strong, nonatomic) IBOutlet UITextField *base64ImageData;
@property (strong, nonatomic) IBOutlet UISegmentedControl *fingerDetectMode;

@property NSMutableArray* onyxResults;

- (IBAction)capture:(id)sender;

-(void(^)(NSMutableArray* onyxResults))onyxSuccessCallback;

-(void(^)(OnyxError* onyxError)) onyxErrorCallback;

-(void(^)(Onyx* configuredOnyx))onyxCallback;

@end

