#import "GDBannerListController.h"
#import "GDBannerCell.h"

/* 
To-Do:
Time since notification occured, have it count up to 1 hour ago, and then switch to the actual time it occured. Cycle every screen wake and stop for each cell once it has reached the full time listing?
Fix layout
Handle multi-line notifications
Work on better animations
Slide to open
*/


#define debug TRUE
@implementation GDBannerListController
@synthesize banners = _banners;

- (id)init
{
    self = [super init];
    if (self) {
        self.banners = [[NSMutableArray alloc] init];
    }
    return self;
}



-(void)reloadCells{
/* Some initial stuff to reload all the cells? */
//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
CGRect screenFrame = [[UIScreen mainScreen] bounds];
float screenWidth = screenFrame.size.width;
float screenHeight = screenFrame.size.height;
//[self.tableView reloadData];
NSArray *insertIndexPaths = [[NSArray alloc] initWithObjects:
        [NSIndexPath indexPathForRow:0 inSection:0],
        nil];

[self.tableView beginUpdates];
[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:FALSE];
//[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:FALSE];
//[self.tableView deleteRowsAtIndexPaths:insertIndexPaths withRowAnimation:FALSE];
//[self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:FALSE];




[self.tableView endUpdates];

[self.tableView beginUpdates];
[self.tableView reloadRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
[insertIndexPaths release];
[self.tableView endUpdates];
//[pool drain];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if(debug) NSLog(@"GDBannerListController: didReceiveMemoryWarning");
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.banners count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!self.banners){
        return NULL;
    }
    static NSString *CellIdentifier = @"GDBannerCell";
    
    GDBannerCell *cell;
    //if (cell == nil) {
        // allocate the cell:
        cell = [[GDBannerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //cell.separatorInset = UIEdgeInsetsMake(0,0,0, cell.bounds.size.width);
        NSString *bundle = [[self.banners objectAtIndex:indexPath.row] valueForKey:@"bundleID"];
        NSString *title = [[self.banners objectAtIndex:indexPath.row] valueForKey:@"title"];
        NSString *message = [[self.banners objectAtIndex:indexPath.row] valueForKey:@"message"];
        NSString *subtitle = [[self.banners objectAtIndex:indexPath.row] valueForKey:@"subtitle"];
        NSString *appName = [[self.banners objectAtIndex:indexPath.row] valueForKey:@"appName"];

        cell.bundleID = [bundle copy];
        cell.title = [title copy];
        cell.message = [message copy];
        cell.subtitle = [subtitle copy];
        cell.appName = [appName copy];
        cell.cellIndex = indexPath.row;
        //cell.offset = self.offset;
        cell.cellHeight = [self cellHeight];
        //cell.cellHighlighted = FALSE;
        //cell.totalCells = [self.banners count];
        //NSLog(@"Loading bundleID: %@", bundle);
        // create a background image for the cell:
        /*
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setSelectionStyle:UITableViewcellsArrayelectionStyleNone];
        [cell setBackgroundView:bgView];
        [cell setIndentationWidth:0.0];
        
        // create a custom label:                                        x    y   width  height
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 8.0, 300.0, 30.0)];
        [nameLabel setTag:1];
        [nameLabel setBackgroundColor:[UIColor clearColor]]; // transparent label background
        [nameLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
        // custom views should be added as subviews of the cell's contentView:
        [cell.contentView addSubview:nameLabel];
         */
    
        
        [cell baseInit];
       
   // }
    
    // Configure the cell:
   // [(UILabel *)[cell.contentView viewWithTag:1] setText:[[self.cellsArray objectAtIndex:indexPath.row] valueForKey:@"mpgDate"]];
    
    return cell;
}

-(float)cellHeight{
        CGRect screenFrame = [[UIScreen mainScreen] bounds];
        float screenWidth = screenFrame.size.width;
        float screenHeight = screenFrame.size.height;
        //float divisor = -(-screenHeight / (screenHeight / (screenHeight / [self.cellsArray count]))) / (100 - ([self.cellsArray count] * 10));
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if([self isHighlightingIndex:indexPath.row]){
    //    return [self cellHeight] * 1.6;
    //}
   // else{
    return [self cellHeight];
    //}
}

/*
-(float)cellHeightForHighlight{
return [self cellHeight] * 1.6;
}

-(BOOL)isHighlightingIndex:(int)index{
    if(self.highlightedIndex == index && shouldHighlightCells){
        return TRUE;
    }
    else{
        return FALSE;
    }
}
*/


@end