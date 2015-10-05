//
//  NewsTableViewController.h
//  RLPriceNew
//
//  Created by Mikola Dyachok on 10/5/15.
//  Copyright © 2015 Mikola Dyachok. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsTableViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) NSMutableArray *newsArray;
@property (strong, nonatomic) IBOutlet UITableView *nTableView;

@end
