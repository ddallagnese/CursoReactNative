//
//  HomeViewController.h
//  Sagebin
//
//  
//  
//

//typedef enum : NSUInteger {
//    
//    TAG_MAIN_VIEW=10,
//    TAG_ViewAccountState=11,
//    TAG_ViewSearch=12,
//    TAG_ViewNewRelease=13,
//    TAG_ViewPurchase=14,
//    TAG_ViewDownload=15,
//    TAG_LBLACCOUNT_STATE=16,
//    TAG_LBLMOVIE_TITLE=17,
//    TAG_LBLMOVIE_NUMBER=18,
//    TAG_LBLFRNDMOVIE_TITLE=19,
//    TAG_LBLFRNDMOVIE_NUMBER=20,
//    TAG_LBLSEARCH=21,
//    TAG_LBLNEWRELEASE=22,
//    TAG_LBLPURCHASE=23,
//    TAG_LBLDOWNLOAD=24
//} SUBVIEW_TAGS;

typedef enum : NSUInteger {
    
    TAG_MAIN_VIEW=9,
    TAG_ViewFriendMovies=10,
    TAG_ViewMyMovies=11,
    TAG_ViewSearch=12,
    TAG_ViewNewRelease=13,
    TAG_ViewFriends=14,
    TAG_ViewNews=15,
    TAG_LBL_MYMOVIE=16,
    TAG_LBLFRIENDS_MOVIES=17,
    TAG_LBLSEARCH=18,
    TAG_LBLNEWRELEASE=19,
    TAG_LBLOFFLINE_MOVIES=20,
    TAG_LBLNEWS=21
} SUBVIEW_TAGS;

#import "RootViewController.h"
#import "RegistrationVC.h"
@interface HomeViewController : RootViewController <UIScrollViewDelegate, IMDEventImageDelegate, ChromecastControllerDelegate,UITextFieldDelegate>
{
    // PortraitView
    IBOutlet UIView *mainPortraitView;
    
    // LandscapeView
    IBOutlet UIView *mainLandscapeView;
    
    IBOutlet UIScrollView *imageGalleryScroll;
    NSMutableArray *arrImageGalleryRecords, *arrImageUrls;
    BOOL pageControlUsed;
     NSTimer *timer;
    
   IBOutlet UIView *searchView;
    UITextField *txtSearch;
    
    
    // Home View SubViews.
    
//    // Account Views
//     UIView *accountStateView;
//     UILabel *lblAcountState;
//     UILabel *lblMoviesNumber;
//     UILabel *lblFrndMoviesNumber;
//     UILabel *lblMoviesTitle;
//     UILabel *lblFrndsMovieTitle;
//    
//    // SearchView
//     UIView *ViewSearch;
//     UILabel *lblSearch;
//    
//    // Release View
//     UIView *ViewRelease;
//     UILabel *lblRelease;
//    
//    // Purchase View
//     UIView *ViewPurchase;
//     UILabel *lblPurchase;
//    
//    //Download View
//     UIView *ViewDownload;
//     UILabel *lblDownload;
    
        UIDeviceOrientation currentOrientaion;
    
}

@property (nonatomic, retain) NSMutableArray *arrImageViews;
@property(nonatomic,assign)BOOL isFromRegistration;

@end
