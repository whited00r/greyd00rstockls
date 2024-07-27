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


#define debug TRUE

@interface UILabel (FSHighlightAnimationAdditions)

- (void)setTextWithChangeAnimation:(NSString*)text;

@end


@implementation UILabel (FSHighlightAnimationAdditions)

- (void)setTextWithChangeAnimation:(NSString*)text
{
   
    self.text = text;
    CALayer *maskLayer = [CALayer layer];

    // Mask image ends with 0.15 opacity on both sides. Set the background color of the layer
    // to the same value so the layer can extend the mask image.
    //maskLayer.backgroundColor = [[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.25f] CGColor];
    maskLayer.contents = (id)[[UIImage imageWithContentsOfFile:@"/Library/liblockscreen/Lockscreens/Greyd00rStockLS.bundle/Mask.png"] CGImage]; 

    // Center the mask image on twice the width of the text layer, so it starts to the left
    // of the text layer and moves to its right when we translate it by width.
    maskLayer.contentsGravity = kCAGravityCenter;
    maskLayer.frame = CGRectMake(self.frame.size.width * -1, 0.0f, self.frame.size.width * 2, self.frame.size.height);




CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
animationGroup.duration = 3.0f;
animationGroup.repeatCount = INFINITY;


    // Animate the mask layer's horizontal position
    CABasicAnimation *maskAnim = [CABasicAnimation animationWithKeyPath:@"position.x"];
    maskAnim.byValue = [NSNumber numberWithFloat:self.frame.size.width];
    //maskAnim.repeatCount = HUGE_VALF;
    maskAnim.duration = 2.5f;

animationGroup.animations = @[maskAnim];

[maskLayer addAnimation:animationGroup forKey:@"slideAnim"];


    //[maskLayer addAnimation:maskAnim forKey:@"slideAnim"];

    self.layer.mask = maskLayer;
}

@end

@interface SBAwayBulletinListController


@end

@interface SBAwayBulletinListView : UIScrollView

@end


@interface SBBulletinCellContentViewBase 
-(void)setShadowColor:(UIColor*)color;
@end



 //This tints without blending the images together properly... Although I may have fixed it using voodoo.
@interface UIImage (Tint)

- (UIImage *)tintedImageUsingColor:(UIColor *)tintColor alpha:(float)alpha;

@end

@implementation UIImage (Tint)

- (UIImage *)tintedImageUsingColor:(UIColor *)tintColor alpha:(float)alpha {
  UIGraphicsBeginImageContext(self.size);
  CGRect drawRect = CGRectMake(0, 0, self.size.width, self.size.height);
  [self drawInRect:drawRect blendMode:kCGBlendModeNormal alpha:alpha];

  [tintColor set];
  UIRectFillUsingBlendMode(drawRect, kCGBlendModeColor);

  [self drawInRect:drawRect blendMode:kCGBlendModeDestinationIn alpha:1.0f];
  UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return tintedImage;
}

@end


@class Greyd00rStockLockScreen;
@interface Greyd00rStockLSView : UIView {
  UILabel *timeLabel;
  UILabel *dateLabel;
  UILabel *unlockLabel;
  UIImage *normalWallpaper;
  UIImage *blurredWallpaper;
  UIImageView *wallpaperView;
  UITableView *bannerListView;
  SBAwayBulletinListController *notificationList;
  SBAwayDateView *dateView;
  GDBannerListController *bannerListController;
  UIView *dimOverlay;
  UIView *mediaControlsHolder;
  UIButton *mediaPausePlayButton;
  UIButton *mediaForwardButton;
  UIButton *mediaPreviousButton;
  UILabel *mediaArtistAlbumLabel;
  UILabel *mediaSongLabel;
  UILabel *unlockShadeLabel;
  UIImageView *mediaAlbumImageView;
  UIImageView *mediaAlbumImageViewUnderlay;
  SBMediaController *mediaController;
  UIView *blurDim;
  BOOL backgroundBlurred;
  BOOL hasNotifications;
  float screenWidth;
  float screenHeight;
  BOOL canceledTimer;
  BOOL unlocking;
  BOOL isFirstUndimAfterWake;
  BOOL showingMediaControls;
  BOOL firstMenuButtonTapCall;
  BOOL firstMenuButtonTapForUndim;
  int homeButtonTapCount;
  int homeButtonTapCountForUndim;
  int currentOrientation;
}
@property (nonatomic, assign) LibLSController *lsController;
@property (nonatomic, assign) Greyd00rStockLockScreen *controller;
@property (nonatomic, assign) GDScrollUnlockView *unlockScrollView;

-(UIView *)initWithFrame:(CGRect)frame controller:(Greyd00rStockLockScreen*)controller lsController:(LibLSController*)lsController; //Required
-(void)blurBackground:(BOOL)blur;
-(void)updateClockWithTime:(NSString*)time andDate:(NSString*)date;
-(void)receivedNotification:(NSMutableDictionary *)notification;

-(void)passcodeAccepted;
//-(void)unlockedDevice;
-(BOOL)usesStockNotificationList;
-(void)showBulletinView;
-(void)insertBulletinView;
-(void)showPasscodeScreen:(BOOL)show;
-(void)animateLockKeyPadIn;
-(void)animateLockKeyPadOutForCancel;
-(void)undimScreen;
-(void)dimScreen;
-(UIImage*)blurredBackgroundImage;
-(void)configureAndPositionNotificationList;
-(void)homeButtonTapped; //Hmmmm
-(void)toggleMediaControls:(BOOL)show;
-(void)nowPlayingInfoChanged;
-(void)togglePlayback:(UIButton*)sender;
-(void)loadPrefs;
@end