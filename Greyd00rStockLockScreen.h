#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Greyd00rStockLSView.h"

@interface Greyd00rStockLockScreen : NSObject <LibLockscreen>{
 
}
@property (nonatomic, assign) Greyd00rStockLSView *view;
@property (nonatomic, assign) LibLSController *controller;
@property (nonatomic, assign) SBMediaController *mediaController;
@property (nonatomic, assign) BOOL backgroundBlurred;
@property (nonatomic, assign) BOOL hasNotifications;
@property (nonatomic, assign) BOOL blurAlbumArt;
@property (nonatomic, assign) BOOL showAlbumArtUnderlay;
@property (nonatomic, assign) BOOL tintWallpaper;
@property (nonatomic, assign) float screenWidth;
@property (nonatomic, assign) float screenHeight;
@property (nonatomic, assign) BOOL canceledTimer;
@property (nonatomic, assign) BOOL unlocking;
@property (nonatomic, assign) BOOL isFirstUndimAfterWake;
@property (nonatomic, assign) BOOL showingMediaControls;
@property (nonatomic, assign) BOOL firstMenuButtonTapCall;
@property (nonatomic, assign) BOOL firstMenuButtonTapForUndim;
@property (nonatomic, assign) int homeButtonTapCount;
@property (nonatomic, assign) int homeButtonTapCountForUndim;
-(Greyd00rStockLockScreen *)initWithController:(LibLSController*)controller;

-(float)liblsVersion; //Required
-(void)updateClockWithTime:(NSString*)time andDate:(NSString*)date;
-(void)receivedNotification:(NSMutableDictionary *)notification;
-(void)unlock;
//-(void)showMediaControls:(BOOL)show;

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
-(void)willRotateToInterfaceOrientation:(int)interfaceOrientation duration:(double)duration;
-(void)willAnimateRotationToInterfaceOrientation:(int)interfaceOrientation duration:(double)duration;
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
@end


