//
//  GroupsTableViewController.m
//  RLPriceNew
//
//  Created by Mikola Dyachok on 10/5/15.
//  Copyright © 2015 Mikola Dyachok. All rights reserved.
//

#import "GroupsTableViewController.h"
#import "ItemsViewController.h"

@interface GroupsTableViewController () <UISearchBarDelegate, UISearchResultsUpdating>
@property (nonatomic) UISearchController *searchController;

@end

@implementation GroupsTableViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        // Custom the table
        
        // The className to query on
        self.parseClassName = @"ParseGroups";
        
        // The key of the PFObject to display in the label of the default cell style
        //        self.textKey = @"nombrePanaderia";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 25;
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSearchBar];
    
    
}


- (void)setupSearchBar{
    if (!self.tableView.allowsMultipleSelection) {
        //------------search bar------------------------//
        self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        self.searchController.searchResultsUpdater = self;
        self.searchController.dimsBackgroundDuringPresentation = NO;
        self.searchController.searchBar.delegate = self;
        self.tableView.tableHeaderView = self.searchController.searchBar;
        self.definesPresentationContext = YES;
        [self.searchController.searchBar sizeToFit];
    }
    
}

- (PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    [query whereKey:@"Enable" equalTo: @YES];
    if (self.searchController.searchBar.text.length) {
        //		[query whereKey:@"name" containsString: [self.searchController.searchBar.text lowercaseString]];
        [query whereKey:@"name" matchesRegex:self.searchController.searchBar.text modifiers:@"mi"];
        query.cachePolicy = kPFCachePolicyIgnoreCache;
    }
    else{
        
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        query.maxCacheAge=60*60;
        
    }
    NSLog(@"%@", self.searchController.searchBar.text);
    [query orderByAscending:@"sortcode"];
    
    return query;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *CellIdentifier = @"FirstGroups";
    static NSString *CellSecond = @"SecondGroups";
    UITableViewCell *cell;
    
    if (![object[@"firstGroup"] boolValue]){
        
        cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellSecond];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellSecond];
        }
    }
    else
    {
        cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    }
    // Configure the cell
    
    //    NSLog(@"%@",object[@"name"]);
    
    //    UIView *selectionColor = [[UIView alloc] init];
    //    selectionColor.backgroundColor = [UIColor colorWithRed:(245/255.0) green:(245/255.0) blue:(245/255.0) alpha:1];
    //    cell.selectedBackgroundView = selectionColor;
    
    UILabel *groupName = (UILabel *)[cell viewWithTag:1];
    groupName.text = [NSString stringWithFormat:@"%@",object[@"name"]];
    
    
    
    
    return cell;
}

//http://stackoverflow.com/questions/27253685/paging-pfquerytableviewcontroller-automatically

- (IBAction)nextPage:(id)sender
{
    [self loadNextPageInTable];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    
    
    
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    float reload_distance = 15;
    if(y > h + reload_distance) {
        //        NSLog(@"load more rows");
        [self loadNextPageInTable];
    }
}

-(void) loadNextPageInTable {
    
    [self loadNextPage];
    //    NSLog(@"NEW PAGE LOADED");
}




- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    [self loadObjects];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if (([segue.identifier isEqualToString:@"segueFirstGroup"])||([segue.identifier isEqualToString:@"segueSecondGroup"])) {
        if ([segue.destinationViewController isKindOfClass:[ItemsViewController class]]){
            PFObject *curObject = (PFObject*)[self objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
            ItemsViewController* mvc = [segue destinationViewController];
            mvc.curGroup =curObject;
            
            
        }
    }
}

@end
