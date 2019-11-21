//
//  ContactListViewController.h
//  Sagebin
//
//  Created by hyperlink on 31/10/14.
//  Copyright (c) 2014  . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomPopupView.h"

typedef enum ContactlistTags : NSUInteger {
    
    TAG_Main_ScrollView=100,
    TAG_ContactSearchText,
    TAG_ContactSearchButton,
    
    TAG_FacebookContact,
    TAG_GmailContact,
    TAG_Contact,
    
    TAG_ContactTable,
    TAG_ContactReuseView,
    TAG_Contact_LblTitle,
    Tag_Contact_ViewLine,
    Tag_Contact_Selected,
    Tag_Invite_Time_Pending,
    
    TAG_EmailView,
    TAG_EmailText,
    TAG_Emailbtn,
    
    TAG_Contact_Popup_View
    
  
} ContactlistTags;

typedef enum InviteType
{
    TYPE_INVITE=0,
    TYPE_PENDING_INVITE,
}IN_TYPE;

@interface ContactListViewController : RootViewController<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, ChromecastControllerDelegate,CustomPopupViewDelegate>
{
    UIView *searchView,*emailView;
    UITextField *txtSearch,*txtEmail ,*activeField;;
    UIScrollView *_mainScrollView;
    
    NSMutableArray *arrData, *arraySectionTitles;
    UITableView *searchTable;
    
     CustomPopupView *objView;
}
@property (nonatomic,retain) NSString *strMovieId,*strMovieTitle;
@property (nonatomic,assign) int inviteType;

@end
