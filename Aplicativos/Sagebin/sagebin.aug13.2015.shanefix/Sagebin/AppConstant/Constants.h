//
//  Constants.h
//  ShowAndTell
//
//  
//

#import "float.h"

#ifndef Sagebin_Constants_h
#define Sagebin_Constants_h

#define iPhone UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone
#define iPad  UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define iPad_storyboard [UIStoryboard storyboardWithName:@"Main_iPad" bundle:[NSBundle mainBundle]];
#define iPhone_storyboard [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];


#define isPhone568 ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568)
#define iPhone568ImageNamed(image) (isPhone568 ? [NSString stringWithFormat:@"%@~568h.%@", [image stringByDeletingPathExtension], [image pathExtension]] : image)
#define KKeyboardHeight 216
#define DegreesToRadians(x)         ((x) * M_PI / 180.0)
#define RadiansToDegrees(x)         ((x) * 180.0 /M_PI )

#define KStatusBarHeight     CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)

#define KStatusBarWidth    CGRectGetWidth([UIApplication sharedApplication].statusBarFrame)
#define iOS8  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define iOS7  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define iOS6  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
//Home page BAckground color set
#define kHomebgColor [UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:1.0f];

#define SELECTED_TEXT_COLOR [UIColor colorWithRed:0.19f green:0.30f blue:0.51f alpha:1.0f]

#define TEXT_LEFT_ALIGNMENT     0
#define TEXT_CENTER_ALIGNEMNT   1
#define TEXT_RIGHT_ALIGINMENT   2

#define TEXT_LINEBREAKMODE_WORDWRAP  0
#define TEXT_LINEBREAKMODE_TRUNCATINGTRAIL 4
//Global Tags
#define msgBottomSpace 30
#define kMessageLblTag 1234
#define kMessageLblMovieTag 1155
#define showOpacityTime 3.0
#define showMessageTime 3.0
#define fontSpace 30
#define TotalProfilePages 2
#define TotalUserPerPage 20
#define KCategoryTableTag 1301
#define DownloadVideoFolder @"DownloadedVideos"

#define KSlideRightKey @"SlideRight"

#define ColorTxtPlaceHolder [UIColor colorWithRed:113.0/255.0 green:111.0/255.0 blue:105.0/255.0 alpha:1.0]


//Statusbar issue

#define KBackButtonFrame CGRectMake(iPad?13:5,iOS7?(MIN(KStatusBarHeight, KStatusBarWidth)+5):5, 31, 31)
#define kCenterFrame CGRectMake(31,iOS7?(MIN(KStatusBarHeight, KStatusBarWidth)+5):5, 176, 28)
#define KSlideButtonFrame CGRectMake(11,iOS7?KStatusBarHeight+12:12,26,22)
#define KSaveButtonFrame    CGRectMake(self.view.frame.size.width-60, iOS7?KStatusBarHeight+8:8, 50, 30)
#define KSearchButtonFrame CGRectMake(self.view.frame.size.width-35, iOS7?KStatusBarHeight+12:12, 22, 22)
#define KRightButtonFrame CGRectMake(self.view.frame.size.width-73, iOS7?KStatusBarHeight+9:9, 66, 25)


#define IMAGE_SCALE_SIZE                CGSizeMake(100,100)

#define KErrorLabel_X 15
#define KErrorLabel_Height 50
#define KAccessoryFrame CGRectMake(0, 0, 8, 13)
//Statusbar issue
//#define KTopBarHeight 45

#define KTopBarHeight iPad?(iOS7?96:76):(iOS7?64:44)
#define KAppStatusBarHeight (iOS7?20:0)//20
#define KEY_POSTTUMB_ALBUMS @"albums"
#define KSearchImageViewTag 1301
#define KSearchCloseButtonTag 1302

#define KTextFieldGroupTag 51000


//View Frames
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
//#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)



#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE_5_GREATER (IS_IPHONE && SCREEN_MAX_LENGTH >= 568.0)
#define KOpenHeight IS_IPHONE_5?470-2: 395
#define KCloseHeight IS_IPHONE_5?470-78: 395
#define KRegisterOpenFrame CGRectMake(0, 23, 290, 445)
#define KRegisterCloseFrame CGRectMake(0, 365-5, 290, 445+10)
#define KContentViewOpenFrame CGRectMake(15, iOS7?KStatusBarHeight+60:60, 290, KOpenHeight)
#define KContentViewCloseFrame CGRectMake(15, iOS7?KStatusBarHeight+60:60, 290, KCloseHeight-4)
#define KCoverPhotoHeight 170



#define KKeyUserList @"userlist"

#define KEY_LOCAL_GLOBALBUTTON_RUNNING_REQUEST @"isGlobalRunning"
#define KEY_YES @"Yes"
#define KEY_NO  @"No"
#define KEY_GLOBALBTN_ENABLE @"Enable"
//Profileview
#define KProfileMainScrollviewTag 201

#define KCoverPhotoDisplayHeight 170
#define KCoverAnimationDuration 1.45
#define KCoverDelayAnimation 0.5
#define TopBgColor [UIColor colorWithRed:99.0/255.0 green:124.0/255.0 blue:143.0/255.0 alpha:1.0]
#define LoginBgColor [UIColor colorWithRed:83.0/255.0 green:130.0/255.0 blue:187.0/255.0 alpha:1.0]
#define HomeBgColor [UIColor colorWithRed:52.0/255.0 green:166.0/255.0 blue:165.0/255.0 alpha:1.0]
#define FriendViewBgColor [UIColor colorWithRed:0.0/255.0 green:51.0/255.0 blue:153.0/255.0 alpha:1.0]
#define SettingsViewBgColor [UIColor colorWithRed:24.0/255.0 green:95.0/255.0 blue:144.0/255.0 alpha:1.0]
#define NewReleaseViewBgColor [UIColor colorWithRed:0.0/255.0 green:33.0/255.0 blue:68.0/255.0 alpha:1.0]
#define SearchMoviesViewBgColor [UIColor colorWithRed:24.0/255.0 green:95.0/255.0 blue:144.0/255.0 alpha:1.0]
#define NewsViewBgColor [UIColor colorWithRed:29.0/255.0 green:123.0/255.0 blue:127.0/255.0 alpha:1.0]
#define NewsDetailsViewBgColor [UIColor colorWithRed:29.0/255.0 green:123.0/255.0 blue:127.0/255.0 alpha:1.0]
#define MovieDetailsViewBgColor [UIColor colorWithRed:0.0/255.0 green:51.0/255.0 blue:153.0/255.0 alpha:1.0]
#define AlertViewBgColor [UIColor whiteColor]
#define ProfileViewBgColor [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0]
#define FriendMoviesViewBgColor [UIColor colorWithRed:0.0/255.0 green:174.0/255.0 blue:245.0/255.0 alpha:1.0]
#define MyMoviesViewBgColor [UIColor colorWithRed:218.0/255.0 green:171.0/255.0 blue:0.0/255.0 alpha:1.0]
//For Registration


#define DURATION_SUBSCRIPTION_1     12   //in months
#define DURATION_SUBSCRIPTION_2     12 //in months


#define kcollectionTopY (iOS7 ? 70 : 50)


//API Tags
#define kTAG_LOGIN 100
#define kTAG_NEW_RELEASE 101
#define kTAG_FRIENDS 102
#define kTAG_FRIEND_SEARCH 103
#define kTAG_SETTINGS 104

#define kTAG_MY_MOVIE 105
#define kTAG_BORROWED_MOVIE 106
#define kTAG_FRIEND_MOVIE 107
#define kTAG_SEARCH_MOVIE 108
#define kTAG_NEWS 109
#define kTAG_NEWS_DETAILS 110
#define kTAG_MOVIE_DETAILS 111
#define kTAG_MY_FRIENDS 112
#define kTAG_OFFLINE_DOWNLOAD_MOVIE 113
#define kTAG_OFFLINE_DOWNLOAD_MOVIE_DURATION 114
#define kTAG_OTHER_REQUEST 115
#define kTAG_CANCEL_REMOVE_OFFLINE 116
#define kTAG_ALERT_PAGE 117
#define kTAG_OTHER_ALERT_REQUEST 118
#define kTAG_REMOVE_OFFLINE 119
#define kTAG_MOVIE_VIEW_COUNT 120
#define kTAG_REMOVE_LENT 121

#define kTAG_HOME_IMAGES 124
#define kTAG_SEND_MOVIE_TO_FRIEND_REQUEST 125
#define kTAG_ADD_FRIEND 126
#define kTAG_REMOVE_FRIEND 127
#define kTAG_BIN_MOVIE 128
#define kTAG_FAV_MOVIE 129

#define kTAG_INVITAIONCODE 130
#define kTAG_INVITAIONCODE_FB 131
#define kTAG_INVITAIONCODE_GMAIL_FB 132
#define kTAG_CREATE_USER 133
#define kTAG_CLAIM_MOVIE 134
#define kTAG_SENDMOVIE_INVITAION 135
#define kTAG_PENDING_INVITATION_REQUEST 136




// SHARED SINGLETONE CLASS
#define SEGBIN_SINGLETONE_INSTANCE [Segbin_Singletone sharedInstance]


//STATUS METHODS
#define StatusString(USER_STATUS) ((USER_STATUS == USER_STATUS_ONLINE)? NSLocalizedString(@"txtOnline", nil) : NSLocalizedString(@"txtOffline", nil) )
#endif

#define kFontHelvetica @"Helvetica"
#define kPlaceholderImage [UIImage imageNamed:@"logo"]
#define kPlaceholderImg [UIImage imageNamed:@"logo~iphone.png"]
#define kLoaderImage [UIImage imageNamed:@"loader"]
#define kMoviePlaceholderImage [UIImage imageNamed:@"star_ipad.png"]
#define kTagLoaderView 1111

typedef enum{
    DownLoadModeWIFI = 0,
    DownLoadModeBoth
}DownLoadMode;

typedef enum{
    NotificationTypePush = 0,
    NotificationTypeEmail,
    NotificationTypeBoth
}NotificationType;

typedef enum{
    NotificationPeriodDaily = 0,
    NotificationPeriodWeekly,
    NotificationPeriodMonthly,
}NotificationPeriod;

typedef enum {
    ViewTypeFriends = 1,
    ViewTypeFriendsVideoList,
    ViewTypeList,
    ViewTypeNewVideoList,
    ViewTypeFindVideoList,
    ViewTypeVideoDetails,
    ViewTypeOfflineList,
    ViewTypeNewsList,
    ViewTypeNewsDetails,
    ViewTypeUserProfile
}ViewType;

typedef enum{
    VideoActionRevoke = 88,
    VideoActionBorrow,
    VideoActionReturn,
    VideoActionSend,
    VideoActionSell,
    VideoActionUnCell,
    VideoActionSellToFriend,
    VideoActionGiftToFriend,
    VideoActionInviteToFriend,
    
    VideoDownloadOffline,
    VideoDownloadOfflineFrom,
    VideoDownloadOfflineRenew,
    
    VideoActionAdminPurchase,
    VideoActionPurchaseFromFriend,
    
    BlurayBtn,
    DvdBtn
}VideoAction;

#define facebookAppID @"314999865328551"

#define DefaultKeyDownloadMode @"_KEY_DOWNLOAD_MODE_"
#define DefaultKeyNotificationType @"_KEY_NOTIFICATION_TYPE_"
#define DefaultKeyNotificationPeriod @"_KEY_NOTIFICATION_PERIOD_"

#define DefaultKeySettingsChanged @"_KEY_SETTINGS_CHANGED_"
#define DefaultValueDownloadMode DownLoadModeWIFI
#define DefaultValueNotificationType NotificationTypePush
#define DefaultValueNotificationPeriod NotificationPeriodDaily

#define keyAlerts @"alerts"
#define keyInAlertView @"inAlertView"
#define keyIsAlertAvailable @"isAlertAvailable"

#define keyAccount @"account"
#define keyDisplayName @"display_name"
#define keyCode @"code"
#define keySuccess @"success"
#define keyValue @"value"
#define keyFailed @"failed"
#define keyValid @"valid_code"
#define keyFailure @"failure"
#define keyTotalCount @"totalcount"
#define keyPhones @"phones"
#define keyGoogleFriends @"GoogleFriends"
#define keyFacebookFriends @"FacebookFriends"
#define keyFacebook_GmailDetail @"Facebook_GmailDetail"

//Invitation Movie limit
#define keyGiveMovies @"give_movies"
#define keyGiveMoviesLimit @"give_limit"
#define keyGiveFreeMovies @"free_movies"
#define keymovie_credits @"movie_credits"
#define keymovie_shares @"movie_shares"



//Settings - Profile
#define keyMode @"mode"
#define keySetting @"setting"
#define keyNotificationPeriod @"notification_period"
#define keyProfilePhoto @"profile_photo"
#define keyPage @"page"
#define keyOldPassword @"old_password"
#define keyNewPassword @"new_password"
#define keyModeVal @"mode_val"
#define keyNotifyVal @"notify_val"
#define keyNotifyPeriodVal @"notify_period_val"
#define keyProfilePhoto @"profile_photo"
#define keyProfileFileName @"UserPic.jpeg"
#define keyCreditAmount @"credit_amount"

//For FriendsList
#define keyID @"ID"
#define keyId @"id"
#define keyAvatar @"avatar"
#define keyBID @"bid"
#define keyFriendStatus @"friend_status"
#define keyUserEmail @"user_email"
#define keyUserNicename @"user_nicename"

//News & News Details
#define keyNews @"news"
#define keyTitle @"title"
#define keyImage @"image"
#define keyContent @"content"

#define keyItemTitle @"item_title"
#define keyItemRating @"item_rating"
#define keyItemDescription @"item_description"

//Movie Details
#define keyPoster @"poster"
#define keyPoster1 @"poster1"
#define keyDescription @"description"
#define keyItemRate @"item_rate"
#define keyTrailer @"trailer"
#define keyItemStreaming @"item_streaming"
#define keyItemStreaming_720 @"item_streaming_720"
#define keyItemStreaming_360 @"item_streaming_360"
#define keyItemStreaming_480 @"item_streaming_480"
#define keyItemStreaming_1080 @"item_streaming_1080"
#define keyIsMyVideo @"is_my_video"
#define keyCanBorrow @"can_borrow"
#define keyCanPlay @"can_play"
#define keyName @"name"
#define keyBorrowFriends @"borrow_friends"
#define keyBorrow @"borrow"
#define keyOwnerType @"owner_type"
#define keyFavourite @"favorite"
#define keyIID @"iid"
#define keyUID @"uid"
#define keyCanPlayMess @"can_play_mess"
#define keySagebinPrice @"sagebin_price"
#define keySagebinBliurayPrice @"sagebin_bluray_price"
#define keyBinPrice @"sagebin_bin_price"
#define keyBinBliurayPrice @"sagebin_bluray_bin_price"

#define keyIsPurchasedFromSagebin @"is_purchased_from_sagebin"
#define keyIsPurchasedFromSagebinMsg @"is_purchased_from_sagebin_msg"
#define keyItemStreaming1 @"item_streaming1"
#define keyItemStreaming2 @"item_streaming2"
#define keyItemStreaming3 @"item_streaming3"

#define keyPurchase @"purchase"
#define keySalePrice @"sale_price"
#define keyMessage @"message"
#define keyTime @"time"
#define keyError @"error"
#define keyURL @"url"

//Find Friends
#define keyEmails @"emails"

#define keyOfflineMode @"offline_mode"
#define keyExpiryDate @"expiry_date"
#define keyServerDate @"server_date"
#define keyNewServerDate @"new_server_date"
#define keyNewExpiryDate @"new_expiry_date"

#define keyLents @"lents"
#define keySaleFlag @"sale_flag"
#define keyIsAlreadyDownloaded @"is_already_downloaded"
#define keyUsers @"users"

//Alert Notification
#define keyFriends @"friends"
#define keyType @"type"
#define keyVideoRequest @"video_request"
#define keySendRequest @"send_request"
#define keyVideoType @"video_type"
#define keyVideoName @"video_name"
#define keyPermissionUser @"permission_user"
#define keyVideoId @"video_id"
#define keyFriendRequest @"friend_request"
#define keySellFriendRequest @"sell_friend_request"
#define keyRenewRequest @"renew_request"
#define keyAcceptBorrow @"accept_borrow"
#define keyGiftMovieShow @"Gift _Show"
#define keyInvitePending @"Invite_Pending"


#define WARNING @"no internet, only off-line mode is available."
#define kServerError @"Could not connect to server"

#define kButtonBGColorSel [UIColor whiteColor]
#define kButtonBGColorUnSel SettingsViewBgColor

#define kButtonTitleColorSel [UIColor blackColor]
#define kButtonTitleColorUnSel [UIColor whiteColor]

#define keyComment @"keyComment"
#define keyDuration @"keyDuration"
#define keyPrice @"keyPrice"
#define keyFriendsSelected @"keyFriendsSelected"
#define kVideosArray @"videosArray"

//offline-mode---
#define PAUSE_DOWNLOAD 8879
#define DOWNLOAD_MOVIE_OFFLINE_FROM 8880
#define DOWNLOAD_MOVIE_OFFLINE 8881
#define DOWNLOADING_MOVIE_PROGRESS_OFFLINE 8882
#define REMOVE_MOVIE_OFFLINE 8883
#define RENEW_MOVIE_OFFLINE 8884
#define OFFLINE_MOVIE_STATUS 8885

#define DOWNLOAD_MOVIE_OFFLINE_ENABLED 8886
#define DOWNLOAD_MOVIE_OFFLINE_REMOVE_MOVIE 8887
#define DOWNLOAD_MOVIE_OFFLINE_RENEW_MOVIE 8888
#define DOWNLOAD_MOVIE_OFFLINE_DURATION_LEFT 8889

#define DOWNLOADING_PROGRESS_BAR 88821
#define DOWNLOADING_PROGRESS_LABEL 88822

#define DOWNLOAD_MOVIE_OFFLINE_WAITING_FOR_APPROVAL 8801
#define DOWNLOAD_MOVIE_OFFLINE_CANCEL 8802

#define OFFLINE_VIDEO_LOCAL_PATH @"offline_video_local_path"
#define OFFLINE_DURATION @"offline_duration"
#define OFFLINE_VIDEO_TEMP_LOCAL_PATH @"offline_video_temp_local_path"
//---

#define kBorrowTimeDurations @"7 Days,24 Hours,48 Hours"
#define kPlaceHolderText @"send a message"

//#define KeyAPIBorrowVideo @"KeyAPIBorrowVideo"
#define KeyButtonValue @"KeyButtonValue"
#define keyCastVideo @"castVideo"

#define kTagCastButton 7575
