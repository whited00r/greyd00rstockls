#import "GDBannerCell.h"
#import "SBApplicationIcon.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore2.h>
#import <QuartzCore/CAAnimation.h>


#define debug TRUE

@implementation UIImage (RoundCorners)
-(UIImage *)roundCorners{
        CGSize imageSize = self.size;
        CGRect imageRect = CGRectMake(0, 0, imageSize.width, imageSize.height);

        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
        // Create the clipping path and add it
        int cropSize;
        int heightOffset = 0;
        int widthOffset = 0;
        if(imageSize.width <= imageSize.height){
            cropSize = floor(imageSize.width);
            heightOffset = (imageSize.height - imageSize.width) / 2;
        }
        else{
            cropSize = floor(imageSize.height);
            widthOffset = (imageSize.width - imageSize.height) / 2;
        }
        CGRect circleRect = CGRectMake(widthOffset, heightOffset, cropSize, cropSize);
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:circleRect];
        [path addClip];


        [self drawInRect:imageRect];
        UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return roundedImage;
}

@end


@implementation GDBannerCell
@synthesize appIconView = _appIconView;
@synthesize previewView = _previewView;
@synthesize bundleID = _bundleID;
@synthesize title = _title;
@synthesize message = _message;
@synthesize subtitle = _subtitle;
@synthesize appName = _appName;
@synthesize appIconImage = _appIconImage;
@synthesize cellIndex = _cellIndex;
@synthesize totalCells = _totalCells;
@synthesize offset;
@synthesize cellHighlighted;
@synthesize holderView = _holderView;
@synthesize cellHeight;
@synthesize appNameLabel = _appNameLabel;
@synthesize titleLabel = _titleLabel;
@synthesize messageLabel = _messageLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //self.offset = 30;
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];

        self.selectedBackgroundView = [UIView new];
        self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)layoutSubviews{
if(debug) NSLog(@"GDBannerCell: layoutSubviews");
    [super layoutSubviews];
 if(debug) NSLog(@"GDBannerCell: layoutSubviews Completed");   

    //self.appIconView.center = CGPointMake(0+centerOffset + (60 / 2), self.frame.size.height / 2);
    //self.holderView.frame = CGRectMake(self.holderView.frame.origin.x, 0,self.frame.size.width, self.frame.size.height);
    //float textWidth =  [self.appNameLabel.text sizeWithFont:self.appNameLabel.font].width;
    //float textHeight = [self.appNameLabel.text sizeWithFont:self.appNameLabel.font].height;
   // self.appNameLabel.frame = CGRectMake(0+centerOffset+ 50 - textWidth -10, 0, textWidth, 60);
    //self.appNameLabel.center = CGPointMake(0 + centerOffset - (textWidth / 2) - 10, self.frame.size.height / 2);
    //self.previewView.center = CGPointMake(0+ centerOffset + (self.previewView.frame.size.width / 2), self.frame.size.height / 2);

    
}

-(void)baseInit{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        CGRect screenFrame = [[UIScreen mainScreen] bounds];
        float screenWidth = screenFrame.size.width;
        float screenHeight = screenFrame.size.height;

        self.holderView = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.frame.size.width, self.frame.size.height)];
        //self.holderView.backgroundColor = [UIColor blueColor];
        self.appIconView = [[UIImageView alloc] initWithFrame:CGRectMake(10,0,30,30)];
        SBApplicationIcon *appIconImage = [[objc_getClass("SBApplicationIcon") alloc] initWithApplication:[[objc_getClass("SBApplicationController") sharedInstance] applicationWithDisplayIdentifier:self.bundleID]];
        self.appIconView.image = [appIconImage getIconImage:1];

        

        //self.appIconView.layer.cornerRadius = self.appIconView.image.size.height / 2;
        //self.appIconView.clipsToBounds = TRUE;
        [appIconImage release];
        [self.contentView addSubview:self.holderView];
        [self.holderView addSubview:self.appIconView];


        
        _appNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, self.frame.size.width - 10, 20)];
        _appNameLabel.text = [[[objc_getClass("SBApplicationController") sharedInstance] applicationWithDisplayIdentifier:self.bundleID] displayName];
        _appNameLabel.textColor = [UIColor whiteColor];
        _appNameLabel.backgroundColor = [UIColor clearColor];
        _appNameLabel.textAlignment = NSTextAlignmentLeft;
        _appNameLabel.font = [UIFont boldSystemFontOfSize:16];

      
        [self.holderView addSubview:self.appNameLabel];
        [self.appNameLabel release];


        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 22, self.frame.size.width - 10, 10)];
        _titleLabel.text = self.title;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont boldSystemFontOfSize:12];

       
        [self.holderView addSubview:self.titleLabel];
        [self.titleLabel release];

        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 18, self.frame.size.width - 10, 60)];
        _messageLabel.text = self.message;
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.textAlignment = NSTextAlignmentLeft;
        _messageLabel.font = [UIFont systemFontOfSize:16];

 
       
        [self.holderView addSubview:self.messageLabel];
        [self.messageLabel release];
        
        /*
        self.appNameLabel = [CATextLayer layer];
        self.appNameLabel.frame = CGRectMake(0, 0, 100, 60);
        self.appNameLabel.foregroundColor = [UIColor whiteColor].CGColor;
        self.appNameLabel.string = [[[objc_getClass("SBApplicationController") sharedInstance] applicationWithDisplayIdentifier:self.bundleID] displayName];
        self.appNameLabel.font = [UIFont systemFontOfSize:8];
        self.appNameLabel.alignmentMode = kCAAlignmentCenter;
        //self.appNameLabel.wrapped = true;

        blurHolder = [[UIView alloc] initWithFrame:CGRectMake(0 + centerOffset + 30,0, 100, 60)];
        self.appNameLabelOverlay = [[objc_getClass("_UIBackdropView") alloc] initWithFrame:CGRectMake(0,0, 100, 60) privateStyle:3];;
        //[self.appNameLabelOverlay setCenter:CGPointMake(320/2, -320)];
        //self.appNameLabelOverlay.backgroundColor = [UIColor blueColor];
        blurHolder.backgroundColor = [UIColor colorWithRed:0/255 green:0/255 blue:0/255 alpha:0.5];
        blurHolder.layer.mask = self.appNameLabel;
        [blurHolder addSubview:self.appNameLabelOverlay];
        [self addSubview:blurHolder];
        [blurHolder release];
        [self.appNameLabelOverlay release];
        */


        [pool drain];
}


@end