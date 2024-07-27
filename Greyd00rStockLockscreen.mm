#import "LibLockscreen.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "UIImage+StackBlur.h"
#import <substrate.h>
#import "GDBannerListController.h"
#import <SpringBoard/SpringBoard.h>
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import "GDScrollUnlockView.h"
#import "UIImage+AverageColor.h"
#import "UIImage+LiveBlur.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Greyd00rStockLockScreen.h"
#import "Greyd00rStockLSViewController.h"

#import "Greyd00rStockLSView.h"



//static LibLSController *controller;

#define debug TRUE
#define gdStockLSPrefsPath @"/var/mobile/Library/Preferences/com.greyd00r.lockscreen.plist"

#define KNORMAL  "\x1B[0m"
#define KRED  "\x1B[31m"

#define REDLog(fmt, ...) NSLog((@"%s" fmt @"%s"),KRED,##__VA_ARGS__,KNORMAL)




/*

TO-DO:
Tweak to modify bannerlistcells to look like iOS 7. That should be easier that way and still not break the system...
Get color average code from whited00r UI tweak (or find modern equivilent that works better for iOS 5)
Get image resizing code from whited00r UI tweak, and image tinting code.

*/



/*FIXME:
Make the LibLockscreen a UIViewController and the actual view a LibLockscreenView or something like that. Then in the liblockscreen tweak have it load the
controller and add the controller's view as needed. Hopefully memory management still remains fine Make delegates as needed.

*/







@implementation Greyd00rStockLockScreen

/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        return YES;
    }

    return NO;
}
*/

-(Greyd00rStockLockScreen *)initWithController:(LibLSController*)controller{
	self = [super init];
    if (self){

    [self loadPrefs]; //Probably need to do this in the background, or else in another place/time?
    if(debug) REDLog(@"GDSTOCKLS: initWithController called - creating lockscreen");
    self.hasNotifications = FALSE;
    self.canceledTimer = FALSE;
    self.isFirstUndimAfterWake = TRUE;
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    self.screenWidth = screenFrame.size.width;
    self.screenHeight = screenFrame.size.height;
    self.unlocking = FALSE;
    self.firstMenuButtonTapCall = TRUE;
    self.firstMenuButtonTapForUndim = FALSE;
    self.homeButtonTapCount = 0;
		self.controller = controller; //[objc_getClass("SBAwayController") sharedLibLSController]; //With this, we can use methods from the tweak that could be useful.
    self.mediaController = [objc_getClass("SBMediaController") sharedInstance];

    self.view = [[Greyd00rStockLSView alloc] initWithFrame:CGRectMake(0,0,self.screenWidth, self.screenHeight) controller:self lsController:controller];


	}
    return self;
}


-(float)liblsVersion{
	return 0.1; //What version of liblockscreen you built this using, so that legacy support can be provided and things don't break.
}

-(void)updateClockWithTime:(NSString*)time andDate:(NSString*)date{

[self.view updateClockWithTime:time andDate:date]; //Magic?  I built it wrong the first time around so the view was basically the controller. Bad idea eh?

//dateLabel.text = date;
  
//timeLabel.text = time;

}



-(void)unlock{
   if(debug) REDLog(@"GDSTOCKLS: unlock - unlock triggered");
if(self.unlocking){
  return;
}
self.unlocking = TRUE; //Sometimes this triggers many times. Bad things happen when it does.

  self.hasNotifications = FALSE;
  self.canceledTimer = FALSE;
  //self.view.unlockScrollView.delegate = nil; //So I can't check the content offsets?
  
  //if(debug) REDLog(@"GDSTOCKLS: unlock - self.view.normalWallpaper released");
  [self.controller unlock];  //Simple enough, right?
  if(debug) REDLog(@"GDSTOCKLS: unlock - unlock triggered via controller");

}

-(void)receivedNotification:(NSMutableDictionary *)notification{
self.hasNotifications = TRUE;
[self.view receivedNotification:notification];

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
self.hasNotifications = FALSE;
self.canceledTimer = FALSE;
}

-(void)showBulletinView{
 
  //REDLog(@"GDSTOCKLS: showBulletinView called");
  [self.view showBulletinView];
 

}

-(void)insertBulletinView{
  [self.view insertBulletinView];
}




//Blurring the background on media controls...
/*
-(void)showMediaControls:(BOOL)show{

if(!show && !self.hasNotifications){
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
  //On lock, increment the self.homeButtonTapCount to accept the next tap, so waking up the device via the home button doesn't break things or whatever is currently wrong with it.
  if(debug) REDLog(@"GDSTOCKLS: homeButtonTapped");

if(self.firstMenuButtonTapForUndim){
switch(self.homeButtonTapCount){
  case 0: 

    self.homeButtonTapCount++;
    break;
  case 1: 

    self.homeButtonTapCount = 0;
    self.firstMenuButtonTapForUndim = FALSE;
    break;
}
return;
}

switch(self.homeButtonTapCount){
  case 0: 

    self.homeButtonTapCount++;
    break;
  case 1: 
      if(!self.showingMediaControls && [self.mediaController hasTrack]){
        [self toggleMediaControls:TRUE];
      }
      else if(self.showingMediaControls){
        [self toggleMediaControls:FALSE];
      }
    self.homeButtonTapCount = 0;
    self.firstMenuButtonTapForUndim = FALSE;
    break;
}

}


-(void)toggleMediaControls:(BOOL)show{
    if(debug) REDLog(@"GDSTOCKLS: toggleMediaControls called");
  if(![self.mediaController hasTrack]){
      return;
  }
  self.showingMediaControls = show;
  [self.view toggleMediaControls:show];

  
  [self nowPlayingInfoChanged];

}



-(void)nowPlayingInfoChanged{
   if(![self.mediaController hasTrack]){
    if(debug) REDLog(@"GDSTOCKLS: nowPlayingInfoChanged - mediaController doesn't have a track!");
    return;
   }
  [self.view nowPlayingInfoChanged];

}





-(void)unlockedDevice{
  self.hasNotifications = FALSE;
  self.canceledTimer = FALSE;

  if(debug) REDLog(@"GDSTOCKLS: unlockedDevice - all done?");
}


-(BOOL)usesStockNotificationList{
  return TRUE;
}

-(void)animateLockKeyPadOutForCancel{
  if(debug) REDLog(@"GDSTOCKLS: animateLockKeyPadOutForCancel called");
  CGRect screenFrame = [[UIScreen mainScreen] bounds];
  self.screenWidth = screenFrame.size.width;
  self.screenHeight = screenFrame.size.height;
  //self.unlocking = FALSE;
  //[self.view.unlockScrollView setContentOffset:CGPointMake(self.screenWidth, 0) animated:TRUE];
  [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{

    [self.view.unlockScrollView setContentOffset:CGPointMake(self.screenWidth, 0) animated: NO];
} completion:^(BOOL finished) {
    self.unlocking = FALSE;
}];

}

-(void)undimScreen{
  if(debug) REDLog(@"GDSTOCKLS: undimScreen called");
  [self.view undimScreen];

    CGRect screenFrame = [[UIScreen mainScreen] bounds];
  self.screenWidth = screenFrame.size.width;
  self.screenHeight = screenFrame.size.height;
  self.canceledTimer = FALSE;
}

-(void)dimScreen{
if(debug) REDLog(@"GDSTOCKLS: dimScreen called");
[self.view dimScreen];


[self toggleMediaControls:FALSE];


self.firstMenuButtonTapCall = TRUE;
self.firstMenuButtonTapForUndim = TRUE;
self.homeButtonTapCount = 0;
self.unlocking = FALSE;

}


-(void)animateLockKeyPadIn{
  //CGRect screenFrame = [[UIScreen mainScreen] bounds];
  //self.screenWidth = screenFrame.size.width;
  //self.screenHeight = screenFrame.size.height;
  //[self.view.unlockScrollView setContentOffset:CGPointMake(0, 0) animated:TRUE];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
 // NSLog(@"ScrollView did scroll to %f", scrollView.contentOffset.x);
  if(self.unlocking){
   // NSLog(@"Unlocking :(");
    return;
  }
  //if(debug) REDLog(@"GDSTOCKLS: scrollViewDidScroll called");
    if(scrollView.contentOffset.x <= 100){
      [self unlock];

    }

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
 if(![[objc_getClass("SBAwayController") sharedAwayController] isDimmed] && !self.canceledTimer){
    [[objc_getClass("SBAwayController") sharedAwayController] cancelDimTimer];
    self.canceledTimer = TRUE;
  }
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{

  if(![[objc_getClass("SBAwayController") sharedAwayController] isDimmed] && [[objc_getClass("SBAwayController") sharedAwayController] isLocked]){
      [[objc_getClass("SBAwayController") sharedAwayController] restartDimTimer:50.0];
      self.canceledTimer = FALSE;
  }
}


-(UIImage *)blurredBackgroundImage{
if([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/SpringBoard/LockBackgroundBlurred.png"]){
  return [UIImage imageWithContentsOfFile:@"/var/mobile/Library/SpringBoard/LockBackgroundBlurred.png"]; //Flags?
}
else{
  return [self.controller backgroundImage]; //Flags?
}
}

-(void)willRotateToInterfaceOrientation:(int)interfaceOrientation duration:(double)duration{
  REDLog(@"GDSTOCKLSDEBUG: willRotateToInterfaceOrientation");
  [self.view layoutSubviews:interfaceOrientation];
}

-(void)willAnimateRotationToInterfaceOrientation:(int)interfaceOrientation duration:(double)duration{
  REDLog(@"GDSTOCKLSDEBUG: willAnimateRotationToInterfaceOrientation");
  [self.view layoutSubviews:interfaceOrientation];
}


-(void)loadPrefs{
  //FIXME: Add more preferences
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
if([[NSFileManager defaultManager] fileExistsAtPath:gdStockLSPrefsPath]){
  NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:gdStockLSPrefsPath];
  if([prefs objectForKey:@"blurAlbumArt"]) self.blurAlbumArt = [[prefs objectForKey:@"blurAlbumArt"] boolValue];
  if([prefs objectForKey:@"tintWallpaper"]) self.tintWallpaper = [[prefs objectForKey:@"tintWallpaper"] boolValue];
  if([prefs objectForKey:@"showAlbumArtUnderlay"]) self.showAlbumArtUnderlay = [[prefs objectForKey:@"showAlbumArtUnderlay"] boolValue];
  [prefs release];
}
else{
NSMutableDictionary *prefs = [[NSMutableDictionary alloc] init];
//[prefs setObject:@"Example 1" forKey:@"lockscreenName"];
[prefs setObject:[NSNumber numberWithBool:FALSE] forKey:@"blurAlbumArt"];
[prefs setObject:[NSNumber numberWithBool:FALSE] forKey:@"tintWallpaper"];
[prefs setObject:[NSNumber numberWithBool:FALSE] forKey:@"showAlbumArtUnderlay"];

[prefs writeToFile:gdStockLSPrefsPath atomically:YES];
[prefs release];
}


[pool drain];
}

-(void)dealloc{ //Clean up your mess
  //[self.view.unlockScrollView release];
  [self.view release];
  /*
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
  */
  //[bannerListController release];
  //[bannerListView release];
  //if(debug) REDLog(@"GDSTOCKLS: unlockedDevice - self.view.unlockScrollView released");
  [super dealloc];
}

@end