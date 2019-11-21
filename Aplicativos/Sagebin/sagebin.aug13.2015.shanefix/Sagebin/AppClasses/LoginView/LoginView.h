//
//  LoginView.h
//  Sagebin
//
//  
//  
//

#import <UIKit/UIKit.h>
#import "RegistrationVC.h"
#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2ViewControllerTouch.h"

typedef enum LoginTag
{
    LoginView_Tag=501,
    Login_Main_ScrollView,
    Login_TxtUsernameTag,
    Login_TxtPasswordTag,
    Login_ForgetButtonTag,
    Login_ButtonTag,
    Login_InvitaionTag,
    Login_NewAccountTag,
    Login_GmailTag,
    Login_FacebookTag
}LoginViewTags;
@interface LoginView : UIView<UITextFieldDelegate>
{
    
}
-(void)didChangeOrientation:(UIInterfaceOrientation)orientation;

@end
