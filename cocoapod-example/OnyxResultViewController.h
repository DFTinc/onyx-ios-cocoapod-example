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
@property (strong, nonatomic) IBOutlet UIImageView* rawImage1;
@property (strong, nonatomic) IBOutlet UIImageView* rawImage2;
@property (strong, nonatomic) IBOutlet UIImageView* rawImage3;
@property (strong, nonatomic) IBOutlet UIImageView* rawImage4;
@property (strong, nonatomic) IBOutlet UIImageView* grayRawImage1;
@property (strong, nonatomic) IBOutlet UIImageView* grayRawImage2;
@property (strong, nonatomic) IBOutlet UIImageView* grayRawImage3;
@property (strong, nonatomic) IBOutlet UIImageView* grayRawImage4;
@property (strong, nonatomic) IBOutlet UIImageView* processedImage1;
@property (strong, nonatomic) IBOutlet UIImageView* processedImage2;
@property (strong, nonatomic) IBOutlet UIImageView* processedImage3;
@property (strong, nonatomic) IBOutlet UIImageView* processedImage4;
@property (strong, nonatomic) IBOutlet UIImageView* enhancedImage1;
@property (strong, nonatomic) IBOutlet UIImageView* enhancedImage2;
@property (strong, nonatomic) IBOutlet UIImageView* enhancedImage3;
@property (strong, nonatomic) IBOutlet UIImageView* enhancedImage4;
@property (strong, nonatomic) IBOutlet UIImageView* blackWhiteImage1;
@property (strong, nonatomic) IBOutlet UIImageView* blackWhiteImage2;
@property (strong, nonatomic) IBOutlet UIImageView* blackWhiteImage3;
@property (strong, nonatomic) IBOutlet UIImageView* blackWhiteImage4;
@property (strong, nonatomic) IBOutlet UITextView* detailTextView;
@property NSData* rawGrayWSQData1;
@property NSData* rawGrayWSQData2;
@property NSData* rawGrayWSQData3;
@property NSData* rawGrayWSQData4;
@property NSData* WSQData1;
@property NSData* WSQData2;
@property NSData* WSQData3;
@property NSData* WSQData4;
@property NSMutableArray* onyxResults;
@property NSString* side;

- (IBAction)save:(id)sender;

@end
