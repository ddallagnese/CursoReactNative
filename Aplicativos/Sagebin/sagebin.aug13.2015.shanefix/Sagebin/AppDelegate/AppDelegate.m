//
//  AppDelegate.m
//  Sagebin
//
//
//  
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "OpenUDID.h"
#import <AdSupport/ASIdentifierManager.h>
#import "ASIHTTPRequest.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/ParseFacebookUtilsV4.h>
#import "AlertViewController.h"
#import "MovieDetailsViewController.h"
#import "FriendListVC.h"
#import "Crittercism.h"
#import "MovieDetailsViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

static NSString *const kCrittercismAppID = @"53db59ad17878435c7000004";

@implementation AppDelegate

@synthesize navRootCont = _navRootCont;
@synthesize netOnLink;
@synthesize customAlertResult;
@synthesize requestObjects;
@synthesize requestDelegate;
@synthesize latestProfImg;
@synthesize isFromBuyMovie;
@synthesize currentVideoObj;
@synthesize isFromLocalPlayerScreen;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    /*
     #define RobotoReg(fontSize) [UIFont fontWithName:@"Roboto-Regular" size:fontSize]
     */
    
    [[AirPlayDetector defaultDetector] startMonitoring:self.window];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if(iOS7)
    {
        NSString *strPath = [NSString stringWithFormat:@"/Library/Caches/%@", [[NSBundle mainBundle] bundleIdentifier]];
        if ([filemgr removeItemAtPath: [NSHomeDirectory() stringByAppendingString:strPath] error: NULL]  == YES)
            NSLog (@"Remove successful");
        else
            NSLog (@"Remove failed");
        [filemgr createDirectoryAtPath: [NSHomeDirectory() stringByAppendingString:strPath] withIntermediateDirectories:NO attributes:nil error:nil];
    }
    else
    {
        if ([filemgr removeItemAtPath: [NSHomeDirectory() stringByAppendingString:@"/Library/Caches"] error: NULL]  == YES)
            NSLog (@"Remove successful");
        else
            NSLog (@"Remove failed");
        [filemgr createDirectoryAtPath: [NSHomeDirectory() stringByAppendingString:@"/Library/Caches"] withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    customAlertResult = [[NSMutableDictionary alloc] init];
    requestObjects = [[NSMutableDictionary alloc] init];
    temporaryDownloadedVideos = [[NSMutableArray alloc]init];
    
    // Initialize the chromecast device controller.
    self.chromecastDeviceController = [[ChromecastDeviceController alloc] init];
    
    // Scan for devices.
    [self.chromecastDeviceController performScan:YES];
    
    if([[NSUserDefaults standardUserDefaults] valueForKey:keyCastVideo]) {
        currentVideoObj = [[NSUserDefaults standardUserDefaults] valueForKey:keyCastVideo];
    }
    
    if (!iOS7)
    {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
    UIStoryboard *storyboard = iPhone_storyboard;
    if (iPad)
    {
        storyboard = iPad_storyboard;
    }
    
    self.navRootCont = [storyboard instantiateViewControllerWithIdentifier:@"navRootCont"];
    self.window.rootViewController = self.navRootCont;
    
    _isConnectionSet = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    [self checkDefaultSettingsForSourceAndNotifications];
    [self setReachibility];
    
    
    
    [Parse setApplicationId:@"ZXvHWpyNV3NY9lDAqzwaLGkQqG1DsLBPncI7GPsC"
                  clientKey:@"wl8R1nKyVeEAARdLZrC8zpxrTYOCPwLLOW4yomY0"];
    //[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    //[PFUser enableRevocableSessionInBackground];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];

	// Register for Push Notitications (iOS 8 and earlier)
	if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {

		UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
														UIUserNotificationTypeBadge |
														UIUserNotificationTypeSound);
        
		UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
																				 categories:nil];
		[application registerUserNotificationSettings:settings];
		[application registerForRemoteNotifications];

	} else {
		[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
		 (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
	}

    //NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    //[self setFirstPage:userInfo];
    
    [Crittercism enableWithAppID:kCrittercismAppID];
    
    return YES;
}

/*
 aps =     {
 alert = "Hyperlink Info Systems request friend with you";
 sound = cheer;
 };
 pageOpen = alert;
 pageOpenId = "";
 */

/*
 aps =     {
 alert = "Harnil Oza accept your friend request";
 sound = cheer;
 };
 pageOpen = friend;
 pageOpenId = "";
 */

/*
 aps =     {
 alert = "Leonardo Sagebin would like to borrow Star Trek";
 sound = cheer;
 };
 pageOpen = alert;
 pageOpenId = "";
 */

- (void)setFirstPage:(NSDictionary *)notification
{
    NSLog(@"notification: %@", notification);
    NSString *page = [notification objectForKey:@"pageOpen"];
    if ([page isEqualToString:@"alert"]){
        [self gotoAlertVC];
    }else if ([page isEqualToString:@"friend"]){
        [self gotoAlertVC];
    }else if ([page isEqualToString:@"video"]){
        //[self gotoMovieDetailsVCWithMovieId:[notification objectForKey:@"pageOpenId"]];
    }
}

-(void)gotoAlertVC
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:keyInAlertView])
    {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *account = [defaults objectForKey:keyAccount];
    NSLog(@"account = %@", account);
    if (account == nil || [account isEqualToString:@""])
    {
        return;
    }
    UIStoryboard *storyBoard = iPhone_storyboard;
    if (iPad)
    {
        storyBoard = iPad_storyboard;
    }
    AlertViewController *alertVC = (AlertViewController *) [storyBoard instantiateViewControllerWithIdentifier:@"AlertVC"];
    alertVC.parentController = self;
    [APPDELEGATE.navRootCont pushViewController:alertVC animated:YES];
    
    
}

/*-(void)gotoFriendsListVC
{
    UIStoryboard *storyboard;
    if (iPhone)
    {
        storyboard = iPhone_storyboard;
    }
    else
    {
        storyboard = self.storyboard;
    }
    FriendListVC *friendVC = (FriendListVC *) [storyboard instantiateViewControllerWithIdentifier:@"FriendViewVC"];
    [self.navigationController pushViewController:friendVC animated:YES];
}*/

-(void)gotoMovieDetailsVCWithMovieId:(NSString *)strMovieId
{
    NSLog(@"strMovieId : %@", strMovieId);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *account = [defaults objectForKey:keyAccount];
    NSLog(@"account = %@", account);
    if (account == nil || [account isEqualToString:@""])
    {
        return;
    }
    UIStoryboard *storyBoard = iPhone_storyboard;
    if (iPad)
    {
        storyBoard = iPad_storyboard;
    }
    MovieDetailsViewController *movieDetailsVC = (MovieDetailsViewController *) [storyBoard instantiateViewControllerWithIdentifier:@"MovieDetailsVC"];
    movieDetailsVC.strMovieId = strMovieId;
    movieDetailsVC.viewType = ViewTypeList;
    [APPDELEGATE.navRootCont pushViewController:movieDetailsVC animated:YES];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	//NSLog(@"Failed to get token, error: %@", error);
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Push Notification" message:@"Registration fail for push notification" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    //[alert show];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"deviceToken: %@", deviceToken);
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    //[currentInstallation addUniqueObject:@"everyone" forKey:@"channels"];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"userInfo: %@", userInfo);
    [PFPush handlePush:userInfo];
    [self setFirstPage:userInfo];
    
    if ( application.applicationState == UIApplicationStateActive)
    {
        
    }
}

// for ios 7
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    if (application.applicationState == UIApplicationStateInactive) {
//        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
//    }
    NSLog(@"userInfo ios7: %@", userInfo);
    [PFPush handlePush:userInfo];
    [self setFirstPage:userInfo];
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];

}

//- (void)applicationDidBecomeActive:(UIApplication *)application
//{
//    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
//}
//
//- (void)applicationWillTerminate:(UIApplication *)application
//{
//    [[PFFacebookUtils session] close];
//}

#pragma mark - Reachability Settings
-(void)setReachibility
{
    netOnLink = -1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    //Change the host name here to change the server your monitoring
    hostReach = [Reachability reachabilityWithHostName: @"www.google.com"];
	[hostReach startNotifier];
    [self configureReachability:hostReach];
    
    // For Individual Net Connection
    
    wifiReach = [Reachability reachabilityForLocalWiFi];
	[wifiReach startNotifier];
	//[self updateInterfaceWithReachability: wifiReach];
    [self configureReachability:wifiReach];
    
    internetReach = [Reachability reachabilityForInternetConnection];
	[internetReach startNotifier];
	//[self updateInterfaceWithReachability: internetReach];
    [self configureReachability:internetReach];
}

- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    if(curReach == hostReach)
	{
        /*[self configureReachability:curReach];
         BOOL connectionRequired= [curReach connectionRequired];
         
         NSString* baseLabel=  @"";
         if(connectionRequired)
         {
         baseLabel=  @"Cellular data network is available.\n  Internet traffic will be routed through it after a connection is established.";
         }
         else
         {
         baseLabel=  @"Cellular data network is active.\n  Internet traffic will be routed through it.";
         }
         NSLog(@"%@", baseLabel);*/
    }
	if(curReach == internetReach)
	{
        [self configureReachability:curReach];
        /*if(netOnLink == 1)
         {
         return;
         }*/
	}
	if(curReach == wifiReach)
	{
        [self configureReachability:curReach];
	}
}

- (void) configureReachability:(Reachability *)curReach
{
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    //BOOL connectionRequired= [curReach connectionRequired];
    //NSString* statusString= @"";
    switch (netStatus)
    {
        case NotReachable:
        {
            netOnLink = 0;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelDownloading" object:nil];
            break;
        }
            
        case ReachableViaWWAN:
        {
            netOnLink = 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"resumeDownloading" object:nil];
            break;
        }
        case ReachableViaWiFi:
        {
            netOnLink = 2;
            break;
        }
    }
    
    NSLog(@"%@", [NSString stringWithFormat:@"network : %d", netOnLink]);
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
    
    if (_isConnectionSet == [curReach currentReachabilityStatus]) {
        return;
    }
    _isConnectionSet = [curReach currentReachabilityStatus];
    
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	//[self updateInterfaceWithReachability: curReach];
    [self configureReachability:curReach];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationWillEnterForeground" object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
      [FBSDKAppEvents activateApp];
}
#pragma mark - App Methods
+(AppDelegate*)sharedDelegate
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}
-(void)setViewBorder:(UIView *)view withColor:(UIColor *)color
{
    [view.layer setBorderWidth:0.5];
    [view.layer setBorderColor:color.CGColor];
}
-(UILabel *)createLabelWithFrame:(CGRect)frame withBGColor:(UIColor *)color withTXColor:(UIColor *)txcolor withText:(NSString *)lblTitle withFont:(UIFont *)font withTag:(int)tag withTextAlignment:(NSTextAlignment)alignment
{
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:frame] ;
    tempLabel.backgroundColor = color;
    tempLabel.textColor = txcolor;
    [tempLabel setText:lblTitle];
    [tempLabel setFont:font];
    [tempLabel setTag:tag];
    [tempLabel setTextAlignment:alignment];
    tempLabel.numberOfLines = 0;
    return tempLabel;
}
-(UIView *)createTextFieldWithFrame:(CGRect)frame withImage:(UIImage *)image delegate:(id)delegate withTag:(NSInteger)tag
{
    UIView *textView = [[UIView alloc]initWithFrame:frame];
    [textView setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *icon_View =[self createImageViewWithFrame:CGRectMake(10, 0, image.size.width, image.size.height) withImage:image];
    [textView addSubview:icon_View];
    
    [icon_View setCenter:CGPointMake(icon_View.frame.size.width / 2 + 10, textView.frame.size.height/2)];
    
    
    UITextField *tempTextField = [[UITextField alloc]initWithFrame:CGRectMake(icon_View.frame.size.width + 20, 0, textView.frame.size.width - (icon_View.frame.size.width + 20), textView.frame.size.height)];
    [textView addSubview:tempTextField];
    [tempTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    tempTextField.tag = tag;
    [tempTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [tempTextField setBackgroundColor:[UIColor clearColor]];
    [tempTextField setDelegate:delegate];
    return textView;
}
-(UIView *)createTextViewWithFrame:(CGRect)frame withImage:(UIImage *)image delegate:(id)delegate withTag:(NSInteger)tag
{
    UIView *textView = [[UIView alloc]initWithFrame:frame];
    [textView setBackgroundColor:[UIColor whiteColor]];

    UIWebView *tempTextView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, textView.frame.size.width, textView.frame.size.height)];
    [textView addSubview:tempTextView];
    tempTextView.tag = tag;
//    [tempTextView setEditable:FALSE];
//    [tempTextView setScrollEnabled:YES];
    [tempTextView setBackgroundColor:[UIColor clearColor]];
    [tempTextView setDelegate:delegate];
    return textView;
}
-(UIImageView *)createImageViewWithFrame:(CGRect)frame withImage:(UIImage *)image
{
    UIImageView *tempImageView = [[UIImageView alloc]initWithFrame:frame];
    [tempImageView setBackgroundColor:[UIColor clearColor]];
    if (image) {
        [tempImageView setImage:image];
    }
    else{
        [tempImageView setBackgroundColor:[UIColor grayColor]];
    }
    [tempImageView setUserInteractionEnabled:NO];
    return tempImageView;
}

-(IMDEventImageView *)createEventImageViewWithFrame:(CGRect)frame withImageURL:(NSString *)imageURL Placeholder:(UIImage *)image tag:(int)tag
{
    IMDEventImageView *tempImageView = [[IMDEventImageView alloc]initWithFrame:frame];
    [tempImageView setBackgroundColor:[UIColor clearColor]];
    [tempImageView setImageWithURL:imageURL placeholderImage:image];
    [tempImageView setUserInteractionEnabled:NO];
    [tempImageView setContentMode:UIViewContentModeScaleToFill];
    [tempImageView setTag:tag];
    return tempImageView;
}

-(void)errorAlertMessageTitle:(NSString *)title andMessage:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
-(BOOL)email_Check:(NSString *)email
{
    NSString *mailreg = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *mailtest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",mailreg];
    return [mailtest evaluateWithObject:email];
}

/*
 #define Fonts_Orbitron_Medium(fontSize) ([UIFont fontWithName:@"orbitron-medium" size:fontSize])
 #define Fonts_OpenSans_Light(fontSize) ([UIFont fontWithName:@"OpenSans-Light" size:fontSize])
 #define Fonts_OpenSans_Regular(fontSize) ([UIFont fontWithName:@"OpenSans-Regular" size:fontSize])
 #define Fonts_OpenSans_Bold(fontSize) ([UIFont fontWithName:@"OpenSans-Bold" size:fontSize])
 */

#pragma mark - GET CUSTOM FONTS
-(UIFont *)Fonts_Orbitron_Medium:(NSInteger)fontSize
{
    return [UIFont fontWithName:@"Orbitron-Medium" size:fontSize];
}
-(UIFont *)Fonts_OpenSans_Light:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"OpenSans-Light" size:fontSize];
}
-(UIFont *)Fonts_OpenSans_Regular:(NSInteger)fontSize
{
    return [UIFont fontWithName:@"OpenSans" size:fontSize];
}
-(UIFont *)Fonts_OpenSans_Bold:(NSInteger)fontSize
{
    return [UIFont fontWithName:@"OpenSans-Bold" size:fontSize];
}
-(UIFont *)Fonts_OpenSans_LightItalic:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"OpenSansLight-Italic" size:fontSize];
}


-(NSString *)numberFormatStyleFromString:(NSString *)strValue
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    return [numberFormatter stringFromNumber:[NSNumber numberWithInteger:[strValue integerValue]]];
}

-(void)openHomeViewController
{
    HomeViewController *controller;
    if (IS_IPHONE_5)
    {
        controller = [[HomeViewController alloc]initWithNibName:@"HomeViewController4" bundle:nil];
    }
    else
    {
        controller = [[HomeViewController alloc]initWithNibName:@"HomeViewController_35" bundle:nil];
    }
    NSArray *controllers = [APPDELEGATE.navRootCont viewControllers];
    UIViewController *lastView = [controllers objectAtIndex:[controllers count]-1];
    NSLog(@"%@",lastView);
    if ([lastView isKindOfClass:[RegistrationVC class]]  )
    {
        controller.isFromRegistration=TRUE;
    }

    
    [APPDELEGATE.navRootCont pushViewController:controller animated:YES];
}

-(void)storeLoginResponse:(NSDictionary *)result
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[result objectForKey:keyAccount] forKey:keyAccount];
    [defaults setObject:[result objectForKey:keyDisplayName] forKey:keyDisplayName];
    [defaults synchronize];
    
    int downloadMode = [[result valueForKey:keyMode] integerValue]-1;
    if(downloadMode == -1)
    {
        downloadMode = 0;
    }
    else if(downloadMode == 1)
    {
        if(iPad)
        {
            downloadMode = 0;
        }
    }
    
    int notificationType = [[result valueForKeyPath:keySetting] integerValue]-1;
    if(notificationType == -1)
    {
        notificationType = 0;
    }
    
    int notificationPeriod = [[result valueForKeyPath:keyNotificationPeriod] integerValue]-1;
    if(notificationPeriod == -1)
    {
        notificationPeriod = 1;
    }
    
    [self setVideoDownloadMode:downloadMode];
    [self setNotificationType:notificationType];
    [self setNotificationPeriod:notificationPeriod];
}

#pragma mark - Set Default Settings
-(void)setVideoDownloadMode:(DownLoadMode)mode
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:mode forKey:DefaultKeyDownloadMode];
    [defaults synchronize];
}

-(void)setNotificationType:(NotificationType)type
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:type forKey:DefaultKeyNotificationType];
    [defaults synchronize];
}

-(void)setNotificationPeriod:(NotificationPeriod)period
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:period forKey:DefaultKeyNotificationPeriod];
    [defaults synchronize];
}

-(DownLoadMode)getDownLoadMode
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:DefaultKeyDownloadMode];
}

-(NotificationType)getNotificationType
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:DefaultKeyNotificationType];
}

-(NotificationPeriod)getNotificationPeriod
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:DefaultKeyNotificationPeriod];
}
-(void)checkDefaultSettingsForSourceAndNotifications
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults valueForKey:DefaultKeyDownloadMode]) {
        [self setVideoDownloadMode:DefaultValueDownloadMode];
    }
    if (![defaults valueForKey:DefaultKeyNotificationType]) {
        [self setNotificationType:DefaultValueNotificationType];
    }
    if (![defaults valueForKey:DefaultKeyNotificationPeriod]) {
        [self setNotificationPeriod:DefaultValueNotificationPeriod];
    }
}

- (NSString *)getAppToken
{
    NSString *udid = @"";
    if (!NSClassFromString(@"ASIdentifierManager")) {
        // This is will run before iOS6 and you can use openUDID, per example...
        udid= [OpenUDID value];
    }
    else{
        udid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
    return udid;
}

#pragma mark - Download Methods
- (void) removeRequestObjectForTag:(int)tag {
    if(requestObjects) {
        if([requestObjects valueForKey:[self getKeyForTag:tag]]) {
            [requestObjects removeObjectForKey:[self getKeyForTag:tag]];
        }
    }
}

- (void) saveVideoIdForTimeUpdationWithTag:(int)tag {
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"OFFLINE_VIDEOS_IDS"])
    {
        NSString *ids = [[NSUserDefaults standardUserDefaults] valueForKey:@"OFFLINE_VIDEOS_IDS"];
        if([[ids componentsSeparatedByString:@","] count] > 0) {
            ids = [ids stringByAppendingFormat:@",%d",tag];
        }else{
            ids = [ids stringByAppendingFormat:@"%d",tag];
        }
        
        [self setNewPrefrencesForObject:ids forKey:@"OFFLINE_VIDEOS_IDS"];
        
        NSLog(@"Video IDs saved %@",ids);
    }
}

- (void) removeTempFileForTheRequest:(ASIHTTPRequest *)request
{
    if(request)
    {
        NSDictionary *requestInfo = (NSDictionary *)[request userInfo];
        
        if([requestInfo valueForKey:@"tempDownloadPath"])
        {
            NSString *path = [requestInfo valueForKey:@"tempDownloadPath"];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if([fileManager fileExistsAtPath:path])
            {
                NSError *error = nil;
                [fileManager removeItemAtPath:path error:&error];
                
                if (error)
                {
                    NSLog(@"error in removing alias - %@",error.description);
                }
            }
        }
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    //remove temp file which was may creating if user choosed play while download
    [self removeTempFileForTheRequest:request];
    
    //removing ASI request object from the dictionary.
    [self removeRequestObjectForTag:request.tag];
    
    //save video request tag for future use like, update time, renew, etc.
    [self saveVideoIdForTimeUpdationWithTag:request.tag];
    
    NSDictionary *dics = [request userInfo];
    [dics setValue:[NSNumber numberWithInt:2] forKey:keyOfflineMode];
    [dics setValue:[NSNumber numberWithInt:1] forKey:keyIsAlreadyDownloaded];
    
    [self setNewPrefrencesForObject:dics forKey:[self getKeyForTag:request.tag]];
    
    // remove temporary video details from plist after successful download
    temporaryDownloadedVideos = [self readFromListForKey:kVideosArray];
    for(int i=0;i<temporaryDownloadedVideos.count;i++)
    {
        NSDictionary *dictionary = [temporaryDownloadedVideos objectAtIndex:i];
        if([[dictionary valueForKey:keyId] intValue] == request.tag)
        {
            [temporaryDownloadedVideos removeObject:dictionary];
        }
    }
    [self writeToListToDeleteAllVideosForKey:kVideosArray];
    for(int i=0;i<temporaryDownloadedVideos.count;i++)
    {
        NSDictionary *dictionary = [temporaryDownloadedVideos objectAtIndex:i];
        [self writeToListForKey:kVideosArray content:dictionary];
    }
    
    NSString *downloadPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[self getTitleForVideo:request.userInfo]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:downloadPath])
    {
        [fileManager removeItemAtPath:downloadPath error:nil];
    }
    
    /*
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:0] forKey:NSFilePosixPermissions]; //511 is Decimal for the 777 octal
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error1;
    [fm setAttributes:dict ofItemAtPath:request.downloadDestinationPath error:&error1];
     */
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",[error localizedDescription]);
    
    //removing ASI request object from the dictionary.
    [self removeRequestObjectForTag:request.tag];
}

- (ASIHTTPRequest *) startDownloadingWithUrl:(NSString *)urlString withFileNameToSave:(NSString *)fileName withTag:(int)tag withUserInfo:(NSDictionary *)dictionary
{
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setTimeOutSeconds:30.f]; //60.f
    [request setDelegate:self];
    [request setUserInfo:dictionary];
    request.tag = tag;
    request.receivedHeader = NO;
    
    [request setShowAccurateProgress:YES];
    
    [request setDidFinishSelector:@selector(requestFinished:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setHeadersReceivedBlock:^(NSDictionary *responseHeaders)
     {
         //NSLog(@"%@", responseHeaders);
     }];
    
    NSString *downloadPath = [[APPDELEGATE getDocumentDirectory] stringByAppendingPathComponent:fileName];
    NSLog(@"Download path %@", downloadPath);
    [request setDownloadDestinationPath:downloadPath];
    
    NSString *downloadPath1 = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    [request setTemporaryFileDownloadPath:downloadPath1];
    
    [request setAllowResumeForFileDownloads:YES];
    [request setShouldContinueWhenAppEntersBackground:YES];
    [request startAsynchronous];
    
    if(![requestObjects valueForKey:[self getKeyForTag:tag]])
    {
        [requestObjects setObject:request forKey:[self getKeyForTag:tag]];
    }
    
    return request;
}
/**/

- (NSString *)getKeyForTag:(int)tag {
    return [NSString stringWithFormat:@"ASIObjectIndex_%d",tag];
}

- (ASIHTTPRequest *)getObjectForKey:(NSString *)key {
    ASIHTTPRequest *requst = nil;
    if([requestObjects valueForKey:key]){
        requst = (ASIHTTPRequest *)[requestObjects valueForKey:key];
        //NSLog(@"%llu", requst.contentLength);
    }
    
    return requst;
}

- (void) setProgressViewForDownloadingRequest:(ASIHTTPRequest *)request withProgressView:(UIProgressView *)progressView {
    if(request)
        [request setDownloadProgressDelegate:progressView];
}

#pragma mark -
#pragma mark LINE DETAILS FROM PLIST

-(NSMutableArray *)readFromListForKey:(NSString *)key{
	
	NSString *filePath=[self getPathForMetaDataList];
	NSMutableDictionary *mDictData = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    
    [temporaryDownloadedVideos removeAllObjects];
    NSMutableArray *videos = [[NSMutableArray alloc]init];
    videos = [mDictData objectForKey:key];
    if([videos count] > 0)
    {
        for(int i=0;i<[videos count];i++)
        {
            NSDictionary *video = [videos objectAtIndex:i];
            [temporaryDownloadedVideos addObject:video];
        }
    }
    return temporaryDownloadedVideos;
}

-(NSString *)getPathForMetaDataList{
	
	NSError *error = nil;
	
	// Get path to settings file.
	NSString *filePath = [[self getDocumentDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"TemporaryDownloadedVideos.plist"]];
	
	// Get pointer to file manager.
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// If the file does not exist, copy the generic starter theme data file from the app bundle.
	if(![fileManager fileExistsAtPath:filePath])
	{
		// Set path to the app bundle file.
		NSString *appBundleFilePath = [[NSBundle mainBundle] pathForResource:@"TemporaryDownloadedVideos" ofType:@"plist"];
		
		// Copy the app bundle file to the document directory.
		[fileManager copyItemAtPath:appBundleFilePath toPath:filePath error:&error];
	}
	return filePath;
}

-(void)writeToListForKey:(NSString *)key content:(id)contents
{
    NSString *filePath=[self getPathForMetaDataList];
	// Load the settings dictionary with the contents of the settings file.
	NSMutableDictionary *mDictData = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
	if (mDictData) {
        
        NSMutableArray *array = [mDictData valueForKey:key];
        [array addObject:contents];
        //		[mDictData setObject:array forKey:key];
		if([mDictData writeToFile:filePath atomically: YES]){
		}
	}
}

-(void)writeToListToDeleteAllVideosForKey:(NSString *)key
{
    NSString *filePath=[self getPathForMetaDataList];
	// Load the settings dictionary with the contents of the settings file.
	NSMutableDictionary *mDictData = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
	if (mDictData) {
        
        NSMutableArray *array = [mDictData valueForKey:key];
        [array removeAllObjects];
		if([mDictData writeToFile:filePath atomically:YES]){
		}
	}
}

-(BOOL)checkForDownloadedVideo:(NSDictionary *)video
{
    NSString *downloadPath = [self getPathForDownloadedVideo:video];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL flag = [fileManager fileExistsAtPath:downloadPath]?YES:NO;
    return flag;
}

-(NSString *)getDocumentDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

-(NSString *)getPathForDownloadedVideo:(NSDictionary *)video
{
    NSString *downloadPath = @"";
    downloadPath = [[self getDocumentDirectory] stringByAppendingPathComponent:[self getTitleForVideo:video]];
    return downloadPath;
}

-(NSString *)getTitleForVideo:(NSDictionary *)video // change movie title to avoid path problem
{
    NSString *title = [video valueForKey:keyTitle];
    //title = [title stringByDeletingPathExtension];
    NSArray *arrayTitle = [title componentsSeparatedByString:@"/"];
    NSString *strTitle = @"";
    if([arrayTitle count] > 1)
    {
        strTitle = [NSString stringWithFormat:@"%@-%@", [arrayTitle objectAtIndex:0], [arrayTitle objectAtIndex:1]];
    }
    else
    {
        strTitle = title;
    }
    return [NSString stringWithFormat:@"%@.%@", strTitle, [self getPathExtensionForVideoFile:[video valueForKey:keyItemStreaming]]];
}

-(NSString *)getPathExtensionForVideoFile:(NSString *)strURL
{
    NSString *lastPath = [strURL lastPathComponent];
    NSString *fileExtension = [lastPath pathExtension]; // [path pathExtension];
    NSLog(@"%@", lastPath); //myvideo.mp4
    NSLog(@"%@", fileExtension); // mp4
    NSArray *arr = [fileExtension componentsSeparatedByString:@"?"];
    if([arr count] == 2)
    {
        return [arr objectAtIndex:0];
    }
    return [strURL pathExtension];
}

-(uint64_t)getFreeDiskspace {
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        //NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return totalFreeSpace;
}
-(void)removeOldPrefrencesForKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setNewPrefrencesForObject:(id)obj forKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
