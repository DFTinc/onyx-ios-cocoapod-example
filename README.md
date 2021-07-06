# Onyx CocoaPod Example

Clone the repository
```
git clone https://github.com/DFTinc/onyx-ios-cocoapod-example.git
```

Change directories to the project and install the CocoaPod dependencies
```
cd onyx-ios-cocoapod-example
```
```
pod install
```
* Open the new workspace that was created `onyx-cocoapod-example.xcworkspace`

***NOTE***

OnyxCamera cocoapod 7.0.1 now implements the latest ONYX four finger simultaneous capture process you will see a breaking change from the previous single finger capture cocoapods. ONYX no longer returns a single OnyxResult file it returns an array of files representing each individual fingerprint and is now denoted as
```
onyxResults
```
You will see 
```
onyxResults
```
referenced below in the implementation sections, so if you have previously implmented the OnyxCamera cocoapod for single finger capture, please pay special attention to this README to implement the changes.


## Requirements
- Minimum iOS Deployment Target 9.0
- xCode 11 & 12

## Known issues
### Archiving app with iOS Deployment Target 9.x OR 10.x will fail. 
Reason: OnyxCamera fails to archive app with "armv7" architecture included.

Solution A:
Set Minimum Deployment Target to >= 11.0

Solution B: 
STEP 1: xCode -> App Target -> Build Settings -> set "YES" to "Build Active Architectures Only [Release]"
STEP 2: plug in your iOS device -> select "Your iOS device" as build target (instead of "Any iOS Device (arm64, armv7))
STEP 3: Archive app

### 3 files must be added manually into your project project:

1. Select your xcodeproj file from the naviagtion pane on the left
2. Select "Build Phases"
3. Expaned "Copy Bunde Resources"
4. Click the "+"
5. Click "Add Other..."
6. A Finder window will launch
7. Navigate to Pods/OnyxCamera/OnyxCamera/Assets/ source the resource files from here

```
onyx_4f_logo_v2.png
onyx_4f_logo_v2@2x.png
capture_unet_nn_quant.tflite
```

## How to integrate OnyxCamera CocoaPod

* Open Xcode and create a new project
    * File > New > Project...
    * Single View App > Next
        * Product Name: `onyx-cocoapod-example`
        * Language: `Objective-C`
        * Next
            * Select location of new project
            * Create

* Open `Terminal` and navigate to the root directory of the new project

```
cd path/to/onyx-cocoapod-example
```

* Create a Podfile

```
pod init
```

* Open the new workspace that was created `onyx-cocoapod-example.xcworkspace`

* Add the Podfile to the project
    * Right-click on the root project `onyx-cocoapod-example`
    * Add files to "onyx-cocoapod-example"...
    * Select the Podfile

* Add the `OnyxCamera` cocoapod to the Podfile

```
pod 'OnyxCamera', '~> 7.0.1'
```

```
# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'onyx-cocoapod-example' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  # use_frameworks!

  # Pods for cocoapod-example
    pod 'OnyxCamera', '~> 7.0.1'
end
```

* Add 3 files to your project. 

1. Select your xcodeproj file from the naviagtion pane on the left
2. Select "Build Phases"
3. Expand "Copy Bunde Resources"
4. Click the "+"
5. Click "Add Other..."
6. A Finder window will launch
7. Navigate to Pods/OnyxCamera/OnyxCamera/Assets/ source the resource files from here

```
onyx_4f_logo_v2.png
onyx_4f_logo_v2@2x.png
capturenet.tflite
qualitynet.tflite
```

Otherwise the OnyxCamera will crash!

* Change the #import path for TFLTensorFlowLite.h in CaptureNetController.h

Navigate to the "Pods" Project area of your workspace NOT the "Pods" driectory in your project section of your project.

Expand the "Pods" area, then expand Pods/OnyxCamera/Frameworks/OnyxCamera.framework/Headers and open CaptureNetController.h

Change
```
#import <TensorFlowLiteObjC/TFLTensorFlowLite.h>
```
to
```
#import <TFLTensorFlowLite.h>
```

* Disable Bitcode
    * Select the root directory and go to `Build Settings`
    * Search for `bitcode`
    * Set `Enable Bitcode` to `No`

* Run you project on a device

## How to implement Onyx

### Add usage descriptions for requested permissions to `Info.plist`
* Right-click on `Info.plist` > Open As > Source Code
* Paste the following lines at the bottom of the `<dict>` element

```
<key>NSCameraUsageDescription</key>
<string>Capture fingerprint image</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save Onyx Image Results</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Save Pictures</string>
```

### ViewController.h
* Import the `OnyxCamera` headers

```
#import <OnyxCamera/OnyxConfigurationBuilder.h>
#import <OnyxCamera/Onyx.h>
```

* Add a property to hold the `onyxResults`

```
@property NSMutableArray* onyxResults;
```

* Define the required asynchronous callbacks

```
-(void(^)(NSMutableArray* onyxResults))onyxSuccessCallback;

-(void(^)(OnyxError* onyxError)) onyxErrorCallback;

-(void(^)(Onyx* configuredOnyx))onyxCallback;
```

### ViewController.mm
* Change the file extension of `ViewController.m` to `ViewController.mm`
* Implement the required Onyx callbacks

```
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
```

* Create a button to launch the Onyx.
* Connect the button's action to the ViewController

```
- (IBAction)capture:(UIButton *)sender {

}
```

* The capture method should build and create an `OnyxConfigurationBuilder`.
```
OnyxConfigurationBuilder* onyxConfigBuilder = [[OnyxConfigurationBuilder alloc] init];
    onyxConfigBuilder.setViewController(self)
    .setLicenseKey(@"onyx-license-key-goes-here")
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

    [onyxConfigBuilder buildOnyxConfiguration];
```

* Your application should be able to run and successfully capture a fingerprint at this point.  Next we will handle the `onyxResults`.

### OnyxResult

* Create a new `OnyxResultViewController` to display the imagery and save the images.
    * Right-click the directory containing your `ViewController` files > New File...
        * Select `Header File` > Next
            * Save As: OnyxResultViewController.h
            * Select the project as a target: `onyx-cocoapod-example`
            * Create
    * Right-click the directory containing your `ViewController` files > New File...
        * Select `Objective-C File` > Next
            * File: `OnyxResultViewController
            * File Type: `Empty File`
            * Create

* Edit `OnyxResultViewController.h` to contain the following

```
#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface OnyxResultViewController : UIViewController

@property OnyxResult *onyxResult;
@property (nonatomic, weak) IBOutlet UIStackView *livenessStackView;
@property (nonatomic, weak) IBOutlet UITextView *livenessTextView;
@property (nonatomic, weak) IBOutlet UIStackView *processedStackView;
@property (nonatomic, weak) IBOutlet iCarousel *processedCarousel;
@property (nonatomic, weak) IBOutlet UIStackView *rawStackView;
@property (nonatomic, weak) IBOutlet iCarousel *rawCarousel;

- (IBAction)save:(id)sender;

@end
```
* Edit `OnyxResultViewController.m` to contain the following

```
#import <Foundation/Foundation.h>
#import "OnyxResultViewController.h"
#import <OnyxCamera/OnyxMatch.h>

@interface OnyxResultViewController ()


@end

@implementation OnyxResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
	if (_onyxResult) {
        
        // Processed Images (1 or 4 or none)
        NSMutableArray *processedImages = [_onyxResult getProcessedFingerprintImages];
        if (processedImages && [processedImages count] > 0) {
        	for (UIImage *image in processedImages) {
        	    // Your code here... example: myImageViews[0].image = image;
        	    
        	    // Metrics
    			NSString *nfiqText = nil;
				NSMutableArray* nfiqMetrics = [[_onyxResult getMetrics] getNfiqMetrics];
				if (nfiqMetrics) {
		
					if (index < [nfiqMetrics count]) {
						int nfiqScoreFingerprint = [nfiqMetrics[index] getNfiqScore];
						nfiqText = [NSString stringWithFormat:@"Finger %d\nNFIQ Score: %d", (int)index+1, nfiqScoreFingerprint];
						label.text = nfiqText;
					}
				}

        	}
            self.processedCarousel.hidden = NO;
        } else {
            self.processedCarousel.hidden = YES;
        }
        
        // Raw Images (1 or 4 or none)
        NSMutableArray *rawImages = [_onyxResult getRawFingerprintImages];
        if (rawImages && [rawImages count] > 0) {
            self.rawStackView.hidden = NO;
            // Your code here... example: myImageViews[0].image = image;
        } else {
            self.rawStackView.hidden = YES;
        }
        
        // Templates - example: get "Match score" for first finger in array of Templates
		NSMutableArray* fingerprintTemplates = [_onyxResult getFingerprintTemplates];
		if (fingerprintTemplates && [fingerprintTemplates count] != 0 && [[_onyxResult getProcessedFingerprintImages] count] != 0) {
			double matchScore = [OnyxMatch pyramidMatch:fingerprintTemplates[0]
											  withImage:[[_onyxResult getProcessedFingerprintImages] objectAtIndex:0]
												 scales:[NSArray arrayWithObjects:@"0.6", @"0.8", @"1.0", @"1.2", @"1.4",nil]];
			NSLog(@"Match score: %f", matchScore);
		}
        
        // Liveness Confidence
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
        
    }

}

@end
```

* Update `Main.storyboard`
    * Create a Navigation Controller to navigate between the capture screen and the result screen
        * Open the `Library` and search for `Navigation Controller`
        * Drag and drop a `Naigation Controller` onto the Storyboard
        * Move the `Storyboard Entry Point` to the `Navigation Controller`
        * Delete the default `Root Controller`
        * Control-click on the `Navigation Controller` and click on the `ViewController` and set the `Relationship Segue` to `root view controller`
        * Give the `Navigation Item` a  title in the `Attributes Inspector`: Onyx CocoaPod Example

    * Add a `View Controller` to display the `OnyxResult` information.
        * From the `Library` search for `View Controller` and drag the element onto the Storyboard.
        * Select the `Identity Inspector` for the new view controller and update the `Class` to `OnyxResultViewController`
        * From the `Library` search for `Navigation Item` and add one to the `OnyxResultViewController`
        * Select the `Attribute Inspector` and give it a `Title` of **Onyx Result**

    * Create a segue to navigate to the result page
        * Control-click from `ViewController` to `OnyxResultViewController` to create a segue
            * Select `Show` under `Manual Segue`
            * Give the segue an ID
                * Select the segue `Show segue to "Onyx Result View Controller"`
                * Go to the `Attributes Inspector` and give the segue an Identifier of `segueToOnyxResult`

* Import `OnyxResultViewController.h` in `ViewController.mm`

```
#import "OnyxResultViewController.h"
```

* Implement the segue in `ViewController.mm`

```
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueToOnyxResult"]) {
        OnyxResultViewController* orvc = segue.destinationViewController;
        orvc.onyxResults = sender;
    }
}
```


* Add `Labels` for metrics and `UIImageViews` for all the images to be displayed, a `Text View` to display liveness confidence, and a save button.
* Wire up the storyboard elements to `OnyxResultViewController.h` using the `Assistant Editor`.
    * Control-click on the storyboard element and connect it to the corresponding element in `OnyxResultViewController.h`.

