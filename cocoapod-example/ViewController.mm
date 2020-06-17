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

-(void(^)(NSMutableArray* onyxResults))onyxSuccessCallback {
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

- (IBAction)capture:(UIButton *)sender {
    OnyxConfigurationBuilder* onyxConfigBuilder = [[OnyxConfigurationBuilder alloc] init];
    onyxConfigBuilder.setViewController(self)
    .setLicenseKey(@"5844-3213-7705-1-2")
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
        orvc.onyxResults = sender;
    }
}

@end
