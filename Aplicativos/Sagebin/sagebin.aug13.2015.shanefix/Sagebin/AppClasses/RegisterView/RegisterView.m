//
//  RegisterView.m
//  Sagebin
//
//  Created by hyperlink on 15/10/14.
//  Copyright (c) 2014  . All rights reserved.
//

#import "RegisterView.h"

@interface RegisterView() <IMDHTTPRequestDelegate>
{
    UIScrollView *_mainScrollView;
    UITextField *_txtUserName;
    UITextField *_txtEmail;
    UITextField *_txtConfirmEmail;
    UITextField *_txtPassword;
    UITextField *_txtConfirmPassword;
    UIWebView *_termsCondition;
    UIButton *_checkBtn;
    UIButton *_createAccount;
    
    BOOL TCselected;
    UITextField *activeField;
}

@end

@implementation RegisterView
@synthesize invitationCode,userData;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createLayout];
        
        [self registerForKeyboardNotifications];
    }
    return self;
}

-(void)createLayout
{
    UIImage *imgLogin = [UIImage imageNamed:@"login"];
    
    CGFloat xPos = (self.frame.size.width/2 - imgLogin.size.width/2);
    
    //    NSInteger xWidth = iPad?465:268;
    CGFloat xWidth = imgLogin.size.width;
    
    //    NSInteger xHeight = iPad?64:37;
    NSInteger xHeight = imgLogin.size.height;
    
    _mainScrollView = [SEGBIN_SINGLETONE_INSTANCE createScrollViewWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) bgColor:[UIColor clearColor] tag:Register_Main_ScrollView delegate:self];
    [_mainScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self addSubview:_mainScrollView];
    
    UIFont *loginFont = [APPDELEGATE Fonts_Orbitron_Medium:(iPad?38:22)];
    UILabel *lblLogin = [APPDELEGATE createLabelWithFrame:CGRectMake(xPos, iPad?58:10, xWidth, 50) withBGColor:[UIColor clearColor] withTXColor:[UIColor whiteColor] withText:NSLocalizedString(@"lblRegister", nil) withFont:loginFont withTag:0 withTextAlignment:NSTextAlignmentCenter];
    [lblLogin setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [_mainScrollView addSubview:lblLogin];
    
    UIView *viewUsername = [APPDELEGATE createTextFieldWithFrame:CGRectMake(xPos, (lblLogin.frame.size.height+lblLogin.frame.origin.y)+(iPad?29:16), xWidth, xHeight) withImage:[UIImage imageNamed:@"user"] delegate:self withTag:Register_TxtUsernameTag];
    _txtUserName =(UITextField *)[viewUsername viewWithTag:Register_TxtUsernameTag];
    [_txtUserName setPlaceholder:NSLocalizedString(@"txtPlaceHolderUser", nil)];
    [_txtUserName setFont:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)]];
    [_txtUserName setTextColor:ColorTxtPlaceHolder];
    [_txtUserName setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [viewUsername setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [_mainScrollView addSubview:viewUsername];
    
    UIView *viewEmail = [APPDELEGATE createTextFieldWithFrame:CGRectMake(xPos, (viewUsername.frame.size.height+viewUsername.frame.origin.y)+(iPad?29:16), xWidth, xHeight) withImage:[UIImage imageNamed:@"email"] delegate:self withTag:Register_TxtEmailTag];
    _txtEmail =(UITextField *)[viewEmail viewWithTag:Register_TxtEmailTag];
    [_txtEmail setPlaceholder:NSLocalizedString(@"txtPlaceHolderEmail", nil)];
    [_txtEmail setFont:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)]];
    [_txtEmail setTextColor:ColorTxtPlaceHolder];
    [_txtEmail setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [viewEmail setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [_mainScrollView addSubview:viewEmail];
    
    UIView *viewConfirmEmail = [APPDELEGATE createTextFieldWithFrame:CGRectMake(xPos, (viewEmail.frame.size.height+viewEmail.frame.origin.y)+(iPad?29:16), xWidth, xHeight) withImage:[UIImage imageNamed:@"email"] delegate:self withTag:Register_TxtConfirmEmailTag];
    _txtConfirmEmail =(UITextField *)[viewConfirmEmail viewWithTag:Register_TxtConfirmEmailTag];
    [_txtConfirmEmail setPlaceholder:NSLocalizedString(@"txtPlaceHolderConfirmEmail", nil)];
    [_txtConfirmEmail setFont:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)]];
    [_txtConfirmEmail setTextColor:ColorTxtPlaceHolder];
    [_txtConfirmEmail setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [viewConfirmEmail setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [_mainScrollView addSubview:viewConfirmEmail];
    
    UIView *viewPassword = [APPDELEGATE createTextFieldWithFrame:CGRectMake(xPos, (viewConfirmEmail.frame.size.height+viewConfirmEmail.frame.origin.y)+(iPad?29:16), xWidth, xHeight) withImage:[UIImage imageNamed:@"pw"] delegate:self withTag:Register_TxtPassowrdTag];
    _txtPassword =(UITextField *)[viewPassword viewWithTag:Register_TxtPassowrdTag];
    [_txtPassword setPlaceholder:NSLocalizedString(@"txtPlaceHolderPassword", nil)];
    [_txtPassword setFont:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)]];
    [_txtPassword setTextColor:ColorTxtPlaceHolder];
    [_txtPassword setSecureTextEntry:YES];
    [_txtPassword setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [viewPassword setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [_mainScrollView addSubview:viewPassword];
    
    UIView *viewConfirmPassword = [APPDELEGATE createTextFieldWithFrame:CGRectMake(xPos, (viewPassword.frame.size.height+viewPassword.frame.origin.y)+(iPad?29:16), xWidth, xHeight) withImage:[UIImage imageNamed:@"pw"] delegate:self withTag:Register_TxtConfirmPassowrdTag];
    _txtConfirmPassword =(UITextField *)[viewConfirmPassword viewWithTag:Register_TxtConfirmPassowrdTag];
    [_txtConfirmPassword setPlaceholder:NSLocalizedString(@"txtPlaceHolderConfirmPassword", nil)];
    [_txtConfirmPassword setFont:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)]];
    [_txtConfirmPassword setTextColor:ColorTxtPlaceHolder];
    [_txtConfirmPassword setSecureTextEntry:YES];
    [_txtConfirmPassword setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [viewConfirmPassword setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [_mainScrollView addSubview:viewConfirmPassword];
    
    UIView *viewTermsConditionView = [APPDELEGATE createTextViewWithFrame:CGRectMake(xPos, (viewConfirmPassword.frame.size.height+viewConfirmPassword.frame.origin.y)+(iPad?29:16), xWidth, (iPad?200:100)) withImage:[UIImage imageNamed:@"user"] delegate:self withTag:Register_TxtViewTag];
    _termsCondition =(UIWebView *)[viewTermsConditionView viewWithTag:Register_TxtViewTag];
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"termsandcondition" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [_termsCondition loadHTMLString:htmlString baseURL:nil];
    [viewTermsConditionView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [_mainScrollView addSubview:viewTermsConditionView];
    
    
    _checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _checkBtn.frame = CGRectMake(xPos, (viewTermsConditionView.frame.size.height+viewTermsConditionView.frame.origin.y)+(iPad?25:13), imgLogin.size.width, imgLogin.size.height);
    [_checkBtn setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    [_checkBtn setBackgroundColor:[UIColor blackColor]];
    [_checkBtn addTarget:self action:@selector(checkBtnclick:) forControlEvents:UIControlEventTouchUpInside];
    [_checkBtn setTitle:NSLocalizedString(@"txttermsandCondition", nil) forState:UIControlStateNormal];
    [_mainScrollView addSubview:_checkBtn];
    [_checkBtn setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    _checkBtn.titleLabel.font = [APPDELEGATE Fonts_OpenSans_Regular:(iPad?21:12)];
    [_checkBtn setImageEdgeInsets:UIEdgeInsetsMake(0,-30, 0, 0)];
    [_checkBtn setSelected:NO];
    TCselected=FALSE;
    

    //New Account Button
    _createAccount = [UIButton buttonWithType:UIButtonTypeCustom];
    _createAccount.frame = CGRectMake(xPos, (_checkBtn.frame.size.height+_checkBtn.frame.origin.y)+(iPad?25:13), imgLogin.size.width, imgLogin.size.height);
    [_createAccount setBackgroundImage:imgLogin forState:UIControlStateNormal];
    [_createAccount addTarget:self action:@selector(btnNewAccountClick:) forControlEvents:UIControlEventTouchUpInside];
    [_createAccount setTitle:NSLocalizedString(@"txtnewAccount", nil) forState:UIControlStateNormal];
    [_mainScrollView addSubview:_createAccount];
    [_createAccount setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    _createAccount.titleLabel.font = [APPDELEGATE Fonts_OpenSans_Regular:(iPad?21:12)];
    
}
-(void)layoutSubviews
{
    _mainScrollView.contentSize = CGSizeMake(_mainScrollView.contentSize.width, _createAccount.frame.origin.y+_createAccount.frame.size.height+10);
    [super layoutSubviews];
    
    if(userData!=nil)
    {
        NSLog(@"%@",userData);
        _txtUserName.text=[userData valueForKey:@"Username"];
        _txtEmail.text=[userData valueForKey:@"Email"];
        _txtConfirmEmail.text=[userData valueForKey:@"Conf_Email"];
        _txtPassword.text=[userData valueForKey:@"password"];
        _txtConfirmPassword.text=[userData valueForKey:@"Conf_password"];
        
        [self enableDisableUI:FALSE];
        
    }
    else
    {
        NSLog(@"%@",userData);
        [self enableDisableUI:TRUE];
    }

}
-(void)enableDisableUI:(BOOL)status
{
    [_txtUserName setUserInteractionEnabled:status];
    [_txtEmail setUserInteractionEnabled:status];
     [_txtConfirmEmail setUserInteractionEnabled:status];
     [_txtPassword setUserInteractionEnabled:status];
     [_txtConfirmPassword setUserInteractionEnabled:status];
}
-(void)checkBtnclick:(UIButton *)btn
{
    if(btn.isSelected)
    {
        [btn setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
        [btn setSelected:NO];
        TCselected=FALSE;
    }
    else
    {
        [btn setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
        [btn setSelected:YES];
        TCselected=TRUE;
    }
}
-(void)btnNewAccountClick:(UIButton *)btn
{
    [_txtConfirmEmail resignFirstResponder];
    [_txtConfirmPassword resignFirstResponder];
    [_txtEmail resignFirstResponder];
    [_txtPassword resignFirstResponder];
    [_txtUserName resignFirstResponder];
    
   
   
    //Validation only check when user will not come from the Facebook and Gmail Login
    if (userData==nil)
    {
        
        if(![self emptyfieldValidation:_txtUserName.text] || ![self emptyfieldValidation:_txtEmail.text] || ![self emptyfieldValidation:_txtConfirmEmail.text] || ![self emptyfieldValidation:_txtPassword.text] || ![self emptyfieldValidation:_txtConfirmPassword.text] )
        {
            [self.superview makeToast:NSLocalizedString(@"validateAllFields", nil)];
            return;
        }
        
        NSString *specialCharacterString1 = @"!~`@#$%^&*-+();:={}[],.<>?\\/\"\' ";
        NSCharacterSet *specialCharacterSet1 = [NSCharacterSet
                                                characterSetWithCharactersInString:specialCharacterString1];
        
        if ([_txtUserName.text.lowercaseString rangeOfCharacterFromSet:specialCharacterSet1].length)
        {
            [self.superview makeToast:@"User Name only letter,underscore up to 3 to 15 Character "];
            return;
        }
        
        if(_txtUserName.text.length<3 || _txtUserName.text.length>15)
        {
            [self.superview makeToast:@"User Name only letter,underscore up to 3 to 15 Character "];
            return;
        }
        if(![self validateEmail:_txtEmail.text] || ![self validateEmail:_txtConfirmEmail.text])
        {
            [self.superview makeToast:NSLocalizedString(@"validateEmail", nil)];
            return;
        }
        if(_txtPassword.text.length<8)
        {
            [self.superview makeToast:@"Your new password should contain at least 8 characters with at least one upper-cased letter and at least one symbol."];
            return;
        }
        if ([[[_txtPassword.text componentsSeparatedByCharactersInSet:[NSCharacterSet letterCharacterSet] ] componentsJoinedByString:@""] isEqualToString:_txtPassword.text]
            )
        {
            [self.superview makeToast:@"Your new password should contain at least 8 characters with at least one upper-cased letter and at least one symbol."];
            return;
        }
        NSString *specialCharacterString = @"!~`@#$%^&*-+();:={}[],.<>?\\/\"\'";
        NSCharacterSet *specialCharacterSet = [NSCharacterSet
                                               characterSetWithCharactersInString:specialCharacterString];
        
        if (![_txtPassword.text.lowercaseString rangeOfCharacterFromSet:specialCharacterSet].length) {
            [self.superview makeToast:@"Your new password should contain at least 8 characters with at least one upper-cased letter and at least one symbol."];
            return;
        }
        if(![_txtPassword.text isEqualToString:_txtConfirmPassword.text])
        {
            [self.superview makeToast:NSLocalizedString(@"validatePassword", nil)];
            return;
        }

    }
    
    if(!TCselected)
    {
        [self.superview makeToast:NSLocalizedString(@"AcceptTermscondition", nil)];
        return;
    }
    
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.superview makeToast:WARNING];
        return;
    }
    
    IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
    NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
    NSString *strParameter = [NSString stringWithFormat:NSLocalizedString(@"apiCreateUser", nil), _txtUserName.text,_txtPassword.text,_txtConfirmPassword.text,_txtEmail.text,_txtConfirmEmail.text,[NSString stringWithFormat:@"%hhd",TCselected],invitationCode];
    
    [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:kTAG_CREATE_USER];
    [requestConnection startAsynchronousRequest];
    
    [SEGBIN_SINGLETONE_INSTANCE addLoader];
    [self setUserInteractionEnabled:FALSE];
    
   
}
#pragma mark - IMDHTTPRequest Delegates
-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didFailWithError:(NSError*)error withTag:(int)tag
{
    [self setUserInteractionEnabled:TRUE];
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    if (tag==kTAG_CREATE_USER)
    {
        [self.superview makeToast:kServerError];
    }
}

-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didSuccessWithItems:(NSObject*)items withData:(NSData*)data withTag:(int)tag
{
    [self setUserInteractionEnabled:TRUE];
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    if (tag==kTAG_CREATE_USER)
    {
        NSDictionary *result = (NSDictionary *)items;
        if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
        {
            //result=[result objectForKey:keyValue];
            
            NSString *str =  [NSString stringWithFormat:@"Welcome , %@",[result objectForKey:keyDisplayName]];
            [APPDELEGATE errorAlertMessageTitle:nil andMessage:str];
            //[APPDELEGATE.window makeToast:str];
            
            [APPDELEGATE storeLoginResponse:result];
            
             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[[result valueForKey:keyValue] valueForKey:keyAccount] forKey:keyAccount];
            [defaults setObject:[[result valueForKey:keyValue] valueForKey:keyDisplayName] forKey:keyDisplayName];
            
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
                home.isFromRegistration=TRUE;
                [APPDELEGATE.navRootCont pushViewController:home animated:YES];
            }

        }
        else
        {
            [self.superview makeToast:[result objectForKey:keyMessage]];
        }
        
    }
}

#pragma mark Webview Delegate
-(void)webViewDidFinishLoad:(UIWebView *)webView1
{
    
    int fontSize = (iPad?60:40);
    NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'", fontSize];
    [webView1 stringByEvaluatingJavaScriptFromString:jsString];
   
    
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
   // [self btnLoginClick:nil];
    return [textField resignFirstResponder];
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
-(BOOL) validateEmail: (NSString *) email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [emailTest evaluateWithObject:email];
    return isValid;
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
        if(iPad)
        {
            return;
        }
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
            [_mainScrollView setContentOffset:CGPointMake(_mainScrollView.contentOffset.x,frame.origin.y) animated:YES];
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
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
