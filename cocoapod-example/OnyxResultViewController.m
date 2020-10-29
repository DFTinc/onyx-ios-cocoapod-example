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
    OnyxResult* _onyxResult = _onyxResults[0];
    NSLog(@"onyxResults %lu", (unsigned long) [_onyxResults count]);
    _rawImage1.image = [_onyxResult getRawFingerprintImage]; // _onyxResult.rawFingerprintImage;
    _processedImage1.image = [_onyxResult getProcessedFingerprintImage]; // _onyxResult.processedFingerprintImage;
    _enhancedImage1.image = [_onyxResult getEnhancedFingerprintImage]; // _onyxResult.enhancedFingerprintImage;
    _grayRawImage1.image = [_onyxResult getGrayRawFingerprintImage]; // _onyxResult.grayRawFingerprintImage;
    _blackWhiteImage1.image = [_onyxResult getBlackWhiteProcessedFingerprintImage]; // _onyxResult.blackWhiteFingerprintImage;
    
    _WSQData1 = [_onyxResult getWsqData]; // _onyxResult.wsqData;
    _rawGrayWSQData1 = [_onyxResult getGrayRawWsqData]; // _onyxResult.rawGrayWsqData;
    
    int nfiqScore = [[[_onyxResult getMetrics] getNfiqMetrics] getNfiqScore]; //_onyxResult.captureMetrics.nfiqMetrics.nfiqScore;
    float mlpScore = [[[_onyxResult getMetrics] getNfiqMetrics] getMlpScore]; //_onyxResult.captureMetrics.nfiqMetrics.mlpScore;
    float focusQuality = [[_onyxResult getMetrics] getFocusQuality]; //_onyxResult.captureMetrics.focusQuality;
    float focusMeasure = [[_onyxResult getMetrics] getDistanceToCenter]; //_onyxResult.captureMetrics.distanceToCenter;
    float livenessConfidence = [[_onyxResult getMetrics] getLivenessConfidence]; // _onyxResult.captureMetrics.livenessConfidence;
    _side = [[_onyxResult getMetrics] side];
    NSString *resultText = [NSString stringWithFormat:@"returnFingerprintTemplate: %s\nreturnISOFingerprintTemplate: %s\nreturnWSQ: %s\nreturnGrayRawWSQ: %s\nnfiqScore: %d\nmplScore: %f\nfocusQuality: %f\nfocusMesaure: %f\nhandSide: %@", [_onyxResult getFingerprintTemplate] ? "true":"false", [_onyxResult getISOFingerprintTemplate] ? "true":"false", [_onyxResult getWsqData] ? "true":"false", [_onyxResult getGrayRawWsqData] ? "true":"false",nfiqScore, mlpScore, focusQuality, focusMeasure, _side];
    if (livenessConfidence != -1) {
        resultText = [resultText stringByAppendingString:[NSString stringWithFormat:@"\nlivenessConfidence: %f", livenessConfidence]];
    }
    _detailTextView.text = resultText;
    
    if (nil != _onyxResult.fingerprintTemplate && nil != _onyxResult.processedFingerprintImage) {
        double matchScore = [OnyxMatch pyramidMatch:[_onyxResult getFingerprintTemplate] withImage:[_onyxResult getProcessedFingerprintImage] scales:[NSArray arrayWithObjects:@"0.6", @"0.8", @"1.0", @"1.2", @"1.4",nil]];
        NSLog(@"Match score: %f", matchScore);
    }
}

- (IBAction)save:(id)sender {
    for (OnyxResult* _onyxResult in _onyxResults) {
    UIImageWriteToSavedPhotosAlbum([_onyxResult getRawFingerprintImage], nil, nil, nil);
    UIImageWriteToSavedPhotosAlbum([_onyxResult getGrayRawFingerprintImage], nil, nil, nil);
    UIImageWriteToSavedPhotosAlbum([_onyxResult getProcessedFingerprintImage], nil, nil, nil);
    UIImageWriteToSavedPhotosAlbum([_onyxResult getEnhancedFingerprintImage], nil, nil, nil);
    UIImageWriteToSavedPhotosAlbum([_onyxResult getBlackWhiteProcessedFingerprintImage], nil, nil, nil);
    }
    NSString *docsDir;
    NSArray *dirPaths;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"rawGrayWSQ.wsq"]];
    [_rawGrayWSQData1 writeToFile:databasePath atomically:YES];
    NSString *moreDatabasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"WSQ.wsq"]];
    [_WSQData1 writeToFile:moreDatabasePath atomically:YES];
}

@end

