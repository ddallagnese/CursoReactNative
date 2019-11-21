//
//  SettingsViewController.m
//  Sagebin
//
//  
//

#import "SettingsViewController.h"
#import "ProfileViewController.h"
#import "CastViewController.h"
#import "DeviceTableViewController.h"

#define kSectionTitles @"How Movies are downloaded,Notifications,Notification Period,Account Credits:"
#define kTitlesDownloadMode @"Wifi,Cellular and Wifi"
#define kTitlesNotificationType @"Push only,Email only,Both"
#define KTitlesNotificationPeriod @"Daily,Weekly,Monthly"

#define kFont [APPDELEGATE Fonts_OpenSans_Regular:(iPad?18:12)]

#define MARGIN (iPad?10:10)

@interface SettingsViewController ()
{
    __weak ChromecastDeviceController *_chromecastController;
}
@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:SettingsViewBgColor];
    UIButton *btnSettings = [self rightButton];
    [btnSettings setImage:[UIImage imageNamed:@"settings_profile"] forState:UIControlStateNormal];
    [btnSettings removeTarget:self action:@selector(btnRightClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btnSettings addTarget:self action:@selector(btnSettingsClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setupLayoutMethods];
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
    }
    else
    {
        [self getApiData];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [settingsTable reloadData];
    [self setSagebinLogoInCenterForOrientation:[UIApplication sharedApplication].statusBarOrientation];
    if([[NSUserDefaults standardUserDefaults] objectForKey:keyIsAlertAvailable])
    {
        [self.alertButton setHidden:YES];
    }
    _chromecastController = APPDELEGATE.chromecastDeviceController;
    _chromecastController.delegate = self;
    if (_chromecastController.deviceScanner.devices.count > 0 && APPDELEGATE.currentVideoObj && _chromecastController.isConnected == YES)
    {
        //[self.castButton setHidden:NO];
        UIButton *btnCast = (UIButton *)[self.view viewWithTag:kTagCastButton];
        if(!btnCast)
        {
            btnCast = (UIButton *)_chromecastController.chromecastBarButton.customView;
            [btnCast setTag:kTagCastButton];
            [btnCast setHidden:NO];
            if(iPhone)
            {
                [btnCast setFrame:self.castButton.frame];
            }
            else
            {
                [btnCast setFrame:self.castButton.frame];
            }
            [btnCast setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin];
            [self.view addSubview:btnCast];
        }
    }
}

-(void)btnSettingsClicked:(UIButton *)btn
{
    UIStoryboard *storyboard = iPhone_storyboard;
    if (iPad)
    {
        storyboard = self.storyboard;
    }
    ProfileViewController *profileVC = (ProfileViewController *) [storyboard instantiateViewControllerWithIdentifier:@"profileVC"];
    [self.navigationController pushViewController:profileVC animated:YES];
}

-(void)setupLayoutMethods
{
    CHECKED_INDEX_DOWNLOAD_MODE = [APPDELEGATE getDownLoadMode];
    CHECKED_INDEX_NOTIFICATION_TYPE = [APPDELEGATE getNotificationType];
    CHECKED_INDEX_NOTIFICATION_PERIOD = [APPDELEGATE getNotificationPeriod];
    
    arraySectionTitles = [[NSMutableArray alloc]init];
    [arraySectionTitles addObjectsFromArray:[kSectionTitles componentsSeparatedByString:@","]];
    
    arrayDownloadModes = [[NSMutableArray alloc]init];
    [arrayDownloadModes addObjectsFromArray:[kTitlesDownloadMode componentsSeparatedByString:@","]];
    
    arrayNotificationTypes = [[NSMutableArray alloc]init];
    [arrayNotificationTypes addObjectsFromArray:[kTitlesNotificationType componentsSeparatedByString:@","]];
    
    arrayNotificationPeriods = [[NSMutableArray alloc]init];
    [arrayNotificationPeriods addObjectsFromArray:[KTitlesNotificationPeriod componentsSeparatedByString:@","]];
    
    UIView *topView = [self.view viewWithTag:TopView_Tag];
    
    // add News buttonView
    
    UIView *newsButtonView = [[UIView alloc]initWithFrame:CGRectMake(MARGIN,  topView.frame.origin.y+topView.frame.size.height+10,  self.view.frame.size.width-MARGIN*2, (iPad?50:30))];
    [newsButtonView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
     [self.view addSubview:newsButtonView];
    
    
    
    UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,  (iPad?50:30), (iPad?50:30))];
    image.image=[UIImage imageNamed:@"news"];
    [newsButtonView addSubview:image];
    
    UIButton *btnNews = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnNews setFrame:CGRectMake(image.frame.origin.x+image.frame.size.width+5,  0,  newsButtonView.frame.size.width-image.frame.size.width-5, (iPad?50:30))];
    [btnNews setTitle:NSLocalizedString(@"btnNews", nil) forState:UIControlStateNormal];
    [btnNews setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnNews addTarget:self action:@selector(newsButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [btnNews setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [btnNews setBackgroundColor:TopBgColor];
    [btnNews.titleLabel setFont:kFont];
    [newsButtonView addSubview:btnNews];

   
    
    
    settingsTable = [[UITableView alloc]initWithFrame:CGRectMake(MARGIN, topView.frame.origin.y+topView.frame.size.height+15+btnNews.frame.size.height, self.view.frame.size.width-MARGIN*2, self.view.frame.size.height-(topView.frame.origin.y+topView.frame.size.height+10)-MARGIN-btnNews.frame.size.height) style:UITableViewStylePlain];
    settingsTable.tag = kTagTableSettings;
    settingsTable.delegate = self;
    settingsTable.dataSource = self;
    settingsTable.backgroundView = nil;
    settingsTable.backgroundColor = [UIColor clearColor];
    [settingsTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [settingsTable setShowsVerticalScrollIndicator:NO];
    [settingsTable setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    if ([settingsTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [settingsTable setSeparatorInset:UIEdgeInsetsZero];
    }
    [self.view addSubview:settingsTable];
    [settingsTable reloadData];
    
//    // add News button
//    CGFloat buttonMargin1 = 0.0;
//    CGFloat buttonHeight1 = 40.0;
//    UIButton *btnNews = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btnNews setFrame:CGRectMake(buttonMargin1, buttonMargin1, settingsTable.frame.size.width - buttonMargin1*2.0, buttonHeight1)];
//    [btnNews setTitle:NSLocalizedString(@"btnNews", nil) forState:UIControlStateNormal];
//    [btnNews setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [btnNews addTarget:self action:@selector(submitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//    [btnNews setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
//    [btnNews setBackgroundColor:TopBgColor];
//    [btnNews.titleLabel setFont:kFont];
//    settingsTable.tableHeaderView = btnNews;

    
    // add submit button
    CGFloat buttonMargin = 0.0;
    CGFloat buttonHeight = 40.0;
    UIButton *btnSubmit = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSubmit setFrame:CGRectMake(buttonMargin, buttonMargin, settingsTable.frame.size.width - buttonMargin*2.0, buttonHeight)];
    [btnSubmit setTitle:NSLocalizedString(@"btnSubmitUpdate", nil) forState:UIControlStateNormal];
    [btnSubmit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSubmit addTarget:self action:@selector(submitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [btnSubmit setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [btnSubmit setBackgroundColor:TopBgColor];
    [btnSubmit.titleLabel setFont:kFont];
    settingsTable.tableFooterView = btnSubmit;
}

-(void)getApiData
{
    IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
    NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], NSLocalizedString(@"apiSettings", nil)];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl]];
    NSData *postData = [NSData dataWithBytes:[strParameter UTF8String] length:[strParameter length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:kTAG_SETTINGS];
    [requestConnection startAsynchronousRequest];
    
    [SEGBIN_SINGLETONE_INSTANCE addLoader];
    [self enableDisableUI:NO];
}

-(void)enableDisableUI:(BOOL)status
{
    [settingsTable setUserInteractionEnabled:status];
    [self.rightButton setUserInteractionEnabled:status];
}
-(void)newsButtonClicked
{
        UIStoryboard *storyboard = iPhone_storyboard;
        if (iPad)
        {
            storyboard = self.storyboard;
        }
        NewsViewController *newsVC = (NewsViewController *) [storyboard instantiateViewControllerWithIdentifier:@"NewsVC"];
    
        [self.navigationController pushViewController:newsVC animated:YES];
}
-(void)submitButtonClicked
{
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    
    [SEGBIN_SINGLETONE_INSTANCE addLoader];
    [self enableDisableUI:NO];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *aUrl = [NSURL URLWithString:NSLocalizedString(@"appAPI", nil)];
    //NSLog(@"%@", aUrl);
    NSMutableURLRequest *request1 = [[NSMutableURLRequest alloc] initWithURL:aUrl];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request1 addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *body = [[NSMutableData alloc] init];
    
    [SEGBIN_SINGLETONE_INSTANCE setName:keyAccount withValue:[defaults objectForKey:keyAccount] onBody:body];
    [SEGBIN_SINGLETONE_INSTANCE setName:keyPage withValue:NSLocalizedString(@"apiUpdateUserDetail", nil) onBody:body];
    [SEGBIN_SINGLETONE_INSTANCE setName:keyOldPassword withValue:@"" onBody:body];
    [SEGBIN_SINGLETONE_INSTANCE setName:keyNewPassword withValue:@"" onBody:body];
    //[self setName:@"profile_photo" withFileName:@"UserPic.jpeg" withValue:UIImageJPEGRepresentation(posterView.image, 0.8) onBody:body];
    
    int m = [APPDELEGATE getDownLoadMode] + 1;
    int nv = [APPDELEGATE getNotificationType] + 1;
    int np = [APPDELEGATE getNotificationPeriod] + 1;
    
    [SEGBIN_SINGLETONE_INSTANCE setName:keyModeVal withValue:[NSString stringWithFormat:@"%d", m] onBody:body];
    [SEGBIN_SINGLETONE_INSTANCE setName:keyNotifyVal withValue:[NSString stringWithFormat:@"%d", nv] onBody:body];
    [SEGBIN_SINGLETONE_INSTANCE setName:keyNotifyPeriodVal withValue:[NSString stringWithFormat:@"%d", np] onBody:body];
    
    [request1 setHTTPBody:body];
    [request1 setHTTPMethod:@"POST"];
    
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request1 queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         [self enableDisableUI:YES];
         [SEGBIN_SINGLETONE_INSTANCE removeLoader];
         if(data != nil)
         {
             NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
             
             if ([[result objectForKey:keyCode] isEqualToString:keySuccess]){
        
                 [self.view makeToast:[result valueForKey:keyValue]];
                 
             }else{
                 [self.view makeToast:kServerError];
             }
         }
         else
         {
             [self.view makeToast:kServerError];
         }
     }];
}



#pragma mark - IMDHTTPRequest Delegates
//When fail parssing with error then get error for url tag
-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didFailWithError:(NSError*)error withTag:(int)tag
{
    [self.view makeToast:kServerError];
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    [self enableDisableUI:YES];
}
//when success parssing then get nsdata and NSObject (NSArray,NSMutableDictionary,NSString) with url tag
-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didSuccessWithItems:(NSObject*)items withData:(NSData*)data withTag:(int)tag
{
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    [self enableDisableUI:YES];
    if (tag==kTAG_SETTINGS)
    {
        NSDictionary *result = (NSDictionary *)items;
        if ([result isKindOfClass:[NSDictionary class]] && [result objectForKey:keyCode])
        {
            if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
            {
                [self checkUserAlert:[result objectForKey:keyAlerts]];
                userDictionary = [result objectForKey:keyValue];
                //[self showContent];
                
                int downloadMode = [[userDictionary valueForKey:keyMode] integerValue]-1;
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
                CHECKED_INDEX_DOWNLOAD_MODE = downloadMode;//[delegate getDownLoadSource];
                
                int notificationType = [[userDictionary valueForKey:keySetting]  integerValue]-1;
                if(notificationType == -1)
                {
                    notificationType = 0;
                }
                CHECKED_INDEX_NOTIFICATION_TYPE = notificationType ;//[delegate getSendNotiVia];
                
                int notificationPeriod = [[userDictionary valueForKey:keyNotificationPeriod] integerValue]-1;
                if(notificationPeriod == -1)
                {
                    notificationPeriod = 1;
                }
                CHECKED_INDEX_NOTIFICATION_PERIOD = notificationPeriod;//[delegate getSendNotiME];
                
                [APPDELEGATE setVideoDownloadMode:CHECKED_INDEX_DOWNLOAD_MODE];
                [APPDELEGATE setNotificationType:CHECKED_INDEX_NOTIFICATION_TYPE];
                [APPDELEGATE setNotificationPeriod:CHECKED_INDEX_NOTIFICATION_PERIOD];
                
                [settingsTable reloadData];
            }
            else
            {
                [self.view makeToast:kServerError];
            }
        }
        else
        {
            [self.view makeToast:kServerError];
        }
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return arraySectionTitles.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [arraySectionTitles objectAtIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kRowHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    [view setBackgroundColor:[UIColor colorWithRed:5.0/255.0 green:40.0/255.0 blue:65.0/255.0 alpha:1.0]];
    
    UILabel *lbl = [APPDELEGATE createLabelWithFrame:CGRectMake(0, 10, 280, 24) withBGColor:[UIColor clearColor] withTXColor:[UIColor colorWithRed:94.0/255.0 green:173.0/255.0 blue:221.0/255.0 alpha:1.0] withText:[NSString stringWithFormat:@"   %@", [arraySectionTitles objectAtIndex:section]] withFont:[UIFont fontWithName:kFontHelvetica size:15.0] withTag:-1 withTextAlignment:NSTextAlignmentLeft];
    [view addSubview:lbl];
    
    if(section == SectionAccountCredits)
    {
        NSString *strCreditAmt = @"";
        if([userDictionary valueForKey:keyCreditAmount])
        {
            strCreditAmt = [userDictionary valueForKey:keyCreditAmount];
        }
        lbl = [APPDELEGATE createLabelWithFrame:CGRectMake(settingsTable.frame.size.width - 50, 10, 50, 24) withBGColor:[UIColor clearColor] withTXColor:[UIColor colorWithRed:94.0/255.0 green:173.0/255.0 blue:221.0/255.0 alpha:1.0] withText:strCreditAmt withFont:[UIFont fontWithName:kFontHelvetica size:15.0] withTag:-1 withTextAlignment:NSTextAlignmentCenter];
        [view addSubview:lbl];
    }
    
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kRowHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSString *strCellIden = [NSString stringWithFormat:@"Cell%d%d",indexPath.section,indexPath.row];
    static NSString *cellIden = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIden];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIden];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //cell.backgroundColor = [UIColor clearColor];
        [self setupCell:cell indexPath:indexPath];
    }
    [self updateCell:cell indexPath:indexPath];
    
    UILabel *lbl = (UILabel *)[cell viewWithTag:TAG_Cell_LblTitle];
    if (indexPath.section == SectionDownloadMode) {
        
        if (indexPath.row == CHECKED_INDEX_DOWNLOAD_MODE) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        lbl.text = [arrayDownloadModes objectAtIndex:indexPath.row];
        
    }
    else if(indexPath.section == SectionNotificationType){
        
        if (indexPath.row == CHECKED_INDEX_NOTIFICATION_TYPE) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        lbl.text = [arrayNotificationTypes objectAtIndex:indexPath.row];
    }
    else {
        if (indexPath.row == CHECKED_INDEX_NOTIFICATION_PERIOD) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        lbl.text = [arrayNotificationPeriods objectAtIndex:indexPath.row];
    }
    
    //cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (void)setupCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    UIView *whiteBGView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(0, 0, settingsTable.frame.size.width, kRowHeight) bgColor:[UIColor whiteColor] tag:TAG_REUSEVIEW alpha:1.0];
    [cell addSubview:whiteBGView];
    
    CGFloat leftMargin = 15.0;
    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(leftMargin, leftMargin, self.view.frame.size.width-10*2-leftMargin*2, (iPad?18:16))];
    [lblTitle setFont:[UIFont fontWithName:kFontHelvetica size:15.0]];
    [lblTitle setTag:TAG_Cell_LblTitle];
    [lblTitle setTextColor:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [cell addSubview:lblTitle];
    
    CGFloat lineHeight = 1.0/[UIScreen mainScreen].scale;
    UIView *line = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(0, kRowHeight - lineHeight, self.view.frame.size.width-10*2, lineHeight) bgColor:[UIColor blackColor] tag:Tag_Cell_ViewLine alpha:0.3];
    [cell addSubview:line];
}

- (void)updateCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    UIView *whiteBGView = (UIView *)[cell viewWithTag:TAG_REUSEVIEW];
    [whiteBGView setFrame:CGRectMake(0, 0, settingsTable.frame.size.width, kRowHeight)];
    
    CGFloat leftMargin = 15.0;
    CGRect frame = CGRectMake(leftMargin, leftMargin, self.view.frame.size.width-10*2-leftMargin*2, (iPad?18:16));
    UILabel *label = (UILabel *)[cell viewWithTag:TAG_Cell_LblTitle];
    //label.text = text;
    label.frame = frame;
    
    CGFloat lineHeight = 1.0/[UIScreen mainScreen].scale;
    UIView *line = (UIView *)[cell viewWithTag:Tag_Cell_ViewLine];
    [line setFrame:CGRectMake(0, kRowHeight - lineHeight, self.view.frame.size.width-10*2, lineHeight)];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SectionDownloadMode)
    {
        return arrayDownloadModes.count;
    }
    else if (section == SectionNotificationType)
    {
        return arrayNotificationTypes.count;
    }
    else if (section == SectionNotificationPeriod)
    {
        return arrayNotificationPeriods.count;
    }
    else
    {
        return 0;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SectionDownloadMode) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:CHECKED_INDEX_DOWNLOAD_MODE inSection:indexPath.section]];
        
        if(indexPath.row == 1 && iPad)
        {
            //[self.viewC.view makeToast:@"Cellular data are not available on this device"];
            if(APPDELEGATE.netOnLink == 1)
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
                CHECKED_INDEX_DOWNLOAD_MODE = indexPath.row;
                
                if([[NSUserDefaults standardUserDefaults] objectForKey:DefaultKeyDownloadMode])
                {
                    int downloadMode = [[NSUserDefaults standardUserDefaults] integerForKey:DefaultKeyDownloadMode];
                    if(downloadMode == DownLoadModeWIFI && indexPath.row == DownLoadModeBoth)
                    {
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DefaultKeySettingsChanged];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }
                
                [APPDELEGATE setVideoDownloadMode:indexPath.row];
            }
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            CHECKED_INDEX_DOWNLOAD_MODE = indexPath.row;
            
            if([[NSUserDefaults standardUserDefaults] objectForKey:DefaultKeyDownloadMode])
            {
                int downloadOption = [[NSUserDefaults standardUserDefaults] integerForKey:DefaultKeyDownloadMode];
                if(downloadOption == DownLoadModeWIFI && indexPath.row == DownLoadModeBoth)
                {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DefaultKeySettingsChanged];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
            
            [APPDELEGATE setVideoDownloadMode:indexPath.row];
        }
        
    } else if (indexPath.section == SectionNotificationType) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:CHECKED_INDEX_NOTIFICATION_TYPE inSection:indexPath.section]];
        cell.accessoryType = UITableViewCellAccessoryNone;
        CHECKED_INDEX_NOTIFICATION_TYPE = indexPath.row;
        [APPDELEGATE setNotificationType:indexPath.row];
    }
    else if (indexPath.section == SectionNotificationPeriod) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:CHECKED_INDEX_NOTIFICATION_PERIOD inSection:indexPath.section]];
        cell.accessoryType = UITableViewCellAccessoryNone;
        CHECKED_INDEX_NOTIFICATION_PERIOD = indexPath.row;
        [APPDELEGATE setNotificationPeriod:indexPath.row];
    }
    if (indexPath.section == SectionDownloadMode || indexPath.section ==SectionNotificationType || indexPath.section ==SectionNotificationPeriod) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if(indexPath.section == SectionDownloadMode && indexPath.row == 1 && iPad)
        {
            if(APPDELEGATE.netOnLink == 1)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
}

#pragma mark - Rotation Method

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [settingsTable reloadData];
    [self setSagebinLogoInCenterForOrientation:toInterfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ChromecastControllerDelegate

/**
 * Called when chromecast devices are discoverd on the network.
 */
- (void)didDiscoverDeviceOnNetwork {
    // Add the chromecast icon if not present.
    UIButton *btnCast = (UIButton *)[self.view viewWithTag:kTagCastButton];
    if(!btnCast)
    {
        btnCast = (UIButton *)_chromecastController.chromecastBarButton.customView;
        [btnCast setTag:kTagCastButton];
        [btnCast setHidden:NO];
        if(iPhone)
        {
            [btnCast setFrame:self.castButton.frame];
        }
        else
        {
            [btnCast setFrame:self.castButton.frame];
        }
        [btnCast setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin];
        [self.view addSubview:btnCast];
    }
}

/**
 * Called when connection to the device was established.
 *
 * @param device The device to which the connection was established.
 */
- (void)didConnectToDevice:(GCKDevice *)device {
    [_chromecastController updateToolbarForViewController:self];
}

/**
 * Called when connection to the device was closed.
 */
- (void)didDisconnect {
    [_chromecastController updateToolbarForViewController:self];
}

/**
 * Called when the playback state of media on the device changes.
 */
- (void)didReceiveMediaStateChange {
    [_chromecastController updateToolbarForViewController:self];
}

/**
 * Called to display the modal device view controller from the cast icon.
 */
- (void)shouldDisplayModalDeviceController {
    //[self performSegueWithIdentifier:@"listDevices" sender:self];
    
    UIStoryboard *storyboard = iPhone_storyboard;
    if (iPad)
    {
        storyboard = self.storyboard;
    }
    DeviceTableViewController *objDTVC = (DeviceTableViewController *) [storyboard instantiateViewControllerWithIdentifier:@"DeviceTableVC"];
    UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:objDTVC];
    [self.navigationController presentViewController:navBar animated:YES completion:nil];
}

/**
 * Called to display the remote media playback view controller.
 */
- (void)shouldPresentPlaybackController {
    // Select the item being played in the table, so prepareForSegue can find the
    
    if([[APPDELEGATE.currentVideoObj objectForKey:keyCanPlay] isEqualToNumber:[NSNumber numberWithInt:0]])
    {
        [APPDELEGATE errorAlertMessageTitle:@"Alert" andMessage:NSLocalizedString(@"strYou can not play this movie", nil)];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    UIStoryboard *storyboard = iPhone_storyboard;
    if (iPad)
    {
        storyboard = self.storyboard;
    }
    CastViewController *objCastVC = (CastViewController *) [storyboard instantiateViewControllerWithIdentifier:@"CastVC"];
    objCastVC.objVideo = APPDELEGATE.currentVideoObj;
    [self.navigationController pushViewController:objCastVC animated:YES];
}

-(void)dealloc
{
    NSLog(@"SettingsViewController dealloc called");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
