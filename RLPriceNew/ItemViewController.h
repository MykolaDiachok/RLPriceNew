//
//  ItemViewController.h
//  RLPriceNew
//
//  Created by Mikola Dyachok on 10/5/15.
//  Copyright © 2015 Mikola Dyachok. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ItemViewController : UIViewController
@property (nonatomic) PFObject *curItem;
@end
