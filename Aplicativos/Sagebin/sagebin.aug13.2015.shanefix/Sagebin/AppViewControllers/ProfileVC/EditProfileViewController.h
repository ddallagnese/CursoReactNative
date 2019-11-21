//
//  EditProfileViewController.h
//  Sagebin
//
//  
//

#import <UIKit/UIKit.h>

typedef enum EditProfTags
{
    TAG_IMGVW_PROFILE,
    TAG_TXT_OLDPASS,
    TAG_TXT_NEWPASS,
    TAG_TXT_CONFIRMPASS,
    TAG_BTN_SUBMIT
}EditProfTags;

@interface EditProfileViewController : RootViewController <UITextFieldDelegate, IMDEventImageDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIPopoverControllerDelegate, ChromecastControllerDelegate>
{
    UIScrollView *mainScroll;
    UITextField *activeField;
    UITextField *txtOldPass;
    UITextField *txtNewPass;
    UITextField *txtConfirmPass;
    IMDEventImageView *imgVwProfile;
    CustomButton *btnSubmit;
}

@property(nonatomic,retain) NSString *strImageURL;
@property (nonatomic, retain) UIPopoverController *popover;

@end
