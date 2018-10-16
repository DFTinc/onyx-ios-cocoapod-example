//
//  OnyxResultViewController.h
//  cocoapod-example
//
//  Created by Matthew Wheatley on 10/15/18.
//  Copyright © 2018 Diamond Fortress Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface OnyxResultViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView* rawImage;
@property (strong, nonatomic) IBOutlet UIImageView* grayRawImage;
@property (strong, nonatomic) IBOutlet UIImageView* processedImage;
@property (strong, nonatomic) IBOutlet UIImageView* enhancedImage;
@property (strong, nonatomic) IBOutlet UIImageView* blackWhiteImage;
@property (strong, nonatomic) IBOutlet UITextView* detailTextView;
@property NSData* rawGrayWSQData;
@property NSData* WSQData;
@property OnyxResult* onyxResult;

- (IBAction)save:(id)sender;

@end
