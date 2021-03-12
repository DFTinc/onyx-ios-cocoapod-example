//
//  OnyxResultViewController.m
//  cocoapod-example
//
//  Created by Matthew Wheatley on 10/15/18.
//  Copyright © 2018 Diamond Fortress Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnyxResultViewController.h"
#import <OnyxCamera/OnyxMatch.h>

@interface OnyxResultViewController ()


@end

@implementation OnyxResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Image Carousel Setup
    self.rawCarousel.delegate = self;
    self.rawCarousel.dataSource = self;
    self.rawCarousel.type = iCarouselTypeCoverFlow;
    self.rawCarousel.pagingEnabled = YES;
    self.rawCarousel.scrollSpeed = 0.66f;
    self.rawCarousel.decelerationRate = 0.33f;
    self.rawCarousel.clipsToBounds = NO;
    self.rawCarousel.backgroundColor = [UIColor clearColor];
    
    self.processedCarousel.delegate = self;
    self.processedCarousel.dataSource = self;
    self.processedCarousel.type = iCarouselTypeCoverFlow;
    self.processedCarousel.pagingEnabled = YES;
    self.processedCarousel.scrollSpeed = 0.66f;
    self.processedCarousel.decelerationRate = 0.33f;
    self.processedCarousel.clipsToBounds = NO;
    self.processedCarousel.backgroundColor = [UIColor clearColor];
    
    if (_onyxResult) {
        
        // Processed Images (1 or 4 or none)
        if ([_onyxResult getProcessedFingerprintImages] && [[_onyxResult getProcessedFingerprintImages] count] > 0) {
            self.processedCarousel.hidden = NO;
        } else {
            self.processedCarousel.hidden = YES;
        }
        
        // Raw Images (1 or 4 or none)
        NSMutableArray *rawImages = [_onyxResult getRawFingerprintImages];
        if (rawImages && [rawImages count] > 0) {
            self.rawStackView.hidden = NO;
        } else {
            self.rawStackView.hidden = YES;
        }
        
        // Get Liveness Confidence
        if ([_onyxResult getMetrics]) {
            float livenessConfidence = [[_onyxResult getMetrics] getLivenessConfidence];
            if (livenessConfidence != -1) {
                self.livenessTextView.text = [NSString stringWithFormat:@"Liveness Confidence: %f", livenessConfidence];
                self.livenessStackView.hidden = NO;
            } else {
                self.livenessTextView.text = @"";
                self.livenessStackView.hidden = YES;
            }
        }
    }

}
    
#pragma mark - Actions

- (IBAction)save:(id)sender {
    if (_onyxResult) {
        
        if ([_onyxResult getProcessedFingerprintImages] && [[_onyxResult getProcessedFingerprintImages] count] > 0) {
            NSMutableArray *images = [_onyxResult getProcessedFingerprintImages];
            for (UIImage *image in images) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            }
        }
        
        if ([_onyxResult getRawFingerprintImages] && [[_onyxResult getRawFingerprintImages] count] > 0) {
            NSMutableArray *images = [_onyxResult getRawFingerprintImages];
            for (UIImage *image in images) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            }
        }
        
        // Save WSQ & Template as File
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask, YES);
        NSString *docsDir = [dirPaths objectAtIndex:0];

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd-MM-yyyy-HH-mm-ss"];
        NSDate *currentDate = [NSDate date];
        NSString *dateString = [formatter stringFromDate:currentDate];

        // Save WSQ
        if ([_onyxResult getWsqData]) {
            NSMutableArray* wsqData = [_onyxResult getWsqData];
            if (wsqData && [wsqData count] > 0) {
                for (int i=0; i<wsqData.count; i++) {
                    NSData *wsq = [wsqData objectAtIndex:i];
                    NSString *filename = [NSString stringWithFormat:@"%@-wsq-%d.wsq",dateString,i+1];
                    NSString *filePath = [docsDir stringByAppendingPathComponent:filename];
                    [wsq writeToFile:filePath atomically:YES];
                }

            }
        }

        // Save Template
        if ([_onyxResult getWsqData]) {
            NSMutableArray* templateData = [_onyxResult getFingerprintTemplates];
            if (templateData && [templateData count] > 0) {
                for (int i=0; i<templateData.count; i++) {
                    NSData *data = [templateData objectAtIndex:i];
                    NSString *filename = [NSString stringWithFormat:@"%@-template-%d.txt",dateString,i+1];
                    NSString *filePath = [docsDir stringByAppendingPathComponent:filename];
                    [[data base64EncodedDataWithOptions:NSUTF8StringEncoding] writeToFile:filePath atomically:YES];

                }

            }
        }
        
        /*
         * Legacy
        */
        //        // Save Enhanced
        //        if ([_onyxResult getEnhancedFingerprintImages]) {
        //            NSMutableArray *images = [_onyxResult getEnhancedFingerprintImages];
        //            for (UIImage *image in images) {
        //                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        //            }
        //        }
        //
        //        // Save Back-White
        //        if ([_onyxResult getEnhancedFingerprintImages]) {
        //            NSMutableArray *images = [_onyxResult getBlackWhiteProcessedFingerprintImages];
        //            for (UIImage *image in images) {
        //                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        //            }
        //        }
        //
        
    }

}
- (IBAction)emailResults:(id)sender {
    if (!_onyxResult) return;
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    
    if (mailClass != nil) {
        
        // Test to ensure that device is configured for sending emails.
        if ([mailClass canSendMail]) {
            
            // Date string for files
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"dd-MM-yyyy-HH-mm-ss"];
            NSDate *currentDate = [NSDate date];
            NSString *dateString = [formatter stringFromDate:currentDate];
            
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            [picker setSubject:[NSString stringWithFormat:@"Onyx Results: %@", dateString]];
            
            NSString *emailBody = [NSString stringWithFormat:@""];
            
            // Attach Processed
            NSMutableArray *processedData = [_onyxResult getProcessedFingerprintImages];
            if (processedData && [processedData count] > 0) {

                for (int i=0; i<processedData.count; i++) {
                    UIImage *image = [processedData objectAtIndex:i];
                    NSData *data = UIImagePNGRepresentation(image);
                    NSString *filename = [NSString stringWithFormat:@"%@-processed-%d.png",dateString,i+1];
                    [picker addAttachmentData:data
                                     mimeType:@"image/png"
                                     fileName:filename];

                }
            }

            // Attach Raw
            NSMutableArray *rawData = [_onyxResult getRawFingerprintImages];
            if (rawData && [rawData count] > 0) {

                for (int i=0; i<rawData.count; i++) {
                    UIImage *image = [rawData objectAtIndex:i];
                    NSData *data = UIImagePNGRepresentation(image);
                    NSString *filename = [NSString stringWithFormat:@"%@-raw-%d.png",dateString,i+1];
                    [picker addAttachmentData:data
                                     mimeType:@"image/png"
                                     fileName:filename];

                }
            }
            
            // Attach WSQ
            NSMutableArray *wsqData = [_onyxResult getWsqData];
            if (wsqData && [wsqData count] > 0) {
                
                for (int i=0; i<wsqData.count; i++) {
                    NSData *data = [wsqData objectAtIndex:i];
                    NSString *filename = [NSString stringWithFormat:@"%@-wsq-%d.wsq",dateString,i+1];
                    [picker addAttachmentData:[data base64EncodedDataWithOptions:NSUTF8StringEncoding]
                                     mimeType:@"text/txt"
                                     fileName:filename];
                
                }
            }
            
            // Attach Template
            NSMutableArray *templateData = [_onyxResult getFingerprintTemplates];
            if (templateData && [templateData count] > 0) {
                
                for (int i=0; i<templateData.count; i++) {
                    NSData *data = [templateData objectAtIndex:i];
                    NSString *filename = [NSString stringWithFormat:@"%@-template-%d.txt",dateString,i+1];
                    [picker addAttachmentData:[data base64EncodedDataWithOptions:NSUTF8StringEncoding]
                                     mimeType:@"text/txt"
                                     fileName:filename];
                
                }
            }
            
            [picker setMessageBody:emailBody isHTML:NO];
            [self presentViewController:picker animated:YES completion:nil];
            [self resignFirstResponder];
            
        }
        else {
            // Device is not configured for sending emails, so notify user.
            NSLog(@"Error: Mail app is not configured!");
        }
    }
}
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    NSString *resultTitle = nil;
    
    switch (result) {
        case MFMailComposeResultCancelled:
            resultTitle = @"Email cancelled";
            break;
        case MFMailComposeResultSaved:
            resultTitle = @"Email saved as a draft";
            break;
        case MFMailComposeResultSent:
            resultTitle = @"Your email was delivered. Thank you!";
            break;
        case MFMailComposeResultFailed:
            resultTitle = @"Mail Composer failed. Please try again.";
            break;
        default: resultTitle = @"Email could not sent";
            break;
    }
    
    // Notifies user of any Mail Composer errors received.
    [self showMessage:resultTitle];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)showMessage:(NSString *)message{
    
    // Message Label for showing confirmation and status messages
    CGFloat yLabelViewOffset = self.view.bounds.size.height;
    
    UIView *messageView = [[UIView alloc] initWithFrame:CGRectMake(0, yLabelViewOffset, self.view.bounds.size.width, 50)];
    messageView.backgroundColor = [UIColor lightGrayColor];
    
    UIView *messageInsetView = [[UIView alloc] initWithFrame:CGRectMake(1, 1, self.view.bounds.size.width-1, 50)];
    messageInsetView.backgroundColor = [UIColor colorWithRed:255.0/255.0
                                                       green:248.0/255.0
                                                        blue:228.0/255.0
                                                       alpha:1];
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 1, self.view.bounds.size.width-10, 50)];
    messageLabel.text = @"";
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0
                                                   green:248.0/255.0
                                                    blue:228.0/255.0
                                                   alpha:0.6];
    [messageInsetView addSubview:messageLabel];
    [messageView addSubview:messageInsetView];
    messageView.hidden = YES;
    [self.view addSubview:messageView];
    messageLabel.text = message;
    messageView.hidden = NO;
    
    // Hide activity indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // Use animation to show the message from the bottom then hide it.
    [UIView animateWithDuration:0.5
                          delay:1.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = messageView.frame;
                         frame.origin.y -= frame.size.height;
                         messageView.frame = frame;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.5
                                               delay:3.0
                                             options: UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              CGRect frame = messageView.frame;
                                              frame.origin.y += frame.size.height;
                                              messageView.frame = frame;
                                          }
                                          completion:^(BOOL _finished){
                                              messageView.hidden = YES;
                                              messageLabel.text = @"";
                                          }];
                     }
     ];
}

#pragma mark - iCarousel

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    
    if (_onyxResult == nil) return 0;
    
    if (carousel == self.rawCarousel) {
        return [[_onyxResult getRawFingerprintImages] count];
    }
    else if (carousel == self.processedCarousel) {
        return [[_onyxResult getProcessedFingerprintImages] count];
    }
    
    return 0;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    
    if (_onyxResult == nil) return view;

    NSArray *covers = nil;
    UIStackView *parentStackView = nil;
    if (carousel == self.rawCarousel) {
        covers = [_onyxResult getRawFingerprintImages];
        parentStackView = self.rawStackView;
    }
    else if (carousel == self.processedCarousel) {
        covers = [_onyxResult getProcessedFingerprintImages];
        parentStackView = self.processedStackView;
    }
    
    if (!covers || index >= covers.count) {
        return view;
    }
    
    UILabel *label = nil;
    if (view == nil) {
        UIImage *img = [covers objectAtIndex:index];
        float width = img.size.width;
        float height = img.size.height;
        float ratio = width / height;
        
        float desiredHeight = parentStackView.frame.size.height - 30;
        float caclulatedWidth = desiredHeight * ratio;
        
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, caclulatedWidth,desiredHeight)];
        view.contentMode = UIViewContentModeScaleAspectFit;
        view.layer.masksToBounds = NO;
        view.layer.cornerRadius = 2.0;
        view.layer.borderWidth = 1;
        view.layer.borderColor = [UIColor darkGrayColor].CGColor;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(8, desiredHeight, caclulatedWidth - 8, 30)];
        label.textColor = [UIColor blackColor];
        //label.backgroundColor = [UIColor greenColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.alpha = 1.0f;
        label.minimumScaleFactor = 0.35;
        label.numberOfLines = 0;
        label.adjustsFontSizeToFitWidth = YES;
        [view addSubview:label];
        
    } else {
        label = [[view subviews] lastObject];
    }
    

    // NFIQ Metrics
    NSString *nfiqText = nil;
    NSMutableArray* nfiqMetrics = [[_onyxResult getMetrics] getNfiqMetrics];
    if (nfiqMetrics) {
        
        if (index < [nfiqMetrics count]) {
            int nfiqScoreFingerprint = [nfiqMetrics[index] getNfiqScore];
            nfiqText = [NSString stringWithFormat:@"Finger %d\nNFIQ Score: %d", (int)index+1, nfiqScoreFingerprint];
            label.text = nfiqText;
        }
    }
   
    
    
    // Templates
    NSMutableArray* fingerprintTemplates = [_onyxResult getFingerprintTemplates];
    if (fingerprintTemplates && [fingerprintTemplates count] != 0 && [[_onyxResult getProcessedFingerprintImages] count] != 0) {
        double matchScore = [OnyxMatch pyramidMatch:fingerprintTemplates[0]
                                          withImage:[[_onyxResult getProcessedFingerprintImages] objectAtIndex:0]
                                             scales:[NSArray arrayWithObjects:@"0.6", @"0.8", @"1.0", @"1.2", @"1.4",nil]];
        NSLog(@"Match score: %f", matchScore);
    }
    
    if (covers.count > 0 && [[covers objectAtIndex:index] isKindOfClass:[UIImage class]]) {
        ((UIImageView *)view).image = [[covers objectAtIndex:index] copy];
    }
    
    return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionSpacing:
        {
            return value * 1.05f;
        }
        default:
        {
            return value;
        }
    }
}
- (NSInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel {
    return 1;
}
- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSInteger)index reusingView:(UIView *)view {

    UILabel *label = nil;

    if (view == nil) {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, carousel.frame.size.width, carousel.frame.size.height)];
        view.contentMode = UIViewContentModeCenter;

        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        [view addSubview:label];
    } else {
        label = [[view subviews] lastObject];
    }

    label.text = @"";

    return view;
}
- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    
}

@end
