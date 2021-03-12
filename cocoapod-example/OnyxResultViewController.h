//
//  OnyxResultViewController.h
//  cocoapod-example
//
//  Created by Matthew Wheatley on 10/15/18.
//  Copyright © 2018 Diamond Fortress Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "iCarousel.h"
#import <MessageUI/MessageUI.h>

@interface OnyxResultViewController : UIViewController <iCarouselDataSource, iCarouselDelegate, MFMailComposeViewControllerDelegate>

@property OnyxResult *onyxResult;
@property (nonatomic, weak) IBOutlet UIStackView *livenessStackView;
@property (nonatomic, weak) IBOutlet UITextView *livenessTextView;
@property (nonatomic, weak) IBOutlet UIStackView *processedStackView;
@property (nonatomic, weak) IBOutlet iCarousel *processedCarousel;
@property (nonatomic, weak) IBOutlet UIStackView *rawStackView;
@property (nonatomic, weak) IBOutlet iCarousel *rawCarousel;

- (IBAction)save:(id)sender;

@end
