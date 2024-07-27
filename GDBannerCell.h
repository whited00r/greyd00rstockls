#import <UIKit/UIKit.h>

@interface GDBannerCell : UITableViewCell{
UIImageView *_appIconView;
UIImageView *_previewView;
NSString *_bundleID;
NSString *_message;
NSString *_subtitle;
NSString *_title;
NSString *_appName;
UIImage *_appIconImage;
UILabel *_appNameLabel;
int _cellIndex;
int _totalCells;
float offset;
BOOL cellHighlighted;
UIView *_holderView;
UIImage *normalPreviewImage;
UIImage *circlePreviewImage;
UILabel *appName;
UILabel *_titleLabel;
UILabel *_messageLabel;


float cellHeight;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
-(void)baseInit;
-(void)highlight:(BOOL)highlight;
-(void)highlightForNonFocus:(BOOL)highlight;
-(void)bounce;
@property(nonatomic, retain) UIImageView *appIconView;
@property(nonatomic, retain) UIImageView *previewView;
@property(nonatomic, retain) NSString *bundleID;
@property(nonatomic, retain) NSString *message;
@property(nonatomic, retain) NSString *subtitle;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *appName;
@property(nonatomic, retain) UIImage *appIconImage;
@property(nonatomic, assign) int cellIndex;
@property(nonatomic, assign) int totalCells;
@property(nonatomic, assign) float offset;
@property(nonatomic, assign) float cellHeight;
@property(nonatomic, assign) BOOL cellHighlighted;
@property(nonatomic, retain) UIView *holderView;
@property(nonatomic, retain) UILabel *appNameLabel;
@property(nonatomic, retain) UILabel *titleLabel;
@property(nonatomic, retain) UILabel *subtitleLabel;
@property(nonatomic, retain) UILabel *messageLabel;
@end
