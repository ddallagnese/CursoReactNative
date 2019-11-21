//
//  RootViewController.m
//  Sagebin
//
//  
//  
//

#import "RootViewController.h"
#import "SettingsViewController.h"
#import "AlertViewController.h"
#import "CastViewController.h"

#define kFriendsBtnWidth (iPhone?130:280)
#define kFriendLblWidth (iPhone?90:200)

@interface RootViewController ()

@end

@implementation RootViewController

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
    [self setupTopBar];
    [self setupViewTitle];
}
-(void)setupViewTitle
{
    UIView *topView = [self.view viewWithTag:TopView_Tag];
    
    UIImage *imgName = [UIImage imageNamed:@"help"];
    
    CGFloat starViewHeight = (iPad ? 40 : 28);
    
    UIImageView *imgView = [[UIImageView alloc]initWithImage:imgName];
    [imgView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [imgView setFrame:CGRectMake(14, topView.frame.size.height+10, starViewHeight, starViewHeight)];
    [imgView setTag:TOP_ViewImage_Tag];
    [imgView setHidden:YES];
    [self.view addSubview:imgView];
    
    //JM 1/7/2014
    //change width of lable for ipad.
    UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(imgView.frame.origin.x+imgView.frame.size.width+5, topView.frame.size.height+(iPad?13:8), (iPhone?110:230), 30)];
    //
    [lbl setFont:[APPDELEGATE Fonts_OpenSans_Light:(iPad?28:13)]];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [lbl setTag:TOP_ViewLbl_Tag];
    [lbl setHidden:YES];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:lbl];
    
    CustomButton *btnFriends = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(self.view.frame.size.width - kFriendsBtnWidth - 20, topView.frame.size.height, kFriendsBtnWidth, 44.0) withTitle:nil withImage:nil withTag:Top_FriendsBtn_Tag Font:nil BGColor:[UIColor clearColor]];
    [btnFriends setHidden:YES];
    //[btnFriends setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self.view addSubview:btnFriends];
    
    UIImage *frndsImg = [UIImage imageNamed:@"icon_friendlist"];
    UIImageView *imgViewFrnds = [[UIImageView alloc]initWithFrame:CGRectMake(0, btnFriends.frame.size.height/2-28/2, starViewHeight, starViewHeight)];
    [imgViewFrnds setImage:frndsImg];
    [imgViewFrnds setTag:Top_FriendsImgVw_Tag];
    [btnFriends addSubview:imgViewFrnds];
    
    lbl = [[UILabel alloc]initWithFrame:CGRectMake(imgViewFrnds.frame.origin.x+imgViewFrnds.frame.size.width+5, btnFriends.frame.size.height/2-(iPad?20:30)/2, (iPhone?110:230), 30)];
    [lbl setFont:[APPDELEGATE Fonts_OpenSans_Light:(iPad?28:13)]];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTag:Top_FriendsLbl_Tag];
    [lbl setText:NSLocalizedString(@"lblFriends", nil)];
    [lbl setNumberOfLines:2];
    [btnFriends addSubview:lbl];
}
-(void)setupTopBar
{
    UIView *topView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), KTopBarHeight) bgColor:TopBgColor tag:TopView_Tag alpha:1.0];
    [topView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    UIButton *btnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:@"back"];
    CGFloat yPos = topView.frame.size.height/2 - (iPad?56:28)/2;
    [btnLeft setImage:img forState:UIControlStateNormal];
    btnLeft.frame = CGRectMake((iPad?13:2), (iOS7?yPos+10:yPos), (iPad?31:28), (iPad?56:28));
    [btnLeft setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
    [btnLeft addTarget:self action:@selector(btnBackClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btnLeft setTag:Top_QRView_Tag];
    [topView addSubview:btnLeft];
    
    img = [UIImage imageNamed:@"new_icon_cast_off"];
    yPos = topView.frame.size.height/2 - img.size.height/2;
    UIButton *btnCast = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCast setImage:img forState:UIControlStateNormal];
    btnCast.frame = CGRectMake(btnLeft.frame.origin.x + btnLeft.frame.size.width + (iPad?15:7), (iOS7?yPos+10:yPos), img.size.width, img.size.height);
    [btnCast setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
    [btnCast addTarget:self action:@selector(btnCastClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btnCast setTag:Top_CastBtn_Tag];
    [btnCast setHidden:YES];
    [topView addSubview:btnCast];
    
    img = [UIImage imageNamed:@"top_logo"];
    NSInteger imgX = self.view.frame.size.width/2 - img.size.width/2;
    UIImageView *centerImageV =[[UIImageView alloc]initWithImage:img];
    centerImageV.frame = CGRectMake(imgX, KAppStatusBarHeight+10, img.size.width, img.size.height);
    [centerImageV setTag:Top_Logo_Tag];
    [topView addSubview:centerImageV];
    [self.view addSubview:topView];
    
    UIButton *btnAlert = [UIButton buttonWithType:UIButtonTypeCustom];
    img = [UIImage imageNamed:@"notification"];
    [btnAlert setImage:img forState:UIControlStateNormal];
    yPos = topView.frame.size.height/2 - img.size.height/2;
    btnAlert.frame = CGRectMake(self.view.frame.size.width-(img.size.width*2.0)-(iPhone?20:32), (iOS7?yPos+10:yPos), img.size.width, img.size.height);
    [btnAlert addTarget:self action:@selector(btnAlertClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btnAlert setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
    [btnAlert setTag:Top_ButtonAlert_Tag];
    [btnAlert setHidden:YES];
    [topView addSubview:btnAlert];
    
    UIButton *btnClaim = [UIButton buttonWithType:UIButtonTypeCustom];
    img = [UIImage imageNamed:@"notification"];
    //[btnClaim setImage:img forState:UIControlStateNormal];
    yPos = topView.frame.size.height/2 - img.size.height/2;
    btnClaim.frame = CGRectMake(self.view.frame.size.width-(img.size.width*4.0)-(iPhone?20:32), (iOS7?yPos+10:yPos), img.size.width*4, img.size.height);
    [btnClaim addTarget:self action:@selector(btnClaimClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btnClaim setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
    [btnClaim setTitle:@"Claim" forState:UIControlStateNormal];
    [btnClaim setTag:Top_ClaimBtn_Tag];
    [btnClaim setHidden:YES];
    [topView addSubview:btnClaim];
    
    
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    yPos = topView.frame.size.height/2 - img.size.height/2-3;
    img = [UIImage imageNamed:@"settings"];
    [btnRight setImage:img forState:UIControlStateNormal];
    btnRight.frame = CGRectMake(self.view.frame.size.width-img.size.width-5, (iOS7?yPos+10:yPos), img.size.width, img.size.height);
    [btnRight addTarget:self action:@selector(btnRightClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btnRight setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
    [btnRight setTag:Top_HelpView_Tag];
    [topView addSubview:btnRight];
   
}

#pragma mark - GET Buttons
-(UIButton *)leftButton
{
    return (UIButton *)[self.view viewWithTag:Top_QRView_Tag];
}
-(UIButton *)rightButton
{
    return (UIButton *)[self.view viewWithTag:Top_HelpView_Tag];
}
-(UIButton *)alertButton
{
    return (UIButton *)[self.view viewWithTag:Top_ButtonAlert_Tag];
}
-(UIButton *)claimButton
{
    return (UIButton *)[self.view viewWithTag:Top_ClaimBtn_Tag];
}
-(CustomButton *)friendsButton
{
    return (CustomButton *)[self.view viewWithTag:Top_FriendsBtn_Tag];
}
-(UIButton *)castButton
{
    return (UIButton *)[self.view viewWithTag:Top_CastBtn_Tag];
}

#pragma mark - Button Click Event
-(void)btnBackClicked:(UIButton *)button
{
    [APPDELEGATE setReachibility];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    if([IMDHTTPRequest currentRequest])
    {
        [SEGBIN_SINGLETONE_INSTANCE removeLoader];
        [[IMDHTTPRequest currentRequest] stopRequest];
    }
}
-(void)btnRightClicked:(UIButton *)button
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    
    if([IMDHTTPRequest currentRequest])
    {
        [SEGBIN_SINGLETONE_INSTANCE removeLoader];
        [[IMDHTTPRequest currentRequest] stopRequest];
    }
    
    UIStoryboard *storyboard = iPhone_storyboard;
    if (iPad)
    {
        storyboard = self.storyboard;
    }
    SettingsViewController *settingsVC = (SettingsViewController *) [storyboard instantiateViewControllerWithIdentifier:@"settingsVC"];
    
    [self.navigationController pushViewController:settingsVC animated:YES];
}
-(void)setViewImage:(UIImage *)image withTitle:(NSString *)title
{
    UIImageView *img = (UIImageView *)[self.view viewWithTag:TOP_ViewImage_Tag];
    UILabel *lbl = (UILabel *)[self.view viewWithTag:TOP_ViewLbl_Tag];
    [img setHidden:NO];
    [lbl setHidden:NO];
    [img setImage:image];
    [lbl setText:title];
}

-(void)hideImageAndTitle
{
    UIImageView *img = (UIImageView *)[self.view viewWithTag:TOP_ViewImage_Tag];
    UILabel *lbl = (UILabel *)[self.view viewWithTag:TOP_ViewLbl_Tag];
    [img setHidden:YES];
    [lbl setHidden:YES];
}

-(void)resetTopViewLogoFrameForOrientation:(UIInterfaceOrientation)orientation withImage:(UIImage *)image withTitle:(NSString *)strTitle
{
    
    UIView *topView = [self.view viewWithTag:TopView_Tag];
    UIImageView *imgVw = (UIImageView *)[topView viewWithTag:Top_Logo_Tag];
    if(orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft)
    {
        [imgVw setFrame:CGRectMake(self.leftButton.frame.origin.x + self.leftButton.frame.size.width + (iPad?90:(IS_IPHONE_5?80:60)), imgVw.frame.origin.y, imgVw.frame.size.width, imgVw.frame.size.height)];
        CustomButton *btn = (CustomButton *)[self.view viewWithTag:Top_FriendsBtn_Tag];
        [btn setFrame:CGRectMake(imgVw.frame.origin.x+imgVw.frame.size.width+(iPad?120:25), imgVw.frame.origin.y+(iPhone?-7:5), btn.frame.size.width, btn.frame.size.height)];
        [btn setBackgroundColor:[UIColor clearColor]];
        UIImageView *img = (UIImageView *)[btn viewWithTag:Top_FriendsImgVw_Tag];
        [img setImage:image];
        
        UILabel *lbl = (UILabel *)[btn viewWithTag:Top_FriendsLbl_Tag];
        [lbl setText:strTitle];
        [btn setHidden:NO];
    }
    else
    {
        CGRect frame;
        if(iOS8)
        {
            frame = CGRectMake(0, 0, (iPad?768:320), [UIScreen mainScreen].bounds.size.height);
        }
        else
        {
            frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        }
        
        
        [imgVw setFrame:CGRectMake(frame.size.width/2-imgVw.frame.size.width/2, imgVw.frame.origin.y, imgVw.frame.size.width, imgVw.frame.size.height)];
        CustomButton *btn = (CustomButton *)[self.view viewWithTag:Top_FriendsBtn_Tag];
        [btn setHidden:YES];
    }
}

-(void)setFriendsBtnFrameForOrientation:(UIInterfaceOrientation)orientation
{
    CustomButton *btn = (CustomButton *)[self.view viewWithTag:Top_FriendsBtn_Tag];
    [btn setHidden:NO];
    
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    if(orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft)
    {
        frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    
    CGFloat btnWidth = kFriendsBtnWidth/2 + 20;
    [btn setFrame:CGRectMake(frame.size.width-btnWidth - 20, btn.frame.origin.y, btnWidth, btn.frame.size.height)];
    
    UILabel *lbl = (UILabel *)[btn viewWithTag:Top_FriendsLbl_Tag];
    [lbl setFrame:CGRectMake(lbl.frame.origin.x, lbl.frame.origin.y, kFriendLblWidth/2, lbl.frame.size.height)];
}

-(void)setSagebinLogoInCenterForOrientation:(UIInterfaceOrientation)orientation
{
    UIView *topView = [self.view viewWithTag:TopView_Tag];
    UIImageView *imgVw = (UIImageView *)[topView viewWithTag:Top_Logo_Tag];
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    if(orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft)
    {
       
        
        frame = CGRectMake(0, 0, ([UIScreen mainScreen].bounds.size.height<[UIScreen mainScreen].bounds.size.width?[UIScreen mainScreen].bounds.size.width:[UIScreen mainScreen].bounds.size.height), [UIScreen mainScreen].bounds.size.width);
    }
    else
    {
        if(iOS8)
        {
            frame = CGRectMake(0, 0, (iPad?768:320), [UIScreen mainScreen].bounds.size.height);
        }
        
    }
    
    [imgVw setFrame:CGRectMake(frame.size.width/2-imgVw.frame.size.width/2, imgVw.frame.origin.y, imgVw.frame.size.width, imgVw.frame.size.height)];
}

-(void)btnAlertClicked:(UIButton *)button
{
    UIStoryboard *storyboard = iPhone_storyboard;
    if (iPad)
    {
        storyboard = self.storyboard;
    }
    AlertViewController *alertVC = (AlertViewController *) [storyboard instantiateViewControllerWithIdentifier:@"AlertVC"];
    alertVC.parentController = self;
    [self.navigationController pushViewController:alertVC animated:YES];
}
-(void)btnClaimClicked:(UIButton *)button
{
    UIStoryboard *storyboard = iPhone_storyboard;
    if (iPad)
    {
        storyboard = iPad_storyboard;
    }
     MovieListViewController *movieListVC = (MovieListViewController *) [storyboard instantiateViewControllerWithIdentifier:@"MovieListVC"];
    
    [movieListVC btnClaimClicked:button];
    
}
- (void)checkUserAlert:(NSMutableArray *)alerts{
    
    if ([alerts count] > 0){
        [self.alertButton setHidden:NO];
    }else
    {
        if([[[NSUserDefaults standardUserDefaults] valueForKey:keymovie_credits]intValue] != 0 || [[[NSUserDefaults standardUserDefaults] valueForKey:keymovie_shares]intValue] != 0)
        {
            [self.alertButton setHidden:NO];
        }
        else
        {
             [self.alertButton setHidden:YES];
        }
       // [self.alertButton setHidden:YES];
        //[self.alertButton setHidden:NO];
    }
}

-(void)setHidden:(BOOL)flag
{
    [self.alertButton setHidden:flag];
}

#pragma mark - Cats Button Clicked
-(void)btnCastClicked:(UIButton *)button
{
    if(APPDELEGATE.currentVideoObj && [[APPDELEGATE.currentVideoObj objectForKey:keyCanPlay] isEqualToNumber:[NSNumber numberWithInt:0]])
    {
        [APPDELEGATE errorAlertMessageTitle:@"Alert" andMessage:NSLocalizedString(@"strYou can not play this movie", nil)];
        return;
    }
    
    UIStoryboard *storyboard = iPhone_storyboard;
    if (iPad)
    {
        storyboard = self.storyboard;
    }
    CastViewController *objCastVC = (CastViewController *) [storyboard instantiateViewControllerWithIdentifier:@"CastVC"];
    objCastVC.objVideo = APPDELEGATE.currentVideoObj;
    [self.navigationController pushViewController:objCastVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
