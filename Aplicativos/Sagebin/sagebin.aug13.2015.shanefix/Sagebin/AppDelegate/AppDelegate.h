//
//  AppDelegate.h
//  Sagebin
//
// 
//  
//

#import <UIKit/UIKit.h>
#import "CustomNavigationController.h"
#import "Constants.h"
#import "Reachability.h"
#import "ChromecastDeviceController.h"
#import "IMDEventImageView.h"

#define APPDELEGATE [AppDelegate sharedDelegate]

@class ASIHTTPRequest;


@protocol VideoDownLoadResponseDelegate;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;
    BOOL isNetAvailable,_changeReachability;
    BOOL _isConnectionSet;
    
    NSMutableDictionary *requestObjects;
    NSMutableArray *temporaryDownloadedVideos;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) CustomNavigationController *navRootCont;
@property (retain, nonatomic) NSMutableDictionary *customAlertResult;
@property (readwrite) int netOnLink;
@property (retain, nonatomic) NSMutableDictionary *requestObjects;
@property (retain, nonatomic) id <VideoDownLoadResponseDelegate> requestDelegate;
@property (retain, nonatomic) UIImage *latestProfImg;
@property (nonatomic, assign) BOOL isFromBuyMovie;
@property (nonatomic) ChromecastDeviceController* chromecastDeviceController;
@property (nonatomic, retain) NSDictionary *currentVideoObj;
@property (nonatomic, assign) BOOL isFromLocalPlayerScreen;

+(AppDelegate*)sharedDelegate;
-(void)setViewBorder:(UIView *)view withColor:(UIColor *)color;
-(void)setReachibility;


#pragma mark - creation methods
-(UILabel *)createLabelWithFrame:(CGRect)frame withBGColor:(UIColor *)color withTXColor:(UIColor *)txcolor withText:(NSString *)lblTitle withFont:(UIFont *)font withTag:(int)tag withTextAlignment:(NSTextAlignment)alignment;
-(UIView *)createTextFieldWithFrame:(CGRect)frame withImage:(UIImage *)image delegate:(id)delegate withTag:(NSInteger)tag;
-(UIView *)createTextViewWithFrame:(CGRect)frame withImage:(UIImage *)image delegate:(id)delegate withTag:(NSInteger)tag;
-(UIImageView *)createImageViewWithFrame:(CGRect)frame withImage:(UIImage *)image;
-(IMDEventImageView *)createEventImageViewWithFrame:(CGRect)frame withImageURL:(NSString *)imageURL Placeholder:(UIImage *)image tag:(int)tag;
-(void)errorAlertMessageTitle:(NSString *)title andMessage:(NSString *)msg;

#pragma mark - Validation Methods
-(BOOL)email_Check:(NSString *)email;

#pragma mark - Fonts Methods
-(UIFont *)Fonts_Orbitron_Medium:(NSInteger)fontSize;
-(UIFont *)Fonts_OpenSans_Light:(CGFloat)fontSize;
-(UIFont *)Fonts_OpenSans_Regular:(NSInteger)fontSize;
-(UIFont *)Fonts_OpenSans_Bold:(NSInteger)fontSize;
-(UIFont *)Fonts_OpenSans_LightItalic:(CGFloat)fontSize;

#pragma mark - Number Formate Methdos
-(NSString *)numberFormatStyleFromString:(NSString *)strValue;
-(void)openHomeViewController;

#pragma - Store Login Response
-(void)storeLoginResponse:(NSDictionary *)result;

#pragma - Default Settings
-(void)setVideoDownloadMode:(DownLoadMode)mode;
-(void)setNotificationType:(NotificationType)type;
-(void)setNotificationPeriod:(NotificationPeriod)period;

-(DownLoadMode)getDownLoadMode;
-(NotificationType)getNotificationType;
-(NotificationPeriod)getNotificationPeriod;

#pragma - App Token
- (NSString *)getAppToken;

#pragma mark - Download Video
- (ASIHTTPRequest *) startDownloadingWithUrl:(NSString *)urlString withFileNameToSave:(NSString *)fileName withTag:(int)tag  withUserInfo:(NSDictionary *)dictionary;
- (void) setProgressViewForDownloadingRequest:(ASIHTTPRequest *)request withProgressView:(UIProgressView *)progressView;

- (ASIHTTPRequest *)getObjectForKey:(NSString *)key;
- (NSString *)getKeyForTag:(int)tag;
-(NSString *)getPathForMetaDataList;
-(void)writeToListForKey:(NSString *)key content:(id)contents;
-(void)writeToListToDeleteAllVideosForKey:(NSString *)key;
-(NSMutableArray *)readFromListForKey:(NSString *)key;
-(BOOL)checkForDownloadedVideo:(NSDictionary *)video;
-(NSString *)getPathForDownloadedVideo:(NSDictionary *)video;
-(NSString *)getTitleForVideo:(NSDictionary *)video;

-(NSString *)getDocumentDirectory;
-(uint64_t)getFreeDiskspace;
-(NSString *)getPathExtensionForVideoFile:(NSString *)strURL;

-(void)removeOldPrefrencesForKey:(NSString *)key;
-(void)setNewPrefrencesForObject:(id)obj forKey:(NSString *)key;

@end

@protocol VideoDownLoadResponseDelegate <NSObject>
@required
- (void)didReceiveVideoRequest:(ASIHTTPRequest *)donwloadrequest;
@end