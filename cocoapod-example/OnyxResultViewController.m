//
//  OnyxResultViewController.m
//  cocoapod-example
//
//  Created by Matthew Wheatley on 10/15/18.
//  Copyright © 2018 Diamond Fortress Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnyxResultViewController.h"

@interface OnyxResultViewController ()


@end

@implementation OnyxResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //        NSString* rawImageEncodedBytes = [_onyxResult.rawImageUri substringFromIndex:[IMAGE_URI_PREFIX length]];
    //        NSData* rawImageData = [[NSData alloc] initWithBase64EncodedString:rawImageEncodedBytes options:NSDataBase64DecodingIgnoreUnknownCharacters];
    //        UIImage* rawImage = [UIImage imageWithData:rawImageData];
    
    _rawImage.image = [_onyxResult getRawFingerprintImage]; // _onyxResult.rawFingerprintImage;
    _processedImage.image = [_onyxResult getProcessedFingerprintImage]; // _onyxResult.processedFingerprintImage;
    _enhancedImage.image = [_onyxResult getEnhancedFingerprintImage]; // _onyxResult.enhancedFingerprintImage;
    _grayRawImage.image = [_onyxResult getGrayRawFingerprintImage]; // _onyxResult.grayRawFingerprintImage;
    _blackWhiteImage.image = [_onyxResult getBlackWhiteProcessedFingerprintImage]; // _onyxResult.blackWhiteFingerprintImage;
    
    _WSQData = [_onyxResult getWsqData]; // _onyxResult.wsqData;
    _rawGrayWSQData = [_onyxResult getGrayRawWsqData]; // _onyxResult.grayRawWsqData;
    
    int nfiqScore = [[[_onyxResult getMetrics] getNfiqMetrics] getNfiqScore]; //_onyxResult.captureMetrics.nfiqMetrics.nfiqScore;
    float mlpScore = [[[_onyxResult getMetrics] getNfiqMetrics] getMlpScore]; //_onyxResult.captureMetrics.nfiqMetrics.mlpScore;
    float focusQuality = [[_onyxResult getMetrics] getFocusQuality]; //_onyxResult.captureMetrics.focusQuality;
    float focusMeasure = [[_onyxResult getMetrics] getDistanceToCenter]; //_onyxResult.captureMetrics.distanceToCenter;
    float livenessConfidence = [[_onyxResult getMetrics] getLivenessConfidence]; // _onyxResult.captureMetrics.livenessConfidence;
    
    NSString *resultText = [NSString stringWithFormat:@"returnFingerprintTemplate: %s\nreturnWSQ: %s\nreturnGrayRawWSQ: %s\nnfiqScore: %d\nmplScore: %f\nfocusQuality: %f\nfocusMesaure: %f", [_onyxResult getFingerprintTemplate] ? "true":"false", [_onyxResult getWsqData] ? "true":"false", [_onyxResult getGrayRawWsqData] ? "true":"false",nfiqScore, mlpScore, focusQuality, focusMeasure];
    if (livenessConfidence != -1) {
        resultText = [resultText stringByAppendingString:[NSString stringWithFormat:@"\nlivenessConfidence: %f", livenessConfidence]];
    }
    _detailTextView.text = resultText;
}

- (IBAction)save:(id)sender {
    UIImageWriteToSavedPhotosAlbum([_onyxResult getRawFingerprintImage], nil, nil, nil);
    UIImageWriteToSavedPhotosAlbum([_onyxResult getGrayRawFingerprintImage], nil, nil, nil);
    UIImageWriteToSavedPhotosAlbum([_onyxResult getProcessedFingerprintImage], nil, nil, nil);
    UIImageWriteToSavedPhotosAlbum([_onyxResult getEnhancedFingerprintImage], nil, nil, nil);
    UIImageWriteToSavedPhotosAlbum([_onyxResult getBlackWhiteProcessedFingerprintImage], nil, nil, nil);
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"rawGrayWSQ.wsq"]];
    [_rawGrayWSQData writeToFile:databasePath atomically:YES];
    NSString *moreDatabasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"WSQ.wsq"]];
    [_WSQData writeToFile:moreDatabasePath atomically:YES];
}

@end
