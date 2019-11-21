//
//  RootViewController.h
//  Sagebin
//
//  
//  
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

enum
{
    TopView_Tag = 100,
    Top_QRView_Tag,
    Top_Logo_Tag,
    Top_HelpView_Tag,
    TOP_ViewImage_Tag,
    TOP_ViewLbl_Tag,
    Top_ButtonAlert_Tag,
    Top_FriendsBtn_Tag,
    Top_FriendsImgVw_Tag,
    Top_FriendsLbl_Tag,
    Top_CastBtn_Tag,
    Top_ClaimBtn_Tag
};
@interface RootViewController : UIViewController
{
    
}
-(UIButton *)leftButton;
-(UIButton *)rightButton;
-(UIButton *)alertButton;
-(UIButton *)claimButton;
-(CustomButton *)friendsButton;
-(UIButton *)castButton;

// Button Events
-(void)btnBackClicked:(UIButton *)button;
-(void)btnRightClicked:(UIButton *)button;
-(void)btnAlertClicked:(UIButton *)button;

-(void)setViewImage:(UIImage *)image withTitle:(NSString *)title;
-(void)hideImageAndTitle;
-(void)resetTopViewLogoFrameForOrientation:(UIInterfaceOrientation)orientation withImage:(UIImage *)image withTitle:(NSString *)strTitle;

-(void)setFriendsBtnFrameForOrientation:(UIInterfaceOrientation)orientation;

- (void)checkUserAlert:(NSMutableArray *)alerts;
-(void)setSagebinLogoInCenterForOrientation:(UIInterfaceOrientation)orientation;

@end
