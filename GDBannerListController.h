#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

/* 

Eh, iOS 7 table view anyone? Might have been easier to just grab the existing table view and hook that, but this is more fun ;)

*/

@interface GDBannerListController : UITableViewController <UITableViewDelegate>{
NSMutableArray *_banners;
}

-(void)viewDidLoad;
-(void)reloadCells;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

@property(nonatomic, retain) NSMutableArray *banners;
@end