#import <UIKit/UIKit.h>

/*
GDScrollUnlockView
Copyright Grayd00r 2015
For use in Greyd00r
This is just a simple subclass of UIScrollView which hopefully will implement the sort of physics that the iOS 7 + unlock screen has.


*/

@interface GDScrollUnlockView : UIScrollView <UIScrollViewDelegate>
-(id)initWithFrame:(CGRect)frame;



@property(nonatomic, retain) UILabel *subtitleLabel;
@property(nonatomic, retain) UILabel *messageLabel;
@end
