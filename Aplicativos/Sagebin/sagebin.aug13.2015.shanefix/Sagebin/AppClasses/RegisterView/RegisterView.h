//
//  RegisterView.h
//  Sagebin
//
//  Created by hyperlink on 15/10/14.
//  Copyright (c) 2014  . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MovieListViewController.h"
#import "HomeViewController.h"
typedef enum RegisterTag
{
    RegisterView_Tag=1001,
    Register_Main_ScrollView,
    Register_TxtUsernameTag,
    Register_TxtEmailTag,
    Register_TxtConfirmEmailTag,
    Register_TxtPassowrdTag,
    Register_TxtConfirmPassowrdTag,
    Register_TxtViewTag,
    Register_CheckBtnTag,
    Register_CreateBtnTag
}RegisterViewTags;

@interface RegisterView : UIView<UITextFieldDelegate>
{
    
}
@property(nonatomic,retain)NSString *invitationCode;
@property(nonatomic,retain)NSMutableDictionary *userData;
@end
