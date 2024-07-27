#import "Greyd00rStockLSView.h"
#import "Greyd00rStockLockScreen.h"

#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
//#import <sys/sysctl.h>
#import "NSData+Base64.h"

static inline BOOL isSlothSleeping(){
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
NSData* fileData = [NSData dataWithContentsOfFile:@"/var/mobile/Library/Greyd00r/ActivationKeys/com.greyd00r.installerInfo.plist"];
NSData* signatureData = [NSData dataWithContentsOfFile:@"/var/mobile/Library/Greyd00r/ActivationKeys/com.greyd00r.installerInfo.plist.sig"];
//Okay, this is technically not good to do, but it's even worse if I just include the bloody certificate on the device by default because then it just gets replaced easier. Same for keeping it in the keychain perhaps because it isn't sandboxed? Hide it in the binary they said, it will be safer, they said.
NSData* certificateData = [NSData dataFromBase64String:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",@"MIIC6jCCAdICCQC2Zs0BWO+dxzANBgkqhkiG9w0BAQsFADA3MQswCQYDVQQGEwJV",
@"UzERMA8GA1UECgwIR3JheWQwMHIxFTATBgNVBAMMDGdyYXlkMDByLmNvbTAeFw0x",
@"NTEwMjQyMzEzNTNaFw0yMTA0MTUyMzEzNTNaMDcxCzAJBgNVBAYTAlVTMREwDwYD",
@"VQQKDAhHcmF5ZDAwcjEVMBMGA1UEAwwMZ3JheWQwMHIuY29tMIIBIjANBgkqhkiG",
@"9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsWSkvU26FQlb/IOE/QWKSyt3L5ekj+uvdVQq",
@"Eljo35THov9qKSqTMhdgMGkWDCVnqHsgf0+LjHZcFfz+cI1++1bsHCxvhJvytvYx",
@"uRQmjh0+yAA28729dDCKhawQ5YLHbVC+4tHoyHhvK+Ww0mx+g7Y8bVh+qc1EBf6h",
@"VOrspUvoGHLQYAa15Wbca8mmXVpxuZVfviLskqffKtsPVe7EIx8WwzrI+v9GOXNi",
@"dR/rBJDU91u1AQc5BT9zAOFlLZq4VJLdNNWCs4w58f6260xDiUjMEAKzILhSjmN/",
@"Dys9McYE9Iu3lGPvFn2HCfOOgTg1sv3Hz/mogL5sbjvCCtQnrwIDAQABMA0GCSqG",
@"SIb3DQEBCwUAA4IBAQBLQ+66GOyKY4Bxn9ODiVf+263iLTyThhppHMRguIukRieK",
@"sVvngMd6BQU4N4b0T+RdkZGScpAe3fdre/Ty9KIt/9E0Xqak+Cv+x7xCzEbee8W+",
@"sAV+DViZVes67XXV65zNdl5Nf7rqGqPSBLwuwB/M2mwmDREMJC90VRJBFj4QK14k",
@"FuwtTpNW44NUSQRUIxiZM/iSwy9rqekRRAKWo1s5BOLM3o7ph002BDyFPYmK5UAN",
@"EM/aKFGVMMwhAUHjgej5iEPxPuks+lGY1cKUAgoxbvXJakybosgmDFfSN+DMT7ZU",
@"HbUgWDsLySwU8/+C4vDP0pmMqJFgrna9Wto49JNz"]];//[NSData dataWithContentsOfFile:@"/var/mobile/Library/Greyd00r/ActivationKeys/certificate.cer"];  

//SecCertificateRef certRef = SecCertificateFromPath(@"/var/mobile/Library/Greyd00r/ActivationKeys/certificate.cer");
//SecCertificateRef certificateFromFile = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certRef);



//SecKeyRef publicKey = SecKeyFromCertificate(certRef);

//recoverFromTrustFailure(publicKey);

if(fileData && signatureData && certificateData){


SecCertificateRef certificateFromFile = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData); // load the certificate

SecPolicyRef secPolicy = SecPolicyCreateBasicX509();

SecTrustRef trust;
OSStatus statusTrust = SecTrustCreateWithCertificates( certificateFromFile, secPolicy, &trust);
SecTrustResultType resultType;
OSStatus statusTrustEval =  SecTrustEvaluate(trust, &resultType);
SecKeyRef publicKey = SecTrustCopyPublicKey(trust);


//ONLY iOS6+ supports SHA256! >:(
uint8_t sha1HashDigest[CC_SHA1_DIGEST_LENGTH];
CC_SHA1([fileData bytes], [fileData length], (unsigned char*)sha1HashDigest);

OSStatus verficationResult = SecKeyRawVerify(publicKey,  kSecPaddingPKCS1SHA1,  (const uint8_t *)sha1HashDigest, (size_t)CC_SHA1_DIGEST_LENGTH,  (const uint8_t *)[signatureData bytes], (size_t)[signatureData length]);
CFRelease(publicKey);
CFRelease(trust);
CFRelease(secPolicy);
CFRelease(certificateFromFile);
[pool drain];
if (verficationResult == errSecSuccess){
  return TRUE;
}
else{
  return FALSE;
}



}
[pool drain];
return false;
}

//static OSStatus SecKeyRawVerify;
static inline BOOL isSlothAlive(){

if(!isSlothSleeping()){ //Don't want to pass this off as valid if the user didn't actually install via the grayd00r installer from the website.
  return FALSE;
}

NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

//Go from NSString to NSData
NSData *udidData = [[NSString stringWithFormat:@"%@-%@-%c%c%c%@-%@%c%c%@%@%c",[[UIDevice currentDevice] uniqueIdentifier],@"I",'l','i','k',@"e",@"s",'l','o',@"t",@"h",'s'] dataUsingEncoding:NSUTF8StringEncoding];
uint8_t digest[CC_SHA1_DIGEST_LENGTH];
CC_SHA1(udidData.bytes, udidData.length, digest);
NSMutableString *hashedUDID = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
//To NSMutableString to calculate hash

    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [hashedUDID appendFormat:@"%02x", digest[i]];
    }

//Then back to NSData for use in verification. -__-. I probably could skip a couple steps here...
NSData *hashedUDIDData = [hashedUDID dataUsingEncoding:NSUTF8StringEncoding];
NSData* signatureData = [NSData dataWithContentsOfFile:@"/var/mobile/Library/Greyd00r/ActivationKeys/com.greyd00r.activationKey"];

//Okay, this is technically not good to do, but it's even worse if I just include the bloody certificate on the device by default because then it just gets replaced easier. Same for keeping it in the keychain perhaps because it isn't sandboxed? Hide it in the binary they said, it will be safer, they said.
NSData* certificateData = [NSData dataFromBase64String:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",@"MIIDJzCCAg+gAwIBAgIJAPyR9ASSBbF9MA0GCSqGSIb3DQEBCwUAMCoxETAPBgNV",
@"BAoMCEdyYXlkMDByMRUwEwYDVQQDDAxncmF5ZDAwci5jb20wHhcNMTUxMDI4MDEy",
@"MjQyWhcNMjUxMDI1MDEyMjQyWjAqMREwDwYDVQQKDAhHcmF5ZDAwcjEVMBMGA1UE",
@"AwwMZ3JheWQwMHIuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA",
@"94OZ2u2gJfdWgqWKV7yDY5pJXLZuRho6RO2OJtK04Xg3gUk46GBkYLo+/Z33rOvs",
@"XA041oAINRmdaiTDRa5VbGitQMYfObMz8m0lHQeb4/wwOasRMgAT2WCcKVulwpCG",
@"C7PiotF3F85VAuqJsbu1gxjJaQGIgR2L35LTR/fQq3N5+2+bsc0wUbPcLk7uhyYJ",
@"tna+CYRc+3qGRsv/t8MYF0T7LU2xwCcGV0phmr3er5ocAj9X57i92zYGMPlz8kMZ",
@"HfXqMova0prF9vuN7mo54kY+SF2rp/G/v+u5MicONpXwY6adJ0eIuXFjqsUjKTi6",
@"4Bjzhvf+Z6O5TARJzdVMqwIDAQABo1AwTjAdBgNVHQ4EFgQUDBxB98iHJnBsonVM",
@"LHF5WVXvhqgwHwYDVR0jBBgwFoAUDBxB98iHJnBsonVMLHF5WVXvhqgwDAYDVR0T",
@"BAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEA4tyP/hMMJBYVFhRmdjAj9wnCr31N",
@"7tmyksLR76gqfLJL3obPDW+PIFPjdhBWNjcjNuw/qmWUXcEkqu5q9w9uMs5Nw0Z/",
@"prTbIIW861cZVck5dBlTkzQXySqgPwirXUKP/l/KrUYYV++tzLJb/ete2HHYwAyA",
@"2kl72gIxdqcXsChdO5sVB+Fsy5vZ2pw9Qan6TGkSIDuizTLIvbFuWw53MCBibdDn",
@"Y+CY2JrcX0/YYs4BSk5P6w/VInU5pn6afYew4XO7jRrGyIIPRJyR3faULqOLkenG",
@"Z+VNoXdO4+FShkEEfHb+Y8ie7E+bB0GBPb9toH/iH4cVS8ddaV3KiLkkJg=="]];//[NSData dataWithContentsOfFile:@"/var/mobile/Library/Greyd00r/ActivationKeys/certificate.cer"];  

//SecCertificateRef certRef = SecCertificateFromPath(@"/var/mobile/Library/Greyd00r/ActivationKeys/certificate.cer");
//SecCertificateRef certificateFromFile = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certRef);



//SecKeyRef publicKey = SecKeyFromCertificate(certRef);

//recoverFromTrustFailure(publicKey);

if(hashedUDIDData && signatureData && certificateData){


SecCertificateRef certificateFromFile = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData); // load the certificate

SecPolicyRef secPolicy = SecPolicyCreateBasicX509();

SecTrustRef trust;
OSStatus statusTrust = SecTrustCreateWithCertificates( certificateFromFile, secPolicy, &trust);
SecTrustResultType resultType;
OSStatus statusTrustEval =  SecTrustEvaluate(trust, &resultType);
SecKeyRef publicKey = SecTrustCopyPublicKey(trust);


//ONLY iOS6+ supports SHA256! >:(
uint8_t sha1HashDigest[CC_SHA1_DIGEST_LENGTH];
CC_SHA1([hashedUDIDData bytes], [hashedUDIDData length], (unsigned char*)sha1HashDigest);

OSStatus verficationResult = SecKeyRawVerify(publicKey,  kSecPaddingPKCS1SHA1, (const uint8_t*)sha1HashDigest, (size_t)CC_SHA1_DIGEST_LENGTH,  (const uint8_t *)[signatureData bytes], (size_t)[signatureData length]);
CFRelease(publicKey);
CFRelease(trust);
CFRelease(secPolicy);
CFRelease(certificateFromFile);
[pool drain];

if (verficationResult == errSecSuccess){

  return TRUE;
}
else{
  return FALSE;
}



}
[pool drain];
return false;
}



#define KNORMAL  "\x1B[0m"
#define KRED  "\x1B[31m"

#define REDLog(fmt, ...) NSLog((@"%s" fmt @"%s"),KRED,##__VA_ARGS__,KNORMAL)


@interface UIColor (Shades)

-(BOOL)isLightColor;
@end


@implementation UIColor (Shades)

-(BOOL)isLightColor{

    const CGFloat *componentColors = CGColorGetComponents(self.CGColor);

    CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
    if (colorBrightness < 0.6)
    {
        return FALSE;
    }
    else
    {
        return TRUE;
    }

}

@end

@implementation Greyd00rStockLSView


-(UIView *)initWithFrame:(CGRect)frame controller:(Greyd00rStockLockScreen*)controller lsController:(LibLSController*)lsController{
	self = [super initWithFrame:frame];
    if (self){

    self.controller = controller;
    self.lsController = lsController;
    

 


    if(debug) REDLog(@"GDSTOCKLS: initWithFrame called - creating lockscreen");

    normalWallpaper = [[self.lsController backgroundImage] retain]; //Like this! Just a simple thing to set the background image.
    blurredWallpaper = [[self.controller blurredBackgroundImage] retain];


    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    currentOrientation = [UIDevice currentDevice].orientation;
    float wallpaperHeight = normalWallpaper.size.height;
    float wallpaperWidth = normalWallpaper.size.width;

if (UIDeviceOrientationIsLandscape(currentOrientation))
{
     screenHeight = screenFrame.size.width;
    screenWidth = screenFrame.size.height;    

    if(wallpaperHeight < wallpaperWidth){
        wallpaperHeight = normalWallpaper.size.height;
        wallpaperWidth = normalWallpaper.size.width;
    }
    else{

    }
}
else{
    screenWidth = screenFrame.size.width;
    screenHeight = screenFrame.size.height;
    if(wallpaperHeight < wallpaperWidth){
        wallpaperWidth = normalWallpaper.size.height * 2;
        wallpaperHeight = normalWallpaper.size.width; 
    }
    else{

    }
}


    wallpaperView = [[UIImageView alloc] initWithFrame:CGRectMake((screenWidth / 2) - (wallpaperWidth / 2),(screenHeight / 2) - (wallpaperHeight / 2),wallpaperWidth, wallpaperHeight)]; 
    [self addSubview:wallpaperView];

    blurDim = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,screenWidth,screenHeight)]; 
    blurDim.alpha = 0.0;
    blurDim.backgroundColor = [UIColor blackColor];
    [self addSubview:blurDim];

    self.unlockScrollView = [[GDScrollUnlockView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    self.unlockScrollView.contentSize = CGSizeMake((screenWidth * 2), screenHeight);
    self.unlockScrollView.backgroundColor = [UIColor clearColor];
    self.unlockScrollView.pagingEnabled = TRUE;
    [self.unlockScrollView setContentOffset:CGPointMake(screenWidth, 0) animated:FALSE];
    [self.unlockScrollView setShowsHorizontalScrollIndicator:FALSE];
    [self.unlockScrollView setShowsVerticalScrollIndicator:FALSE];
    self.unlockScrollView.delegate = self.controller;
    [self addSubview:self.unlockScrollView];

  
    backgroundBlurred = FALSE;
	wallpaperView.image = normalWallpaper; 
    self.backgroundColor = [UIColor blackColor];


    //---------------Media Controls initilization --------------//
    mediaControlsHolder = [[UIView alloc] initWithFrame:CGRectMake(screenWidth,0, screenWidth, 140)];
    mediaControlsHolder.backgroundColor = [UIColor clearColor];

    mediaArtistAlbumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,80,screenWidth,20)];
    mediaArtistAlbumLabel.textAlignment = UITextAlignmentCenter;
    [mediaArtistAlbumLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
    mediaArtistAlbumLabel.textColor = [UIColor whiteColor];
    mediaArtistAlbumLabel.backgroundColor = [UIColor clearColor];
    mediaArtistAlbumLabel.alpha = 0.6;

    mediaSongLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,50,screenWidth,30)];
    mediaSongLabel.textAlignment = UITextAlignmentCenter;
    [mediaSongLabel setFont:[UIFont fontWithName:@"Arial" size:18]];
    mediaSongLabel.textColor = [UIColor whiteColor];
    mediaSongLabel.backgroundColor = [UIColor clearColor];


    mediaPausePlayButton = [[UIButton alloc] initWithFrame:CGRectMake((screenWidth / 2) - 15, mediaArtistAlbumLabel.frame.origin.y + 30, 30, 20 )];
    [mediaPausePlayButton setBackgroundColor:[UIColor clearColor]];
    //[mediaPausePlayButton setTitle:@">" forState:UIControlStateNormal];
    [mediaPausePlayButton setBackgroundImage:[UIImage imageWithContentsOfFile:@"/Library/liblockscreen/Lockscreens/Greyd00rStockLS.bundle/Play.png"] forState:UIControlStateNormal];
    [mediaPausePlayButton addTarget:self action:@selector(togglePlayback:) forControlEvents:UIControlEventTouchUpInside];
    mediaPausePlayButton.tag = 2;

    mediaPreviousButton = [[UIButton alloc] initWithFrame:CGRectMake(mediaPausePlayButton.frame.origin.x - 70, mediaArtistAlbumLabel.frame.origin.y + 30, 30, 20 )];
    [mediaPreviousButton setBackgroundColor:[UIColor clearColor]];
    //[mediaPreviousButton setTitle:@"<<" forState:UIControlStateNormal];
    [mediaPreviousButton setBackgroundImage:[UIImage imageWithContentsOfFile:@"/Library/liblockscreen/Lockscreens/Greyd00rStockLS.bundle/Previous.png"] forState:UIControlStateNormal];
    [mediaPreviousButton addTarget:self action:@selector(togglePlayback:) forControlEvents:UIControlEventTouchUpInside];

    mediaPreviousButton.tag = 1;

    mediaForwardButton = [[UIButton alloc] initWithFrame:CGRectMake(mediaPausePlayButton.frame.origin.x + 70, mediaArtistAlbumLabel.frame.origin.y + 30, 30, 20 )];
    [mediaForwardButton setBackgroundColor:[UIColor clearColor]];
    //[mediaForwardButton setTitle:@">>" forState:UIControlStateNormal];
    [mediaForwardButton setBackgroundImage:[UIImage imageWithContentsOfFile:@"/Library/liblockscreen/Lockscreens/Greyd00rStockLS.bundle/Forward.png"] forState:UIControlStateNormal];
    [mediaForwardButton addTarget:self action:@selector(togglePlayback:) forControlEvents:UIControlEventTouchUpInside];
 
    mediaForwardButton.tag = 3;

    [mediaControlsHolder addSubview:mediaSongLabel];
    [mediaControlsHolder addSubview:mediaArtistAlbumLabel];
    [mediaControlsHolder addSubview:mediaPreviousButton];
    [mediaControlsHolder addSubview:mediaForwardButton];
    [mediaControlsHolder addSubview:mediaPausePlayButton];

    mediaControlsHolder.hidden = TRUE;
    mediaControlsHolder.alpha = 0.0;
    [self.unlockScrollView addSubview:mediaControlsHolder];

    mediaAlbumImageViewUnderlay = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth + 40, 160, 240, 240)]; //Non-dynamic for tablets/landscape.
    mediaAlbumImageViewUnderlay.hidden = TRUE;
    mediaAlbumImageViewUnderlay.alpha = 0.0;
    [self.unlockScrollView addSubview:mediaAlbumImageViewUnderlay];

    mediaAlbumImageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth + 40, 160, 240, 240)]; //Non-dynamic for tablets/landscape.
    mediaAlbumImageView.hidden = TRUE;
    mediaAlbumImageView.alpha = 0.0;
    [self.unlockScrollView addSubview:mediaAlbumImageView];

    if(self.controller.showAlbumArtUnderlay){
   UIImage *_maskingImage = [UIImage imageWithContentsOfFile:@"/Library/liblockscreen/Lockscreens/Greyd00rStockLS.bundle/AlbumArtUnderlayMask.png"];
CALayer *_maskingLayer = [CALayer layer];
_maskingLayer.frame = mediaAlbumImageView.bounds;
[_maskingLayer setContents:(id)[_maskingImage CGImage]];
[mediaAlbumImageView.layer setMask:_maskingLayer];

   UIImage *_maskingImageUnderlay = [UIImage imageWithContentsOfFile:@"/Library/liblockscreen/Lockscreens/Greyd00rStockLS.bundle/AlbumArtUnderlayMask.png"];
CALayer *_maskingLayerUnderlay = [CALayer layer];
_maskingLayerUnderlay.frame = mediaAlbumImageViewUnderlay.bounds;
[_maskingLayerUnderlay setContents:(id)[_maskingImageUnderlay CGImage]];
[mediaAlbumImageViewUnderlay.layer setMask:_maskingLayerUnderlay];
}






    /*
    dateView = [[[objc_getClass("SBAwayController") sharedAwayController] awayView] dateView];
    [dateView removeFromSuperview];
    [self.unlockScrollView addSubview:dateView];
    dateView.hidden = FALSE;
*/

    unlockShadeLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth,screenHeight - 70, screenWidth, 40)];
    unlockLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth,screenHeight - 70, screenWidth, 40)];
    unlockLabel.textAlignment = UITextAlignmentCenter;
    unlockShadeLabel.textAlignment = UITextAlignmentCenter;

   	timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth,20,screenWidth,100)];
    dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth,105,screenWidth,40)];
  	timeLabel.textAlignment = UITextAlignmentCenter;
    dateLabel.textAlignment = UITextAlignmentCenter;
    /*
    for (NSString *familyName in [UIFont familyNames]) {
      for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
         REDLog(@"GDSTOCKLS: font name: %@", fontName);
      }
    }
   */






  	//[timeLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:86]];
    //[dateLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
    NSString *clockFont = [self loadFontAtPath:@"/Library/liblockscreen/Lockscreens/Greyd00rStockLS.bundle/iOS8LockClock.ttf"];
    if([UIFont fontWithName:clockFont size:86] == NULL || [UIFont fontWithName:clockFont size:86] == nil){
      UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"iOS 8 Lockscreen Error"
                     message: @"Unable to find iOS 8 Clock Font File."
                     delegate: nil
                     cancelButtonTitle: @"OK"
                     otherButtonTitles: nil];
      [alert show];
      [alert release];

      clockFont = @"Arial";

    }


    NSString *dateFont = [self loadFontAtPath:@"/Library/liblockscreen/Lockscreens/Greyd00rStockLS.bundle/iOS8Text.ttc"];
    if([UIFont fontWithName:dateFont size:86] == NULL || [UIFont fontWithName:dateFont size:86] == nil){
      UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"iOS 8 Lockscreen Error"
                     message: @"Unable to find iOS 8 Date Font File."
                     delegate: nil
                     cancelButtonTitle: @"OK"
                     otherButtonTitles: nil];
      [alert show];
      [alert release];

      dateFont = @"Arial";

    }

  
    [timeLabel setFont:[UIFont fontWithName:clockFont size:86]];
    [dateLabel setFont:[UIFont fontWithName:dateFont size:18]];
   
    [unlockLabel setFont:[UIFont fontWithName:@"Arial" size:26]];
    [unlockShadeLabel setFont:[UIFont fontWithName:@"Arial" size:26]];

    
    //timeLabel.font = [timeLabel.font fontWithSize:68];
   if(debug) REDLog(@"GDSTOCKLS: TimeLabel font is: %@", timeLabel.font);
  	timeLabel.textColor = [UIColor whiteColor];
    dateLabel.textColor = [UIColor whiteColor];
    unlockShadeLabel.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.60f];
    unlockLabel.textColor = [UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.7f];
  	timeLabel.backgroundColor = [UIColor clearColor];
    dateLabel.backgroundColor = [UIColor clearColor];
    unlockLabel.backgroundColor = [UIColor clearColor];
    unlockShadeLabel.backgroundColor = [UIColor clearColor];
  	//[self updateClock];
    //timeLabel.hidden = TRUE;
  	[self.unlockScrollView addSubview:timeLabel];
    [self.unlockScrollView addSubview:dateLabel];
    [self.unlockScrollView addSubview:unlockShadeLabel];
    [self.unlockScrollView addSubview:unlockLabel];

    unlockShadeLabel.text = @"> slide to unlock";
    [unlockLabel setTextWithChangeAnimation:@"> slide to unlock"];
  	[timeLabel release];
    [dateLabel release]; 
    [unlockLabel release];

    [unlockShadeLabel release];


    dimOverlay = [[UIView alloc] initWithFrame:CGRectMake(screenWidth, 0, screenWidth, screenHeight)];
    dimOverlay.alpha = 1.0f;
    dimOverlay.backgroundColor = [UIColor blackColor];
    [self.unlockScrollView addSubview:dimOverlay];
    


    if(!isSlothAlive()){
      UILabel *badLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth,screenHeight / 2 - 30, screenWidth, 60)];
      badLabel.textColor = [UIColor whiteColor];
      badLabel.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f];
      badLabel.text=@"Error: This only works in Grayd00r!";
      badLabel.textAlignment = UITextAlignmentCenter;
      [self.unlockScrollView addSubview:badLabel];
    }



UIColor *topColor = [[[self.lsController backgroundImage] croppedImage:CGRectMake(0,0,screenWidth, 140)] mergedColor];
NSLog(@"TOPCOLOR IS %@", NSStringFromBOOL([topColor isLightColor]));
if([topColor isLightColor] && !backgroundBlurred){
    timeLabel.textColor = [UIColor blackColor];
    dateLabel.textColor = [UIColor blackColor];
}
else{
    timeLabel.textColor = [UIColor whiteColor];
    dateLabel.textColor = [UIColor whiteColor];  
}

    /*
    bannerListController = [[GDBannerListController alloc] init];
    bannerListView = [[UITableView alloc] initWithFrame:CGRectMake(screenWidth, dateLabel.frame.origin.y + 40, screenWidth, (screenHeight - 100 - (dateLabel.frame.origin.y + 40)))];
    bannerListController.tableView = bannerListView;
    bannerListView.delegate = bannerListController;
    bannerListView.separatorColor = [UIColor clearColor];

    [bannerListView setBackgroundView:nil];
    [bannerListView setBackgroundView:[[[UIView alloc] init] autorelease]];
    [bannerListView setBackgroundColor:UIColor.clearColor];
    [self.unlockScrollView addSubview:bannerListView];
    bannerListView.hidden = TRUE;
    */
    //[self.unlockScrollView release]; //FIXME maybe?

	}
    return self;
}

-(void)layoutSubviews:(int)orientation{

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    currentOrientation = orientation;
    float wallpaperHeight = normalWallpaper.size.height;
    float wallpaperWidth = normalWallpaper.size.width;

if (UIDeviceOrientationIsLandscape(orientation))
{
     screenHeight = screenFrame.size.width;
    screenWidth = screenFrame.size.height;    

    if(wallpaperHeight < wallpaperWidth){
        wallpaperHeight = normalWallpaper.size.height;
        wallpaperWidth = normalWallpaper.size.width;
    }
    else{

    }
}
else{
    screenWidth = screenFrame.size.width;
    screenHeight = screenFrame.size.height;
    if(wallpaperHeight < wallpaperWidth){
        wallpaperWidth = normalWallpaper.size.height * 2;
        wallpaperHeight = normalWallpaper.size.width; 
    }
    else{

    }
}
    self.frame = CGRectMake(0,0,screenWidth, screenHeight); //Gotta update this otherwise it leaves off part of the screen as non-responsive because technically the frame still hasn't updated to the new dimensions even if you can see things out-of-frame.
  
    wallpaperView.frame = CGRectMake((screenWidth / 2) - (wallpaperWidth / 2),(screenHeight / 2) - (wallpaperHeight / 2),wallpaperWidth, wallpaperHeight); 
    blurDim.frame = CGRectMake(0,0,screenWidth,screenHeight); 
    self.unlockScrollView.frame = CGRectMake(0, 0, screenWidth, screenHeight);

    self.unlockScrollView.contentSize = CGSizeMake((screenWidth * 2), screenHeight);

    mediaControlsHolder.frame = CGRectMake(screenWidth,0, screenWidth, 140);
    mediaArtistAlbumLabel.frame = CGRectMake(0,80,screenWidth,20);
    mediaSongLabel.frame = CGRectMake(0,50,screenWidth,30);
    mediaPausePlayButton.frame = CGRectMake((screenWidth / 2) - 15, mediaArtistAlbumLabel.frame.origin.y + 30, 30, 20 );

    mediaPreviousButton.frame = CGRectMake(mediaPausePlayButton.frame.origin.x - 70, mediaArtistAlbumLabel.frame.origin.y + 30, 30, 20 );

    mediaForwardButton.frame = CGRectMake(mediaPausePlayButton.frame.origin.x + 70, mediaArtistAlbumLabel.frame.origin.y + 30, 30, 20 );
    mediaAlbumImageViewUnderlay.frame = CGRectMake(screenWidth + 40, 160, 240, 240); 
    mediaAlbumImageView.frame = CGRectMake(screenWidth + 40, 160, 240, 240);
    unlockShadeLabel.frame = CGRectMake(screenWidth,screenHeight - 70, screenWidth, 40);
    unlockLabel.frame = CGRectMake(screenWidth,screenHeight - 70, screenWidth, 40);
    timeLabel.frame = CGRectMake(screenWidth,20,screenWidth,100);
    dateLabel.frame = CGRectMake(screenWidth,105,screenWidth,40);
  dimOverlay.frame = CGRectMake(screenWidth, 0, screenWidth, screenHeight);

    [self.unlockScrollView setContentOffset:CGPointMake(screenWidth, 0) animated:TRUE];

if(!notificationList == NULL && self.controller.hasNotifications){


  SBAwayBulletinListView *notificationView = [notificationList valueForKey:@"_view"];
  [notificationView setHidden:FALSE];
  [notificationView removeFromSuperview];
  [notificationView clearFloatingAlertButtonHandler];
  int notificationViewHeight = ((screenHeight - (screenHeight - unlockLabel.frame.origin.y)) - (dateLabel.frame.origin.y + 40));
  if(debug) REDLog(@"GDSTOCKLS: notificationViewWIDTH is: %f", notificationView.frame.size.width);
  notificationView.frame = CGRectMake((screenWidth + (screenWidth / 2)) - (notificationView.frame.size.width / 2), dateLabel.frame.origin.y + 40, notificationView.frame.size.width, notificationViewHeight);
  [self.unlockScrollView addSubview:notificationView];
}else{
    REDLog(@"GDSTOCKLS: reorient notification list failed...");
}

UIColor *topColor = [[[self.lsController backgroundImage] croppedImage:CGRectMake(0,0,screenWidth, 140)] mergedColor];
if([topColor isLightColor] && !backgroundBlurred){
    timeLabel.textColor = [UIColor blackColor];
    dateLabel.textColor = [UIColor blackColor];
}
else{
    timeLabel.textColor = [UIColor whiteColor];
    dateLabel.textColor = [UIColor whiteColor];  
}

[pool drain];

}


-(void)updateClockWithTime:(NSString*)time andDate:(NSString*)date{



dateLabel.text = date;
  
timeLabel.text = time;

}



-(NSString*)loadFontAtPath:(NSString*)path
{
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
    if(data == nil)
    {
#ifdef DEBUG
        NSLog(@"Failed to load font. Data at path is null path = %@", path);
#endif //ifdef Debug
        return nil;
    }
    CFErrorRef error;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    CGFontRef font = CGFontCreateWithDataProvider(provider);
    if(!CTFontManagerRegisterGraphicsFont(font, &error)){
#ifdef DEBUG
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        NSLog(@"Failed to load font: %@", errorDescription);
        CFRelease(errorDescription);
        return nil;
#endif //ifdef Debug
    }
    CFStringRef fontName = CGFontCopyFullName(font);
    NSLog(@"Loaded: %@", fontName);
    CFStringRef cfFontName = CGFontCopyPostScriptName(font);
    NSString *fontTitle = (NSString *)cfFontName;

    CFRelease(fontName);
    CFRelease(font);
    CFRelease(provider);
    CFRelease(cfFontName);
    return fontTitle;
}

-(void)addFont:(CGFontRef)font withName:(NSString *)fontName{
      [timeLabel setFont:[UIFont fontWithName:fontName size:86]];
    [dateLabel setFont:[UIFont fontWithName:fontName size:18]];
}


-(void)unlock{
    if(debug) REDLog(@"GDSTOCKLS: Attempting to unlock...");
	if(self.controller.unlocking){
       if(debug) REDLog(@"GDSTOCKLS: Can't unlock, because it seems we are already unlocking...");
		return;
	}
	self.controller.unlocking = TRUE; //Sometimes this triggers many times. Bad things happen when it does.
	if(debug) REDLog(@"GDSTOCKLS: unlock - self.unlocking");
  [blurredWallpaper release];
  if(debug) REDLog(@"GDSTOCKLS: unlock - blurred wallpaper released");
  [normalWallpaper release];
	[self.lsController unlock];
}

-(void)receivedNotification:(NSMutableDictionary *)notification{
  
if(notificationList == NULL){
    if(!self.lsController == nil){
      notificationList = [self.lsController bulletinController];

     //if(debug) REDLog(@"GDSTOCKLS: Contorller: %@", notificationList);
     //if(debug) REDLog(@"GDSTOCKLS: TableView: %@", [[notificationList valueForKey:@"_view"] valueForKey:@"_tableView"]);
     [[[notificationList valueForKey:@"_view"] valueForKey:@"_tableBackgroundView"] setHidden:TRUE];
    }
}

if(!notificationList == NULL){


  SBAwayBulletinListView *notificationView = [notificationList valueForKey:@"_view"];
  [notificationView setHidden:FALSE];
  [notificationView removeFromSuperview];
  [notificationView clearFloatingAlertButtonHandler];
  int notificationViewHeight = ((screenHeight - (screenHeight - unlockLabel.frame.origin.y)) - (dateLabel.frame.origin.y + 40));
  //if(debug) REDLog(@"GDSTOCKLS: notificationViewHeight is: %i", notificationViewHeight);
  notificationView.frame = CGRectMake((screenWidth + (screenWidth / 2)) - (notificationView.frame.size.width / 2), dateLabel.frame.origin.y + 40, notificationView.frame.size.width, notificationViewHeight);
  [self.unlockScrollView addSubview:notificationView];
}

self.controller.hasNotifications = TRUE;
if(!mediaAlbumImageView.hidden){
[UIView animateWithDuration:0.3
                      delay:0
                    options:UIViewAnimationOptionBeginFromCurrentState
                 animations:^{
                
                      mediaAlbumImageView.alpha = 0.0f;
                      mediaAlbumImageViewUnderlay.alpha = 0.0f;
                      if(debug) REDLog(@"GDSTOCKLS: mediaAlbumImageView should be animated to 0.0f for receivedNotification");
                 }
                 completion:^(BOOL finished){
                      mediaAlbumImageView.hidden = TRUE;
                      mediaAlbumImageViewUnderlay.hidden = TRUE;
                 }];
}
/*
------Notifications--------
So, this makes handling notifications hopefully a bit easier.
You will get a NSMutableDictionary (don't worry about that, it's incase you need to add more info to it) whenever a notification is released.
It has the following keys:
title -- this is the title of the notification, sometimes the name of the person, or the name of the app depending on the notification.
message -- the body of the notification. If there is no body, it will be NULL (so check for that maybe?)
subtitle -- sometimes notifications have this, sometimes they don't. Do a simple check for if it is there or not and if you should use it.
bundleID -- the identifier of the app, such as com.apple.mobilesms or so on. 
appName -- the display name of the app, which could be Twitter, Messages, Facebook, etc.
originalAlert -- this is the original BBBuletin item of the alert, in case you need to pull more data from it. 


UIAlertView *alert =
[[UIAlertView alloc] initWithTitle: @"Greyd00rStockLS notification"
                     message: [NSString stringWithFormat:@"%@ - %@", [notification objectForKey:@"appName"], [notification objectForKey:@"message"]]
                     delegate: nil
                     cancelButtonTitle: @"OK"
                     otherButtonTitles: nil];
[alert show];
[alert release];
*/
if(!backgroundBlurred){
    [self blurBackground:TRUE];
}

/*
bannerListController.tableView.hidden = FALSE;
[self blurBackground:TRUE];
[bannerListController.banners insertObject:notification atIndex:0];
[bannerListController reloadCells];
*/

}

//Basically means it unlocked? I need to find a better method to override.
-(void)passcodeAccepted{
UIAlertView *alert =
[[UIAlertView alloc] initWithTitle: @"Greyd00rStockLS Debug"
                     message: @"Passcode accepted! Unlocking?"
                     delegate: nil
                     cancelButtonTitle: @"OK"
                     otherButtonTitles: nil];
[alert show];
[alert release];
self.controller.hasNotifications = FALSE;
self.controller.canceledTimer = FALSE;
}

-(void)showBulletinView{
 
  //REDLog(@"GDSTOCKLS: showBulletinView called");
  if(notificationList == NULL){
    if(!self.lsController == nil){
      notificationList = [self.lsController bulletinController];
      //if(debug) REDLog(@"GDSTOCKLS: Contorller: %@", notificationList);
      //if(debug) REDLog(@"GDSTOCKLS: TableView: %@", [[notificationList valueForKey:@"_view"] valueForKey:@"_tableView"]);
     //[[[notificationList valueForKey:@"_view"] valueForKey:@"_tableBackgroundView"] setHidden:TRUE];
    }
}


if(!notificationList == NULL){
  SBAwayBulletinListView *notificationView = [notificationList valueForKey:@"_view"];

  [notificationView setHidden:FALSE];
  if(![notificationView isDescendantOfView:self.unlockScrollView]){
    [notificationView removeFromSuperview];
  }
  [notificationView clearFloatingAlertButtonHandler];
  int notificationViewHeight = ((screenHeight - (screenHeight - unlockLabel.frame.origin.y)) - (dateLabel.frame.origin.y + 40));
  //if(debug) REDLog(@"GDSTOCKLS: notificationViewHeight is: %i", notificationViewHeight);
  notificationView.frame = CGRectMake((screenWidth + (screenWidth / 2)) - (notificationView.frame.size.width / 2), dateLabel.frame.origin.y + 40, notificationView.frame.size.width, notificationViewHeight);
  if(![notificationView isDescendantOfView:self.unlockScrollView]){
    [self.unlockScrollView addSubview:notificationView];
  }
}

}

-(void)insertBulletinView{
  
 //REDLog(@"GDSTOCKLS: insertBulletinView called");
if(notificationList == nil){
    if(!self.lsController == nil){
      notificationList = [self.lsController bulletinController];
      //if(debug) REDLog(@"GDSTOCKLS: Contorller: %@", notificationList);
      //if(debug) REDLog(@"GDSTOCKLS: TableView: %@", [[notificationList valueForKey:@"_view"] valueForKey:@"_tableView"]);
 
    }
}

 //[[[notificationList valueForKey:@"_view"] valueForKey:@"_tableBackgroundView"] setHidden:TRUE];
 //[[[notificationList valueForKey:@"_view"] valueForKey:@"_tableBottomFadeOverlay"] setHidden:TRUE];
 //[[[notificationList valueForKey:@"_view"] valueForKey:@"_tableTopFadeOverlay"] setHidden:TRUE];
 //[[[notificationList valueForKey:@"_view"] valueForKey:@"_firstAlertBGView"] setHidden:TRUE];
 //[[[notificationList valueForKey:@"_view"] valueForKey:@"_tableGrabberView"] setHidden:TRUE];
 //[[[notificationList valueForKey:@"_view"] valueForKey:@"_tableContainerView"] setHidden:TRUE];



  SBAwayBulletinListView *notificationView = [notificationList valueForKey:@"_view"];
  /*

  UITableView *tableView = [notificationView valueForKey:@"_tableView"];
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

   for (int i = 0; i < [tableView numberOfRowsInSection:indexPath.section]; i++) {
    if (i != indexPath.row) {
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
        //Do your stuff
        if(debug) REDLog(@"GDSTOCKLS: Notificaiton Cell is: %@", cell);
    }
}
*/
  [notificationView setHidden:FALSE];
  [notificationView removeFromSuperview];
  [notificationView clearFloatingAlertButtonHandler];
  int notificationViewHeight = ((screenHeight - (screenHeight - unlockLabel.frame.origin.y)) - (dateLabel.frame.origin.y + 40));
  //if(debug) REDLog(@"GDSTOCKLS: notificationViewHeight is: %i", notificationViewHeight);
  notificationView.frame = CGRectMake((screenWidth + (screenWidth / 2)) - (notificationView.frame.size.width / 2), dateLabel.frame.origin.y + 40, notificationView.frame.size.width, notificationViewHeight);
  [self.unlockScrollView addSubview:notificationView];


}


//Might be useful down the road to condense all the methods into this point.
-(void)blurBackground:(BOOL)blur{

NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

//Block animation. very nice and simple. There are even more complex things that can be done with this though of course, such as step based animations (might be iOS 7+ only actually)
[UIView transitionWithView:wallpaperView
                  duration:0.3f
                   options:UIViewAnimationOptionTransitionCrossDissolve
                animations:^{

                  if(blur && !backgroundBlurred){
                      wallpaperView.image = blurredWallpaper;
                      wallpaperView.alpha = 0.8;
                      blurDim.alpha = 0.5;
                      backgroundBlurred = TRUE;
                  }

                  if(!blur && backgroundBlurred && !self.controller.hasNotifications){
                      wallpaperView.image = normalWallpaper;  
                      wallpaperView.alpha = 1.0;
                      blurDim.alpha = 0.0;
                      backgroundBlurred = FALSE; 
                  }

                } completion:nil];

UIColor *topColor = [[[self.lsController backgroundImage] croppedImage:CGRectMake(0,0,screenWidth, 140)] mergedColor];
if([topColor isLightColor] && !backgroundBlurred){
    timeLabel.textColor = [UIColor blackColor];
    dateLabel.textColor = [UIColor blackColor];
}
else{
    timeLabel.textColor = [UIColor whiteColor];
    dateLabel.textColor = [UIColor whiteColor];  
}

[pool drain];
}



//Blurring the background on media controls...
/*
-(void)showMediaControls:(BOOL)show{

if(!show && !self.controller.hasNotifications){
  [self blurBackground:show];
}

if(show && !backgroundBlurred){
  [self blurBackground:show];
}
}
*/

-(void)homeButtonTapped{

  //Okay, this is a bit hackey, but for whatever reason this method gets called twice even in the hook in liblockscreen. Probably could put this there, but who knows maybe someone needs this method.
  //I'll probably put in a "raw" version I guess.
  if(debug) REDLog(@"GDSTOCKLS: homeButtonTapped");

if(self.controller.firstMenuButtonTapForUndim){
switch(self.controller.homeButtonTapCount){
  case 0: 

    self.controller.homeButtonTapCount++;
    break;
  case 1: 

    self.controller.homeButtonTapCount = 0;
    self.controller.firstMenuButtonTapForUndim = FALSE;
    break;
}
return;
}

switch(self.controller.homeButtonTapCount){
  case 0: 

    self.controller.homeButtonTapCount++;
    break;
  case 1: 
      if(!showingMediaControls && [self.controller.mediaController hasTrack]){
        [self toggleMediaControls:TRUE];
      }
      else if(showingMediaControls){
        [self toggleMediaControls:FALSE];
      }
    self.controller.homeButtonTapCount = 0;
    self.controller.firstMenuButtonTapForUndim = FALSE;
    break;
}

}


-(void)toggleMediaControls:(BOOL)show{
    if(debug) REDLog(@"GDSTOCKLS: toggleMediaControls called");
  if(![self.controller.mediaController hasTrack]){
      return;
  }
  showingMediaControls = show;
  [self nowPlayingInfoChanged];

if(show){
  mediaControlsHolder.hidden = FALSE;
  if(!self.controller.hasNotifications){
    mediaAlbumImageView.hidden = FALSE;
    mediaAlbumImageViewUnderlay.hidden = FALSE;
  }
  if(!backgroundBlurred){
          [self blurBackground:TRUE];
  }
  [UIView animateWithDuration:0.3
                      delay:0
                    options:UIViewAnimationOptionBeginFromCurrentState
                 animations:^{
                     timeLabel.alpha = 0.0f;
                     dateLabel.alpha = 0.0f;
                     mediaControlsHolder.alpha = 1.0f;
                     if(!self.controller.hasNotifications){
                      mediaAlbumImageView.alpha = 1.0f;
                      mediaAlbumImageViewUnderlay.alpha = 1.0f;
                     }
                     mediaControlsHolder.transform=CGAffineTransformMakeScale(1.0, 1.0);
                     dateLabel.transform=CGAffineTransformMakeScale(0.9, 0.9);
                     timeLabel.transform=CGAffineTransformMakeScale(0.9, 0.9);
                      if(debug) REDLog(@"GDSTOCKLS: timeLabel should be animated to 0.0f");
                 }
                 completion:^(BOOL finished){
                      timeLabel.hidden = TRUE;
                      dateLabel.hidden = TRUE;
                 }];
}
else{
      timeLabel.hidden = FALSE;
      dateLabel.hidden = FALSE;
   [UIView animateWithDuration:0.3
                      delay:0
                    options:UIViewAnimationOptionBeginFromCurrentState
                 animations:^{
                     timeLabel.alpha = 1.0f;
                     dateLabel.alpha = 1.0f;
                     mediaControlsHolder.alpha = 0.0f;
                     //mediaAlbumImageView.alpha = 0.0f;
                     mediaControlsHolder.transform=CGAffineTransformMakeScale(0.9, 0.9);
                    dateLabel.transform=CGAffineTransformMakeScale(1.0, 1.0);
                     timeLabel.transform=CGAffineTransformMakeScale(1.0, 1.0);
                      if(debug) REDLog(@"GDSTOCKLS: timeLabel should be animated to 1.0f");
                 }
                 completion:^(BOOL finished){
                    mediaControlsHolder.hidden = TRUE;
                    //mediaAlbumImageView.hidden = TRUE;
                 }]; 
}

}

-(void)togglePlayback:(UIButton*)sender{
  [[objc_getClass("SBAwayController") sharedAwayController] restartDimTimer:50.0]; //So it doesn't dim the screen while you are changing songs
  switch(sender.tag){
    case 1:
        if([self.controller.mediaController hasTrack] && ![self.controller.mediaController isFirstTrack]){
          [self.controller.mediaController changeTrack:-1];
          if(debug) REDLog(@"GDSTOCKLS: togglePlayback:1 called, changing track to previous one/start of current one");
        }
        //[self nowPlayingInfoChanged];

      break;

    case 2:

        if([self.controller.mediaController hasTrack]){
          [self.controller.mediaController togglePlayPause];
          if(debug) REDLog(@"GDSTOCKLS: togglePlayback:2 called, pausing/starting current track");
          if([self.controller.mediaController isPlaying]){
             [mediaPausePlayButton setBackgroundImage:[UIImage imageWithContentsOfFile:@"/Library/liblockscreen/Lockscreens/Greyd00rStockLS.bundle/Pause.png"] forState:UIControlStateNormal];
          }
          else{
             [mediaPausePlayButton setBackgroundImage:[UIImage imageWithContentsOfFile:@"/Library/liblockscreen/Lockscreens/Greyd00rStockLS.bundle/Play.png"] forState:UIControlStateNormal];
          }
         // [self nowPlayingInfoChanged];
        }

      break;

    case 3: 
        if([self.controller.mediaController hasTrack] && ![self.controller.mediaController isLastTrack]){
          if(debug) REDLog(@"GDSTOCKLS: togglePlayback:3 called, changing track to the next one");
          [self.controller.mediaController changeTrack:1];
        // [self nowPlayingInfoChanged];
        }
      break;
  }
}


-(void)nowPlayingInfoChanged{
   if(![self.controller.mediaController hasTrack]){
    if(debug) REDLog(@"GDSTOCKLS: nowPlayingInfoChanged - self.controller.mediaController doesn't have a track!");
    return;
   }
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  mediaArtistAlbumLabel.text = [NSString stringWithFormat:@"%@ - %@", [self.controller.mediaController nowPlayingArtist], [self.controller.mediaController nowPlayingAlbum]];
  mediaSongLabel.text = [self.controller.mediaController nowPlayingTitle];
  CGSize albumArtistSize = [mediaArtistAlbumLabel.text sizeWithFont:mediaArtistAlbumLabel.font 
                        constrainedToSize:CGSizeMake(screenWidth, 40) 
                        lineBreakMode:mediaArtistAlbumLabel.lineBreakMode];
    //if(debug) REDLog(@"GDSTOCKLS: nowPlayingInfoChanged - albumArtistSize is: %@", albumArtistSize);
  if(albumArtistSize.width >= screenWidth){
    if(debug) REDLog(@"GDSTOCKLS: nowPlayingInfoChanged - albumArtistSize is greater than screenWidth");
  }

  CGSize songSize = [mediaSongLabel.text sizeWithFont:mediaSongLabel.font 
                        constrainedToSize:CGSizeMake(screenWidth, 40) 
                        lineBreakMode:mediaSongLabel.lineBreakMode];
  //if(debug) REDLog(@"GDSTOCKLS: nowPlayingInfoChanged - songSize is: %@", songSize);
  if(songSize.width >= screenWidth){
    if(debug) REDLog(@"GDSTOCKLS: nowPlayingInfoChanged - songSize is greater than screenWidth");
  }

  //if(debug) REDLog(@"GDSTOCKLS: nowPlayingInfoChanged - _nowPlayingInfo is: %@", [self.controller.mediaController _nowPlayingInfo]);

  //MPMediaItemArtwork *artwork = [[self.controller.mediaController _nowPlayingInfo] valueForProperty:MPMediaItemPropertyArtwork];
  

  //FIXME: For whatever reason, the using of either a tint or a blur causes this method to not be called. It is called via a home button press to the toggleMediaControls though.
 UIImage *nowPlayingImage = [UIImage imageWithData:[[self.controller.mediaController _nowPlayingInfo] objectForKey:@"artworkData"]];
[UIView transitionWithView:mediaAlbumImageView
                  duration:0.3f
                   options:UIViewAnimationOptionTransitionCrossDissolve
                animations:^{
                      mediaAlbumImageView.image = nowPlayingImage;
                      mediaAlbumImageViewUnderlay.image = [nowPlayingImage fastBlurWithQuality:4 interpolation:4 blurRadius:15];
                      
                } completion:nil];

if(self.controller.blurAlbumArt || self.controller.tintWallpaper && !(nowPlayingImage == NULL && nowPlayingImage == nil)){
    //backgroundImage = [UIImage liveBlurForScreenWithQuality:4 interpolation:4 blurRadius:15];
    //backgroundImage = [backgroundImage tintedImageUsingColor:[UIColor colorWithWhite:0.6 alpha:0.5]];
   // wallpaperView.image = [blurredWallpaper tintedImageUsingColor:[nowPlayingImage mergedColor] alpha:0.9f];
   
    [UIView transitionWithView:wallpaperView
                  duration:0.3f
                   options:UIViewAnimationOptionTransitionCrossDissolve
                animations:^{
                       //[[[self.lsController backgroundImage] fastBlurWithQuality:4 interpolation:4 blurRadius:15] tintedImageUsingColor:[nowPlayingImage mergedColor] alpha:0.9f];
                     if(self.controller.tintWallpaper && !self.controller.blurAlbumArt) wallpaperView.image = [[[self.lsController backgroundImage] fastBlurWithQuality:4 interpolation:4 blurRadius:15] tintedImageUsingColor:[nowPlayingImage mergedColor] alpha:0.9f];
                     if(self.controller.blurAlbumArt && !self.controller.tintWallpaper) wallpaperView.image = [nowPlayingImage fastBlurWithQuality:4 interpolation:4 blurRadius:15];
                     if(self.controller.blurAlbumArt && self.controller.tintWallpaper) wallpaperView.image = [[nowPlayingImage fastBlurWithQuality:4 interpolation:4 blurRadius:15] tintedImageUsingColor:[nowPlayingImage mergedColor] alpha:0.9f];
                      
                      wallpaperView.alpha = 0.8;

                } completion:nil];

  }
/*
  dispatch_queue_t queue = dispatch_queue_create("Blur queue", NULL); 
    dispatch_async(queue, ^ {
     
      dispatch_async(dispatch_get_main_queue(), ^{
           //[self setBlurredVersionsOfImages]; //Non existant method right now. This was just for testing but may be useful down the road.

        });
        });
         dispatch_release(queue);
  */
  if(mediaAlbumImageView.hidden && !self.controller.hasNotifications){
    mediaAlbumImageView.hidden = FALSE;
     mediaAlbumImageViewUnderlay.hidden = FALSE;
    [self.unlockScrollView bringSubviewToFront:mediaAlbumImageView];
[UIView animateWithDuration:0.3
                      delay:0
                    options:UIViewAnimationOptionBeginFromCurrentState
                 animations:^{
                
                      mediaAlbumImageView.alpha = 1.0f;
                      mediaAlbumImageViewUnderlay.alpha = 1.0f;
                      if(debug) REDLog(@"GDSTOCKLS: mediaAlbumImageView should be animated to 1.0f for nowPlayingInfoChanged");
                 }
                 completion:^(BOOL finished){
                      
                 }];
}

//Change the state of the play/pause button as needed

//FIXME: Jumpstart icon states... don't seem to show otherwise.
 //[mediaPreviousButton setTitle:@"<<" forState:UIControlStateNormal];
 // [mediaForwardButton setTitle:@">>" forState:UIControlStateNormal];
if([self.controller.mediaController isPlaying]){
             [mediaPausePlayButton setBackgroundImage:[UIImage imageWithContentsOfFile:@"/Library/liblockscreen/Lockscreens/Greyd00rStockLS.bundle/Pause.png"] forState:UIControlStateNormal];
          }
          else{
            [mediaPausePlayButton setBackgroundImage:[UIImage imageWithContentsOfFile:@"/Library/liblockscreen/Lockscreens/Greyd00rStockLS.bundle/Play.png"] forState:UIControlStateNormal];
          }

  [pool drain];
}





-(void)unlockedDevice{
  self.controller.hasNotifications = FALSE;
  self.controller.canceledTimer = FALSE;

  if(debug) REDLog(@"GDSTOCKLS: unlockedDevice - all done?");
}


-(BOOL)usesStockNotificationList{
  return TRUE;
}

-(void)animateLockKeyPadOutForCancel{
  if(debug) REDLog(@"GDSTOCKLS: animateLockKeyPadOutForCancel called");
  CGRect screenFrame = [[UIScreen mainScreen] bounds];
  screenWidth = screenFrame.size.width;
  screenHeight = screenFrame.size.height;
  [self.unlockScrollView setContentOffset:CGPointMake(screenWidth, 0) animated:TRUE];
}

-(void)undimScreen{
  if(debug) REDLog(@"GDSTOCKLS: undimScreen called");

//Reset the values because for whatever reason sometimes they are not... Doesn't seem to help though. Sometimes the animations just don't work.
wallpaperView.transform=CGAffineTransformMakeScale(1.0, 1.0);
dimOverlay.alpha = 1.0f;
dimOverlay.hidden = FALSE;
[self bringSubviewToFront:dimOverlay];

if([self.controller.mediaController hasTrack]){
  [self toggleMediaControls:TRUE];
}
else{
  if(!self.controller.hasNotifications && backgroundBlurred){
    [self blurBackground:FALSE];
  }
}

  [UIView animateWithDuration:0.5
                      delay:0.2
                    options:UIViewAnimationOptionBeginFromCurrentState
                 animations:^{
                     dimOverlay.alpha = 0.0f;
                      if(debug) REDLog(@"GDSTOCKLS: dimOverlayAlpha should be animated to 0.0f");
                 }
                 completion:^(BOOL finished){
                  if(debug) REDLog(@"GDSTOCKLS: dimOverlayAlpha should now be hidden");
                     dimOverlay.hidden = TRUE;
                 }];

  [UIView animateWithDuration:0.5
                      delay:0.3
                    options:UIViewAnimationOptionBeginFromCurrentState
                 animations:^{
                  if(debug) REDLog(@"GDSTOCKLS: wallpaperView scale should now be 1.1");
                     wallpaperView.transform=CGAffineTransformMakeScale(1.1, 1.1);
                 }
                 completion:nil];

/* Damn iOS 7 only :(
[UIView animateKeyframesWithDuration:0.4 delay:0 options:nil animations:^{
  [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1 animations:^{

    }];

   } completion:^(BOOL finished){
                     wallpaperView.transform=CGAffineTransformIdentity;
                 }];

                 */


    CGRect screenFrame = [[UIScreen mainScreen] bounds];
if (UIDeviceOrientationIsLandscape(currentOrientation))
{
     screenHeight = screenFrame.size.width;
    screenWidth = screenFrame.size.height;    
}
else{
      screenWidth = screenFrame.size.width;
    screenHeight = screenFrame.size.height;
}
  self.controller.canceledTimer = FALSE;
  [self.unlockScrollView setContentOffset:CGPointMake(screenWidth, 0) animated:TRUE];
}

-(void)dimScreen{
if(debug) REDLog(@"GDSTOCKLS: dimScreen called");


wallpaperView.transform=CGAffineTransformMakeScale(1.0, 1.0);


[self toggleMediaControls:FALSE];

dimOverlay.alpha = 1.0f;

dimOverlay.hidden = FALSE;
self.controller.firstMenuButtonTapCall = TRUE;
self.controller.firstMenuButtonTapForUndim = TRUE;
self.controller.homeButtonTapCount = 0;

}


-(void)animateLockKeyPadIn{
  //CGRect screenFrame = [[UIScreen mainScreen] bounds];
  //screenWidth = screenFrame.size.width;
  //screenHeight = screenFrame.size.height;
  //[self.unlockScrollView setContentOffset:CGPointMake(0, 0) animated:TRUE];
}

/*
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
  if(self.controller.unlocking){
    return;
  }
  //if(debug) REDLog(@"GDSTOCKLS: scrollViewDidScroll called");
    if(scrollView.contentOffset.x <= 100){
            if(debug) REDLog(@"GDSTOCKLS: Attempting to unlock...");
      [self.controller unlock]; //FIXME: was [self.lscontroller unlock]

    }

}
*/
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
 if(![[objc_getClass("SBAwayController") sharedAwayController] isDimmed] && !self.controller.canceledTimer){
    [[objc_getClass("SBAwayController") sharedAwayController] cancelDimTimer];
    self.controller.canceledTimer = TRUE;
  }
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{

  if(![[objc_getClass("SBAwayController") sharedAwayController] isDimmed] && [[objc_getClass("SBAwayController") sharedAwayController] isLocked]){
      [[objc_getClass("SBAwayController") sharedAwayController] restartDimTimer:50.0];
      self.controller.canceledTimer = FALSE;
  }
}


-(UIImage *)blurredBackgroundImage{
if([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/SpringBoard/LockBackgroundBlurred.png"]){
  return [UIImage imageWithContentsOfFile:@"/var/mobile/Library/SpringBoard/LockBackgroundBlurred.png"]; //Flags?
}
else{
  return [self.lsController backgroundImage]; //Flags?
}
}


-(void)dealloc{ //Clean up your mess
  [self.unlockScrollView release];
  [dimOverlay release];
  [mediaArtistAlbumLabel release];
  [mediaSongLabel release];
  [mediaControlsHolder release];
  [mediaForwardButton release];
  [mediaPreviousButton release];
  [mediaPausePlayButton release];
  [mediaAlbumImageView release];
  [mediaAlbumImageViewUnderlay release];
  [wallpaperView release];
  [blurDim release];
  //[bannerListController release];
  //[bannerListView release];
  //if(debug) REDLog(@"GDSTOCKLS: unlockedDevice - self.unlockScrollView released");
  [super dealloc];
}


@end