//
//  RegistrationVC.m
//  Sagebin
//
//  Created by hyperlink on 15/10/14.
//  Copyright (c) 2014  . All rights reserved.
//

#import "RegistrationVC.h"
#import "RegisterView.h"

@interface RegistrationVC ()
{
    RegisterView *registerView;
}

@end

@implementation RegistrationVC
@synthesize tempInvitationCode,tempUserData;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:LoginBgColor];
    
    // Do any additional setup after loading the view.
    [self setupRegisterView];
}
-(void)viewWillDisappear:(BOOL)animated
{
    for (UIView *v in self.view.subviews)
    {
      
            if([v isKindOfClass:[UITextField class]])
            {
                [v resignFirstResponder];
            }
       
    }
}
-(void)setupRegisterView
{
    
    CGRect RegisterFrame = self.view.frame;
    RegisterFrame.origin.y = [self.view viewWithTag:TopView_Tag].frame.size.height;
    RegisterFrame.size.height-=[self.view viewWithTag:TopView_Tag].frame.size.height;
    registerView = [[RegisterView alloc]initWithFrame:RegisterFrame];
    [registerView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [registerView setTag:RegisterView_Tag];
    registerView.userData=tempUserData;
    registerView.invitationCode=tempInvitationCode;
    [self.view addSubview:registerView];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    UIButton *btnSettings = [self rightButton];
    [btnSettings setHidden:YES];
    
     [self setSagebinLogoInCenterForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}
#pragma mark - Rotation Method
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setSagebinLogoInCenterForOrientation:toInterfaceOrientation];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
