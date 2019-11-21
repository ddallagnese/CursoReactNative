 //
//  AlertViewController.m
//  Sagebin
//
//  
//

#import "AlertViewController.h"
#import "CastViewController.h"
#import "DeviceTableViewController.h"

#define MARGIN 10
#define LABEL_HEIGHT 50
#define BUTTON_HEIGHT 40
#define ROW_HEIGHT 130

@interface AlertViewController ()
{
    __weak ChromecastDeviceController *_chromecastController;
}
@end

@implementation AlertViewController

@synthesize parentController;

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
    [self.view setBackgroundColor:AlertViewBgColor];
    
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    arrAlerts = [[NSMutableArray alloc]init];
    [self getApiDataWithTag:kTAG_ALERT_PAGE];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setSagebinLogoInCenterForOrientation:[UIApplication sharedApplication].statusBarOrientation];
    
    [APPDELEGATE setNewPrefrencesForObject:@"yes" forKey:keyInAlertView];
    
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
    if([arrAlerts count]!=0)
    {
        [alertTable reloadData];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [APPDELEGATE removeOldPrefrencesForKey:keyInAlertView];
}

-(void)getApiDataWithTag:(int)tag
{
    IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
    NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], NSLocalizedString(@"apiAlertPage", nil)];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl]];
    NSData *postData = [NSData dataWithBytes:[strParameter UTF8String] length:[strParameter length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:tag];
    [requestConnection startAsynchronousRequest];
    
    [SEGBIN_SINGLETONE_INSTANCE addLoader];
}

#pragma mark - IMDHTTPRequest Delegates
-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didFailWithError:(NSError*)error withTag:(int)tag
{
    [self.alertButton setHidden:YES];
    [self.view makeToast:kServerError];
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
}
//when success parssing then get nsdata and NSObject (NSArray,NSMutableDictionary,NSString) with url tag
-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didSuccessWithItems:(NSObject*)items withData:(NSData*)data withTag:(int)tag
{
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    if (tag==kTAG_ALERT_PAGE)
    {
        //NSString *string = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionExternalRepresentation];
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
        {
            [self checkUserAlert:[result objectForKey:keyAlerts]];
           
            
            if([[[NSUserDefaults standardUserDefaults]valueForKey:keymovie_credits]intValue] != 0)
            {
                NSMutableDictionary *dic =[[NSMutableDictionary alloc]init];
                [dic setObject:@"Hello" forKey:@"message"];
                [dic setObject:@"hyperlink" forKey:@"display_name"];
                [dic setObject:keyGiftMovieShow forKey:@"type"];
                [arrAlerts addObject:dic];
            }
            
            if([[[NSUserDefaults standardUserDefaults]valueForKey:keymovie_shares]intValue] != 0)
            {
                NSMutableDictionary *dic =[[NSMutableDictionary alloc]init];
                [dic setObject:@"Hello" forKey:@"message"];
                [dic setObject:@"hyperlink" forKey:@"display_name"];
                [dic setObject:keyInvitePending forKey:@"type"];
                [arrAlerts addObject:dic];
            }
            
             [arrAlerts addObjectsFromArray:[result objectForKey:keyAlerts]];
           
            
            if(arrAlerts.count == 0)
            {
                [APPDELEGATE.window makeToast:@"No more alerts!"];
                [APPDELEGATE setNewPrefrencesForObject:@"no" forKey:keyIsAlertAvailable];
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            [APPDELEGATE removeOldPrefrencesForKey:keyIsAlertAvailable];
            [self setupLayoutMethods];
        }else{
            [self.view makeToast:kServerError];
        }
    }
    else if(tag==kTAG_OTHER_ALERT_REQUEST)
    {
        NSString *string = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionExternalRepresentation];
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        if(result)
        {
            if([[result valueForKey:keyCode] isEqualToString:keySuccess]){
                
                for (NSDictionary *alert in arrAlerts){
                    if ([[alert objectForKey:keyBID] intValue] == currentIndex){
                        [arrAlerts removeObject:alert];
                        
                        [alertTable deleteRowsAtIndexPaths:[NSArray arrayWithObjects:currentIndexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
                        break;
                    }
                }
            }
            else if([[result valueForKey:keyCode] isEqualToString:keyFailure])
            {
                [self.view makeToast:[result valueForKey:keyValue]];
            }
        }
        else
        {
            NSArray *arrResponse = [string componentsSeparatedByString:@":"];
            if([arrResponse count] > 1)
            {
                if([[arrResponse objectAtIndex:1] isEqualToString:keySuccess])
                {
                    for (NSDictionary *alert in arrAlerts){
                        if ([[alert objectForKey:keyBID] intValue] == currentIndex){
                            [arrAlerts removeObject:alert];
                            
                            [alertTable deleteRowsAtIndexPaths:[NSArray arrayWithObjects:currentIndexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
                            break;
                        }
                    }
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
        
        if ([arrAlerts count] == 0){
            
            [APPDELEGATE.window makeToast:@"No more alerts!"];
            [APPDELEGATE setNewPrefrencesForObject:@"no" forKey:keyIsAlertAvailable];
            [self.navigationController popViewControllerAnimated:YES];
            return;
            
            UILabel *lblNoAlerts = (UILabel *)[self.view viewWithTag:TAG_NoAlertLabel];
            if(lblNoAlerts)
            {
                [lblNoAlerts setHidden:NO];
            }
            else
            {
                lblNoAlerts = [APPDELEGATE createLabelWithFrame:CGRectMake(MARGIN, alertTable.frame.origin.y+MARGIN*2.0, self.view.frame.size.width-MARGIN*2.0, LABEL_HEIGHT) withBGColor:[UIColor clearColor] withTXColor:[UIColor blackColor] withText:@"No more alerts!" withFont:[UIFont fontWithName:kFontHelvetica size:15.0] withTag:TAG_NoAlertLabel withTextAlignment:NSTextAlignmentCenter];
                [lblNoAlerts setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
                [self.view addSubview:lblNoAlerts];
            }
            
            [self checkUserAlert:nil];
            if ([self.parentController respondsToSelector:@selector(checkUserAlert:)]) {
                [self.parentController checkUserAlert:nil];
            }
            [alertTable setHidden:YES];
        }
        else
        {
            UILabel *lblNoAlerts = (UILabel *)[self.view viewWithTag:TAG_NoAlertLabel];
            if(lblNoAlerts)
            {
                [lblNoAlerts setHidden:YES];
            }
            [alertTable reloadData];
            [APPDELEGATE removeOldPrefrencesForKey:keyIsAlertAvailable];
        }
    }
    [self.alertButton setHidden:YES];
}

#pragma mark - Layout Methods
-(void)setupLayoutMethods
{
    UIView *topView = [self.view viewWithTag:TopView_Tag];
    if(arrAlerts.count == 0)
    {
        UILabel *lblNoAlerts = [APPDELEGATE createLabelWithFrame:CGRectMake(MARGIN, topView.frame.origin.y+topView.frame.size.height+MARGIN, self.view.frame.size.width-MARGIN*2.0, LABEL_HEIGHT) withBGColor:[UIColor clearColor] withTXColor:[UIColor blackColor] withText:@"No more alerts!" withFont:[UIFont fontWithName:kFontHelvetica size:15.0] withTag:TAG_NoAlertLabel withTextAlignment:NSTextAlignmentCenter];
        [lblNoAlerts setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [self.view addSubview:lblNoAlerts];
    }
    else
    {
        alertTable = [[UITableView alloc]initWithFrame:CGRectMake(MARGIN, topView.frame.origin.y+topView.frame.size.height+MARGIN, self.view.frame.size.width-MARGIN*2, self.view.frame.size.height-(topView.frame.origin.y+topView.frame.size.height+MARGIN)) style:UITableViewStylePlain];
        alertTable.tag = TAG_AlertTable;
        alertTable.delegate = self;
        alertTable.dataSource = self;
        alertTable.backgroundView = nil;
        alertTable.backgroundColor = [UIColor clearColor];
        [alertTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [alertTable setShowsVerticalScrollIndicator:NO];
        [alertTable setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        if ([alertTable respondsToSelector:@selector(setSeparatorInset:)]) {
            [alertTable setSeparatorInset:UIEdgeInsetsZero];
        }
        [self.view addSubview:alertTable];
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrAlerts.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT; //[self getHeightForRow:indexPath];
}

/*-(CGFloat)getHeightForRow:(NSIndexPath *)indexPath
{
    NSDictionary *alert = [arrAlerts objectAtIndex:indexPath.row];
    if ([[alert objectForKey:keyType] isEqualToString:keyVideoRequest])
    {
        [message setText:[NSString stringWithFormat:@"%@ request borrow %@ \n %@", [alert objectForKey:@"display_name"], [alert objectForKey:@"item_title"],[alert objectForKey:@"message"]]];
    }
}*/

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSString *strCellIden = [NSString stringWithFormat:@"Cell%d%d",indexPath.section,indexPath.row];
    static NSString *cellIden = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIden];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIden];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if(iOS6)
        {
            cell.contentView.backgroundColor = TopBgColor;
        }
        cell.backgroundColor = TopBgColor;
        [self setupCell:cell indexPath:indexPath];
    }
    //[self setupCell:cell indexPath:indexPath];
    [self updateCell:cell indexPath:indexPath];
    
    return cell;
}

-(void)setupCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    NSDictionary *alert = [arrAlerts objectAtIndex:indexPath.row];
    CGFloat btnWidth = (alertTable.frame.size.width - MARGIN*3)/2;
    UIFont *lblFont = [APPDELEGATE Fonts_OpenSans_Regular:(iPad?18:12)];
    UIFont *btnFont = [APPDELEGATE Fonts_OpenSans_Regular:(iPad?18:12)];
    UIColor *btnGreenColor = [UIColor colorWithRed:143.0/255.0 green:194.0/255.0 blue:0.0/255.0 alpha:1.0];
    UIColor *btnRedColor = NewReleaseViewBgColor;

    if ([[alert objectForKey:keyType] isEqualToString:keyVideoRequest])
    {
        //NSString *str = [NSString stringWithFormat:@"%@ would like to borrow %@ \n %@", [alert objectForKey:keyDisplayName], [alert objectForKey:keyItemTitle],[alert objectForKey:keyMessage]];
        NSString *str = [NSString stringWithFormat:NSLocalizedString(@"strVideoRequestMessage", nil), [alert objectForKey:keyDisplayName], [alert objectForKey:keyItemTitle],[alert objectForKey:keyMessage]];
        UILabel *lblMessage = [APPDELEGATE createLabelWithFrame:CGRectMake(MARGIN*2, MARGIN, alertTable.frame.size.width-MARGIN*2.0, LABEL_HEIGHT) withBGColor:[UIColor clearColor] withTXColor:[UIColor whiteColor] withText:str withFont:lblFont withTag:TAG_AlertMessage withTextAlignment:NSTextAlignmentCenter];
        [cell.contentView addSubview:lblMessage];
        
        CGFloat yPos = lblMessage.frame.origin.y + lblMessage.frame.size.height + MARGIN;
        CustomButton *btnYes = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(MARGIN, yPos, btnWidth, BUTTON_HEIGHT) withTitle:@"Agree" withImage:nil withTag:TAG_AlertBtnYes Font:btnFont BGColor:btnGreenColor];
        [btnYes setButtonTag:[[alert objectForKey:keyBID] intValue]];
        [btnYes.dictData setValue:[NSString stringWithFormat:@"%@||%@||%@||%@", [alert objectForKey:keyDisplayName], [alert objectForKey:keyItemTitle],[alert objectForKey:keyDuration],[alert objectForKey:keyBID]] forKey:KeyButtonValue];
        [btnYes addTarget:self action:@selector(actionVideoYes:) forControlEvents:UIControlEventTouchUpInside];
        [btnYes setIndexPath:indexPath];
        [cell.contentView addSubview:btnYes];
        
        CustomButton *btnNo = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(btnYes.frame.origin.x+btnYes.frame.size.width+MARGIN, yPos, btnWidth, BUTTON_HEIGHT) withTitle:@"Disagree" withImage:nil withTag:TAG_AlertBtnNo Font:btnFont BGColor:btnRedColor];
        [btnNo setButtonTag:[[alert objectForKey:keyBID] intValue]];
        [btnNo.dictData setValue:[NSString stringWithFormat:@"%@||%@||%@||%@", [alert objectForKey:keyDisplayName], [alert objectForKey:keyItemTitle],[alert objectForKey:keyDuration],[alert objectForKey:keyBID]] forKey:KeyButtonValue];
        [btnNo addTarget:self action:@selector(actionVideoNo:) forControlEvents:UIControlEventTouchUpInside];
        [btnNo setIndexPath:indexPath];
        [cell.contentView addSubview:btnNo];
    }
    else if ([[alert objectForKey:keyType] isEqualToString:keySendRequest])
    {
        //gift
        if([[alert objectForKey:keyVideoType] intValue] == 4)
        {
            NSString *str = [NSString stringWithFormat:NSLocalizedString(@"strGiftMessage", nil), [alert objectForKey:keyDisplayName], [alert objectForKey:keyVideoName],[alert objectForKey:keyMessage]];
            UILabel *lblMessage = [APPDELEGATE createLabelWithFrame:CGRectMake(MARGIN*2, MARGIN, alertTable.frame.size.width-MARGIN*2.0, LABEL_HEIGHT) withBGColor:[UIColor clearColor] withTXColor:[UIColor whiteColor] withText:str withFont:lblFont withTag:TAG_AlertMessage withTextAlignment:NSTextAlignmentCenter];
            [cell.contentView addSubview:lblMessage];
            
            CGFloat yPos = lblMessage.frame.origin.y + lblMessage.frame.size.height + MARGIN;
            CustomButton *btnYes = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(MARGIN*2, yPos, btnWidth, BUTTON_HEIGHT) withTitle:@"Accept Offer" withImage:nil withTag:TAG_AlertBtnYes Font:btnFont BGColor:btnGreenColor];
            [btnYes setButtonTag:[[alert objectForKey:keyBID] intValue]];
            [btnYes addTarget:self action:@selector(agreeGift:) forControlEvents:UIControlEventTouchUpInside];
            [btnYes setIndexPath:indexPath];
            [cell.contentView addSubview:btnYes];
            
            CustomButton *btnNo = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(btnYes.frame.origin.x+btnYes.frame.size.width+MARGIN, yPos, btnWidth, BUTTON_HEIGHT) withTitle:@"Reject Offer" withImage:nil withTag:TAG_AlertBtnNo Font:btnFont BGColor:btnRedColor];
            [btnNo setButtonTag:[[alert objectForKey:keyBID] intValue]];
            [btnNo.dictData setValue:[NSString stringWithFormat:@"%@||%@||%@||%@||%@", [alert objectForKey:keyDisplayName], [alert objectForKey:keyVideoName],[alert objectForKey:keyBID],[alert objectForKey:keyPermissionUser],[alert objectForKey:keyVideoId]] forKey:KeyButtonValue];
            [btnNo addTarget:self action:@selector(notInterested:) forControlEvents:UIControlEventTouchUpInside];
            [btnNo setIndexPath:indexPath];
            [cell.contentView addSubview:btnNo];
            
        }else{
            NSString *str = [NSString stringWithFormat:NSLocalizedString(@"strGiveRequestMessage", nil), [alert objectForKey:keyDisplayName], [alert objectForKey:keyVideoName],[alert objectForKey:keyMessage]];
            UILabel *lblMessage = [APPDELEGATE createLabelWithFrame:CGRectMake(MARGIN*2, MARGIN, alertTable.frame.size.width-MARGIN*2.0, LABEL_HEIGHT) withBGColor:[UIColor clearColor] withTXColor:[UIColor whiteColor] withText:str withFont:lblFont withTag:TAG_AlertMessage withTextAlignment:NSTextAlignmentCenter];
            [cell.contentView addSubview:lblMessage];
            
            CGFloat yPos = lblMessage.frame.origin.y + lblMessage.frame.size.height + MARGIN;
            CustomButton *btnYes = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(MARGIN*2, yPos, btnWidth, BUTTON_HEIGHT) withTitle:@"Agree" withImage:nil withTag:TAG_AlertBtnYes Font:btnFont BGColor:btnGreenColor];
            [btnYes setButtonTag:[[alert objectForKey:keyBID] intValue]];
            [btnYes.dictData setValue:[NSString stringWithFormat:@"%@||%@||%@||%@||%@", [alert objectForKey:keyDisplayName], [alert objectForKey:keyVideoName],[alert objectForKey:keyBID],[alert objectForKey:keyPermissionUser],[alert objectForKey:keyVideoId]] forKey:KeyButtonValue];
            [btnYes addTarget:self action:@selector(borrowVideo:) forControlEvents:UIControlEventTouchUpInside];
            [btnYes setIndexPath:indexPath];
            [cell.contentView addSubview:btnYes];
            
            CustomButton *btnNo = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(btnYes.frame.origin.x+btnYes.frame.size.width+MARGIN, yPos, btnWidth, BUTTON_HEIGHT) withTitle:@"Disagree" withImage:nil withTag:TAG_AlertBtnNo Font:btnFont BGColor:btnRedColor];
            [btnNo setButtonTag:[[alert objectForKey:keyBID] intValue]];
            [btnNo.dictData setValue:[NSString stringWithFormat:@"%@||%@||%@||%@||%@", [alert objectForKey:keyDisplayName], [alert objectForKey:keyVideoName],[alert objectForKey:keyBID],[alert objectForKey:keyPermissionUser],[alert objectForKey:keyVideoId]] forKey:KeyButtonValue];
            [btnNo addTarget:self action:@selector(notInterested:) forControlEvents:UIControlEventTouchUpInside];
            [btnNo setIndexPath:indexPath];
            [cell.contentView addSubview:btnNo];
        }
    }
    else if ([[alert objectForKey:keyType] isEqualToString:keyFriendRequest])
    {
        NSString *str = [NSString stringWithFormat:NSLocalizedString(@"strFriendRequestMessage", nil), [alert objectForKey:keyDisplayName]];
        UILabel *lblMessage = [APPDELEGATE createLabelWithFrame:CGRectMake(MARGIN*2, MARGIN, alertTable.frame.size.width-MARGIN*2.0, LABEL_HEIGHT) withBGColor:[UIColor clearColor] withTXColor:[UIColor whiteColor] withText:str withFont:lblFont withTag:TAG_AlertMessage withTextAlignment:NSTextAlignmentCenter];
        [cell.contentView addSubview:lblMessage];
        
        CGFloat yPos = lblMessage.frame.origin.y + lblMessage.frame.size.height + MARGIN;
        CustomButton *btnYes = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(MARGIN*2, yPos, btnWidth, BUTTON_HEIGHT) withTitle:@"Agree" withImage:nil withTag:TAG_AlertBtnYes Font:btnFont BGColor:btnGreenColor];
        [btnYes setButtonTag:[[alert objectForKey:keyBID] intValue]];
        [btnYes addTarget:self action:@selector(actionFriendYes:) forControlEvents:UIControlEventTouchUpInside];
        [btnYes setIndexPath:indexPath];
        [cell.contentView addSubview:btnYes];
        
        CustomButton *btnNo = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(btnYes.frame.origin.x+btnYes.frame.size.width+MARGIN, yPos, btnWidth, BUTTON_HEIGHT) withTitle:@"Disagree" withImage:nil withTag:TAG_AlertBtnNo Font:btnFont BGColor:btnRedColor];
        [btnNo setButtonTag:[[alert objectForKey:keyUID] intValue]];
        [btnNo addTarget:self action:@selector(actionFriendNo:) forControlEvents:UIControlEventTouchUpInside];
        [btnNo setIndexPath:indexPath];
        [cell.contentView addSubview:btnNo];
    }
    else if([[alert objectForKey:keyType] isEqualToString:keySellFriendRequest])
    {
        if([[alert objectForKey:keyVideoType] intValue] == 5)
        {
            NSString *str = [NSString stringWithFormat:NSLocalizedString(@"strVideoAtSpecialPriceRequestMessage", nil),[alert objectForKey:keyDisplayName],[alert objectForKey:keyVideoName],[alert objectForKey:keySalePrice]];
            UILabel *lblMessage = [APPDELEGATE createLabelWithFrame:CGRectMake(MARGIN*2, MARGIN, alertTable.frame.size.width-MARGIN*2.0, LABEL_HEIGHT) withBGColor:[UIColor clearColor] withTXColor:[UIColor whiteColor] withText:str withFont:lblFont withTag:TAG_AlertMessage withTextAlignment:NSTextAlignmentCenter];
            [cell.contentView addSubview:lblMessage];
            
            CGFloat yPos = lblMessage.frame.origin.y + lblMessage.frame.size.height + MARGIN;
            CustomButton *btnYes = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(MARGIN*2, yPos, btnWidth, BUTTON_HEIGHT) withTitle:@"Agree" withImage:nil withTag:TAG_AlertBtnYes Font:btnFont BGColor:btnGreenColor];
            [btnYes setButtonTag:[[alert objectForKey:keyBID] intValue]];
            [btnYes addTarget:self action:@selector(agreeSpecialPriceRequest:) forControlEvents:UIControlEventTouchUpInside];
            [btnYes setIndexPath:indexPath];
            [cell.contentView addSubview:btnYes];
            
            CustomButton *btnNo = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(btnYes.frame.origin.x+btnYes.frame.size.width+MARGIN, yPos, btnWidth, BUTTON_HEIGHT) withTitle:@"Disagree" withImage:nil withTag:TAG_AlertBtnNo Font:btnFont BGColor:btnRedColor];
            [btnNo setButtonTag:[[alert objectForKey:keyBID] intValue]];
            [btnNo.dictData setValue:[NSString stringWithFormat:@"%@||%@||%@||%@||%@", [alert objectForKey:keyDisplayName], [alert objectForKey:keyVideoName],[alert objectForKey:keyBID],[alert objectForKey:keyPermissionUser],[alert objectForKey:keyVideoId]] forKey:KeyButtonValue];
            [btnNo addTarget:self action:@selector(notInterested:) forControlEvents:UIControlEventTouchUpInside];
            [btnNo setIndexPath:indexPath];
            [cell.contentView addSubview:btnNo];
        }
    }
    else if([[alert objectForKey:keyType] isEqualToString:keyRenewRequest])
    {
        NSString *durationMessage = @"duration";
        
        if([[alert valueForKey:keyDuration] intValue] == 1){
            durationMessage = @"1 day";
        }else if([[alert valueForKey:keyDuration] intValue] == 2) {
            durationMessage = @"2 day";
        }else if([[alert valueForKey:keyDuration] intValue] == 7) {
            durationMessage = @"7 days";
        }
        
        NSString *str = [NSString stringWithFormat:NSLocalizedString(@"strRenewRequestMessage", nil),[alert objectForKey:keyDisplayName],[alert objectForKey:keyVideoName], durationMessage];
        UILabel *lblMessage = [APPDELEGATE createLabelWithFrame:CGRectMake(MARGIN*2, MARGIN, alertTable.frame.size.width-MARGIN*2.0, LABEL_HEIGHT) withBGColor:[UIColor clearColor] withTXColor:[UIColor whiteColor] withText:str withFont:lblFont withTag:TAG_AlertMessage withTextAlignment:NSTextAlignmentCenter];
        [cell.contentView addSubview:lblMessage];
        
        CGFloat yPos = lblMessage.frame.origin.y + lblMessage.frame.size.height + MARGIN;
        CustomButton *btnYes = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(MARGIN*2, yPos, btnWidth, BUTTON_HEIGHT) withTitle:@"Agree" withImage:nil withTag:TAG_AlertBtnYes Font:btnFont BGColor:btnGreenColor];
        [btnYes setButtonTag:[[alert objectForKey:keyBID] intValue]];
        [btnYes addTarget:self action:@selector(renewOfflineRequest:) forControlEvents:UIControlEventTouchUpInside];
        [btnYes setIndexPath:indexPath];
        [cell.contentView addSubview:btnYes];
        
        CustomButton *btnNo = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(btnYes.frame.origin.x+btnYes.frame.size.width+MARGIN, yPos, btnWidth, BUTTON_HEIGHT) withTitle:@"Disagree" withImage:nil withTag:TAG_AlertBtnNo Font:btnFont BGColor:btnRedColor];
        [btnNo setButtonTag:[[alert objectForKey:keyBID] intValue]];
        [btnNo.dictData setValue:[NSString stringWithFormat:@"%@||%@||%@||%@||%@", [alert objectForKey:keyDisplayName], [alert objectForKey:keyVideoName],[alert objectForKey:keyBID],[alert objectForKey:keyPermissionUser],[alert objectForKey:keyVideoId]] forKey:KeyButtonValue];
        [btnNo addTarget:self action:@selector(renewOfflineRequestDecline:) forControlEvents:UIControlEventTouchUpInside];
        [btnNo setIndexPath:indexPath];
        [cell.contentView addSubview:btnNo];
    }
    else if([[alert objectForKey:keyType] isEqualToString:keyAcceptBorrow])
    {
        NSString *str = [NSString stringWithFormat:NSLocalizedString(@"strVideoGiveConfirmRequestMessage", nil), [alert objectForKey:keyDisplayName], [alert objectForKey:keyVideoName], [alert objectForKey:keyMessage]];
        UILabel *lblMessage = [APPDELEGATE createLabelWithFrame:CGRectMake(MARGIN*2, MARGIN, alertTable.frame.size.width-MARGIN*2.0, LABEL_HEIGHT) withBGColor:[UIColor clearColor] withTXColor:[UIColor whiteColor] withText:str withFont:lblFont withTag:TAG_AlertMessage withTextAlignment:NSTextAlignmentCenter];
        [cell.contentView addSubview:lblMessage];
        
        CGFloat yPos = lblMessage.frame.origin.y + lblMessage.frame.size.height + MARGIN;
        CustomButton *btnYes = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(alertTable.frame.size.width/2.0 - btnWidth/2.0, yPos, btnWidth, BUTTON_HEIGHT) withTitle:@"Ok" withImage:nil withTag:TAG_AlertBtnYes Font:btnFont BGColor:btnGreenColor];
        [btnYes setButtonTag:[[alert objectForKey:keyBID] intValue]];
        [btnYes setIndexPath:indexPath];
        [btnYes addTarget:self action:@selector(actionOkPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btnYes];
    }
    else if([[alert objectForKey:keyType] isEqualToString:keyGiftMovieShow])
    {
        NSString *str = [NSString stringWithFormat:@"You have %@ free movies to claim",[[NSUserDefaults standardUserDefaults]valueForKey:keymovie_credits]];
        UILabel *lblMessage = [APPDELEGATE createLabelWithFrame:CGRectMake(MARGIN*2, MARGIN, alertTable.frame.size.width-MARGIN*2.0, LABEL_HEIGHT) withBGColor:[UIColor clearColor] withTXColor:[UIColor whiteColor] withText:str withFont:lblFont withTag:TAG_AlertMessage withTextAlignment:NSTextAlignmentCenter];
        [cell.contentView addSubview:lblMessage];
        
        CGFloat yPos = lblMessage.frame.origin.y + lblMessage.frame.size.height + MARGIN;
        CustomButton *btnYes = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(alertTable.frame.size.width/2.0 - btnWidth/2.0, yPos, btnWidth, BUTTON_HEIGHT) withTitle:@"Get Movies" withImage:nil withTag:TAG_AlertBtnYes Font:btnFont BGColor:btnGreenColor];
        [btnYes setButtonTag:[[alert objectForKey:keyBID] intValue]];
        [btnYes setIndexPath:indexPath];
        [btnYes addTarget:self action:@selector(ShowGiftMovieList:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btnYes];
    }
    else if ([[alert objectForKey:keyType] isEqualToString:keyInvitePending])
    {
        NSString *str = [NSString stringWithFormat:NSLocalizedString(@"strInviteFriendsMessage", nil), [[NSUserDefaults standardUserDefaults]valueForKey:keymovie_shares]];
        UILabel *lblMessage = [APPDELEGATE createLabelWithFrame:CGRectMake(MARGIN*2, MARGIN, alertTable.frame.size.width-MARGIN*2.0, LABEL_HEIGHT) withBGColor:[UIColor clearColor] withTXColor:[UIColor whiteColor] withText:str withFont:lblFont withTag:TAG_AlertMessage withTextAlignment:NSTextAlignmentCenter];
        [cell.contentView addSubview:lblMessage];
        
        CGFloat yPos = lblMessage.frame.origin.y + lblMessage.frame.size.height + MARGIN;
        CustomButton *btnYes = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(MARGIN*2, yPos, btnWidth, BUTTON_HEIGHT) withTitle:@"Invite a Friend" withImage:nil withTag:TAG_AlertBtnYes Font:btnFont BGColor:btnGreenColor];
        [btnYes setButtonTag:[[alert objectForKey:keyBID] intValue]];
        [btnYes addTarget:self action:@selector(actionInviteFriend:) forControlEvents:UIControlEventTouchUpInside];
        [btnYes setIndexPath:indexPath];
        [cell.contentView addSubview:btnYes];
        
        CustomButton *btnNo = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(btnYes.frame.origin.x+btnYes.frame.size.width+MARGIN, yPos, btnWidth, BUTTON_HEIGHT) withTitle:@"Invites Pending" withImage:nil withTag:TAG_AlertBtnNo Font:btnFont BGColor:btnRedColor];
        [btnNo setButtonTag:[[alert objectForKey:keyBID] intValue]];
        [btnNo addTarget:self action:@selector(actionPendingRequest:) forControlEvents:UIControlEventTouchUpInside];
        [btnNo setIndexPath:indexPath];
        [cell.contentView addSubview:btnNo];
    }


    
    UIView *lineView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(0, ROW_HEIGHT-1, alertTable.frame.size.width, 1) bgColor:colorWithHexString(@"cccccc") tag:TAG_AlertLineView alpha:1.0];
    [cell.contentView addSubview:lineView];
}

-(void)updateCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    NSDictionary *alert = [arrAlerts objectAtIndex:indexPath.row];
    CGFloat btnWidth = (alertTable.frame.size.width - MARGIN*3)/2;
    
    if ([[alert objectForKey:keyType] isEqualToString:keyVideoRequest])
    {
        NSString *str = [NSString stringWithFormat:NSLocalizedString(@"strVideoRequestMessage", nil), [alert objectForKey:keyDisplayName], [alert objectForKey:keyItemTitle],[alert objectForKey:keyMessage]];
        UILabel *lbl = (UILabel *)[cell.contentView viewWithTag:TAG_AlertMessage];
        [lbl setFrame:CGRectMake(MARGIN, MARGIN, alertTable.frame.size.width-MARGIN*2.0, lbl.frame.size.height)];
        [lbl setText:str];
        
        CGFloat yPos = lbl.frame.origin.y + lbl.frame.size.height + MARGIN;        
        CustomButton *btnYes = (CustomButton *)[cell.contentView viewWithTag:TAG_AlertBtnYes];
        [btnYes setFrame:CGRectMake(MARGIN, yPos, btnWidth, BUTTON_HEIGHT)];
        [btnYes setButtonTag:[[alert objectForKey:keyBID] intValue]];
        [btnYes.dictData setValue:[NSString stringWithFormat:@"%@||%@||%@||%@", [alert objectForKey:keyDisplayName], [alert objectForKey:keyItemTitle],[alert objectForKey:keyDuration],[alert objectForKey:keyBID]] forKey:KeyButtonValue];
        [btnYes setIndexPath:indexPath];
        [btnYes removeTarget:nil
                      action:NULL
            forControlEvents:UIControlEventAllEvents];
        [btnYes addTarget:self action:@selector(actionVideoYes:) forControlEvents:UIControlEventTouchUpInside]; // edited
        
        CustomButton *btnNo = (CustomButton *)[cell.contentView viewWithTag:TAG_AlertBtnNo];
        [btnNo setFrame:CGRectMake(btnYes.frame.origin.x+btnYes.frame.size.width+MARGIN, yPos, btnWidth, BUTTON_HEIGHT)];
        [btnNo setButtonTag:[[alert objectForKey:keyBID] intValue]];
        [btnNo.dictData setValue:[NSString stringWithFormat:@"%@||%@||%@||%@", [alert objectForKey:keyDisplayName], [alert objectForKey:keyItemTitle],[alert objectForKey:keyDuration],[alert objectForKey:keyBID]] forKey:KeyButtonValue];
        [btnNo setIndexPath:indexPath];
        [btnNo removeTarget:nil
                      action:NULL
           forControlEvents:UIControlEventAllEvents];
        [btnNo addTarget:self action:@selector(actionVideoNo:) forControlEvents:UIControlEventTouchUpInside]; // edited
    }
    else if ([[alert objectForKey:keyType] isEqualToString:keySendRequest])
    {
        //gift
        if([[alert objectForKey:keyVideoType] intValue] == 4)
        {
            NSString *str = [NSString stringWithFormat:NSLocalizedString(@"strGiftMessage", nil), [alert objectForKey:keyDisplayName], [alert objectForKey:keyVideoName],[alert objectForKey:keyMessage]];
            UILabel *lbl = (UILabel *)[cell.contentView viewWithTag:TAG_AlertMessage];
            [lbl setFrame:CGRectMake(MARGIN, MARGIN, alertTable.frame.size.width-MARGIN*2.0, lbl.frame.size.height)];
            [lbl setText:str];
            
            CGFloat yPos = lbl.frame.origin.y + lbl.frame.size.height + MARGIN;
            CustomButton *btnYes = (CustomButton *)[cell.contentView viewWithTag:TAG_AlertBtnYes];
            [btnYes setFrame:CGRectMake(MARGIN, yPos, btnWidth, BUTTON_HEIGHT)];
            [btnYes setButtonTag:[[alert objectForKey:keyBID] intValue]];
            [btnYes setIndexPath:indexPath];
            [btnYes removeTarget:nil
                          action:NULL
                forControlEvents:UIControlEventAllEvents];
            [btnYes addTarget:self action:@selector(agreeGift:) forControlEvents:UIControlEventTouchUpInside]; // edited
            
            CustomButton *btnNo = (CustomButton *)[cell.contentView viewWithTag:TAG_AlertBtnNo];
            [btnNo setFrame:CGRectMake(btnYes.frame.origin.x+btnYes.frame.size.width+MARGIN, yPos, btnWidth, BUTTON_HEIGHT)];
            [btnNo setButtonTag:[[alert objectForKey:keyBID] intValue]];
            [btnNo.dictData setValue:[NSString stringWithFormat:@"%@||%@||%@||%@||%@", [alert objectForKey:keyDisplayName], [alert objectForKey:keyVideoName],[alert objectForKey:keyBID],[alert objectForKey:keyPermissionUser],[alert objectForKey:keyVideoId]] forKey:KeyButtonValue];
            [btnNo setIndexPath:indexPath];
            [btnNo removeTarget:nil
                          action:NULL
                forControlEvents:UIControlEventAllEvents];
            [btnNo addTarget:self action:@selector(notInterested:) forControlEvents:UIControlEventTouchUpInside]; //edited
            
        }
        else
        {
            NSString *str = [NSString stringWithFormat:NSLocalizedString(@"strGiveRequestMessage", nil), [alert objectForKey:keyDisplayName], [alert objectForKey:keyVideoName],[alert objectForKey:keyMessage]];
            UILabel *lbl = (UILabel *)[cell.contentView viewWithTag:TAG_AlertMessage];
            [lbl setFrame:CGRectMake(MARGIN, MARGIN, alertTable.frame.size.width-MARGIN*2.0, lbl.frame.size.height)];
            [lbl setText:str];
            
            CGFloat yPos = lbl.frame.origin.y + lbl.frame.size.height + MARGIN;
            CustomButton *btnYes = (CustomButton *)[cell.contentView viewWithTag:TAG_AlertBtnYes];
            [btnYes setFrame:CGRectMake(MARGIN, yPos, btnWidth, BUTTON_HEIGHT)];
            [btnYes setButtonTag:[[alert objectForKey:keyBID] intValue]];
            [btnYes.dictData setValue:[NSString stringWithFormat:@"%@||%@||%@||%@||%@", [alert objectForKey:keyDisplayName], [alert objectForKey:keyVideoName],[alert objectForKey:keyBID],[alert objectForKey:keyPermissionUser],[alert objectForKey:keyVideoId]] forKey:KeyButtonValue];
            [btnYes setIndexPath:indexPath];
            [btnYes removeTarget:nil
                          action:NULL
                forControlEvents:UIControlEventAllEvents];
            [btnYes addTarget:self action:@selector(borrowVideo:) forControlEvents:UIControlEventTouchUpInside]; //edited
    
            CustomButton *btnNo = (CustomButton *)[cell.contentView viewWithTag:TAG_AlertBtnNo];
            [btnNo setFrame:CGRectMake(btnYes.frame.origin.x+btnYes.frame.size.width+MARGIN, yPos, btnWidth, BUTTON_HEIGHT)];
            [btnNo setButtonTag:[[alert objectForKey:keyBID] intValue]];
            [btnNo.dictData setValue:[NSString stringWithFormat:@"%@||%@||%@||%@||%@", [alert objectForKey:keyDisplayName], [alert objectForKey:keyVideoName],[alert objectForKey:keyBID],[alert objectForKey:keyPermissionUser],[alert objectForKey:keyVideoId]] forKey:KeyButtonValue];
            [btnNo setIndexPath:indexPath];
            [btnNo removeTarget:nil
                          action:NULL
                forControlEvents:UIControlEventAllEvents];
            [btnNo addTarget:self action:@selector(notInterested:) forControlEvents:UIControlEventTouchUpInside]; //edited
        }
    }
    else if ([[alert objectForKey:keyType] isEqualToString:keyFriendRequest])
    {
        NSString *str = [NSString stringWithFormat:NSLocalizedString(@"strFriendRequestMessage", nil), [alert objectForKey:keyDisplayName]];
        UILabel *lbl = (UILabel *)[cell.contentView viewWithTag:TAG_AlertMessage];
        [lbl setFrame:CGRectMake(MARGIN, MARGIN, alertTable.frame.size.width-MARGIN*2.0, lbl.frame.size.height)];
        [lbl setText:str];
        
        CGFloat yPos = lbl.frame.origin.y + lbl.frame.size.height + MARGIN;
        CustomButton *btnYes = (CustomButton *)[cell.contentView viewWithTag:TAG_AlertBtnYes];
        [btnYes setFrame:CGRectMake(MARGIN, yPos, btnWidth, BUTTON_HEIGHT)];
        [btnYes setButtonTag:[[alert objectForKey:keyBID] intValue]];
        [btnYes.dictData removeObjectForKey:KeyButtonValue];
        [btnYes setIndexPath:indexPath];
        [btnYes removeTarget:nil
                           action:NULL
                 forControlEvents:UIControlEventAllEvents];
        [btnYes addTarget:self action:@selector(actionFriendYes:) forControlEvents:UIControlEventTouchUpInside]; //edited
        
        CustomButton *btnNo = (CustomButton *)[cell.contentView viewWithTag:TAG_AlertBtnNo];
        [btnNo setFrame:CGRectMake(btnYes.frame.origin.x+btnYes.frame.size.width+MARGIN, yPos, btnWidth, BUTTON_HEIGHT)];
        [btnNo setButtonTag:[[alert objectForKey:keyUID] intValue]];
        [btnNo.dictData removeObjectForKey:KeyButtonValue];
        [btnNo setIndexPath:indexPath];
        [btnNo removeTarget:nil
                      action:NULL
            forControlEvents:UIControlEventAllEvents];
        [btnNo addTarget:self action:@selector(actionFriendNo:) forControlEvents:UIControlEventTouchUpInside]; //edited
    }
    else if([[alert objectForKey:keyType] isEqualToString:keySellFriendRequest])
    {
        if([[alert objectForKey:keyVideoType] intValue] == 5)
        {
            NSString *str = [NSString stringWithFormat:NSLocalizedString(@"strVideoAtSpecialPriceRequestMessage", nil),[alert objectForKey:keyDisplayName],[alert objectForKey:keyVideoName],[alert objectForKey:keySalePrice]];
            UILabel *lbl = (UILabel *)[cell.contentView viewWithTag:TAG_AlertMessage];
            [lbl setFrame:CGRectMake(MARGIN, MARGIN, alertTable.frame.size.width-MARGIN*2.0, lbl.frame.size.height)];
            [lbl setText:str];
            
            CGFloat yPos = lbl.frame.origin.y + lbl.frame.size.height + MARGIN;
            CustomButton *btnYes = (CustomButton *)[cell.contentView viewWithTag:TAG_AlertBtnYes];
            [btnYes setFrame:CGRectMake(MARGIN, yPos, btnWidth, BUTTON_HEIGHT)];
            [btnYes setButtonTag:[[alert objectForKey:keyBID] intValue]];
            [btnYes setIndexPath:indexPath];
            [btnYes removeTarget:nil
                          action:NULL
                forControlEvents:UIControlEventAllEvents];
            [btnYes addTarget:self action:@selector(agreeSpecialPriceRequest:) forControlEvents:UIControlEventTouchUpInside]; //edited
            
            CustomButton *btnNo = (CustomButton *)[cell.contentView viewWithTag:TAG_AlertBtnNo];
            [btnNo setFrame:CGRectMake(btnYes.frame.origin.x+btnYes.frame.size.width+MARGIN, yPos, btnWidth, BUTTON_HEIGHT)];
            [btnNo setButtonTag:[[alert objectForKey:keyBID] intValue]];
            [btnNo.dictData setValue:[NSString stringWithFormat:@"%@||%@||%@||%@||%@", [alert objectForKey:keyDisplayName], [alert objectForKey:keyVideoName],[alert objectForKey:keyBID],[alert objectForKey:keyPermissionUser],[alert objectForKey:keyVideoId]] forKey:KeyButtonValue];
            [btnNo setIndexPath:indexPath];
            [btnNo removeTarget:nil
                          action:NULL
                forControlEvents:UIControlEventAllEvents];
            [btnNo addTarget:self action:@selector(notInterested:) forControlEvents:UIControlEventTouchUpInside];// edited
        }
    }
    else if([[alert objectForKey:keyType] isEqualToString:keyRenewRequest])
    {
        NSString *durationMessage = @"duration";
        
        if([[alert valueForKey:keyDuration] intValue] == 1){
            durationMessage = @"1 day";
        }else if([[alert valueForKey:keyDuration] intValue] == 2) {
            durationMessage = @"2 day";
        }else if([[alert valueForKey:keyDuration] intValue] == 7) {
            durationMessage = @"7 days";
        }
        
        NSString *str = [NSString stringWithFormat:NSLocalizedString(@"strRenewRequestMessage", nil),[alert objectForKey:keyDisplayName],[alert objectForKey:keyVideoName], durationMessage];
        UILabel *lbl = (UILabel *)[cell.contentView viewWithTag:TAG_AlertMessage];
        [lbl setFrame:CGRectMake(MARGIN, MARGIN, alertTable.frame.size.width-MARGIN*2.0, lbl.frame.size.height)];
        [lbl setText:str];
        
        CGFloat yPos = lbl.frame.origin.y + lbl.frame.size.height + MARGIN;
        CustomButton *btnYes = (CustomButton *)[cell.contentView viewWithTag:TAG_AlertBtnYes];
        [btnYes setFrame:CGRectMake(MARGIN, yPos, btnWidth, BUTTON_HEIGHT)];
        [btnYes setButtonTag:[[alert objectForKey:keyBID] intValue]];
        [btnYes setIndexPath:indexPath];
        [btnYes removeTarget:nil
                      action:NULL
            forControlEvents:UIControlEventAllEvents];
        [btnYes addTarget:self action:@selector(renewOfflineRequest:) forControlEvents:UIControlEventTouchUpInside]; //edited
        
        CustomButton *btnNo = (CustomButton *)[cell.contentView viewWithTag:TAG_AlertBtnNo];
        [btnNo setFrame:CGRectMake(btnYes.frame.origin.x+btnYes.frame.size.width+MARGIN, yPos, btnWidth, BUTTON_HEIGHT)];
        [btnNo setButtonTag:[[alert objectForKey:keyBID] intValue]];
        [btnNo.dictData setValue:[NSString stringWithFormat:@"%@||%@||%@||%@||%@", [alert objectForKey:keyDisplayName], [alert objectForKey:keyVideoName],[alert objectForKey:keyBID],[alert objectForKey:keyPermissionUser],[alert objectForKey:keyVideoId]] forKey:KeyButtonValue];
        [btnNo setIndexPath:indexPath];
        [btnNo removeTarget:nil
                      action:NULL
            forControlEvents:UIControlEventAllEvents];
        [btnNo addTarget:self action:@selector(renewOfflineRequestDecline:) forControlEvents:UIControlEventTouchUpInside];// edited
    }
    else if([[alert objectForKey:keyType] isEqualToString:keyAcceptBorrow])
    {
        NSString *str = [NSString stringWithFormat:NSLocalizedString(@"strVideoGiveConfirmRequestMessage", nil), [alert objectForKey:keyDisplayName], [alert objectForKey:keyVideoName], [alert objectForKey:keyMessage]];
        UILabel *lbl = (UILabel *)[cell.contentView viewWithTag:TAG_AlertMessage];
        [lbl setFrame:CGRectMake(MARGIN, MARGIN, alertTable.frame.size.width-MARGIN*2.0, lbl.frame.size.height)];
        [lbl setText:str];
       
        CGFloat yPos = lbl.frame.origin.y + lbl.frame.size.height + MARGIN;
        CustomButton *btnYes = (CustomButton *)[cell.contentView viewWithTag:TAG_AlertBtnYes];
        [btnYes setFrame:CGRectMake(alertTable.frame.size.width/2.0 - btnWidth/2.0, yPos, btnWidth, BUTTON_HEIGHT)];
        [btnYes setButtonTag:[[alert objectForKey:keyBID] intValue]];
        [btnYes setIndexPath:indexPath];
        [btnYes removeTarget:nil
                      action:NULL
            forControlEvents:UIControlEventAllEvents];
        [btnYes addTarget:self action:@selector(actionOkPressed:) forControlEvents:UIControlEventTouchUpInside]; //edited
    }
    else if([[alert objectForKey:keyType] isEqualToString:keyGiftMovieShow])
    {
        NSString *str = [NSString stringWithFormat:@"You have %@ free movies to claim",[[NSUserDefaults standardUserDefaults]valueForKey:keymovie_credits]];
        UILabel *lbl = (UILabel *)[cell.contentView viewWithTag:TAG_AlertMessage];
        [lbl setFrame:CGRectMake(MARGIN, MARGIN, alertTable.frame.size.width-MARGIN*2.0, lbl.frame.size.height)];
        [lbl setText:str];
        
        CGFloat yPos = lbl.frame.origin.y + lbl.frame.size.height + MARGIN;
        CustomButton *btnYes = (CustomButton *)[cell.contentView viewWithTag:TAG_AlertBtnYes];
        [btnYes setFrame:CGRectMake(alertTable.frame.size.width/2.0 - btnWidth/2.0, yPos, btnWidth, BUTTON_HEIGHT)];
        [btnYes setButtonTag:[[alert objectForKey:keyBID] intValue]];
        [btnYes setIndexPath:indexPath];
        [btnYes removeTarget:nil
                      action:NULL
            forControlEvents:UIControlEventAllEvents];
        [btnYes addTarget:self action:@selector(ShowGiftMovieList:) forControlEvents:UIControlEventTouchUpInside]; //edited
    }
    else if ([[alert objectForKey:keyType] isEqualToString:keyInvitePending])
    {
        NSString *str = [NSString stringWithFormat:NSLocalizedString(@"strInviteFriendsMessage", nil),[[NSUserDefaults standardUserDefaults]valueForKey:keymovie_shares]];
        UILabel *lbl = (UILabel *)[cell.contentView viewWithTag:TAG_AlertMessage];
        [lbl setFrame:CGRectMake(MARGIN, MARGIN, alertTable.frame.size.width-MARGIN*2.0, lbl.frame.size.height)];
        [lbl setText:str];
        
        CGFloat yPos = lbl.frame.origin.y + lbl.frame.size.height + MARGIN;
        CustomButton *btnYes = (CustomButton *)[cell.contentView viewWithTag:TAG_AlertBtnYes];
        [btnYes setFrame:CGRectMake(MARGIN, yPos, btnWidth, BUTTON_HEIGHT)];
        [btnYes setButtonTag:[[alert objectForKey:keyBID] intValue]];
        [btnYes.dictData removeObjectForKey:KeyButtonValue];
        [btnYes setIndexPath:indexPath];
        [btnYes removeTarget:nil
                      action:NULL
            forControlEvents:UIControlEventAllEvents];
        [btnYes addTarget:self action:@selector(actionInviteFriend:) forControlEvents:UIControlEventTouchUpInside]; //edited
        
        CustomButton *btnNo = (CustomButton *)[cell.contentView viewWithTag:TAG_AlertBtnNo];
        [btnNo setFrame:CGRectMake(btnYes.frame.origin.x+btnYes.frame.size.width+MARGIN, yPos, btnWidth, BUTTON_HEIGHT)];
        [btnNo setButtonTag:[[alert objectForKey:keyBID] intValue]];
        [btnNo.dictData removeObjectForKey:KeyButtonValue];
        [btnNo setIndexPath:indexPath];
        [btnNo removeTarget:nil
                     action:NULL
           forControlEvents:UIControlEventAllEvents];
        [btnNo addTarget:self action:@selector(actionPendingRequest:) forControlEvents:UIControlEventTouchUpInside]; //edited
    }
    
    UIView *lineView = (UIView *)[cell.contentView viewWithTag:TAG_AlertLineView];
    [lineView setFrame:CGRectMake(0, ROW_HEIGHT-1, alertTable.frame.size.width, 1)];
}

-(void)actionVideoYes:(CustomButton *)sender
{
    currentIndex = sender.buttonTag;
    currentIndexPath = sender.indexPath;
    //currentTitale = sender;
    
    NSString *string = [sender.dictData valueForKey:KeyButtonValue];
    NSArray *array = [string componentsSeparatedByString:@"||"];
    
    currentReqDay = [[array objectAtIndex:2] integerValue];
    bId = [[array objectAtIndex:3] integerValue];
    flagRequstVideo = NO;
    
    objPopupView = [[CustomPopupView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [objPopupView setDelegate:self];
    [self.view addSubview:objPopupView];
    
    //[objPopupView setStrViewTitle:[sender titleForState:UIControlStateNormal]];
    [objPopupView setStrViewMessage:[NSString stringWithFormat:@"Lend Video to %@?",[array objectAtIndex:0]]];
    //[objPopupView setStrViewTitle:[NSString stringWithFormat:@"Respond to %@",[array objectAtIndex:0]]];
	[objPopupView setStrViewMessage:@"How long do you want to lend the movie for?"];
    [objPopupView customizeViewForType:VideoActionBorrow];
    [objPopupView defaultButtonSelectionDuration:currentReqDay];
    [objPopupView adjustForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

-(void)actionVideoNo:(CustomButton *)sender {
    
    currentIndex = sender.buttonTag;
    currentIndexPath = sender.indexPath;
    //[sender setTitle:@"Sending..." forState:UIControlStateNormal];
    [self requestAction:[NSString stringWithFormat:@"page=remove-request&id=%d", currentIndex]];
}

-(void)agreeGift:(CustomButton *)sender
{
    currentIndex = sender.buttonTag;
    currentIndexPath = sender.indexPath;
    //[sender setTitle:@"Sending..." forState:UIControlStateNormal];
    [self requestAction:[NSString stringWithFormat:@"page=gift_accept&bid=%d", currentIndex]];
}

-(void)borrowVideo:(CustomButton *)sender
{
    currentIndex = sender.buttonTag;
    currentIndexPath = sender.indexPath;
    
    NSString *string = [sender.dictData valueForKey:KeyButtonValue];
    NSArray *array = [string componentsSeparatedByString:@"||"];
    flagRequstVideo = YES;
    bId = [[array objectAtIndex:2] integerValue];
    permissonId = [array objectAtIndex:3];
    videoId = [array objectAtIndex:4];
    
    objPopupView = [[CustomPopupView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [objPopupView setDelegate:self];
    [self.view addSubview:objPopupView];
    
    [objPopupView setStrViewTitle:[sender titleForState:UIControlStateNormal]];
    [objPopupView setStrViewMessage:[NSString stringWithFormat:@"Borrow Video From %@?",[array objectAtIndex:0]]];
    [objPopupView customizeViewForType:VideoActionBorrow];
    [objPopupView adjustForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

-(void)notInterested:(CustomButton *)sender {
    currentIndex = sender.buttonTag;
    currentIndexPath = sender.indexPath;
    NSString *string = [sender.dictData valueForKey:KeyButtonValue];
    NSArray *array = [string componentsSeparatedByString:@"||"];
    bId = [[array objectAtIndex:2] integerValue];
    [self requestAction:[NSString stringWithFormat:@"page=not-interested&bid=%d", currentIndex]];
}

- (void) agreeSpecialPriceRequest:(CustomButton *)sender
{
    currentIndex = sender.buttonTag;
    currentIndexPath = sender.indexPath;
    //[sender setTitle:@"Sending..." forState:UIControlStateNormal];
    [self requestAction:[NSString stringWithFormat:@"page=sell_movie_to_friend_accept&bid=%d", currentIndex]];
}

- (void)renewOfflineRequest:(CustomButton *)sender
{
    currentIndex = sender.buttonTag;
    currentIndexPath = sender.indexPath;
    //[sender setTitle:@"Sending..." forState:UIControlStateNormal];
    [self requestAction:[NSString stringWithFormat:@"page=renew-offline-accept&bid=%d", currentIndex]];
}

-(void)renewOfflineRequestDecline:(CustomButton *)sender {
    currentIndex = sender.buttonTag;
    currentIndexPath = sender.indexPath;
    //[sender setTitle:@"Sending..." forState:UIControlStateNormal];
    [self requestAction:[NSString stringWithFormat:@"page=renew-offline-decline&bid=%d", currentIndex]];
}

-(void)actionOkPressed:(CustomButton *)sender
{
    currentIndex = sender.buttonTag;
    currentIndexPath = sender.indexPath;
    //[sender setTitle:@"Sending..." forState:UIControlStateNormal];
    [self requestAction:[NSString stringWithFormat:@"page=remove-borrow-message&bid=%d", currentIndex]];
}

- (void)actionFriendYes:(CustomButton *)sender{
    currentIndex = sender.buttonTag;
    currentIndexPath = sender.indexPath;
   // [self requestActionForFriend:[NSString stringWithFormat:@"action=action_ajax&page=agree_friend&id=%d", currentIndex]];
    [self requestAction:[NSString stringWithFormat:@"page=agree_friend&id=%d", currentIndex]];
}

- (void)actionFriendNo:(CustomButton *)sender{
    
    currentIndex = sender.buttonTag;
    currentIndexPath = sender.indexPath;
   // [self requestActionForFriend:[NSString stringWithFormat:@"action=action_ajax&page=remove_friend&id=%d", currentIndex]];
    [self requestAction:[NSString stringWithFormat:@"page=remove-friend&id=%d", currentIndex]];
}
- (void)actionInviteFriend:(CustomButton *)sender{
    
    
    UIStoryboard *storyboard = iPhone_storyboard;
    if (iPad)
    {
        storyboard = self.storyboard;
    }
    MovieListViewController *movieListVC = (MovieListViewController *) [storyboard instantiateViewControllerWithIdentifier:@"MovieListVC"];
    movieListVC.movieList = 5;
    [self.navigationController pushViewController:movieListVC animated:YES];
}
- (void)actionPendingRequest:(CustomButton *)sender{
    
    UIStoryboard *storyboard = iPhone_storyboard;
    if (iPad)
    {
        storyboard = self.storyboard;
    }
    ContactListViewController *contactListVC = (ContactListViewController *) [storyboard instantiateViewControllerWithIdentifier:@"ContactlistVC"];
    contactListVC.inviteType=1; // for pending
    [self.navigationController pushViewController:contactListVC animated:YES];
}
-(void)ShowGiftMovieList:(CustomButton *)sender
{
    UIStoryboard *storyboard = iPhone_storyboard;
    if (iPad)
    {
        storyboard = iPad_storyboard;
    }
    MovieListViewController *movieListVC = (MovieListViewController *) [storyboard instantiateViewControllerWithIdentifier:@"MovieListVC"];
    movieListVC.movieList = 4;
    //[self.navigationController performSelector:@selector(pushViewController:animated:) withObject:movieListVC afterDelay:1.0];
     [self.navigationController pushViewController:movieListVC animated:YES];
}
- (void)requestAction:(NSString *)post
{
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    
    IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
    NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], post];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl]];
    NSData *postData = [NSData dataWithBytes:[strParameter UTF8String] length:[strParameter length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:kTAG_OTHER_ALERT_REQUEST];
    [requestConnection startAsynchronousRequest];
    [SEGBIN_SINGLETONE_INSTANCE addLoader];
}

- (void)requestActionForFriend:(NSString *)post
{
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    
    IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
    //NSString *apiUrl = NSLocalizedString(@"appAjaxApi", nil);
	NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], post];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl]];
    NSData *postData = [NSData dataWithBytes:[strParameter UTF8String] length:[strParameter length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:kTAG_OTHER_ALERT_REQUEST];
    [requestConnection startAsynchronousRequest];
    [SEGBIN_SINGLETONE_INSTANCE addLoader];
}

#pragma mark - CustomPopupView Delegate
- (void)confirmButtonClicked:(CustomPopupView *)customView forType:(VideoAction)requestType withValues:(NSDictionary *)result
{
    [customView removeFromSuperview];
    
    if(requestType == VideoActionBorrow)
    {
        NSString *comment = [result valueForKey:keyComment];
        NSString *duration = [NSString stringWithFormat:@"%d",[[result valueForKey:keyDuration] intValue]];
        if (!flagRequstVideo)
        {
            NSString *sendRequest= [NSString stringWithFormat:@"page=agree-lent&message=%@&duration=%@&bid=%d", comment, duration, bId];
            [self requestAction:sendRequest];
        }
        else
        {
            NSString *sendRequest= [NSString stringWithFormat:@"page=borrow-video&message=%@&duration=%@&video_id=%@&permission_user=%@", comment,duration, videoId, permissonId];
            [self requestAction:sendRequest];
        }
    }
}

- (void)cancelButtonClicked:(CustomPopupView *)customView {
    [customView removeFromSuperview];
}


#pragma mark - Rotation Method

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [alertTable reloadData];
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
    NSLog(@"AlertVC dealloc called");
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
