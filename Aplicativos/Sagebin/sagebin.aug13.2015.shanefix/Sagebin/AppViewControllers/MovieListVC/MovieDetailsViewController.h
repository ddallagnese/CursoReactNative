//
//  MovieDetailsViewController.h
//  Sagebin
//
//  
//

#import <UIKit/UIKit.h>
#import "CustomPopupView.h"
#import <GoogleCast/GoogleCast.h>


typedef enum MoviType
{
    
    SIMPLE_MOVIE=1,
    BIN_MOVIE

}M_TYPE;

typedef enum MovieDetails
{
    TAG_MD_PICTURE_VIEW = 0,
    TAG_MD_TITLE_VIEW,
    TAG_MD_LBL_TITLE,
    TAG_MD_LBL_RATING,
    TAG_MD_DETAILS_VIEW,
    TAG_MD_LBL_DETAILS,
    TAG_MD_LBL_PLAYMESS,
    TAG_MD_LBL_SAGEPRICE,
    TAG_MD_LBL_PURCHASE,
    TAG_MD_LBL_SALEPRICE,
    TAG_MD_LBL_PURCHASEMSG,
    TAG_MD_LBL_PURCHASEMSGTIME,
    TAG_MD_LBL_TIMERHEADER,
    TAG_MD_LBL_REMAINING_TIMERHEADER,
    TAG_MD_LBL_REMAINING_TIMER,
    TAG_POPUP_VIEW,
    TAG_MD_BTN_PLAY,
    TAG_MD_BTN_CAST,
    TAG_MD_ACTIONSHEET_PLAY,
    TAG_MD_ACTIONSHEET_PLAY_APPLETV,
    TAG_MD_FAVOURITE_BTN,
    TAG_MD_REMOVE_FAVOURITE_BTN,
    TAG_MD_BTN_TRAILER,
    TAG_MD_BTN_LOWDEF,
    TAG_MD_BTN_HIGHDEF,
    TAG_MD_BTN_ULTRADEF
}MovieDetails;

@class ASIHTTPRequest;

@interface MovieDetailsViewController : RootViewController <CustomPopupViewDelegate, IMDEventImageDelegate,GCKDeviceScannerListener, GCKDeviceManagerDelegate, GCKMediaControlChannelDelegate, UIActionSheetDelegate, ChromecastControllerDelegate>
{
    UIScrollView *mainScrollView;
    
    IMDEventImageView *pictureView;
    UIView *titleView, *detailsView;
    
    CustomButton *currentSelectedButton;
    CustomButton *currentSendButton;
    
    CustomPopupView *objView;
    VideoAction currentRequestType;
    NSMutableArray *temporaryDownloadedVideos;
    
    ASIHTTPRequest *asiRequest;
    NSString *strMessage;
    NSTimer *updateProgressTimer;
    int downloadOption;
}

@property (nonatomic,assign) int movieType;

@property (nonatomic,retain) NSString *strMovieId;
@property (nonatomic,retain) NSDictionary *video;
@property (nonatomic, strong) NSTimer *timerForCountdown;
@property (nonatomic, assign) ViewType viewType;

@property GCKMediaControlChannel *mediaControlChannel;
@property GCKApplicationMetadata *applicationMetadata;
@property GCKDevice *selectedDevice;
@property(nonatomic, strong) GCKDeviceScanner *deviceScanner;
@property(nonatomic, strong) UIButton *chromecastButton;
@property(nonatomic, strong) GCKDeviceManager *deviceManager;
@property(nonatomic, readonly) GCKMediaInformation *mediaInformation;

-(void)stopDownloading;

@end
