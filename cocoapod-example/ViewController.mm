//
//  ViewController.m
//  cocoapod-example
//
//  Created by Matthew Wheatley on 10/15/18.
//  Copyright © 2018 Diamond Fortress Technologies, Inc. All rights reserved.
//

#import "ViewController.h"
#import "OnyxResultViewController.h"

@interface ViewController ()

@end

@implementation ViewController

UITextField* activeTextField;
CGPoint lastOffset;
float keyboardHeight;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueToOnyxResult"]) {
        OnyxResultViewController* orvc = segue.destinationViewController;
        orvc.onyxResult = sender;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Actions
- (IBAction)capture:(UIButton *)sender {
    
    OnyxConfigurationBuilder* onyxConfigBuilder = [[OnyxConfigurationBuilder alloc] init];
    onyxConfigBuilder.setViewController(self)
    .setLicenseKey(@"your license key here")
    .setReturnRawImage(_returnRawImage.on)
    .setReturnProcessedImage(_returnProcessedImage.on)
    .setReturnWSQ(_returnWsq.on)
    .setReturnFingerprintTemplate(_returnFingerprintTemplate.on)
    .setReturnISOFingerprintTemplate(true)
    .setUseOnyxLive(_useOnyxLive.on)
    .setReticleOrientation((ReticleOrientation)_reticleOrientation.selectedSegmentIndex)
    .setShowLoadingSpinner(YES)
    .setSuccessCallback([self onyxSuccessCallback])
    .setErrorCallback([self onyxErrorCallback])
    .setOnyxCallback([self onyxCallback]);
    
    /*
     * Legacy params
     *
     * NOTE: subject of change
     */

    //.setReturnGrayRawImage(_returnGrayRawImage.on)
    //.setReturnEnhancedImage(_returnEnhancedImage.on)
    //.setReturnBlackWhiteProcessedImage(_returnBlackWhiteProcessedImage.on)
    //.setReturnGrayRawWSQ(_returnGrayRawWsq.on)
    //.setUseFlash(_useFlash.on)
    //.setUseManualCapture(_useManualCapture.on)
    //.setShowManualCaptureText(_showManualCaptureText.on)
    //.setImageRotation((ImageRotation)_imageRotation.selectedSegmentIndex)
    //.setFingerDetectMode((FingerDetectMode)_fingerDetectMode.selectedSegmentIndex)
    
//    if (![_backgroundColorHexString.text isEqualToString:@""]) {
//        onyxConfigBuilder.setBackgroundColorHexString([NSString stringWithFormat:@"#%@", _backgroundColorHexString.text]);
//    }
//
//    if (![_backButtonText.text isEqualToString:@""]) {
//        onyxConfigBuilder.setBackButtonText(_backButtonText.text);
//    }
//
//    if (![_manualCaptureText.text isEqualToString:@""]) {
//        onyxConfigBuilder.setManualCaptureText(_manualCaptureText.text);
//    }
//
//    if (![_infoText.text isEqualToString:@""]) {
//        onyxConfigBuilder.setInfoText(_infoText.text);
//    }
//
//    if (![_infoTextColorHexString.text isEqualToString:@""]) {
//        onyxConfigBuilder.setInfoTextColorHexString([NSString stringWithFormat:@"#%@", _infoTextColorHexString.text]);
//    }
//
//    if (![_base64ImageData.text isEqualToString:@""]) {
//        onyxConfigBuilder.setBase64ImageData(_base64ImageData.text);
//    }
//
//    if (![_LEDBrightness.text isEqualToString:@""]) {
//        onyxConfigBuilder.setLEDBrightness([_LEDBrightness.text floatValue]);
//    }
//
//    // Crop Factor
//    if (![_cropFactor.text isEqualToString:@""]) {
//        onyxConfigBuilder.setCropFactor([_cropFactor.text floatValue]);
//    }
//
//    // Crop Size
//    float width = 600;
//    float height = 960;
//    float floatValue = 0;
//    if (![_cropSizeWidth.text isEqualToString:@""]) {
//        floatValue = [_cropSizeWidth.text floatValue];
//        if (floatValue != 0) {
//            width = floatValue;
//        }
//    }
//    if (![_cropSizeHeight.text isEqualToString:@""]) {
//        floatValue = [_cropSizeHeight.text floatValue];
//        if (floatValue != 0) {
//            height = floatValue;
//        }
//    }
//
//    onyxConfigBuilder.setCropSize(CGSizeMake(width, height));
    
    [onyxConfigBuilder buildOnyxConfiguration];
}

#pragma mark - Onyx Callbacks

-(void(^)(Onyx* configuredOnyx))onyxCallback {
    return ^(Onyx* configuredOnyx) {
        NSLog(@"Onyx Callback");
        dispatch_async(dispatch_get_main_queue(), ^{
            [configuredOnyx capture:self];
        });

    };
}

-(void(^)(OnyxResult* onyxResult))onyxSuccessCallback {
    return ^(OnyxResult* onyxResult) {
        NSLog(@"Onyx Success Callback");
        self->_onyxResult = onyxResult;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            [self performSegueWithIdentifier:@"segueToOnyxResult" sender:onyxResult];
        }];
    };
}

-(void(^)(OnyxError* onyxError)) onyxErrorCallback {
    return ^(OnyxError* onyxError) {
        NSLog(@"Onyx Error Callback");
        dispatch_async(dispatch_get_main_queue(), ^{
            //            [self stopSpinnner];
            UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"ONYX Error"
                                          message:[NSString stringWithFormat:@"ErrorCode: %d, ErrorMessage:%@, Error:%@", onyxError.error, onyxError.errorMessage, onyxError.exception]
                                          preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *okAction = [UIAlertAction
                        actionWithTitle:@"OK"
                                  style:UIAlertActionStyleDefault
                                handler:nil];

            [alertController addAction:okAction];

            [self presentViewController:alertController animated:YES completion:nil];
        });
            
    };
}
#pragma mark - TextFields

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

@end
