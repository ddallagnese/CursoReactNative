//
//  FriendListVC.h
//  Sagebin
//
//
//
//


#import "ProfileViewController.h"
typedef enum ViewTags {
    TAG_SearchView = 200,
    TAG_MainViewCollection,
    TAG_SEARCHTEXT,
    TAG_SEARCHBUTTON,
    TAG_CONTACTBUTTON,
    // From below tag use for collection view cell
    TAG_REUSEVIEW,
    TAG_Cell_ImageView,
    TAG_Cell_OtherView,
    TAG_Cell_LblName,
    TAG_Cell_LblCity,
    TAG_Cell_BtnStatus,
    TAG_Cell_BtnMSG,
    TAG_Cell_BtnAdd,
    TAG_Cell_LblWaiting
}SUBVIEW_TAG;
@interface FriendListVC : RootViewController <ChromecastControllerDelegate>
{
    CustomButton *btnContact;
    BOOL contactExists;
}
@end
