//
//  ItemsViewController.h
//  RLPriceNew
//
//  Created by Mikola Dyachok on 10/5/15.
//  Copyright © 2015 Mikola Dyachok. All rights reserved.
//

#import "PFQueryTableViewController.h"
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>

@interface ItemsViewController : PFQueryTableViewController<UISearchBarDelegate>

@property (nonatomic) PFObject *curGroup;
@property (nonatomic) PFRelation *pfrelationItems;
@property (nonatomic) NSString *titleInfo;

@end
