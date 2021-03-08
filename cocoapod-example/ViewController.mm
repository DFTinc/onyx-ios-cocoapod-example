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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

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
            //Your code goes in here
            NSLog(@"Main Thread");
            [self performSegueWithIdentifier:@"segueToOnyxResult" sender:onyxResult];
        }];
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

- (IBAction)capture:(UIButton *)sender {
    OnyxConfigurationBuilder* onyxConfigBuilder = [[OnyxConfigurationBuilder alloc] init];
    onyxConfigBuilder.setViewController(self)
    .setLicenseKey(@"9634-1468-8960-1-2")
    .setUseManualCapture(false)
    .setReturnRawImage(true)
    .setReturnProcessedImage(true)
    .setReturnEnhancedImage(true)
    .setReturnWSQ(true)
    .setImageRotation(90)
    .setReturnFingerprintTemplate(true)
    .setReturnISOFingerprintTemplate(true)
    .setShowLoadingSpinner(true)
    .setReturnBlackWhiteProcessedImage(true)
    .setSuccessCallback([self onyxSuccessCallback])
    .setErrorCallback([self onyxErrorCallback])
    .setOnyxCallback([self onyxCallback]);
    
    [onyxConfigBuilder buildOnyxConfiguration];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueToOnyxResult"]) {
        OnyxResultViewController* orvc = segue.destinationViewController;
        orvc.onyxResult = sender;
    }
}

@end
