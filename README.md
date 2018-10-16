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
pod 'OnyxCamera', '~> 5.0.1'
```

```
# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'onyx-cocoapod-example' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  # use_frameworks!

  # Pods for cocoapod-example
    pod 'OnyxCamera', '~> 5.0.1'
end
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

* Add a property to hold the `OnyxResult`

```
@property OnyxResult* onyxResult;
```

* Define the required asynchronous callbacks

```
-(void(^)(OnyxResult* onyxResult))onyxSuccessCallback;

-(void(^)(OnyxError* onyxError)) onyxErrorCallback;

-(void(^)(Onyx* configuredOnyx))onyxCallback;
```

### ViewController.mm
* Change the file extension of `ViewController.m` to `ViewController.mm`
* Implement the required Onyx callbacks

```
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
            // Uncomment this later when ready to handle OnyxResult
            //[self performSegueWithIdentifier:@"segueToOnyxResult" sender:onyxResult];
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
        }];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ONYX Error"
            message:[NSString stringWithFormat:@"ErrorCode: %d, ErrorMessage:%@, Error:%@", onyxError.error, onyxError.errorMessage, onyxError.exception]
            delegate:nil
            cancelButtonTitle:@"OK"
            otherButtonTitles:nil];
        [alert show];
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
    .setReturnRawImage(true)
    .setReturnGrayRawImage(true)
    .setReturnProcessedImage(true)
    .setReturnBlackWhiteProcessedImage(true)
    .setReturnEnhancedImage(true)
    .setSuccessCallback([self onyxSuccessCallback])
    .setErrorCallback([self onyxErrorCallback])
    .setOnyxCallback([self onyxCallback]);

    [onyxConfigBuilder buildOnyxConfiguration];
```

* Your application should be able to run and successfully capture a fingerprint at this point.  Next we will handle the `OnyxResult`.

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
```
* Edit `OnyxResultViewController.m` to contain the following

```
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
        orvc.onyxResult = sender;
    }
}
```

* Uncomment the segue code in the `onyxSuccessCallback`

```
[self performSegueWithIdentifier:@"segueToOnyxResult" sender:onyxResult];
```

* Add `Labels` and `UIImageViews` for all the images to be displayed, a `Text View` to display metrics, and a save button.
* Wire up the storyboard elements to `OnyxResultViewController.h` using the `Assistant Editor`.
    * Control-click on the storyboard element and connect it to the corresponding element in `OnyxResultViewController.h`.

