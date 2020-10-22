//
//  ViewController.m
//  cocoapod-example
//
//  Created by Matthew Wheatley on 10/15/18.
//  Copyright © 2018 Diamond Fortress Technologies, Inc. All rights reserved.
//

#import "ViewController.h"
#import "OnyxResultViewController.h"
#import "OnyxCamera/OnyxResult.h"
#import <malloc/malloc.h>

@interface ViewController ()
            

@end

@implementation ViewController

UITextField* activeTextField;
CGPoint lastOffset;
float keyboardHeight;

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    _backgroundColorHexString.delegate = self;
    _cropFactor.delegate = self;
    _cropSizeWidth.delegate = self;
    _cropSizeHeight.delegate = self;
    _backButtonText.delegate = self;
    _manualCaptureText.delegate = self;
    _infoText.delegate = self;
    _infoTextColorHexString.delegate = self;
    _base64ImageData.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    activeTextField = textField;
    lastOffset = _scrollView.contentOffset;
    return true;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    activeTextField = nil;
    return true;
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -keyboardSize.height;
        self.view.frame = f;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}

- (IBAction)capture:(id)sender {
    OnyxConfigurationBuilder* onyxConfigBuilder =[[OnyxConfigurationBuilder alloc] init];
    onyxConfigBuilder.setViewController(self)
    .setLicenseKey(@"3969-9138-6246-1-2")
    .setShowLoadingSpinner(_showSpinner.on)
    .setReturnRawImage(_returnRawImage.on)
    .setReturnGrayRawImage(_returnGrayRawImage.on)
    .setReturnProcessedImage(_returnProcessedImage.on)
    .setReturnEnhancedImage(_returnEnhancedImage.on)
    .setReturnBlackWhiteProcessedImage(_returnBlackWhiteProcessedImage.on)
    .setReturnWSQ(_returnWsq.on)
    .setReturnGrayRawWSQ(_returnGrayRawWsq.on)
    .setReturnFingerprintTemplate(_returnFingerprintTemplate.on)
    .setReturnISOFingerprintTemplate(true)
    .setUseOnyxLive(_useOnyxLive.on)
    .setUseFlash(_useFlash.on)
    .setUseManualCapture(_useManualCapture.on)
    .setShowManualCaptureText(_showManualCaptureText.on)
    .setReticleOrientation((ReticleOrientation)_reticleOrientation.selectedSegmentIndex)
    .setImageRotation((ImageRotation)_imageRotation.selectedSegmentIndex)
    .setFingerDetectMode((FingerDetectMode)_fingerDetectMode.selectedSegmentIndex)
    .setSuccessCallback([self onyxSuccessCallback])
    .setErrorCallback([self onyxErrorCallback])
    .setOnyxCallback([self onyxCallback]);
    
    if (![_backgroundColorHexString.text isEqualToString:@""]) {
        onyxConfigBuilder.setBackgroundColorHexString([NSString stringWithFormat:@"#%@", _backgroundColorHexString.text]);
    }
    
    if (![_backButtonText.text isEqualToString:@""]) {
        onyxConfigBuilder.setBackButtonText(_backButtonText.text);
    }
    
    if (![_manualCaptureText.text isEqualToString:@""]) {
        onyxConfigBuilder.setManualCaptureText(_manualCaptureText.text);
    }
    
    if (![_infoText.text isEqualToString:@""]) {
        onyxConfigBuilder.setInfoText(_infoText.text);
    }
    
    if (![_infoTextColorHexString.text isEqualToString:@""]) {
        onyxConfigBuilder.setInfoTextColorHexString([NSString stringWithFormat:@"#%@", _infoTextColorHexString.text]);
    }
    
    if (![_base64ImageData.text isEqualToString:@""]) {
        onyxConfigBuilder.setBase64ImageData(_base64ImageData.text);
    }
    
    if (![_LEDBrightness.text isEqualToString:@""]) {
        onyxConfigBuilder.setLEDBrightness([_LEDBrightness.text floatValue]);
    }
    
    // Crop Factor
    if (![_cropFactor.text isEqualToString:@""]) {
        onyxConfigBuilder.setCropFactor([_cropFactor.text floatValue]);
    }
    
    // Crop Size
    float width = 600;
    float height = 960;
    float floatValue = 0;
    if (![_cropSizeWidth.text isEqualToString:@""]) {
        floatValue = [_cropSizeWidth.text floatValue];
        if (floatValue != 0) {
            width = floatValue;
        }
    }
    if (![_cropSizeHeight.text isEqualToString:@""]) {
        floatValue = [_cropSizeHeight.text floatValue];
        if (floatValue != 0) {
            height = floatValue;
        }
    }
    
    onyxConfigBuilder.setCropSize(CGSizeMake(width, height));
    
    
    [onyxConfigBuilder buildOnyxConfiguration];
}

-(void(^)(Onyx* configuredOnyx)) onyxCallback {
    return ^(Onyx* configuredOnyx) {
        NSLog(@"Onyx Callback");
        dispatch_async(dispatch_get_main_queue(), ^{
            [configuredOnyx capture:self];
        });
    };
}

-(void(^)(NSMutableArray* onyxResults)) onyxSuccessCallback {
    return ^(NSMutableArray* onyxResults) {
        NSLog(@"Onyx Success Callback");
        self->_onyxResults = onyxResults;
        dispatch_async(dispatch_get_main_queue(), ^{
            // Uncomment this later when ready to handle OnyxResult
            [self performSegueWithIdentifier:@"segueToOnyxResult" sender:onyxResults];
        });
    };
}

-(void(^)(OnyxError* onyxError)) onyxErrorCallback {
    return ^(OnyxError* onyxError) {
        NSLog(@"Onyx Error Callback");
        dispatch_async(dispatch_get_main_queue(), ^{
            //            [self stopSpinnner];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ONYX Error"
                                                            message:[NSString stringWithFormat:@"ErrorCode: %d, ErrorMessage:%@, Error:%@", onyxError.error, onyxError.errorMessage, onyxError.exception]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        });
        
    };
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueToOnyxResult"]) {
        OnyxResultViewController* orvc = segue.destinationViewController;
        orvc.onyxResults = sender;
    }
}

@end
    
