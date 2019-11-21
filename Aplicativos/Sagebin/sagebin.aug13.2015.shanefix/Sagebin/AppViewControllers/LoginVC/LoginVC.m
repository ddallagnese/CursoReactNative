//
//  LoginVC.m
//  Sagebin
//
// 
//  
//

#import "LoginVC.h"
#import "LoginView.h"
#import "HomeViewController.h"

@interface LoginVC ()
{
        LoginView *loginView;
}
@end

@implementation LoginVC

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
    [self setupLoginView];
    
    // check login
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *account = [defaults objectForKey:keyAccount];
    NSLog(@"account = %@", account);
    if (account == nil || [account isEqualToString:@""])
    {
    }
    else
    {
        if (iPhone)
        {
            [APPDELEGATE openHomeViewController];
        }
        else
        {
            UIStoryboard *storyBoard = iPad_storyboard;
            HomeViewController *home =[storyBoard instantiateViewControllerWithIdentifier:@"HomeVC"];
            [APPDELEGATE.navRootCont pushViewController:home animated:YES];
        }
    }
}
-(void)setupLoginView
{
    
        CGRect loginFrame = self.view.frame;
        loginFrame.origin.y = [self.view viewWithTag:TopView_Tag].frame.size.height;
        loginFrame.size.height-=[self.view viewWithTag:TopView_Tag].frame.size.height;
        loginView = [[LoginView alloc]initWithFrame:loginFrame];
        [loginView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [loginView setTag:LoginView_Tag];
        [self.view addSubview:loginView];
    
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
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIButton *btnLogout = [self leftButton];
    [btnLogout setHidden:YES];
    UIButton *btnSettings = [self rightButton];
    [btnSettings setHidden:YES];
    
    //UIScrollView *mainScrollView = (UIScrollView *)[loginView viewWithTag:Login_Main_ScrollView];
    UITextField *txtUserName = (UITextField *)[loginView  viewWithTag:Login_TxtUsernameTag];
    [txtUserName setText:@""];
    UITextField *txtPassword = (UITextField *)[loginView  viewWithTag:Login_TxtPasswordTag];
    [txtPassword setText:@""];
    
    [self setSagebinLogoInCenterForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [loginView didChangeOrientation:([UIApplication sharedApplication].statusBarOrientation)];
}

#pragma mark - Rotation Method
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setSagebinLogoInCenterForOrientation:toInterfaceOrientation];
}

-(void)dealloc
{
    NSLog(@"LoginViewController dealloc called");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
