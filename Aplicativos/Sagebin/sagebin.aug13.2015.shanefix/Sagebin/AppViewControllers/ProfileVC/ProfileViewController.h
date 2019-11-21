//
//  ProfileViewController.h
//  Sagebin
//
//  
//  
//

#import <UIKit/UIKit.h>

enum Tag_ProfileView {
    TAG_TOPVIEW = 1000,
    TAG_IMGVIEW_USER,
    TAG_LBL_NAME,
    TAG_LBL_LOCATION,
    TAG_LBL_STATUS,
    TAG_IMG_STATUS,
    TAG_MIDDLEVIEW,
    TAG_BTN_FRIEND,
    TAG_BTN_MESSAGS,
    TAG_BTN_SETTINGS,
    TAG_BTN_LOGOUT,
    TAG_LBL_PURCHSMVI,
    TAG_COLLECTIONVIEW_ALBUM,
    TAG_COLLECTIONVIEW_IMG,
    TAG_COLLECTIONVIEW_SELL
    };


@interface ProfileViewController : RootViewController <UICollectionViewDataSource , UICollectionViewDelegate, ChromecastControllerDelegate>

@end
