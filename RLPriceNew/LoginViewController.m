//
//  LoginViewController.m
//  RLPriceNew
//
//  Created by Mikola Dyachok on 10/5/15.
//  Copyright © 2015 Mikola Dyachok. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <PDKeychainBindings.h>

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *loginTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *btnConnect;
@property (nonatomic) UIAlertView *theAlert;


@end

@implementation LoginViewController


- (void)viewDidLoad {
    self.btnConnect.titleLabel.text = @"Connect";
    [super viewDidLoad];
    
    
    PDKeychainBindings *bindings = [PDKeychainBindings sharedKeychainBindings];
    self.loginTextField.text = [bindings objectForKey:@"login"];
    self.passwordTextField.text = [bindings objectForKey:@"password"];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Connect
- (IBAction)btConnect:(UIButton *)sender {
    if ([PFUser currentUser].isAuthenticated) {
        [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
            self.btnConnect.titleLabel.text = @"Connect";
            NSLog(@"%@",@"Diconected");
            for (int x=1; x < [[[self.tabBarController tabBar] items] count]; x++) {
                [[[[self.tabBarController tabBar]  items] objectAtIndex:x]setEnabled:FALSE];
            }
            self.theAlert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                       message:@"Disconected from server"
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
            [self.theAlert show];
        }];
    }
    else{
        
        [PFUser logInWithUsernameInBackground:self.loginTextField.text password:self.passwordTextField.text
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {
                                                NSLog(@"%@",@"Login YES");
                                                [PFConfig getConfigInBackground];
                                                PFUser *currentUser = [PFUser currentUser];
                                                if ((currentUser)&&(currentUser[@"Enable"])) {
                                                    NSLog(@"%@",@"User Enable");
                                                    self.btnConnect.titleLabel.text = @"Connected";
                                                    [currentUser incrementKey:@"RunCount"];
                                                    [currentUser saveInBackground];
                                                    [PFACL setDefaultACL:[PFACL ACL] withAccessForCurrentUser:YES];
                                                    PDKeychainBindings *bindings = [PDKeychainBindings sharedKeychainBindings];
                                                    [bindings setObject:self.loginTextField.text forKey:@"login"];
                                                    [bindings setObject:self.passwordTextField.text forKey:@"password"];
//                                                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//                                                    [userDefaults setValue:self.passwordTextField forKey:@"password"];
//                                                    [userDefaults setValue:self.loginTextField forKey:@"login"];
                                                    
                                                    [[[[self.tabBarController tabBar]items]objectAtIndex:0]setEnabled:YES];
                                                    for (int x=1; x < [[[self.tabBarController tabBar] items] count]; x++) {
                                                        [[[[self.tabBarController tabBar]  items] objectAtIndex:x]setEnabled:TRUE];
                                                    }
                                                    //NSMutableArray *tbViewControllers = [NSMutableArray arrayWithArray:[self.tabBarController viewControllers]];
                                                    //[tbViewControllers removeObjectAtIndex:0];
                                                    //[self.tabBarController setViewControllers:tbViewControllers];
                                                    
                                                    
                                                } else {
                                                    self.theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                               message:@"User login disable"
                                                                                              delegate:self
                                                                                     cancelButtonTitle:@"OK"
                                                                                     otherButtonTitles:nil];
                                                    [self.theAlert show];
                                                }
                                                
                                            } else {
                                                self.theAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                           message:@"Error not working login or password!"
                                                                                          delegate:self
                                                                                 cancelButtonTitle:@"OK"
                                                                                 otherButtonTitles:nil];
                                                [self.theAlert show];
                                                NSLog(@"%@",@"Login NO");
                                            }
                                        }];
    }
    
}



@end
