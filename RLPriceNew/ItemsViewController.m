//
//  ItemsViewController.m
//  RLPriceNew
//
//  Created by Mikola Dyachok on 10/5/15.
//  Copyright © 2015 Mikola Dyachok. All rights reserved.
//

#import "ItemsViewController.h"
#import "ItemViewController.h"
#import <UIImageView+WebCache.h>




@interface ItemsViewController ()<UISearchBarDelegate, UISearchResultsUpdating>

@property (nonatomic) UISearchController *searchController;
@property (atomic) NSMutableArray *curentBasket;

@end

@implementation ItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.curentBasket = [[NSMutableArray alloc] init];
    //    self.title = self.curGroup[@"name"];
    [self setupSearchBar];
    self.curentBasket = [NSMutableArray new];
    //	[self createArrayBasket];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        
        self.parseClassName = @"ParseItems";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
        
    }
    return self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"segueItem"]) {
        if ([segue.destinationViewController isKindOfClass:[ItemViewController class]]){
            PFObject *curItem = (PFObject*)[self objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
            ItemViewController* mvc = [segue destinationViewController];
            mvc.curItem =curItem;
        }
    }
    
}

-(void) createArrayBasket{
    self.curentBasket = [NSMutableArray new];
    PFQuery *basketQuery = [PFQuery queryWithClassName:@"Basket"]; //Запрос в корзину для поиска
    [basketQuery includeKey:@"ParseItems"];
    [basketQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [basketQuery whereKey:@"sent" equalTo:@NO];
    
    //	@synchronized(self.curentBasket) {
    [basketQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError *error) {
        
        for (PFObject *tBasket in objects) {
            PFObject *tItem = tBasket[@"parseItem"];
            
            NSDictionary *dBasket = @{
                                      @"Basket":tBasket.objectId,
                                      @"quantity":tBasket[@"quantity"],
                                      @"item":tItem.objectId
                                      };
            
            [self.curentBasket addObject:dBasket];
            
        }
        //			NSLog(@"%@",self.curentBasket);
        
    }];
    //	}
}

- (PFQuery *)queryForTable
{
    if (self.curGroup!=nil) {
        self.title = self.curGroup[@"name"];
    }
    else if (self.titleInfo!=nil){
        self.title = self.titleInfo;
    }
    
    [self createArrayBasket];
    PFQuery *queryItems = [PFQuery queryWithClassName:self.parseClassName];
    if (self.curGroup!=nil) {
        [queryItems whereKey:@"Availability" equalTo: @YES];
        [queryItems whereKey:@"parseGroupId" equalTo:self.curGroup];
    }
    else if (self.pfrelationItems!=nil){
        queryItems = self.pfrelationItems.query;
        //		[queryItems whereKey:@"objectId" containedIn:self.arrayItems];
    }
    if (self.searchController.searchBar.text.length) {
        [queryItems whereKey:@"Name" matchesRegex: self.searchController.searchBar.text modifiers:@"mi"];
        queryItems.cachePolicy = kPFCachePolicyIgnoreCache;
    }
    else{
        queryItems.cachePolicy = kPFCachePolicyCacheThenNetwork;
        queryItems.maxCacheAge=60*60;
    }
    
    
    
    
    [queryItems orderByAscending:@"sortcode"];
    return queryItems;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *CellIdentifier = @"Items";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    UILabel *itemName = (UILabel *)[cell viewWithTag:1];
    itemName.text = [NSString stringWithFormat:@"%@",object[@"Name"]];
    itemName.numberOfLines = 0;
    //[itemName sizeToFit];
    //itemName.lineBreakMode = NSLineBreakByWordWrapping;
    
    
    UILabel *labelUSD = (UILabel *)[cell viewWithTag:3];
    labelUSD.text = [NSString stringWithFormat:@"$%.02f", [object[@"Price"] floatValue]];
    
    UILabel *labelUAH = (UILabel *)[cell viewWithTag:4];
    labelUAH.text = [NSString stringWithFormat:@"₴%.02f", [object[@"PriceUAH"] floatValue]];
    UILabel *labelQuatity = (UILabel *)[cell viewWithTag:5];
    
    NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", @"item", object.objectId];
    NSArray *filtered = [self.curentBasket filteredArrayUsingPredicate:predicateString];
    if (filtered.count>0) {
        labelQuatity.text = [NSString stringWithFormat:@"%@", [filtered[0] objectForKey:@"quantity"]];
        NSLog(@"%@",[filtered[0] objectForKey:@"quantity"]);
    }
    else
    {
        labelQuatity.text = @"";
    }
    
    
    UIImageView *itemImage = (UIImageView *)[cell viewWithTag:2];
    
    PFFile *theImage = [object objectForKey:@"image"];
    
    
//    [itemImage setShowActivityIndicatorView:YES];
//    [itemImage setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [itemImage sd_setImageWithURL:[NSURL URLWithString:theImage.url ]
                 placeholderImage:[UIImage imageNamed:@"placeholder"]];
    [itemImage setContentMode:UIViewContentModeScaleAspectFit];
    
    
    
    
    
    
    return cell;
}


-(CGFloat)dynamicLblHeight:(UILabel *)lbl
{
    CGFloat lblWidth = lbl.frame.size.width;
    CGRect lblTextSize = [lbl.text boundingRectWithSize:CGSizeMake(lblWidth, MAXFLOAT)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName:lbl.font}
                                                context:nil];
    return lblTextSize.size.height;
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

- (IBAction)btnAddItem:(UIButton *)sender {
    //    NSLog(@"%@",sender);
    CGPoint buttonPostion = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:buttonPostion];
    if (indexPath!=nil) {
        PFObject* tObject = [self objectAtIndexPath:indexPath];//находим объект товара в таблице
        NSNumber *curQuantity = nil;
        
        @synchronized(self.curentBasket) {
            NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", @"item", tObject.objectId];
            NSArray *filtered = [self.curentBasket filteredArrayUsingPredicate:predicateString];
            if (filtered.count>0) {
                
                long quantity =[[filtered[0] objectForKey:@"quantity"] longValue]+1;
                curQuantity = [NSNumber numberWithLong:quantity];
                
                PFQuery *qBasket = [PFQuery queryWithClassName:@"Basket"];
                
                [qBasket getObjectInBackgroundWithId:[filtered[0] objectForKey:@"Basket"] block:^(PFObject * _Nullable object, NSError * _Nullable error) {
                    if (object[@"quantity"]!=curQuantity) {
                        object[@"quantity"]=curQuantity;
                        [object saveInBackground];
                    }
                    
                }];
                
                
                NSMutableDictionary * m = [filtered[0] mutableCopy];
                [m setObject:curQuantity forKey:@"quantity"];
                [self.curentBasket replaceObjectAtIndex:[self.curentBasket indexOfObject:filtered[0]] withObject:m];
                
                
                //				NSLog(@"%@",[filtered[0] objectForKey:@"quantity"]);
            }
            else
            {
                PFObject *newBasket = [PFObject objectWithClassName:@"Basket"];
                newBasket[@"user"]= [PFUser currentUser];
                newBasket[@"sent"]=@NO;
                newBasket[@"quantity"]=@1;
                newBasket[@"name"]=tObject[@"Name"];
                newBasket[@"sortcode"]=tObject[@"sortcode"];
                newBasket[@"parseGroupId"]=tObject[@"parseGroupId"];
                newBasket[@"productId"]=tObject[@"ItemId"];
                newBasket[@"requiredpriceUSD"]=tObject[@"Price"];
                newBasket[@"requiredpriceUAH"]=tObject[@"PriceUAH"];//tObject[@"PriceUAH"];
                newBasket[@"parseItem"]=tObject;
                
                newBasket.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                
                
                
                
                [newBasket save];
                
                
                NSDictionary *dBasket = @{
                                          @"Basket":newBasket.objectId,
                                          @"quantity":@1,
                                          @"item":tObject.objectId
                                          };
                
                [self.curentBasket addObject:dBasket];
                
                
                curQuantity = @1;
            }
        }
        
        UITableViewCell* cell = (UITableViewCell*)[sender superview]; // до обновления обновим лабел
        UILabel *labelQuatity = (UILabel *)[cell viewWithTag:5];
        labelQuatity.text = [NSString stringWithFormat:@"%@", curQuantity];
    }
    
    
    
}

- (IBAction)btnDelItem:(UIButton *)sender {
    NSLog(@"%@",sender);
    
    
    CGPoint buttonPostion = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:buttonPostion];
    if (indexPath!=nil) {
        
        PFObject* tObject = [self objectAtIndexPath:indexPath];//находим объект товара в таблице
        NSNumber *curQuantity = nil;
        
        @synchronized(self.curentBasket) {
            NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", @"item", tObject.objectId];
            NSArray *filtered = [self.curentBasket filteredArrayUsingPredicate:predicateString];
            if (filtered.count>0) {
                long quantity =[[filtered[0] objectForKey:@"quantity"] longValue]-1;
                if (quantity<=0) {
                    quantity=0;
                }
                curQuantity = [NSNumber numberWithLong:quantity];
                
                PFQuery *qBasket = [PFQuery queryWithClassName:@"Basket"];
                
                [qBasket getObjectInBackgroundWithId:[filtered[0] objectForKey:@"Basket"] block:^(PFObject * _Nullable object, NSError * _Nullable error) {
                    if (object[@"quantity"]!=curQuantity) {
                        object[@"quantity"]=curQuantity;
                        [object saveInBackground];
                    }
                }];
                
                
                NSMutableDictionary * m = [filtered[0] mutableCopy];
                [m setObject:curQuantity forKey:@"quantity"];
                [self.curentBasket replaceObjectAtIndex:[self.curentBasket indexOfObject:filtered[0]] withObject:m];
                
                UITableViewCell* cell = (UITableViewCell*)[sender superview]; // до обновления обновим лабел
                UILabel *labelQuatity = (UILabel *)[cell viewWithTag:5];
                labelQuatity.text = [NSString stringWithFormat:@"%@", curQuantity];
                
                //				NSLog(@"%@",[filtered[0] objectForKey:@"quantity"]);
            }
        }
        
        
        
        //		PFObject* tObject = [self objectAtIndexPath:indexPath];//находим объект товара в таблице
        //
        //		PFQuery *query = [PFQuery queryWithClassName:@"Basket"]; //Запрос в корзину для поиска
        //		[query whereKey:@"user" equalTo:[PFUser currentUser]];
        //		[query whereKey:@"sent" equalTo:@NO];
        //		[query whereKey:@"parseItem" equalTo:tObject];
        //
        //		PFObject * basket = [query getFirstObject]; // Тут возникла ситуация если работать с background возможны ситуации когда товар задвоиться или затроиться
        //		if (basket) {
        //			if ([basket[@"quantity"] doubleValue] <=1) {
        //				basket[@"quantity"]=@0;
        //				[basket save]; // инкримент может делать в background проблем нет
        //
        //				//				UITableViewCell* cell = (UITableViewCell*)[sender superview]; // до обновления обновим лабел
        //				//				UILabel *labelQuatity = (UILabel *)[cell viewWithTag:5];
        //				//				labelQuatity.text = [NSString stringWithFormat:@"%@", @0];
        //			}
        //			else
        //			{
        //				//			[basket incrementKey:@"quantity"];
        //				[basket incrementKey:@"quantity" byAmount:@-1];
        //				[basket save]; // инкримент может делать в background проблем нет
        //
        //				//				UITableViewCell* cell = (UITableViewCell*)[sender superview]; // до обновления обновим лабел
        //				//				UILabel *labelQuatity = (UILabel *)[cell viewWithTag:5];
        //				//				labelQuatity.text = [NSString stringWithFormat:@"%@", @([[labelQuatity text] integerValue]-1)];
        //			}
        //		}
        //		//		else
        //		//		{
        //		//			UITableViewCell* cell = (UITableViewCell*)[sender superview]; // до обновления обновим лабел
        //		//			UILabel *labelQuatity = (UILabel *)[cell viewWithTag:5];
        //		//			labelQuatity.text = [NSString stringWithFormat:@"%@", @0];
        //		//		}
        //
        //		[self.tableView reloadData];
        
        
        
    }
    
    
}

@end
