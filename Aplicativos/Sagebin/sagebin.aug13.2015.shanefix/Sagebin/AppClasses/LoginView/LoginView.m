//
//  LoginView.m
//  Sagebin
//
//  
//  
//

#import "LoginView.h"
#import "HomeViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/ParseFacebookUtilsV4.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>


@interface LoginView ()<IMDHTTPRequestDelegate>
{
    UIScrollView *_mainScrollView;
    UIButton *_btnLogin;
    UIButton *_btnForget;
    UIButton *_btnRegister;
    UIButton *_btnNewAccount;
    UITextField *_txtUserName;
    UITextField *_txtPassword;
    UITextField *_txtInvitaionCode;
    CustomButton *_btnGmail;
    CustomButton *_btnFacebook;
    
    UITextField *activeField;
    
    CGRect originalRegFrame;
}
@end


@implementation LoginView
#pragma mark - Init
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        [self createLayout];
        
        [self registerForKeyboardNotifications];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}
-(void)createLayout
{
//    for (NSString *str1 in [UIFont familyNames])
//    {
//        NSLog(@"FAMILY :%@",str1);
//        for (NSString *str in [UIFont fontNamesForFamilyName:str1])
//        {
//            NSLog(@"\t%@",str);
//        }
//        
//    }
    UIImage *imgLogin = [UIImage imageNamed:@"login"];

//    NSInteger xPos = iPad?151:28;
    CGFloat xPos = (self.frame.size.width/2 - imgLogin.size.width/2);
    
//    NSInteger xWidth = iPad?465:268;
    CGFloat xWidth = imgLogin.size.width;
    
//    NSInteger xHeight = iPad?64:37;
    NSInteger xHeight = imgLogin.size.height;
    
    _mainScrollView = [SEGBIN_SINGLETONE_INSTANCE createScrollViewWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) bgColor:[UIColor clearColor] tag:Login_Main_ScrollView delegate:self];
    [_mainScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self addSubview:_mainScrollView];

    UIImage *logoImg = kPlaceholderImage;
    
    UIImageView *logoImage =  [APPDELEGATE createImageViewWithFrame:CGRectMake(xPos, iPad?58:30, xWidth, logoImg.size.height) withImage:logoImg];
    [logoImage setContentMode:UIViewContentModeScaleAspectFit];
    [logoImage setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
   // [_mainScrollView addSubview:logoImage];
    
    //(logoImage.frame.size.height+logoImage.frame.origin.y)+(iPad?37:20)
    UIFont *loginFont = [APPDELEGATE Fonts_Orbitron_Medium:(iPad?38:22)];
    UILabel *lblLogin = [APPDELEGATE createLabelWithFrame:CGRectMake(xPos,iPad?100:50 , xWidth,iPad?40:22) withBGColor:[UIColor clearColor] withTXColor:[UIColor whiteColor] withText:NSLocalizedString(@"lblLogin", nil) withFont:loginFont withTag:0 withTextAlignment:NSTextAlignmentCenter];
    [lblLogin setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [_mainScrollView addSubview:lblLogin];

    UIFont *descFont = [APPDELEGATE Fonts_OpenSans_Light:(iPad?17:10)];
    UILabel *lblDesc = [APPDELEGATE createLabelWithFrame:CGRectMake(xPos, (lblLogin.frame.size.height+lblLogin.frame.origin.y)+(iPad?16:9), xWidth, iPad?20:11) withBGColor:[UIColor clearColor] withTXColor:[UIColor whiteColor] withText:NSLocalizedString(@"lblLoginDesc", nil) withFont:descFont withTag:0 withTextAlignment:NSTextAlignmentCenter];

    [lblDesc setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    //[_mainScrollView addSubview:lblDesc];
    
    
    UIView *viewUser = [APPDELEGATE createTextFieldWithFrame:CGRectMake(xPos, (lblDesc.frame.size.height+lblDesc.frame.origin.y)+(iPad?29:16), xWidth, xHeight) withImage:[UIImage imageNamed:@"user"] delegate:self withTag:Login_TxtUsernameTag];
    _txtUserName =(UITextField *)[viewUser viewWithTag:Login_TxtUsernameTag];
    [_txtUserName setPlaceholder:NSLocalizedString(@"txtPlaceHolderUser", nil)];
    [_txtUserName setFont:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)]];
    [_txtUserName setTextColor:ColorTxtPlaceHolder];
    [_txtUserName setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [viewUser setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [_mainScrollView addSubview:viewUser];
    
    //26
    UIView *viewPassword = [APPDELEGATE createTextFieldWithFrame:CGRectMake(xPos, (viewUser.frame.size.height+viewUser.frame.origin.y)+(iPad?26:14), xWidth, xHeight) withImage:[UIImage imageNamed:@"pw"] delegate:self withTag:Login_TxtPasswordTag];
    _txtPassword =(UITextField *)[viewPassword viewWithTag:Login_TxtPasswordTag];
    [_txtPassword setPlaceholder:NSLocalizedString(@"txtPlaceHolderPassword", nil)];
    [_txtPassword setSecureTextEntry:YES];
    [_txtPassword setFont:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)]];
    [_txtPassword setTextColor:ColorTxtPlaceHolder];
    [viewPassword setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [_mainScrollView addSubview:viewPassword];
    
    _btnForget  = [UIButton buttonWithType:UIButtonTypeCustom];
    NSInteger width = self.frame.size.width - (viewPassword.frame.origin.x+viewPassword.frame.size.width);
   
    _btnForget.frame = CGRectMake((self.frame.size.width-width)-(iPad?168:98), (viewPassword.frame.size.height+viewPassword.frame.origin.y)+(iPad?13:7), iPad?168:98, iPad?16:11);
   
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    
    UIFont *font1 = [APPDELEGATE Fonts_OpenSans_Regular:(iPad?16:9)];
    NSDictionary *dict1 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle),
                            NSFontAttributeName:font1,
                            NSParagraphStyleAttributeName:style,
                            NSForegroundColorAttributeName:[UIColor whiteColor]};
   
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] init];
    [attString appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"lblForgetText", nil)    attributes:dict1]];
    [_btnForget setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [_btnForget setAttributedTitle:attString forState:UIControlStateNormal];
    [_btnForget setTag:Login_ForgetButtonTag];
    [_btnForget addTarget:self action:@selector(btnForgetClick:) forControlEvents:UIControlEventTouchUpInside];
    [_mainScrollView addSubview:_btnForget];
    [_btnForget setHidden:YES];
    
    _btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnLogin.frame = CGRectMake(xPos, (_btnForget.frame.size.height+_btnForget.frame.origin.y)+(iPad?25:13), imgLogin.size.width, imgLogin.size.height);
    [_btnLogin setBackgroundImage:imgLogin forState:UIControlStateNormal];
    [_btnLogin addTarget:self action:@selector(btnLoginClick:) forControlEvents:UIControlEventTouchUpInside];
    [_btnLogin setTitle:NSLocalizedString(@"lblLoginText", nil) forState:UIControlStateNormal];
    [_mainScrollView addSubview:_btnLogin];
    [_btnLogin setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    _btnLogin.titleLabel.font = [APPDELEGATE Fonts_OpenSans_Regular:(iPad?21:12)];
    
    _btnGmail = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnGmail.frame = CGRectMake(xPos, (_btnLogin.frame.size.height+_btnLogin.frame.origin.y)+(iPad?25:13), imgLogin.size.width, imgLogin.size.height);
  //  [_btnGmail setBackgroundImage:imgLogin forState:UIControlStateNormal];
    [_btnGmail setBackgroundColor:[UIColor colorWithRed:191.0/255 green:55.0/255 blue:41.0/255 alpha:1.0]];
    [_btnGmail addTarget:self action:@selector(btnGmailClick:) forControlEvents:UIControlEventTouchUpInside];
    [_btnGmail setTitle:@"Login with Google " forState:UIControlStateNormal];
    [_mainScrollView addSubview:_btnGmail];
    [_btnGmail setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    _btnGmail.titleLabel.font = [APPDELEGATE Fonts_OpenSans_Regular:(iPad?21:12)];
    
    _btnFacebook = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnFacebook.frame = CGRectMake(xPos, (_btnGmail.frame.size.height+_btnGmail.frame.origin.y)+(iPad?25:13), imgLogin.size.width, imgLogin.size.height);
   // [_btnFacebook setBackgroundImage:imgLogin forState:UIControlStateNormal];
    [_btnFacebook setBackgroundColor:[UIColor colorWithRed:59.0/255 green:89.0/255 blue:152.0/255 alpha:1.0]];
    [_btnFacebook addTarget:self action:@selector(btnFacebookClick:) forControlEvents:UIControlEventTouchUpInside];
    [_btnFacebook setTitle:@"Login with Facebook" forState:UIControlStateNormal];
    [_mainScrollView addSubview:_btnFacebook];
    [_btnFacebook setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    _btnFacebook.titleLabel.font = [APPDELEGATE Fonts_OpenSans_Regular:(iPad?21:12)];

    // Invitaion Code
    UIView *viewInvitationCode = [APPDELEGATE createTextFieldWithFrame:CGRectMake(xPos, (_btnFacebook.frame.size.height+_btnFacebook.frame.origin.y)+(iPad?29:16), xWidth, xHeight) withImage:[UIImage imageNamed:@"user"] delegate:self withTag:Login_InvitaionTag];
    _txtInvitaionCode =(UITextField *)[viewInvitationCode viewWithTag:Login_InvitaionTag];
    [_txtInvitaionCode setPlaceholder:NSLocalizedString(@"InvitaionPlaceHolderUser", nil)];
    [_txtInvitaionCode setFont:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)]];
    [_txtInvitaionCode setTextColor:ColorTxtPlaceHolder];
    [_txtInvitaionCode setSecureTextEntry:YES];
    [_txtInvitaionCode setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [viewInvitationCode setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [_mainScrollView addSubview:viewInvitationCode];
    
    //New Account Button
    _btnNewAccount = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnNewAccount.frame = CGRectMake(xPos, (viewInvitationCode.frame.size.height+viewInvitationCode.frame.origin.y)+(iPad?25:13), imgLogin.size.width, imgLogin.size.height);
    [_btnNewAccount setBackgroundImage:imgLogin forState:UIControlStateNormal];
    [_btnNewAccount addTarget:self action:@selector(btnNewAccountClick:) forControlEvents:UIControlEventTouchUpInside];
    [_btnNewAccount setTitle:NSLocalizedString(@"lblNewAccountText", nil) forState:UIControlStateNormal];
    [_mainScrollView addSubview:_btnNewAccount];
    [_btnNewAccount setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    _btnNewAccount.titleLabel.font = [APPDELEGATE Fonts_OpenSans_Regular:(iPad?21:12)];
    
    
    
    _btnRegister = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *imgReg = [UIImage imageNamed:@"signup"];
    CGFloat xReg = (self.frame.size.width/2 - imgReg.size.width/2);
    _btnRegister.frame = CGRectMake(xReg,  (viewInvitationCode.frame.size.height+viewInvitationCode.frame.origin.y)+(iPad?29:16), imgReg.size.width, imgReg.size.height);
    [_btnRegister setBackgroundImage:imgReg forState:UIControlStateNormal];
    [_btnRegister addTarget:self action:@selector(btnRegisterClick:) forControlEvents:UIControlEventTouchUpInside];
    [_btnRegister setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [_btnRegister.titleLabel setFont:[_btnRegister.titleLabel.font fontWithSize:10.0f]];
    [_mainScrollView addSubview:_btnRegister];
    [_btnRegister setHidden:YES];
    
    /// for register text.
    UIFont *fontnew = [APPDELEGATE Fonts_OpenSans_Regular:(iPad?21:12)];
    UIFont *fontHere = [APPDELEGATE Fonts_OpenSans_Bold:(iPad?21:12)];
    NSDictionary *txtDictNew = @{NSFontAttributeName:fontnew,
                                 NSParagraphStyleAttributeName:style,
                                 NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    
    NSDictionary *txtDicthHere =  @{NSFontAttributeName:fontHere,
                                    NSParagraphStyleAttributeName:style,
                                    NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    NSMutableAttributedString *txtReg = [[NSMutableAttributedString alloc] init];
    [txtReg appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"lblNewText", nil)    attributes:txtDictNew]];
    
    [txtReg appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"lblSignupText", nil)    attributes:txtDicthHere]];
    [_btnRegister setAttributedTitle:txtReg forState:UIControlStateNormal];

    originalRegFrame = _btnRegister.frame;
}
#pragma mark - View Methods
-(void)layoutSubviews
{
    UIView *viewPassword = _txtPassword.superview;
    NSInteger width = self.frame.size.width - (viewPassword.frame.origin.x+viewPassword.frame.size.width);
    CGRect btnFrame = _btnForget.frame;
    
    //    _btnForget.frame = CGRectMake((self.frame.size.width-width)-(iPad?150:91), (viewPassword.frame.size.height+viewPassword.frame.origin.y)+13, iPad?168:98, iPad?16:11);
    btnFrame.origin.x = (self.frame.size.width-width)-(iPad?165:91)-5.0;

//    if (iPad)
//    {
//        CGRect regFrame = _btnRegister.frame;
//        regFrame.origin.y = self.frame.size.height-regFrame.size.height;
//        _btnRegister.frame = regFrame;
//    }

    _btnForget.frame = btnFrame;
    _mainScrollView.contentSize = CGSizeMake(_mainScrollView.contentSize.width, _btnRegister.frame.origin.y+_btnRegister.frame.size.height+10);
    [super layoutSubviews];
}

#pragma mark - Button Click Events
-(void)btnLoginClick:(UIButton*) btn
{
    
    
    [_txtUserName resignFirstResponder];
    [_txtPassword resignFirstResponder];
    [_txtInvitaionCode resignFirstResponder];
    
    if (![self emptyfieldValidation:_txtUserName.text] || ![self emptyfieldValidation:_txtPassword.text])
    {
        //[APPDELEGATE errorAlertMessageTitle:nil andMessage:NSLocalizedString(@"validateEmptyFields", nil)];
        [self.superview makeToast:NSLocalizedString(@"validateEmptyFields", nil)];
        return;
    }
    
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.superview makeToast:WARNING];
        return;
    }
    
    
    IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
    NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
    //apiInvitationCode
    NSString *strParameter = [NSString stringWithFormat:NSLocalizedString(@"apiLogin", nil), _txtUserName.text, _txtPassword.text,_txtInvitaionCode.text];

//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl]];
//    NSData *postData = [NSData dataWithBytes:[strParameter UTF8String] length:[strParameter length]];
//    [request setHTTPMethod:@"POST"];
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    [request setHTTPBody:postData];
    
    [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:kTAG_LOGIN];
    [requestConnection startAsynchronousRequest];
    
    [SEGBIN_SINGLETONE_INSTANCE addLoader];
    [self setUserInteractionEnabled:FALSE];
}
-(void)btnGmailClick:(UIButton*) btn
{
    
//    
    NSString *GetDataString=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]stringForKey:@"Loading"]];
    if ([GetDataString isEqualToString:@"(null)"])
    {
        [self signInToGoogle];
    }


}
-(IBAction)btnFacebookClick:(UIButton *)btn
{
    [self facebookLogin];
}
-(void)btnNewAccountClick:(UIButton *)btn
{
    [_txtUserName resignFirstResponder];
    [_txtPassword resignFirstResponder];
    [_txtInvitaionCode resignFirstResponder];
    
    if(![self emptyfieldValidation:_txtInvitaionCode.text])
    {
        [self.superview makeToast:NSLocalizedString(@"validateInvitaionCode", nil)];
        return;
    }
    
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.superview makeToast:WARNING];
        return;
    }

    IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
    NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
    NSString *strParameter = [NSString stringWithFormat:NSLocalizedString(@"apiInvitationCode", nil), _txtInvitaionCode.text];
    
    
    
    [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:kTAG_INVITAIONCODE];
    [requestConnection startAsynchronousRequest];
    
    [SEGBIN_SINGLETONE_INSTANCE addLoader];
    [self setUserInteractionEnabled:FALSE];
    
   
}
-(void)btnForgetClick:(UIButton *)btn
{
    NSLog(@"forget");
}
-(void)btnRegisterClick:(UIButton *)btn
{
    NSLog(@"Register");
}
-(void)createUserAPI
{
    NSMutableDictionary *dic=[[NSUserDefaults standardUserDefaults] valueForKey:keyFacebook_GmailDetail];

    NSString *strParameter;
    
    IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
    NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
    if([[dic valueForKey:@"isFb"] isEqualToString:@"1"])
    {
         strParameter = [NSString stringWithFormat:NSLocalizedString(@"apiFbLogin", nil), [dic valueForKey:@"Email"], [dic valueForKey:@"password"]];
    }
    else
    {
         strParameter = [NSString stringWithFormat:NSLocalizedString(@"apiGmailLogin", nil), [dic valueForKey:@"Email"], [dic valueForKey:@"password"]];
    }
    
    
    
    [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:kTAG_CREATE_USER];
    [requestConnection startAsynchronousRequest];
    
    [SEGBIN_SINGLETONE_INSTANCE addLoader];
    [self setUserInteractionEnabled:FALSE];
}
-(void)checkInvitationCode
{
    IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
    NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
    NSString *strParameter = [NSString stringWithFormat:NSLocalizedString(@"apiInvitationCode", nil), _txtInvitaionCode.text];
    
   
    
    [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:kTAG_INVITAIONCODE_GMAIL_FB];
    [requestConnection startAsynchronousRequest];
    
    [SEGBIN_SINGLETONE_INSTANCE addLoader];
    [self setUserInteractionEnabled:FALSE];
}
#pragma mark - IMDHTTPRequest Delegates
//When fail parssing with error then get error for url tag
-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didFailWithError:(NSError*)error withTag:(int)tag
{
    [self setUserInteractionEnabled:TRUE];
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    if (tag==kTAG_LOGIN)
    {
        [self.superview makeToast:kServerError];
    }
}

-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didSuccessWithItems:(NSObject*)items withData:(NSData*)data withTag:(int)tag
{
    [self setUserInteractionEnabled:TRUE];
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    
    switch (tag)
    {
        case kTAG_LOGIN:
        {
            NSDictionary *result = (NSDictionary *)items;
            if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
            {
                NSString *str =  [NSString stringWithFormat:@"Welcome , %@",[result objectForKey:keyDisplayName]];
                [APPDELEGATE errorAlertMessageTitle:nil andMessage:str];
                //[APPDELEGATE.window makeToast:str];
                
                [APPDELEGATE storeLoginResponse:result];
                
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation addUniqueObject:[NSString stringWithFormat:@"user_%@", [result objectForKey:keyID]] forKey:@"channels"];
                [currentInstallation saveInBackground];
                
                if (iPhone)
                {
                    [APPDELEGATE openHomeViewController];
                }
                else {
                    UIStoryboard *storyBoard = iPad_storyboard;
                    HomeViewController *home =[storyBoard instantiateViewControllerWithIdentifier:@"HomeVC"];
                    [APPDELEGATE.navRootCont pushViewController:home animated:YES];
                }
            }
            else if ([[result objectForKey:keyCode] isEqualToString:keyFailed])
            {
                if([[result valueForKey:keyValid] intValue] == 1 )
                {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    NSLog(@"%@",[[result valueForKey:keyValue] objectForKey:keyGiveMovies] );
//                    [defaults setObject:[[result valueForKey:keyValue] objectForKey:keyGiveMovies] forKey:keyGiveMovies];
//                    [defaults setObject:[[result valueForKey:keyValue] objectForKey:keyGiveMoviesLimit] forKey:keyGiveMoviesLimit];
//                    [defaults setObject:[[result valueForKey:keyValue] objectForKey:keyGiveFreeMovies] forKey:keyGiveFreeMovies];
                    [defaults synchronize];
                    
                    UIStoryboard *storyboard = iPhone_storyboard;
                    if (iPad)
                    {
                        storyboard = iPad_storyboard;
                    }
                    RegistrationVC *registerVC = (RegistrationVC *) [storyboard instantiateViewControllerWithIdentifier:@"RegisterVC"];
                    registerVC.tempInvitationCode=_txtInvitaionCode.text;
                    registerVC.tempUserData=[[NSUserDefaults standardUserDefaults] valueForKey:keyFacebook_GmailDetail];
                    [APPDELEGATE.navRootCont performSelector:@selector(pushViewController:animated:) withObject:registerVC afterDelay:0.5];
                    
                    _txtInvitaionCode.text=@"";
                }
                else
                {
                    
                    [self createUserAPI];
                   // [self.superview makeToast:@"You are not register with Sagebin please enter invitaion code and than login"];
                }
                
            }
            else
            {
                [self.superview makeToast:NSLocalizedString(@"validateUsernamePassword", nil)];
            }

        }
        break;
        case kTAG_INVITAIONCODE:
        {
            NSDictionary *result = (NSDictionary *)items;
            if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
            {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:[result objectForKey:keyGiveMovies] forKey:keyGiveMovies];
                [defaults setObject:[result objectForKey:keyGiveMoviesLimit] forKey:keyGiveMoviesLimit];
                [defaults setObject:[result objectForKey:keyGiveFreeMovies] forKey:keyGiveFreeMovies];
                [defaults synchronize];
                
                UIStoryboard *storyboard = iPhone_storyboard;
                if (iPad)
                {
                    storyboard = iPad_storyboard;
                }
                RegistrationVC *registerVC = (RegistrationVC *) [storyboard instantiateViewControllerWithIdentifier:@"RegisterVC"];
                registerVC.tempInvitationCode=_txtInvitaionCode.text;
                [APPDELEGATE.navRootCont pushViewController:registerVC animated:YES];
                
                _txtInvitaionCode.text=@"";
            }
            else
            {
                [self.superview makeToast:NSLocalizedString(@"validateInvitaionCode", nil)];
            }

        }
            break;
        case kTAG_CREATE_USER:
        {
            NSDictionary *result = (NSDictionary *)items;
            if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
            {
                // go to home
                NSString *str =  [NSString stringWithFormat:@"Welcome , %@",[result objectForKey:keyDisplayName]];
                [APPDELEGATE errorAlertMessageTitle:nil andMessage:str];
                //[APPDELEGATE.window makeToast:str];
                
                [APPDELEGATE storeLoginResponse:result];
                
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation addUniqueObject:[NSString stringWithFormat:@"user_%@", [result objectForKey:keyID]] forKey:@"channels"];
                [currentInstallation saveInBackground];
                
                if (iPhone)
                {
                    [APPDELEGATE openHomeViewController];
                }
                else {
                    UIStoryboard *storyBoard = iPad_storyboard;
                    HomeViewController *home =[storyBoard instantiateViewControllerWithIdentifier:@"HomeVC"];
                    [APPDELEGATE.navRootCont pushViewController:home animated:YES];
                }

            }
            else
            {
                // check invitaion code
                if(_txtInvitaionCode.text.length==0)
                {
                    [self.superview makeToast:[result valueForKey:keyMessage]];
                }
                else
                {
                    [self checkInvitationCode];
                }
               // [self.superview makeToast:NSLocalizedString(@"validateInvitaionCode", nil)];
            }

        }
            break;
        case kTAG_INVITAIONCODE_GMAIL_FB:
        {
            NSDictionary *result = (NSDictionary *)items;
            if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
            {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:[result objectForKey:keyGiveMovies] forKey:keyGiveMovies];
                [defaults setObject:[result objectForKey:keyGiveMoviesLimit] forKey:keyGiveMoviesLimit];
                [defaults setObject:[result objectForKey:keyGiveFreeMovies] forKey:keyGiveFreeMovies];
                [defaults synchronize];
                
                UIStoryboard *storyboard = iPhone_storyboard;
                if (iPad)
                {
                    storyboard = iPad_storyboard;
                }
                RegistrationVC *registerVC = (RegistrationVC *) [storyboard instantiateViewControllerWithIdentifier:@"RegisterVC"];
                registerVC.tempInvitationCode=_txtInvitaionCode.text;
                registerVC.tempUserData=[[NSUserDefaults standardUserDefaults] valueForKey:keyFacebook_GmailDetail];
                [APPDELEGATE.navRootCont pushViewController:registerVC animated:YES];
                
                _txtInvitaionCode.text=@"";
            }
            else
            {
                [self.superview makeToast:NSLocalizedString(@"validateInvitaionCode", nil)];
            }
        }
            break;
            
        default:
            break;
    }
    
    //[APPDELEGATE.window setUserInteractionEnabled:YES];
}
#pragma mark - textfield Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
{
    activeField = textField;
    [_mainScrollView setScrollEnabled:YES];
    //    [activeField setInputAccessoryView:toolBarDone];
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField==_txtPassword)
    {
        [self btnLoginClick:nil];
    }
    return [textField resignFirstResponder];
}


#pragma mark Facebook login
- (void)_presentUserDetailsViewControllerAnimated:(BOOL)animated {
//    UserDetailsViewController *detailsViewController = [[UserDetailsViewController alloc] initWithStyle:UITableViewStyleGrouped];
//    [self.navigationController pushViewController:detailsViewController animated:animated];
}
-(void)facebookLogin
{
//    NSArray *permissionsArray = @[@"user_friends",
//                                  @"read_stream",
//                                  @"read_mailbox",
//                                  @"read_friendlists",
//                                  @"user_about_me",
//                                  @"user_activities",
//                                  @"user_birthday",
//                                  @"user_education_history",
//                                  @"user_events",
//                                  @"user_groups",
//                                  @"user_hometown",
//                                  @"user_interests",
//                                  @"user_likes",
//                                  @"user_location",
//                                  @"user_notes",
//                                  @"user_online_presence",
//                                  @"user_photo_video_tags",
//                                  @"user_photos",
//                                  @"user_relationships",
//                                  @"user_relationship_details",
//                                  @"user_religion_politics",
//                                  @"user_status",
//                                  @"user_videos",
//                                  @"user_website",
//                                  @"user_website",
//                                  @"user_work_history",
//                                  @"email",
//                                  @"friends_about_me",
//                                  @"friends_activities",
//                                  @"friends_birthday",
//                                  @"friends_education_history",
//                                  @"friends_events",
//                                  @"friends_groups",
//                                  @"friends_hometown",
//                                  @"friends_interests",
//                                  @"friends_likes",
//                                  @"friends_location",
//                                  @"friends_notes",
//                                  @"friends_online_presence",
//                                  @"friends_photo_video_tags",
//                                  @"friends_photos",
//                                  @"friends_relationships",
//                                  @"friends_relationship_details",
//                                  @"friends_religion_politics",
//                                  @"friends_status",
//                                  @"friends_videos",
//                                  @"friends_website",
//                                  @"friends_website",
//                                  @"friends_work_history",
//                                  @"manage_friendlists",
//                                  // Publishing
//                                  @"publish_stream",
//                                  @"create_event",
//                                  @"rsvp_event",
//                                  @"read_friendlists"];

     NSArray *permissionsArray = @[@"public_profile",
                                   @"email"
                                   ];
    
    [FBSDKAccessToken setCurrentAccessToken:nil];
    [FBSDKProfile setCurrentProfile:nil];
        // Login PFUser using Facebook
      [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser * _Nullable user, NSError * _Nullable error) {
          
          [SEGBIN_SINGLETONE_INSTANCE addLoader]; // Show loading indicator until login is finished
        if (!user)
        {
            NSString *errorMessage = nil;
            if (!error)
            {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        } else
        {
            if (user.isNew)
            {
                NSLog(@"%@",[PFUser currentUser]);
                NSLog(@"User with facebook signed up and logged in!");
            } else
            {
                
                NSLog(@"User with facebook logged in!");
            }
            
            [self fetchSaveUserFriendDetails];
           [self FacebookData];
        }
        [SEGBIN_SINGLETONE_INSTANCE removeLoader]; // Hide loading indicator
    }];
    

    
    
    
}

-(void)FacebookData
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"id,name,email" forKey:@"fields"];
    [FBSDKAccessToken setCurrentAccessToken:[FBSDKAccessToken currentAccessToken]];
    FBSDKGraphRequest *request1 = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                   parameters:parameters];
    [request1 startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        NSLog(@"%@",result);
        
        if (!error) {
            
            NSDictionary *userData = (NSDictionary *)result;
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            
            [dict setValue:userData[@"id"] forKey:@"password"];
            [dict setValue:userData[@"id"] forKey:@"Conf_password"];
            [dict setValue:userData[@"email"] forKey:@"Email"];
            [dict setValue:userData[@"email"] forKey:@"Conf_Email"];
            [dict setValue:userData[@"email"] forKey:@"Username"];
            [dict setValue:@"1" forKey:@"isFb"];
            
            
            [[NSUserDefaults standardUserDefaults]setObject:dict forKey:keyFacebook_GmailDetail];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            //            [PFUser logOut];
            //
            //            [self fetchSaveUserFriendDetails];
            
            
            IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
            NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
            //apiInvitationCode
            NSString *strParameter = [NSString stringWithFormat:NSLocalizedString(@"apiLogin_FB", nil),userData[@"email"], userData[@"id"],_txtInvitaionCode.text];
            
            
            
            [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:kTAG_LOGIN];
            [requestConnection startAsynchronousRequest];
            
            [SEGBIN_SINGLETONE_INSTANCE addLoader];
            [self setUserInteractionEnabled:FALSE];
            
            
            
            
        }
        else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                  isEqualToString: @"OAuthException"])
        { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
            // [self logoutButtonAction:nil];
        } else
        {
            NSLog(@"Some other error: %@", error);
        }
     
    }];

   
    
   
    /*FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        NSDictionary *userData = (NSDictionary *)result;
        // handle response
        if (!error) {
            // Parse the data received
            
            
            NSLog(@"%@",userData);
            
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            
            [dict setValue:userData[@"id"] forKey:@"password"];
            [dict setValue:userData[@"id"] forKey:@"Conf_password"];
            [dict setValue:userData[@"email"] forKey:@"Email"];
            [dict setValue:userData[@"email"] forKey:@"Conf_Email"];
            [dict setValue:userData[@"email"] forKey:@"Username"];
            [dict setValue:@"1" forKey:@"isFb"];
            
            
            [[NSUserDefaults standardUserDefaults]setObject:dict forKey:keyFacebook_GmailDetail];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
//            [PFUser logOut];
//            
//            [self fetchSaveUserFriendDetails];
            
            
            IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
            NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
            //apiInvitationCode
            NSString *strParameter = [NSString stringWithFormat:NSLocalizedString(@"apiLogin_FB", nil),userData[@"email"], userData[@"id"],_txtInvitaionCode.text];
            
       
            
            [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:kTAG_LOGIN];
            [requestConnection startAsynchronousRequest];
            
            [SEGBIN_SINGLETONE_INSTANCE addLoader];
            [self setUserInteractionEnabled:FALSE];
           
            
            

        }
        else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"])
        { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
           // [self logoutButtonAction:nil];
        } else
        {
            NSLog(@"Some other error: %@", error);
        }
    }];*/

}

-(void)fetchSaveUserFriendDetails
{
   
    /*[FBRequestConnection startWithGraphPath:@"/me/taggable_friends"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              
                              NSArray *friends = result[@"data"];
                              NSLog(@"%@",result[@"data"]);
     
                          }];*/
   

}

/*- (void)request:(FBRequest *)request didLoad:(id)result
{
    
}*/
#pragma mark Google Login


#define GoogleClientID    @"947058629129-f13n9t7d86c0j3aaudldilb3mcgo5ue4.apps.googleusercontent.com"
#define GoogleClientSecret @"_9upvT4zuzTrBRPN2wFYy8MQ"
#define GoogleAuthURL   @"https://accounts.google.com/o/oauth2/auth"
#define GoogleTokenURL  @"https://accounts.google.com/o/oauth2/token"


- (GTMOAuth2Authentication * )authForGoogle
{
    //This URL is defined by the individual 3rd party APIs, be sure to read their documentation
    
    NSURL * tokenURL = [NSURL URLWithString:GoogleTokenURL];
    // We'll make up an arbitrary redirectURI.  The controller will watch for
    // the server to redirect the web view to this URI, but this URI will not be
    // loaded, so it need not be for any actual web page. This needs to match the URI set as the
    // redirect URI when configuring the app with Instagram.
    NSString * redirectURI = @"urn:ietf:wg:oauth:2.0:oob";
    GTMOAuth2Authentication * auth;
    
    auth = [GTMOAuth2Authentication authenticationWithServiceProvider:@"lifebeat"
                                                             tokenURL:tokenURL
                                                          redirectURI:redirectURI
                                                             clientID:GoogleClientID
                                                         clientSecret:GoogleClientSecret];
    //    auth.scope = @"https://www.googleapis.com/auth/userinfo.profile";
    //    auth.scope = @"https://www.googleapis.com/auth/plus.me";
    auth.scope = @"https://www.googleapis.com/auth/plus.login";
    
    return auth;
    
}


- (void)signInToGoogle
{
    GTMOAuth2Authentication * auth = [self authForGoogle];
    
    // Display the authentication view
    GTMOAuth2ViewControllerTouch * viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithAuthentication:auth
                                                                                                authorizationURL:[NSURL URLWithString:GoogleAuthURL]
                                                                                                keychainItemName:@"GoogleKeychainName"
                                                                                                        delegate:self
                                                                                                finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    
    [APPDELEGATE.navRootCont pushViewController:viewController animated:YES];
    
    
}


- (void)viewController:(GTMOAuth2ViewControllerTouch * )viewController
      finishedWithAuth:(GTMOAuth2Authentication * )auth
                 error:(NSError * )error
{
    if (error != nil) {
        
        
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failed" message:@"Error Authorizing with Google" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        
//        [alert show];
        [SEGBIN_SINGLETONE_INSTANCE removeLoader];
       
        
    } else {
        //https://www.googleapis.com/oauth2/v1/userinfo?access_token=ya29.1.AADtN_X9mXbtIxVYay3ILxxD0Y442TJay8DrVX74oSStyDpB2Fb9bY0NoC1qc7bFHGfKeJs
        NSString *popularURLString = [NSString stringWithFormat:@"https://www.googleapis.com/oauth2/v1/userinfo?access_token=%@",auth.accessToken];
        // NSLog(@"URL %@",popularURLString);
        
        NSURLResponse *response = nil;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:popularURLString]];
        [auth authorizeRequest:request];
        NSData *data = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&error];
        if (data) {
            // API fetch succeeded
            NSString *str =[[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding] ;
            
            id val = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
             NSLog(@"API response: %@", val);
            NSArray *data1 = val;
            

            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            
            [dict setValue:[data1 valueForKey:@"id"] forKey:@"password"];
            [dict setValue:[data1 valueForKey:@"id"] forKey:@"Conf_password"];
            [dict setValue:[data1 valueForKey:@"email"] forKey:@"Email"];
            [dict setValue:[data1 valueForKey:@"email"] forKey:@"Conf_Email"];
            [dict setValue:[data1 valueForKey:@"email"] forKey:@"Username"];
            [dict setValue:@"0" forKey:@"isFb"];
            
            [self fetchGoogleFriends:[data1 valueForKey:@"id"] token:auth.accessToken auth:auth];

            [[NSUserDefaults standardUserDefaults]setObject:dict forKey:keyFacebook_GmailDetail];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
            NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
            //apiInvitationCode
            NSString *strParameter = [NSString stringWithFormat:NSLocalizedString(@"apiLogin_Gmail", nil),[data1 valueForKey:@"email"], [data1 valueForKey:@"id"],_txtInvitaionCode.text];
            
        
            
            [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:kTAG_LOGIN];
            [requestConnection startAsynchronousRequest];
            
            [SEGBIN_SINGLETONE_INSTANCE addLoader];
            [self setUserInteractionEnabled:FALSE];
            
   
            
        } else {
            // fetch failed
            
        }
        
    }
   
}
-(void)fetchGoogleFriends:(NSString *)GID token:(NSString *)Gtoken auth:(GTMOAuth2Authentication *)auth
{
    NSString *urlStr =[NSString stringWithFormat:@"https://www.googleapis.com/plus/v1/people/%@/people/visible?orderBy=alphabetical&access_token=%@",GID,Gtoken];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [auth authorizeRequest:request
         completionHandler:^(NSError *error) {
             NSString *output = nil;
             if (error) {
                 output = [error description];
             } else {
                 // Synchronous fetches like this are a really bad idea in Cocoa applications
                 //
                 // For a very easy async alternative, we could use GTMHTTPFetcher
                 NSURLResponse *response = nil;
                 NSData *data2 = [NSURLConnection sendSynchronousRequest:request
                                                       returningResponse:&response
                                                                   error:&error];
                 
                 id val2 = [NSJSONSerialization JSONObjectWithData:data2 options:0 error:&error];
                 NSLog(@"API response: %@", [val2 valueForKey:@"items"]);
                 
                 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                 [defaults setObject:[val2 valueForKey:@"items"] forKey:keyGoogleFriends];
                 
             }
         }];
}

#pragma mark - Orientation
-(void)didChangeOrientation:(UIInterfaceOrientation)orientation;
{
    
}

#pragma mark - Field Validation
-(BOOL)emptyfieldValidation:(NSString *)str
{
    NSCharacterSet *charset = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    if ([str stringByTrimmingCharactersInSet:charset].length>0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - KeyBordMethod

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}
- (void)deregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.



-(void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        // code for Landscape orientation
        //Anand 15-Oct-2013
        if(iOS7)
        {
            CGFloat kbWidth = kbSize.width;// get the keyboard height following your usual method
            
            UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, kbWidth, 0);
            insets.bottom = kbWidth;
            _mainScrollView.contentInset = insets;
            
            UIEdgeInsets scrollInsets = UIEdgeInsetsMake(0, 0, kbWidth, 0);
            scrollInsets.bottom = kbWidth;
            _mainScrollView.scrollIndicatorInsets = scrollInsets;
            
            [_mainScrollView setNeedsDisplay];
        }
        else
        {
            
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(0+MIN(KStatusBarHeight, KStatusBarWidth), 0, kbSize.width, 0);
            _mainScrollView.contentInset = contentInsets;
            _mainScrollView.scrollIndicatorInsets = contentInsets;
            [_mainScrollView setNeedsDisplay];
            
        }
        if (activeField)
        {
            [_mainScrollView setContentOffset:CGPointMake(_mainScrollView.contentOffset.x, activeField.superview.frame.origin.y) animated:YES];
        }
    }
    else
    {
        // code for Portrait orientation
        
        //22-oct
        if(iOS7)
        {
            CGFloat kbHeight = kbSize.height;// get the keyboard height following your usual method
            
            UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, kbHeight, 0);
            insets.bottom = kbHeight;
            _mainScrollView.contentInset = insets;
            
            UIEdgeInsets scrollInsets = UIEdgeInsetsMake(0, 0, kbHeight, 0);
            scrollInsets.bottom = kbHeight;
            
            _mainScrollView.scrollIndicatorInsets = scrollInsets;
            [_mainScrollView setNeedsDisplay];

        }
        else
        {
            
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(0+MIN(KStatusBarHeight, KStatusBarWidth), 0, kbSize.height, 0);
            _mainScrollView.contentInset = contentInsets;
            _mainScrollView.scrollIndicatorInsets = contentInsets;
            [_mainScrollView setNeedsDisplay];
        }
        
        if (activeField)
        {
            CGRect frame = activeField.superview.frame;
            [_mainScrollView setContentOffset:CGPointMake(_mainScrollView.contentOffset.x,(iPad?activeField.frame.size.height+150:frame.origin.y)) animated:YES];
        }
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _mainScrollView.contentInset = contentInsets;
    _mainScrollView.scrollIndicatorInsets = contentInsets;
}

-(void)dealloc
{
    [self deregisterForKeyboardNotifications];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}
@end
