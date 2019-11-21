//
//  FriendListVC.m
//  Sagebin
//
//
//
//

#import "FriendListVC.h"
#import "FriendCell.h"
#import <AddressBook/AddressBook.h>
#import "CastViewController.h"
#import "DeviceTableViewController.h"

#define kRowHeight (iPad?54:35)
#define MARGIN (iPad?15:5)

#define kContactBtnWidth 150
#define kContactBtnHeight 35

@interface FriendListVC ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITextFieldDelegate>
{
    UICollectionView *_collectionView;
    UIView *searchView;
    UITextField *txtSearch;
    NSMutableArray *arrFriends;
    NSMutableArray *arrUsers;
    NSMutableArray *arrOriginalData;
    __weak ChromecastDeviceController *_chromecastController;
}
@end

@implementation FriendListVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc
{
    NSLog(@"FriendListViewController dealloc called");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - LifeCycle
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self setViewImage:[UIImage imageNamed:@"icon_friendlist"] withTitle:NSLocalizedString(@"txtFrienTitle", nil)];
    [self.view setBackgroundColor:FriendViewBgColor];
    
    UIView *lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
    btnContact = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(self.view.frame.size.width-kContactBtnWidth-MARGIN*2, lbl.frame.origin.y, kContactBtnWidth, kContactBtnHeight) withTitle:@"Search Sagebin" withImage:nil withTag:TAG_CONTACTBUTTON Font:[APPDELEGATE Fonts_OpenSans_Regular:(iPad?20:15)] BGColor:FriendViewBgColor];
    [btnContact setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [btnContact addTarget:self action:@selector(btnContactClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnContact.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.view addSubview:btnContact];
    
    arrFriends = [[NSMutableArray alloc]init];
    arrUsers = [[NSMutableArray alloc]init];
    [self setupLayoutMethods];
    
    //    if(APPDELEGATE.netOnLink == 0)
    //    {
    //        [self.view makeToast:WARNING];
    //        return;
    //    }
    //    [self getApiDataWithTag:kTAG_FRIENDS];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
    
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    txtSearch.text = @"";
    [self getApiDataWithTag:kTAG_FRIENDS];
    [self setSagebinLogoInCenterForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

-(void)getApiDataWithTag:(int)tag
{
    IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
    NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strParameter;
    if(tag == kTAG_FRIENDS)
    {
        strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], NSLocalizedString(@"apiFriends", nil)];
    }
    else
    {
        NSString *str = [NSString stringWithFormat:NSLocalizedString(@"apiFriendSearch", nil), txtSearch.text];
        strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], str];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl]];
    NSData *postData = [NSData dataWithBytes:[strParameter UTF8String] length:[strParameter length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:tag];
    [requestConnection startAsynchronousRequest];
    
    [SEGBIN_SINGLETONE_INSTANCE addLoader];
    [self enableDisableUI:FALSE];
}

-(void)enableDisableUI:(BOOL)status
{
    [self.rightButton setUserInteractionEnabled:status];
    [searchView setUserInteractionEnabled:status];
    [_collectionView setUserInteractionEnabled:status];
    [btnContact setUserInteractionEnabled:status];
}

#pragma mark - IMDHTTPRequest Delegates
-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didFailWithError:(NSError*)error withTag:(int)tag
{
    if (tag==kTAG_FRIENDS)
    {
        //[self.view makeToast:kServerError];
    }
    else if(tag == kTAG_FRIEND_SEARCH)
    {
        //[self.view makeToast:kServerError];
    }
    [self.view makeToast:kServerError];
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    [self enableDisableUI:TRUE];
}

-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didSuccessWithItems:(NSObject*)items withData:(NSData*)data withTag:(int)tag
{
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    [self enableDisableUI:TRUE];
    if (tag==kTAG_FRIENDS)
    {
        NSDictionary *result = (NSDictionary *)items;
        if ([result isKindOfClass:[NSDictionary class]] && [result objectForKey:keyCode])
        {
            if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
            {
                [self checkUserAlert:[result objectForKey:keyAlerts]];
                
                [arrUsers removeAllObjects];
                [arrFriends removeAllObjects];
                [arrUsers addObjectsFromArray:[result objectForKey:keyFriends]];
                [arrFriends addObjectsFromArray:[result objectForKey:keyFriends]];
                if([arrFriends count] == 0)
                {
                    [self.view makeToast:[NSString stringWithFormat:NSLocalizedString(@"alertNoSearchResult", nil)]];
                }
                NSLog(@"arrFriends : %@", arrFriends);
                [_collectionView reloadData];
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
    else if (tag==kTAG_FRIEND_SEARCH)
    {
        NSDictionary *result = (NSDictionary *)items;
        if ([result isKindOfClass:[NSDictionary class]] && [result objectForKey:keyCode])
        {
            if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
            {
                [self checkUserAlert:[result objectForKey:keyAlerts]];
                [arrFriends removeAllObjects];
                [arrFriends addObjectsFromArray:[result objectForKey:keyFriends]];
                if([arrFriends count] == 0)
                {
                    [self.view makeToast:[NSString stringWithFormat:NSLocalizedString(@"alertNoSearchResult", nil)]];
                }
                [_collectionView reloadData];
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
    else if(tag == kTAG_REMOVE_FRIEND)
    {
        NSString *strResponse = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        NSArray *arrResponse = [strResponse componentsSeparatedByString:@","];
        if([[arrResponse objectAtIndex:1] isEqualToString:keySuccess])
        {
            [self.view makeToast:@"Friend removed successfully"];
        }
        else
        {
            //[self.view makeToast:@"Friend not removed successfully"];
        }
        //        if(btnContact.tag == TAG_CONTACTBUTTON)
        //        {
        //            [arrFriends removeAllObjects];
        //            [btnContact setTitle:@"Search Sagebin" forState:UIControlStateNormal];
        //            [btnContact setTag:-1];
        //        }
        //        else
        //        {
        //            [btnContact setTitle:@"Search Phone" forState:UIControlStateNormal];
        //            [btnContact setTag:TAG_CONTACTBUTTON];
        //        }
        txtSearch.text = @"";
        [self getApiDataWithTag:kTAG_FRIENDS];
    }
    else if(tag == kTAG_ADD_FRIEND)
    {
        NSString *strResponse = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        NSArray *arrResponse = [strResponse componentsSeparatedByString:@","];
        if([arrResponse count] > 1)
        {
            if([[arrResponse objectAtIndex:1] isEqualToString:@"success"])
            {
                [self.view makeToast:@"Friend added successfully"];
            }
            else
            {
                [self.view makeToast:@"Friend not added successfully"];
            }
            
            //            if(btnContact.tag == TAG_CONTACTBUTTON)
            //            {
            //                [arrFriends removeAllObjects];
            //                [btnContact setTitle:@"Search Sagebin" forState:UIControlStateNormal];
            //                [btnContact setTag:-1];
            //            }
            //            else
            //            {
            //                [btnContact setTitle:@"Search Phone" forState:UIControlStateNormal];
            //                [btnContact setTag:TAG_CONTACTBUTTON];
            //            }
            txtSearch.text = @"";
            [self getApiDataWithTag:kTAG_FRIENDS];
        }
        else
        {
            if([strResponse isEqualToString:@"success"])
            {
                [self.view makeToast:@"Friend request sent successfully"];
                //                if(btnContact.tag == TAG_CONTACTBUTTON)
                //                {
                //                    [arrFriends removeAllObjects];
                //                    [btnContact setTitle:@"Search Sagebin" forState:UIControlStateNormal];
                //                    [btnContact setTag:-1];
                //                }
                //                else
                //                {
                //                    [btnContact setTitle:@"Search Phone" forState:UIControlStateNormal];
                //                    [btnContact setTag:TAG_CONTACTBUTTON];
                //                }
                txtSearch.text = @"";
                [self getApiDataWithTag:kTAG_FRIENDS];
            }
            else
            {
                [self.view makeToast:strResponse];
            }
        }
        txtSearch.text = @"";
    }
    //[APPDELEGATE.window setUserInteractionEnabled:YES];
}


#pragma mark - Layout Methods
-(void)setupLayoutMethods
{
    UIView *lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
    // SubView Header
    
    searchView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake((iPad?25:10), lbl.frame.origin.y+lbl.frame.size.height+13, self.view.frame.size.width-(iPad?25:10)*2, kRowHeight) bgColor:[UIColor whiteColor] tag:-1 alpha:1.0];
    [searchView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    txtSearch = [SEGBIN_SINGLETONE_INSTANCE createTextFieldWithFrame:CGRectMake(MARGIN, kRowHeight/2-kRowHeight/4, searchView.frame.size.width-(iPad?54:30)-MARGIN,kRowHeight/2) placeHolder:NSLocalizedString(@"txtSearchFriend", nil) font:[APPDELEGATE Fonts_OpenSans_LightItalic:(iPad?18:10)] textColor:[UIColor blackColor] tag:TAG_SEARCHTEXT];
    //
    [txtSearch setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth];
    [txtSearch setDelegate:self];
    txtSearch.autocorrectionType = UITextAutocorrectionTypeNo;
    [txtSearch setClearButtonMode:UITextFieldViewModeWhileEditing];
    [txtSearch setReturnKeyType:UIReturnKeySearch];
    [searchView addSubview:txtSearch];
    
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSearch setTag:TAG_SEARCHBUTTON];
    [btnSearch setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [btnSearch setImage:[UIImage imageNamed:@"friend_search"] forState:UIControlStateNormal];
    [btnSearch addTarget:self action:@selector(searchFriend:) forControlEvents:UIControlEventTouchUpInside];
    [btnSearch setFrame:CGRectMake(txtSearch.frame.origin.x + txtSearch.frame.size.width, 0,(iPad?54:30), searchView.frame.size.height)];
    [searchView addSubview:btnSearch];
    [self.view addSubview:searchView];
    
    NSInteger yPos = searchView.frame.size.height+searchView.frame.origin.y+5;
    UICollectionViewFlowLayout *viewLayout = [[UICollectionViewFlowLayout alloc]init];
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake((iPad?25:10), yPos, self.view.frame.size.width-(iPad?25:10)*2, self.view.frame.size.height-yPos-10) collectionViewLayout:viewLayout];
    [_collectionView setShowsVerticalScrollIndicator:NO];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [_collectionView registerClass:[FriendCell class] forCellWithReuseIdentifier:@"cell"];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    [_collectionView setTag:TAG_MainViewCollection];
    [self.view addSubview:_collectionView];
}
#pragma mark - UICollection Delegates
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return arrFriends.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[UICollectionViewCell alloc]init];
    }
    
    UIView *reuseView = [cell.contentView viewWithTag:TAG_REUSEVIEW];
    if (!reuseView)
    {
        [self createView:cell.contentView atIndexPath:indexPath];
    }
    else
    {
        cell.contentView.frame=CGRectMake(cell.contentView.frame.origin.x, cell.contentView.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
        [self reuseView:cell.contentView atIndexPath:indexPath];
    }
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self viewItemSizefor:[UIApplication sharedApplication].statusBarOrientation];
}
-(CGSize)viewItemSizefor:(UIInterfaceOrientation)toOrientation
{
    if (iPad)
    {
        if (UIInterfaceOrientationIsLandscape(toOrientation))
        {
            //return CGSizeMake(325, 70);
            return CGSizeMake(310, 70);
        }
        else
        {
            //return CGSizeMake(365, 78);
            return CGSizeMake(343, 78);
        }
    }
    else
    {
        if (UIInterfaceOrientationIsLandscape(toOrientation))
        {
            if (IS_IPHONE_5_GREATER)
            {
                return  CGSizeMake(266, 60);
            }
            else
            {
                return CGSizeMake(225, 60);
            }
        }
        else
        {
            return  CGSizeMake(295, 75);
        }
    }
}
// 3
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 0, 20, 0);
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"index :%@",indexPath);
    
    //    UIStoryboard *storyboard;
    //    if (iPhone)
    //    {
    //        storyboard = iPhone_storyboard;
    //    }
    //    else
    //    {
    //        storyboard = self.storyboard;
    //    }
    //    ProfileViewController *profileVC = (ProfileViewController *) [storyboard instantiateViewControllerWithIdentifier:@"profileVC"];
    //    [self.navigationController pushViewController:profileVC animated:YES];
    
}
#pragma mark - Create or Reuse Methods
-(void)createView:(UIView *)baseView atIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *friendDictionary = [arrFriends objectAtIndex:indexPath.row];
    
    UIView *subView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(0, 0, CGRectGetWidth(baseView.frame), CGRectGetHeight(baseView.frame)) bgColor:[UIColor whiteColor] tag:TAG_REUSEVIEW alpha:1.0];
    [baseView addSubview:subView];
    
    CGFloat imageWidth = (baseView.frame.size.width/6) + (baseView.frame.size.width/10);
    CGFloat otherViewX= (baseView.frame.size.width/6) + (baseView.frame.size.width/10) ;//+ (2*Gap) ;
    CGFloat otherViewWidth = baseView.frame.size.width - imageWidth ;//-(4*Gap);
    
    IMDEventImageView *imageView = [APPDELEGATE createEventImageViewWithFrame:CGRectMake(0, 0, imageWidth, CGRectGetHeight(baseView.frame)) withImageURL:[friendDictionary valueForKey:keyAvatar] Placeholder:kPlaceholderImage tag:TAG_Cell_ImageView];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView setClipsToBounds:YES];
    [subView addSubview:imageView];
    
    UIView *otherView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(otherViewX, 0, otherViewWidth, CGRectGetHeight(baseView.frame)) bgColor:nil tag:TAG_Cell_OtherView alpha:1.0];
    [subView addSubview:otherView];
    
    CGFloat gap = 5;
    CGFloat lblWidth = (otherView.frame.size.width/2) + (otherView.frame.size.width/4);
    
    UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(gap, 0, CGRectGetWidth(otherView.frame)-(gap*2), (iPad?15:13))];
    [lblName setText:[friendDictionary objectForKey:keyDisplayName]];
    [lblName setFont:[APPDELEGATE Fonts_OpenSans_Light:(iPad?12:11)]];
    [lblName setTag:TAG_Cell_LblName];
    [otherView addSubview:lblName];
    
    UILabel *lblLocation = [[UILabel alloc]initWithFrame:CGRectMake(gap+2, CGRectGetHeight(lblName.frame)+2, lblWidth, 11)];
    [lblLocation setTag:TAG_Cell_LblCity];
    [lblLocation setFont:[APPDELEGATE Fonts_OpenSans_LightItalic:(iPad?10:9)]];
    [lblLocation setText:@""];
    //[otherView addSubview:lblLocation];
    
    if(btnContact.tag == TAG_CONTACTBUTTON)
    {
        NSString *strBtnTitle = @"";
        int friendId;
        if ([[friendDictionary objectForKey:keyFriendStatus] intValue] == 1)  // remove
        {
            strBtnTitle = @"Remove";
            friendId = [[friendDictionary objectForKey:keyID] intValue];
        }
        else if ([[friendDictionary objectForKey:keyFriendStatus] intValue] == 0) // waiting
        {
            strBtnTitle = @"Waiting...";
            friendId = [[friendDictionary objectForKey:keyID] intValue];
        }
        else // add
        {
            strBtnTitle = @"Add";
            friendId = [[friendDictionary objectForKey:keyID] intValue];
        }
        UIColor *purchaseColor = [UIColor colorWithRed:0.0/255.0 green:51.0/255.0 blue:153.0/255.0 alpha:1.0];
        CustomButton *btnAdd = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(gap, otherView.frame.size.height - gap -((iPad?25:20)) , otherView.frame.size.width/3+(iPhone?5:0),(iPad?25:20)) withTitle:strBtnTitle withImage:nil withTag:TAG_Cell_BtnAdd Font:[APPDELEGATE Fonts_OpenSans_Regular:(iPad?12:7)] BGColor:purchaseColor];
        [btnAdd addTarget:self action:@selector(btnAddClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btnAdd setButtonTag:friendId];
        [btnAdd.dictData setValue:friendDictionary forKey:KeyButtonValue];
        [btnAdd setUserInteractionEnabled:TRUE];
        [otherView addSubview:btnAdd];
    }
    else
    {
        NSMutableArray *all_users = [arrUsers mutableCopy];
        int id_user = 0;
        int friend_status = -1;
        NSArray *emails = [friendDictionary objectForKey:keyEmails];
        
        if ([emails count] > 0){
            for (int i = 0; i < [emails count]; i++) {
                for (NSDictionary *user in all_users){
                    if ([[emails objectAtIndex:i] isEqual:[user objectForKey:keyUserEmail]]){
                        if ([user objectForKey:keyFriendStatus] != nil){
                            friend_status = [[user objectForKey:keyFriendStatus] intValue];
                        }
                        id_user = [[user objectForKey:keyID] intValue];
                        break;
                    }
                }
            }
        }
        
        NSMutableDictionary *dic = [friendDictionary mutableCopy];
        [dic setValue:[NSString stringWithFormat:@"%d", friend_status] forKey:keyFriendStatus];
        [dic setValue:[NSString stringWithFormat:@"%d", id_user] forKey:keyID];
        
        UIColor *purchaseColor = [UIColor colorWithRed:0.0/255.0 green:51.0/255.0 blue:153.0/255.0 alpha:1.0];
        CustomButton *btnAdd = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(gap, otherView.frame.size.height - gap -((iPad?25:20)) , otherView.frame.size.width/3+(iPhone?5:0),(iPad?25:20)) withTitle:@"" withImage:nil withTag:TAG_Cell_BtnAdd Font:[APPDELEGATE Fonts_OpenSans_Regular:(iPad?12:7)] BGColor:purchaseColor];
        [btnAdd addTarget:self action:@selector(btnAddClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btnAdd.dictData setValue:dic forKey:KeyButtonValue];
        [btnAdd setUserInteractionEnabled:TRUE];
        [otherView addSubview:btnAdd];
        
        NSString *strBtnTitle = @"";
        int friendId;
        if ([[dic objectForKey:keyFriendStatus] intValue] == -1) // remove
        {
            if([[dic objectForKey:keyID] intValue] == 0)
            {
                strBtnTitle = @"Not on Sagebin";
                [btnAdd setTitle:strBtnTitle forState:UIControlStateNormal];
                [btnAdd setUserInteractionEnabled:FALSE];
            }
            else
            {
                strBtnTitle = @"Add Friend";
                friendId = [[friendDictionary objectForKey:keyID] intValue];
                [btnAdd setButtonTag:friendId];
                [btnAdd setTitle:strBtnTitle forState:UIControlStateNormal];
            }
        }
        else if ([[dic objectForKey:keyFriendStatus] intValue] == 1) // waiting
        {
            strBtnTitle = @"Your friend";
            [btnAdd setTitle:strBtnTitle forState:UIControlStateNormal];
            [btnAdd setUserInteractionEnabled:FALSE];
        }
        else if ([[dic objectForKey:keyFriendStatus] intValue] == 0)
        {
            strBtnTitle = @"Waiting...";
            [btnAdd setTitle:strBtnTitle forState:UIControlStateNormal];
            [btnAdd setUserInteractionEnabled:FALSE];
        }
        else if ([[dic objectForKey:keyFriendStatus] intValue] == 3)
        {
            strBtnTitle = @"Me";
            [btnAdd setTitle:strBtnTitle forState:UIControlStateNormal];
            [btnAdd setUserInteractionEnabled:FALSE];
        }
    }
}

-(void)reuseView:(UIView *)baseView atIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *friendDictionary = [arrFriends objectAtIndex:indexPath.row];
    CGFloat imageWidth = (baseView.frame.size.width/6) + (baseView.frame.size.width/10);
    CGFloat otherViewX= (baseView.frame.size.width/6) + (baseView.frame.size.width/10);
    CGFloat otherViewWidth = baseView.frame.size.width - imageWidth;
    
    UIView *subView = [baseView viewWithTag:TAG_REUSEVIEW];
    subView.frame = CGRectMake(0, 0, CGRectGetWidth(baseView.frame), CGRectGetHeight(baseView.frame));
    IMDEventImageView *imageView  = (IMDEventImageView *)[subView viewWithTag:TAG_Cell_ImageView];
    imageView.frame = CGRectMake(0, 0, imageWidth, CGRectGetHeight(baseView.frame));
    [imageView setImageWithURL:[friendDictionary valueForKey:keyAvatar] placeholderImage:kPlaceholderImage];
    
    UIView *otherView = [subView viewWithTag:TAG_Cell_OtherView];
    otherView.frame = CGRectMake(otherViewX, 0, otherViewWidth, CGRectGetHeight(baseView.frame));
    
    CGFloat gap = 5;
    CGFloat lblWidth = (otherView.frame.size.width/2) + (otherView.frame.size.width/4);
    UILabel *lblName = (UILabel *) [otherView viewWithTag:TAG_Cell_LblName];
    [lblName setFrame:CGRectMake(gap, 0, CGRectGetWidth(otherView.frame)-(gap*2), 20)];
    [lblName setText:[friendDictionary objectForKey:keyDisplayName]];
    
    UILabel *lblLocation = (UILabel *)[otherView viewWithTag:TAG_Cell_LblCity];
    [lblLocation setFrame:CGRectMake(gap+2, CGRectGetHeight(lblName.frame)+2, lblWidth, 11)];
    [lblLocation setText:@""];
    
    if(btnContact.tag == TAG_CONTACTBUTTON)
    {
        NSString *strBtnTitle = @"";
        int friendId;
        if ([[friendDictionary objectForKey:keyFriendStatus] intValue] == 1) // remove
        {
            strBtnTitle = @"Remove";
            friendId = [[friendDictionary objectForKey:keyID] intValue];
        }
        else if ([[friendDictionary objectForKey:keyFriendStatus] intValue] == 0) // waiting
        {
            strBtnTitle = @"Waiting...";
            friendId = [[friendDictionary objectForKey:keyID] intValue];
        }
        else // add
        {
            strBtnTitle = @"Add";
            friendId = [[friendDictionary objectForKey:keyID] intValue];
        }
        CustomButton *btnAdd = (CustomButton *)[otherView viewWithTag:TAG_Cell_BtnAdd];
        [btnAdd setButtonTag:friendId];
        [btnAdd.dictData setValue:friendDictionary forKey:KeyButtonValue];
        [btnAdd setTitle:strBtnTitle forState:UIControlStateNormal];
        [btnAdd setFrame:CGRectMake(gap, otherView.frame.size.height - gap -((iPad?25:20)), otherView.frame.size.width/3+(iPhone?5:0),(iPad?25:20))];
        [btnAdd setUserInteractionEnabled:TRUE];
    }
    else
    {
        NSMutableArray *all_users = [arrUsers mutableCopy];
        int id_user = 0;
        int friend_status = -1;
        NSArray *emails = [friendDictionary objectForKey:@"emails"];
        
        if ([emails count] > 0){
            for (int i = 0; i < [emails count]; i++) {
                for (NSDictionary *user in all_users){
                    if ([[emails objectAtIndex:i] isEqual:[user objectForKey:@"user_email"]]){
                        if ([user objectForKey:@"friend_status"] != nil){
                            friend_status = [[user objectForKey:@"friend_status"] intValue];
                        }
                        id_user = [[user objectForKey:@"ID"] intValue];
                        break;
                    }
                }
            }
        }
        
        NSMutableDictionary *dic = [friendDictionary mutableCopy];
        [dic setValue:[NSString stringWithFormat:@"%d", friend_status] forKey:keyFriendStatus];
        [dic setValue:[NSString stringWithFormat:@"%d", id_user] forKey:keyID];
        
        CustomButton *btnAdd = (CustomButton *)[otherView viewWithTag:TAG_Cell_BtnAdd];
        [btnAdd.dictData setValue:dic forKey:KeyButtonValue];
        [btnAdd setFrame:CGRectMake(gap, otherView.frame.size.height - gap -((iPad?25:20)), otherView.frame.size.width/3+(iPhone?5:0),(iPad?25:20))];
        [btnAdd setUserInteractionEnabled:TRUE];
        NSString *strBtnTitle = @"";
        int friendId;
        if ([[dic objectForKey:keyFriendStatus] intValue] == -1) // remove
        {
            if([[dic objectForKey:keyID] intValue] == 0)
            {
                strBtnTitle = @"Not on Sagebin";
                [btnAdd setFrame:CGRectMake(btnAdd.frame.origin.x, btnAdd.frame.origin.y, otherView.frame.size.width/2, btnAdd.frame.size.height)];
                [btnAdd setTitle:strBtnTitle forState:UIControlStateNormal];
                [btnAdd setUserInteractionEnabled:FALSE];
            }
            else
            {
                strBtnTitle = @"Add Friend";
                friendId = [[friendDictionary objectForKey:keyID] intValue];
                [btnAdd setButtonTag:friendId];
                [btnAdd setTitle:strBtnTitle forState:UIControlStateNormal];
            }
        }
        else if ([[dic objectForKey:keyFriendStatus] intValue] == 1) // waiting
        {
            strBtnTitle = @"Your friend";
            [btnAdd setTitle:strBtnTitle forState:UIControlStateNormal];
            [btnAdd setUserInteractionEnabled:FALSE];
        }
        else if ([[dic objectForKey:keyFriendStatus] intValue] == 0)
        {
            strBtnTitle = @"Waiting...";
            [btnAdd setTitle:strBtnTitle forState:UIControlStateNormal];
            [btnAdd setUserInteractionEnabled:FALSE];
        }
        else if ([[dic objectForKey:keyFriendStatus] intValue] == 3)
        {
            strBtnTitle = @"Me";
            [btnAdd setTitle:strBtnTitle forState:UIControlStateNormal];
            [btnAdd setUserInteractionEnabled:FALSE];
        }
    }
    
    
    /*
     // MEssage Button
     UIButton *btnMsg = (UIButton *)[otherView viewWithTag:TAG_Cell_BtnMSG];
     btnMsg.frame = CGRectMake((otherView.frame.size.width-CGRectGetWidth(btnMsg.frame))-10, lblName.frame.size.height, CGRectGetWidth(btnMsg.frame), CGRectGetHeight(btnMsg.frame));
     
     
     
     // ONLINE STATUS
     UIButton *btnStatus = (UIButton *)[otherView viewWithTag:TAG_Cell_BtnStatus];
     
     
     
     
     UIImage *statusImage = [SEGBIN_SINGLETONE_INSTANCE imageForStatus:USER_STATUS_ONLINE];
     NSString *txtStatus = StatusString(USER_STATUS_ONLINE);
     
     [btnStatus setImage:statusImage forState:UIControlStateNormal];
     [btnStatus setTitle:txtStatus forState:UIControlStateNormal];
     
     UIFont *fontStatus = [APPDELEGATE Fonts_OpenSans_Light:(iPad?11:10)];
     CGSize txtSize = [SEGBIN_SINGLETONE_INSTANCE sizeForString:txtStatus fontType:fontStatus];
     
     btnStatus.frame = CGRectMake(lblX, btnMsg.frame.origin.y+btnMsg.frame.size.height-(iPad?8:10), (statusImage.size.width+txtSize.width+5), 20);
     */
}

-(void)btnAddClicked:(CustomButton *)btn
{
    NSLog(@"%d", btn.buttonTag);
    NSDictionary *friendDictionary = [btn.dictData valueForKey:KeyButtonValue];
    
    IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
    NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
    // NSString *apiUrl = NSLocalizedString(@"appAjaxApi", nil);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strParameter;
    int tag;
    if ([[friendDictionary objectForKey:keyFriendStatus] intValue] == 1) // remove
    {
        //strParameter = [NSString stringWithFormat:@"action=action_ajax&do=remove_friend&id=%d", btn.buttonTag];
        strParameter=[NSString stringWithFormat:@"page=remove-friend&id=%d", btn.buttonTag];
        strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], strParameter];
        tag = kTAG_REMOVE_FRIEND;
    }
    else if ([[friendDictionary objectForKey:keyFriendStatus] intValue] == 0) // waiting
    {
        //  strParameter = [NSString stringWithFormat:@"action=action_ajax&do=remove_friend&id=%d", btn.buttonTag];
        strParameter=[NSString stringWithFormat:@"page=remove-friend&id=%d", btn.buttonTag];
        strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], strParameter];
        tag = kTAG_REMOVE_FRIEND;
    }
    else // add
    {
        // strParameter = [NSString stringWithFormat:@"action=action_ajax&do=add_friend&id=%d", btn.buttonTag];
        strParameter=[NSString stringWithFormat:@"page=add-friend&id=%d", btn.buttonTag];
        strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], strParameter];
        tag = kTAG_ADD_FRIEND;
    }
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl]];
    NSData *postData = [NSData dataWithBytes:[strParameter UTF8String] length:[strParameter length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:tag];
    [requestConnection startAsynchronousRequest];
    
    [SEGBIN_SINGLETONE_INSTANCE addLoader];
    [self enableDisableUI:FALSE];
}

#pragma mark - TextField Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.text.length != 0)
    {
        if(APPDELEGATE.netOnLink == 0)
        {
            [self.view makeToast:WARNING];
        }
        else
        {
            [self searchFriend:nil];
        }
    }
    else
    {
        [self.view makeToast:NSLocalizedString(@"txtSearchEmpty", nil)];
    }
    return [textField resignFirstResponder];
}
#pragma mark - Buttons Events
-(void)btnMessageClicked:(UIButton *)btnMsg
{
    NSLog(@"MsgClicked");
}
-(void)searchFriend:(UIButton *)btnserch
{
    [txtSearch resignFirstResponder];
    
    if(txtSearch.text.length == 0)
    {
        [self.view makeToast:NSLocalizedString(@"txtSearchEmpty", nil)];
        return;
    }
    
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    if(btnContact.tag == TAG_CONTACTBUTTON)
    {
        /*
         [arrFriends removeAllObjects];
         [self showContentByContact];
         [_collectionView reloadData];
         [btnContact setTitle:@"Search Sagebin" forState:UIControlStateNormal];
         [btnContact setTag:-1];
         */
        [self getApiDataWithTag:kTAG_FRIEND_SEARCH];
        [btnContact setTag:TAG_CONTACTBUTTON];
    }
    else
    {
        [self getApiDataWithTag:kTAG_FRIEND_SEARCH];
        [btnContact setTitle:@"Search Phone" forState:UIControlStateNormal];
        [btnContact setTag:TAG_CONTACTBUTTON];
    }
}

-(void)btnContactClicked:(CustomButton *)btn
{
    [txtSearch resignFirstResponder];
    if(txtSearch.text.length == 0)
    {
        [self.view makeToast:NSLocalizedString(@"txtSearchEmpty", nil)];
        return;
    }
    
    if(btn.tag == TAG_CONTACTBUTTON)
    {
        /*
         [arrFriends removeAllObjects];
         [self showContentByContact];
         [btn setTitle:@"Search Sagebin" forState:UIControlStateNormal];
         [btn setTag:-1];
         [_collectionView reloadData];
         */
        [self getApiDataWithTag:kTAG_FRIEND_SEARCH];
        [btn setTag:TAG_CONTACTBUTTON];
    }
    else
    {
        [self getApiDataWithTag:kTAG_FRIEND_SEARCH];
        [btn setTitle:@"Search Phone" forState:UIControlStateNormal];
        [btn setTag:TAG_CONTACTBUTTON];
    }
}

- (void)showContentByContact{
    //[self resetSView];
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        //dispatch_release(sema);
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(
                                                               kCFAllocatorDefault,
                                                               CFArrayGetCount(allPeople),
                                                               allPeople
                                                               );
    
    CFArraySortValues(
                      peopleMutable,
                      CFRangeMake(0, CFArrayGetCount(peopleMutable)),
                      (CFComparatorFunction) ABPersonComparePeopleByName,
                      (void*) ABPersonGetSortOrdering()
                      );
    
    if(nPeople <= 0)
    {
        [self.view makeToast:@"There is no contact"];
        return;
    }
    
    for (int i = 0; i < nPeople; i++)
    {
        NSString* name = @"";
        
        ABRecordRef aPerson = CFArrayGetValueAtIndex(peopleMutable, i);
        ABMultiValueRef fnameProperty = ABRecordCopyValue(aPerson, kABPersonFirstNameProperty);
        ABMultiValueRef lnameProperty = ABRecordCopyValue(aPerson, kABPersonLastNameProperty);
        
        ABMultiValueRef phoneProperty = ABRecordCopyValue(aPerson, kABPersonPhoneProperty);
        ABMultiValueRef emailProperty = ABRecordCopyValue(aPerson, kABPersonEmailProperty);
        
        NSArray *emailArray=[[NSArray alloc] initWithArray:(__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailProperty)];
        NSArray *phoneArray=[[NSArray alloc] initWithArray:(__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneProperty)];
        
        if (fnameProperty != nil) {
            name = [NSString stringWithFormat:@"%@", fnameProperty];
        }
        if (lnameProperty != nil) {
            name = [name stringByAppendingString:[NSString stringWithFormat:@" %@", lnameProperty]];
        }
        NSDictionary *contact = [[NSDictionary alloc] initWithObjectsAndKeys:name, keyDisplayName, phoneArray, keyPhones, emailArray, keyEmails, nil];
        
        //==============================================================================
        NSMutableArray *all_users = [arrUsers mutableCopy];
        int id_user = 0;
        int friend_status = -1;
        NSArray *emails = [contact objectForKey:keyEmails];
        
        if ([emails count] > 0){
            for (int i = 0; i < [emails count]; i++) {
                for (NSDictionary *user in all_users){
                    if ([[emails objectAtIndex:i] isEqual:[user objectForKey:keyUserEmail]]){
                        if ([user objectForKey:keyFriendStatus] != nil){
                            friend_status = [[user objectForKey:keyFriendStatus] intValue];
                        }
                        id_user = [[user objectForKey:keyID] intValue];
                        break;
                    }
                }
            }
        }
        if(friend_status == -1)
        {
            if(id_user == 0)
            {
                continue;
            }
        }
        
        [arrFriends addObject:contact];
        //=================================================================================
    }
    if ([txtSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length>0)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY emails CONTAINS[c] %@ OR display_name CONTAINS[c] %@", txtSearch.text, txtSearch.text];
        NSArray *arrResult = [arrFriends filteredArrayUsingPredicate:predicate];
        [arrFriends removeAllObjects];
        [arrFriends addObjectsFromArray:arrResult];
    }
    if([arrFriends count] == 0)
    {
        [self.view makeToast:@"There is no contact"];
    }
}

#pragma mark - Rotation Method
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UICollectionViewFlowLayout *Layout = (UICollectionViewFlowLayout *) _collectionView.collectionViewLayout;
    
    Layout.itemSize = [self viewItemSizefor:toInterfaceOrientation];
    [Layout invalidateLayout];
    [_collectionView reloadData];
    
    [self setSagebinLogoInCenterForOrientation:toInterfaceOrientation];
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