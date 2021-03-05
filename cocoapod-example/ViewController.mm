//
//  ViewController.m
//  cocoapod-example
//
//  Created by Matthew Wheatley on 10/15/18.
//  Copyright © 2018 Diamond Fortress Technologies, Inc. All rights reserved.
//

#import "ViewController.h"
#import "OnyxCamera/ProcessedFingerprint.h"
#import "OnyxCamera/OnyxResult.h"
#import <malloc/malloc.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void(^)(Onyx* configuredOnyx))onyxCallback {
    return ^(Onyx* configuredOnyx) {
        NSLog(@"Onyx Callback");
        [configuredOnyx capture:self];
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
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            //Your code goes in here
            NSLog(@"Main Thread");
//            [self stopSpinnner];
            
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"ONYX Error"
                                         message:[NSString stringWithFormat:@"ErrorCode: %d\nMessage:%@\nError:%@",
                                                  onyxError.error,
                                                  onyxError.errorMessage,
                                                  onyxError.exception]
                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okBtn = [UIAlertAction
                                        actionWithTitle:@"OK"
                                        style:UIAlertActionStyleCancel
                                        handler:nil];
            
            [alert addAction:okBtn];
            
            [self presentViewController:alert animated:YES completion:nil];
        }];
    };
}

- (IBAction)capture:(id)sender {
    OnyxConfigurationBuilder* onyxConfigBuilder = [[OnyxConfigurationBuilder alloc] init];
    onyxConfigBuilder.setViewController(self)
    .setLicenseKey(@"3969-9138-6246-1-2")
    .setShowLoadingSpinner(true)
    .setUseManualCapture(false)
    .setReturnRawImage(false)
    .setReturnProcessedImage(true)
    .setReturnEnhancedImage(false)
    .setReturnWSQ(false)
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
