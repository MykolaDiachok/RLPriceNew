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

@interface LoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *loginTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *btnConnect;
@property (nonatomic) UIAlertView *theAlert;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *arrayTextField;


@end

@implementation LoginViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        if (!currentUser[@"Enable"]) {
            [PFUser logOutInBackground];
            [self.btnConnect setTitle:@"Connect" forState:(UIControlStateNormal)];
        }
        else{
            [self.btnConnect setTitle:@"Connected" forState:(UIControlStateNormal)];
            for (int x=1; x < [[[self.tabBarController tabBar] items] count]; x++) {
                [[[[self.tabBarController tabBar]  items] objectAtIndex:x]setEnabled:TRUE];
            }
        }
        
    }
    else{
        [self.btnConnect setTitle:@"Connect" forState:(UIControlStateNormal)];
    }
    
    for(UITextField *tempTF in self.arrayTextField)
    {
        tempTF.delegate = self;
    }
    
    PDKeychainBindings *bindings = [PDKeychainBindings sharedKeychainBindings];
    self.loginTextField.text = [bindings objectForKey:@"login"];
    self.passwordTextField.text = [bindings objectForKey:@"password"];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KeyBoard
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for(UITextField *tempTF in self.arrayTextField)
    {
        [tempTF resignFirstResponder];
    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    if (textField.tag==1) {
        [((UITextField *)[self.view viewWithTag:2]) becomeFirstResponder];
        return YES;
    }
    for(UITextField *tempTF in self.arrayTextField)
    {
        [tempTF resignFirstResponder];
    }
    return YES;
}

#pragma mark - Connect
- (IBAction)btConnect:(UIButton *)sender {
    PFUser *currentUser = [PFUser currentUser];
    NSLog(@"%@",currentUser);
    if (currentUser) {
        [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
            [self.btnConnect setTitle:@"Connect" forState:(UIControlStateNormal)];
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
                                                    [self.btnConnect setTitle:@"Connected" forState:(UIControlStateNormal)];
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
