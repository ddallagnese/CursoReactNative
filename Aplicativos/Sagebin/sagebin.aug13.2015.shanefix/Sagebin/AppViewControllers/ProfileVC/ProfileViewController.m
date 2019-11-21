//
//  ProfileViewController.m
//  Sagebin
//
//  
//  
//

#import "ProfileViewController.h"
#import "MovieDetailsViewController.h"
#import "SettingsViewController.h"
#import "EditProfileViewController.h"
#import <Parse/Parse.h>
#import "CastViewController.h"
#import "DeviceTableViewController.h"

#define kIphoneItemWidth 52 // 55
#define kIphoneItemHeight 73
#define kIphoneItemGap 10 // 11

#define kIpadItemWidth 130
#define kIpadItemHeight 166
#define kIpadItemGap 12

@interface ProfileViewController ()
{
    UIScrollView *mainScroll;
    NSDictionary *userDictionary;
    NSMutableArray *arrData;
    __weak ChromecastDeviceController *_chromecastController;
}
@end

@implementation ProfileViewController

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
    [self.view setBackgroundColor:ProfileViewBgColor];
    [self.rightButton setHidden:YES];
    
    [self setUpView];
    arrData = [[NSMutableArray alloc]init];
    
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    [self getApiDataWithTag:kTAG_SETTINGS];
}

-(void)viewWillAppear:(BOOL)animated
{
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
    
    if(APPDELEGATE.latestProfImg)
    {
        UIView *viewTop = [self.view viewWithTag:TAG_TOPVIEW];
        if(viewTop)
        {
            IMDEventImageView *imgVwUSer =(IMDEventImageView *) [viewTop viewWithTag:TAG_IMGVIEW_USER];
            if(imgVwUSer && [imgVwUSer isKindOfClass:[IMDEventImageView class]])
            {
                [imgVwUSer setImage:APPDELEGATE.latestProfImg];
            }
        }
        
    }
    [self setSagebinLogoInCenterForOrientation:[UIApplication sharedApplication].statusBarOrientation];
    
    if(arrData.count != 0)
    {
        [self reloadCollectionView:[UIApplication sharedApplication].statusBarOrientation];
    }
    
    //[self setTopViewForValues:nil userName:@"Segbin" location:@"India, Delhi" status:USER_STATUS_OFFLINE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getApiDataWithTag:(int)tag
{
    IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
    NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strParameter;
    if(tag==kTAG_SETTINGS)
    {
        strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], NSLocalizedString(@"apiSettings", nil)];
    }
    else if(tag==kTAG_MY_MOVIE)
    {
        //strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], NSLocalizedString(@"apiMyMovie", nil)];
        strParameter = [NSString stringWithFormat:NSLocalizedString(@"apiMyMovieAll", nil)];
        strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], strParameter];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl]];
    NSData *postData = [NSData dataWithBytes:[strParameter UTF8String] length:[strParameter length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:tag];
    [requestConnection startAsynchronousRequest];
    
    [SEGBIN_SINGLETONE_INSTANCE addLoader];
    [self enableDisableUI:NO];
}

-(void)enableDisableUI:(BOOL)status
{
    UIView *topView = [mainScroll viewWithTag:TAG_TOPVIEW];
    if(topView)
    {
        [topView setUserInteractionEnabled:status];
    }
    UIView *middleView = [mainScroll viewWithTag:TAG_MIDDLEVIEW];
    if(middleView)
    {
        [middleView setUserInteractionEnabled:status];
    }
    UICollectionView *albumView = (UICollectionView *)[mainScroll viewWithTag:TAG_COLLECTIONVIEW_ALBUM];
    if(albumView)
    {
        [albumView setUserInteractionEnabled:status];
    }
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
                [self setTopViewForValues:[userDictionary objectForKey:keyProfilePhoto] userName:[userDictionary objectForKey:keyDisplayName] location:@"" status:USER_STATUS_OFFLINE];
                
                [self getApiDataWithTag:kTAG_MY_MOVIE];
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
    else if (tag==kTAG_MY_MOVIE)
    {
        NSDictionary *result = (NSDictionary *)items;
        if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
        {
            [self checkUserAlert:[result objectForKey:keyAlerts]];
            if([result valueForKey:keyValue] == [NSNull null] || [[result valueForKey:keyValue] count] == 0)
            {
                if(arrData.count == 0)
                {
                    //UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert Dialog" message:@"No video(s) available!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    //[alert show];
                    [self.view makeToast:NSLocalizedString(@"noMoviesAvailable", nil)];
                }else{
                    UICollectionView *_collectionView = (UICollectionView *)[mainScroll viewWithTag:TAG_COLLECTIONVIEW_ALBUM];
                    [_collectionView reloadData];
                }
            }
            else
            {
                [arrData addObjectsFromArray:[result objectForKey:keyValue]];
                //NSLog(@"%@", arrData);
            
                UICollectionView *_collectionView = (UICollectionView *)[mainScroll viewWithTag:TAG_COLLECTIONVIEW_ALBUM];
                [_collectionView reloadData];
                //[self getApiDataWithTag:kTAG_BORROWED_MOVIE];
                
                UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
                [self willRotateToInterfaceOrientation:currentOrientation duration:0];
                
                /*CGFloat itemWidth = (iPhone?kIphoneItemWidth:kIpadItemWidth);
                CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
                UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
                if (currentOrientation == UIInterfaceOrientationLandscapeLeft
                    || currentOrientation == UIInterfaceOrientationLandscapeRight) {
                    frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
                    itemWidth = itemWidth + (iPhone?kIphoneItemGap:kIpadItemGap);
                }
                int totalColumns = _collectionView.frame.size.width/itemWidth;
                CGFloat rows = (CGFloat)[arrData count]/totalColumns;
                int totalRows = lroundf(rows);
                [_collectionView setFrame:CGRectMake(_collectionView.frame.origin.x, _collectionView.frame.origin.y, _collectionView.frame.size.width, totalRows*((iPhone?kIphoneItemHeight:kIpadItemHeight)+(iPhone?kIphoneItemGap:kIpadItemGap)))];
                mainScroll.contentSize = CGSizeMake(mainScroll.contentSize.width, _collectionView.frame.origin.y+_collectionView.frame.size.height);*/
            }
        }
        else
        {
            [self.view makeToast:kServerError];
        }
    }
}

#pragma mark -
#pragma mark - Set up view

-(void)setUpView
{
    CGFloat yPos = [self.view viewWithTag:TopView_Tag].frame.size.height;
    mainScroll = [SEGBIN_SINGLETONE_INSTANCE createScrollViewWithFrame:CGRectMake(0, yPos, self.view.frame.size.width, self.view.frame.size.height - yPos) bgColor:[UIColor clearColor] tag:-1 delegate:nil];
    [mainScroll setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [mainScroll setScrollEnabled:YES];
    [self.view addSubview:mainScroll];
    
    [self createTopView];
    [self createMiddleView];
    [self createAlbumView];
}

-(void)createTopView
{
    float heigt=iPad ? 240 : 114;
    UIView *viewTop = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(0, 0,self.view.frame.size.width , heigt) bgColor:nil tag:TAG_TOPVIEW alpha:1.0];
    [viewTop setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [viewTop setAutoresizesSubviews:YES];
    
    
    float viewImgX= iPad ? 28 : 12 ;
    float imgSize = iPad ? 190 : 98;
    IMDEventImageView *imgVwUsr = [APPDELEGATE createEventImageViewWithFrame:CGRectMake(viewImgX, viewTop.frame.size.height/2 - (imgSize/2), imgSize, imgSize) withImageURL:nil Placeholder:kPlaceholderImg tag:TAG_IMGVIEW_USER];
    [imgVwUsr setContentMode:UIViewContentModeScaleAspectFill];
    [imgVwUsr setClipsToBounds:YES];
    [viewTop addSubview:imgVwUsr];
    
    UIColor *lblTextColor = [UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:81.0/255.0 alpha:1.0];
    float lblY=iPad ? 48.0 : 20;
    float gapX = 16.0;
    float lblWidth = self.view.frame.size.width - (imgVwUsr.frame.origin.x+ imgVwUsr.frame.size.width + gapX+10);
    //JM 1/7/2014 change in height of lblUserName 38
    UILabel *lblUserName = [SEGBIN_SINGLETONE_INSTANCE createLabelWithFrame: CGRectMake(imgVwUsr.frame.origin.x+ imgVwUsr.frame.size.width + gapX, lblY, lblWidth,(iPad ? 38 : 17)) withFont:[APPDELEGATE Fonts_OpenSans_Light:(iPad ? 30 : 13)] withTextColor:lblTextColor withTextAlignment:NSTextAlignmentLeft withTag:TAG_LBL_NAME];
    //
    //lblUserName.text = @"NAME";
    [lblUserName setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [viewTop addSubview:lblUserName];
    
    UILabel *lblLocation = [SEGBIN_SINGLETONE_INSTANCE createLabelWithFrame: CGRectMake(lblUserName.frame.origin.x,lblUserName.frame.origin.y+lblUserName.frame.size.height+(iPad ? 10 : 5), lblWidth, (iPad ? 22 : 12)) withFont:[APPDELEGATE Fonts_OpenSans_LightItalic:(iPad ? 18 : 8)] withTextColor:lblTextColor withTextAlignment:NSTextAlignmentLeft withTag:TAG_LBL_LOCATION];
    lblLocation.text = @"LOCATION";
    [lblLocation setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [viewTop addSubview:lblLocation];
    [lblLocation setHidden:YES];
    
    UIImage *imgStats = [self imageForStatus:1];
    UIImageView *imgVwStatus = [[UIImageView alloc]initWithFrame:CGRectMake(lblUserName.frame.origin.x,lblLocation.frame.origin.y+lblLocation.frame.size.height+(iPad ? 65 : 30), imgStats.size.width, imgStats.size.height)];
    [imgVwStatus setImage:imgStats];
    imgVwStatus.tag = TAG_IMG_STATUS;
    [viewTop addSubview:imgVwStatus];
    [imgVwStatus setHidden:YES];
    
    UILabel *lblStatus = [SEGBIN_SINGLETONE_INSTANCE createLabelWithFrame: CGRectMake(imgVwStatus.frame.origin.x+imgVwStatus.frame.size.width+6,(imgVwStatus.frame.origin.y-((iPad ? 22 : 12)/2)+(imgStats.size.height/2)), lblWidth-(imgVwStatus.frame.size.width+6), (iPad ? 22 : 12)) withFont:[APPDELEGATE Fonts_OpenSans_LightItalic:(iPad ? 18 : 8)] withTextColor:lblTextColor withTextAlignment:NSTextAlignmentLeft withTag:TAG_LBL_STATUS];
    lblStatus.text = @"Status";
    [lblStatus setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [viewTop addSubview:lblStatus];
    [lblStatus setHidden:YES];
    
    [mainScroll addSubview:viewTop];
}

/*
-(void)setTopViewForValues:(UIImage *)userImg  userName:(NSString *)userNAme location:(NSString *)location status:(USER_STATUS)status
{
    UIView *viewTop = [self.view viewWithTag:TAG_TOPVIEW];
    IMDEventImageView *imgVwUSer =(IMDEventImageView *) [viewTop viewWithTag:TAG_IMGVIEW_USER];
    UILabel * lblName = (UILabel *)[viewTop viewWithTag:TAG_LBL_NAME];
    UILabel *lblLoc = (UILabel *)[viewTop viewWithTag:TAG_LBL_LOCATION];
    UIImageView *imgVwStats = (UIImageView *)[viewTop viewWithTag:TAG_IMG_STATUS];
    UILabel *lblStats = (UILabel *)[viewTop viewWithTag:TAG_LBL_STATUS];
    
    [imgVwUSer setImage:userImg];
    [lblName setText:userNAme];
    [lblLoc setText:location];
    [imgVwStats setImage:[SEGBIN_SINGLETONE_INSTANCE imageForStatus:status]];
    [lblStats setText:StatusString(status)];
}
*/

-(void)setTopViewForValues:(NSString *)userImgURL userName:(NSString *)userNAme location:(NSString *)location status:(USER_STATUS)status
{
    UIView *viewTop = [self.view viewWithTag:TAG_TOPVIEW];
    IMDEventImageView *imgVwUSer =(IMDEventImageView *) [viewTop viewWithTag:TAG_IMGVIEW_USER];
    UILabel * lblName = (UILabel *)[viewTop viewWithTag:TAG_LBL_NAME];
    UILabel *lblLoc = (UILabel *)[viewTop viewWithTag:TAG_LBL_LOCATION];
    UIImageView *imgVwStats = (UIImageView *)[viewTop viewWithTag:TAG_IMG_STATUS];
    UILabel *lblStats = (UILabel *)[viewTop viewWithTag:TAG_LBL_STATUS];
    
    [imgVwUSer setImageWithURL:userImgURL placeholderImage:kPlaceholderImg];
    [lblName setText:userNAme];
    [lblLoc setText:location];
    [imgVwStats setImage:[SEGBIN_SINGLETONE_INSTANCE imageForStatus:status]];
    [lblStats setText:StatusString(status)];
}

-(UIImage * )imageForStatus:(NSInteger )status
{
    if (status == USER_STATUS_OFFLINE)
    {
        return [UIImage imageNamed:@"friend_offline"];
    }
    else if (status == USER_STATUS_ONLINE)
    {
        return [UIImage imageNamed:@"friend_online"];
    }
    return nil;
}


-(void)createMiddleView
{
    UIView *viewTop = [self.view viewWithTag:TAG_TOPVIEW];
    UIView *viewMiddle = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake((iPad?28:12), viewTop.frame.origin.y + viewTop.frame.size.height, self.view.frame.size.width-(iPad?28:12)*2, (iPad?75:42)) bgColor:[UIColor whiteColor] tag:TAG_MIDDLEVIEW alpha:1.0];
    [viewMiddle setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    float gapBtn= viewMiddle.frame.size.width/4;
    
    UIImage *imgFriend = [UIImage imageNamed:@"friends-profile"];
    UIButton *btnFriends = [SEGBIN_SINGLETONE_INSTANCE createBtnWithFrame:CGRectMake((gapBtn/2) - (imgFriend.size.width/2), viewMiddle.frame.size.height/2 - imgFriend.size.height/2, imgFriend.size.width, imgFriend.size.height) withTitle:nil withImage:imgFriend withTag:TAG_BTN_FRIEND];
    [btnFriends setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [btnFriends addTarget:self action:@selector(btnFriendClicked:) forControlEvents:UIControlEventTouchUpInside];
    [viewMiddle addSubview:btnFriends];
    
    UIImage *imgMsg = [UIImage imageNamed:@"message-profile"];
    UIButton *btnMsg = [SEGBIN_SINGLETONE_INSTANCE createBtnWithFrame:CGRectMake((gapBtn/2 + gapBtn)-(imgMsg.size.width/2), btnFriends.frame.origin.y, imgMsg.size.width, imgMsg.size.height) withTitle:nil withImage:imgMsg withTag:TAG_BTN_MESSAGS];
    [btnMsg setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [btnMsg addTarget:self action:@selector(btnMessagesClicked:) forControlEvents:UIControlEventTouchUpInside];
    [viewMiddle addSubview:btnMsg];
    [btnMsg setHidden:YES];
    
    UIImage *imgSettng = [UIImage imageNamed:@"setting-profile"];
    //UIButton *btnSettngs = [SEGBIN_SINGLETONE_INSTANCE createBtnWithFrame:CGRectMake((gapBtn/2 + (2*gapBtn))-(imgSettng.size.width/2), btnFriends.frame.origin.y, imgSettng.size.width, imgSettng.size.height) withTitle:nil withImage:imgSettng withTag:TAG_BTN_SETTINGS];
    UIButton *btnSettngs = [SEGBIN_SINGLETONE_INSTANCE createBtnWithFrame:CGRectMake((2*gapBtn)-(imgSettng.size.width/2), btnFriends.frame.origin.y, imgSettng.size.width, imgSettng.size.height) withTitle:nil withImage:imgSettng withTag:TAG_BTN_SETTINGS];
    [btnSettngs setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [btnSettngs addTarget:self action:@selector(btnSettingsClicked:) forControlEvents:UIControlEventTouchUpInside];
    [viewMiddle addSubview:btnSettngs];
    
    
    UIImage *imgLogout = [UIImage imageNamed:@"logout-profile"];
    UIButton *btnLogout = [SEGBIN_SINGLETONE_INSTANCE createBtnWithFrame:CGRectMake((gapBtn/2 + (3*gapBtn))-(imgLogout.size.width/2), btnFriends.frame.origin.y, imgLogout.size.width, imgLogout.size.height) withTitle:nil withImage:imgLogout withTag:TAG_BTN_LOGOUT];
    [btnLogout setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [btnLogout addTarget:self action:@selector(btnLogoutClicked:) forControlEvents:UIControlEventTouchUpInside];
    [viewMiddle addSubview:btnLogout];
    
    [mainScroll addSubview:viewMiddle];
}


-(void)createAlbumView
{
    UIView *viewMiddle = [mainScroll viewWithTag:TAG_MIDDLEVIEW];

    //(iPad?696:296) width
    UILabel *lblPurchasedMvi =[SEGBIN_SINGLETONE_INSTANCE createLabelWithFrame:CGRectMake((iPad?28:12), viewMiddle.frame.origin.y + viewMiddle.frame.size.height, mainScroll.frame.size.width-(iPad?28:12)*2.0, (iPad?55:40)) withFont:[APPDELEGATE Fonts_OpenSans_LightItalic:(iPad?20:10)] withTextColor:[UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:81.0/255.0 alpha:1.0] withTextAlignment:NSTextAlignmentLeft withTag:TAG_LBL_PURCHSMVI] ;
    [lblPurchasedMvi setBackgroundColor:[UIColor clearColor]];
    [lblPurchasedMvi setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [lblPurchasedMvi setText:NSLocalizedString(@"myMoviesTitle", nil)];
    [mainScroll addSubview:lblPurchasedMvi];

    UICollectionViewFlowLayout *viewLayout = [[UICollectionViewFlowLayout alloc]init];
    if (iPad) {
        [viewLayout setItemSize:CGSizeMake(kIpadItemWidth, kIpadItemHeight)];
    }
    else
       [viewLayout setItemSize:CGSizeMake(kIphoneItemWidth, kIphoneItemHeight)];
    
    //UICollectionView * _collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, lblPurchasedMvi.frame.origin.y + lblPurchasedMvi.frame.size.height, mainScroll.frame.size.width,mainScroll.frame.size.height - (lblPurchasedMvi.frame.origin.y + lblPurchasedMvi.frame.size.height)) collectionViewLayout:viewLayout];
    UICollectionView * _collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake((iPad?28:10), lblPurchasedMvi.frame.origin.y + lblPurchasedMvi.frame.size.height, mainScroll.frame.size.width-(iPad?28:10)*2.0, mainScroll.frame.size.height - (lblPurchasedMvi.frame.origin.y + lblPurchasedMvi.frame.size.height)) collectionViewLayout:viewLayout];
    [_collectionView setShowsVerticalScrollIndicator:NO];
    [_collectionView setTag:TAG_COLLECTIONVIEW_ALBUM];
    
    [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    [_collectionView setScrollEnabled:FALSE];
    
    [mainScroll addSubview:_collectionView];
    [mainScroll setContentSize:CGSizeMake(mainScroll.frame.size.width, _collectionView.frame.origin.y+_collectionView.frame.size.height)];
}

#pragma mark -
#pragma mark - collectionview delegates
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return arrData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    NSDictionary *movieDictionary = [arrData objectAtIndex:indexPath.item];
    UIImage *image = [UIImage imageNamed:@"Sell.png"];
    IMDEventImageView *imgVw = (IMDEventImageView *)[cell viewWithTag:TAG_COLLECTIONVIEW_IMG];
    if (!imgVw) {
        imgVw = [[IMDEventImageView alloc]init];
        imgVw.frame = cell.contentView.frame;
        [imgVw setTag:TAG_COLLECTIONVIEW_IMG];
        [cell addSubview:imgVw];
        
        if (![[movieDictionary objectForKey:keySaleFlag] isKindOfClass:[NSNull class]] && [[movieDictionary objectForKey:keySaleFlag] integerValue] == 1) {
            
            UIImageView *sellImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imgVw.frame.size.width - image.size.width -3, 2, image.size.width, image.size.height)];
            [sellImageView setImage:image];
            [sellImageView setTag:TAG_COLLECTIONVIEW_SELL];
            [imgVw addSubview:sellImageView];
        }
        
    } else {
        //NSLog(@"got the label");
        
        if (![[movieDictionary objectForKey:keySaleFlag] isKindOfClass:[NSNull class]] && [[movieDictionary objectForKey:keySaleFlag] integerValue] == 1) {
            UIImageView *sellImageView = (UIImageView *)[imgVw viewWithTag:TAG_COLLECTIONVIEW_SELL];
            if(sellImageView)
            {
                [sellImageView setFrame:CGRectMake(imgVw.frame.size.width - image.size.width -3, 2, image.size.width, image.size.height)];
                [sellImageView setHidden:NO];
            }
            else
            {
                sellImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imgVw.frame.size.width - image.size.width -3, 2, image.size.width, image.size.height)];
                [sellImageView setImage:image];
                [sellImageView setTag:TAG_COLLECTIONVIEW_SELL];
                [imgVw addSubview:sellImageView];
            }
        }
        else
        {
            UIImageView *sellImageView = (UIImageView *)[imgVw viewWithTag:TAG_COLLECTIONVIEW_SELL];
            if(sellImageView)
            {
                [sellImageView setHidden:YES];
            }
        }
    }
    
    NSString *strImageURL = @"";
    if([movieDictionary objectForKey:keyPoster] != [NSNull null])
    {
        strImageURL = [movieDictionary objectForKey:keyPoster];
    }
    [imgVw setImageWithURL:strImageURL placeholderImage:nil];
    [imgVw setContentMode:UIViewContentModeScaleAspectFill];
    [imgVw setClipsToBounds:YES];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = iPhone_storyboard;
    if (iPad)
    {
        storyboard = self.storyboard;
    }
    MovieDetailsViewController *movieDetailsVC = (MovieDetailsViewController *) [storyboard instantiateViewControllerWithIdentifier:@"MovieDetailsVC"];
    NSDictionary *movieDictionary = [arrData objectAtIndex:indexPath.item];
    movieDetailsVC.strMovieId = [movieDictionary valueForKey:keyId];
    movieDetailsVC.viewType = ViewTypeList;
    [self.navigationController pushViewController:movieDetailsVC animated:YES];

}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    if (kind == UICollectionElementKindSectionHeader) {
//        
//        UICollectionReusableView *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
//        
//        if (reusableview==nil) {
//            reusableview=[[UICollectionReusableView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//        }
//        
//        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//        label.text=[NSString stringWithFormat:@"Recipe Group #%i", indexPath.section + 1];
//        [reusableview addSubview:label];
//        return reusableview;
//    }
//    return nil;
//}


#pragma mark -
#pragma mark - click events

-(void)btnFriendClicked :(UIButton *)btn
{
    //NSLog(@"friend btn clicked ");
    UIStoryboard *storyboard = iPhone_storyboard;
    if (iPad)
    {
        storyboard = self.storyboard;
    }
    EditProfileViewController *editProfileVC = (EditProfileViewController *) [storyboard instantiateViewControllerWithIdentifier:@"EditProfileVC"];
    
    UIView *viewTop = (UIView *)[mainScroll viewWithTag:TAG_TOPVIEW];
    IMDEventImageView *imgVw = (IMDEventImageView *)[viewTop viewWithTag:TAG_IMGVIEW_USER];
    APPDELEGATE.latestProfImg = imgVw.image;
    
    editProfileVC.strImageURL = [userDictionary objectForKey:keyProfilePhoto];
    [self.navigationController pushViewController:editProfileVC animated:YES];
}

-(void)btnMessagesClicked :(UIButton *)btn
{
    //NSLog(@"message btn clicked ");
}

-(void)btnSettingsClicked :(UIButton *)btn
{
    //NSLog(@"settings btn clicked ");
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)btnLogoutClicked :(UIButton *)btn
{
    //NSLog(@"logout btn clicked ");
    if(APPDELEGATE == 0)
    {
        //[self.view makeToast:WARNING];
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"All downloaded video will be deleted after logout" message:@"Are you sure do you want to logout?" delegate:self cancelButtonTitle:@"Confirm" otherButtonTitles:@"Cancel", nil];
    [alert show];
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        NSLog(@"confirm");
        
        NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
        NSDictionary * dict = [defs dictionaryRepresentation];
        for (id key in dict) {
            [defs removeObjectForKey:key];
        }
        [defs synchronize];
        
        NSArray *directoryContents =  [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] error:NULL];
        
        if([directoryContents count] > 0)
        {
            for (NSString *path in directoryContents)
            {
                NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:path];
                [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
            }
        }
        
        NSString *path = NSTemporaryDirectory();
        if ([path length] > 0)
        {
            NSError *error = nil;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            BOOL deleted = [fileManager removeItemAtPath:path error:&error];
            if (deleted != YES || error != nil)
            {
            }
            else{
                // Recreate the Documents directory
                [fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
            }
        }
        
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"stopTimerNotification" object:nil];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"" forKey:keyAccount];
        [defaults synchronize];
        
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation removeObjectForKey:@"channels"];
        [currentInstallation saveInBackground];
        
        [APPDELEGATE setVideoDownloadMode:DefaultValueDownloadMode];
        [APPDELEGATE setNotificationType:DefaultValueNotificationType];
        [APPDELEGATE setNotificationPeriod:DefaultValueNotificationPeriod];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        NSLog(@"cancel");
    }
}

#pragma mark - Rotation Method

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self reloadCollectionView:toInterfaceOrientation];
    [self setSagebinLogoInCenterForOrientation:toInterfaceOrientation];
    [self performSelector:@selector(de) withObject:self afterDelay:0.2];
}
-(void)de
{
     UICollectionView *_collectionView = (UICollectionView *)[mainScroll viewWithTag:TAG_COLLECTIONVIEW_ALBUM];
    mainScroll.contentSize = CGSizeMake(self.view.frame.size.width, _collectionView.frame.origin.y+_collectionView.frame.size.height);
}

- (void)reloadCollectionView:(UIInterfaceOrientation)toInterfaceOrientation
{
    UICollectionView *_collectionView = (UICollectionView *)[mainScroll viewWithTag:TAG_COLLECTIONVIEW_ALBUM];
    [_collectionView reloadData];
    
    int totalColumns = 5;
    CGFloat itemHeight = (iPhone?kIphoneItemHeight:kIpadItemHeight);
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft
        || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
        totalColumns = (iPad?6:(IS_IPHONE_5?9:7));
    }
    CGFloat rows = (CGFloat)[arrData count]/totalColumns;
    int totalRows = lroundf(rows)+1;
    
    CGFloat k = rows - (int)rows;
    if(k == 0.0)
    {
        totalRows = rows;
    }
    else
    {
        totalRows = rows+1;
    }
    
    [_collectionView setFrame:CGRectMake(_collectionView.frame.origin.x, _collectionView.frame.origin.y, _collectionView.frame.size.width, totalRows*(itemHeight+(iPhone?kIphoneItemGap:kIpadItemGap)))];
    mainScroll.contentSize = CGSizeMake(mainScroll.contentSize.width, _collectionView.frame.origin.y+_collectionView.frame.size.height);
    [self setSagebinLogoInCenterForOrientation:[UIApplication sharedApplication].statusBarOrientation];
    
    
    /*
    UICollectionView *_collectionView = (UICollectionView *)[mainScroll viewWithTag:TAG_COLLECTIONVIEW_ALBUM];
    [_collectionView reloadData];
    
    CGFloat itemWidth = (iPhone?kIphoneItemWidth:kIpadItemWidth);
    CGFloat itemHeight = (iPhone?kIphoneItemHeight:kIpadItemHeight);
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft
        || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
        itemWidth = itemWidth + (iPhone?kIphoneItemGap:kIpadItemGap);
    }
    int totalColumns = frame.size.width/itemWidth;
    CGFloat rows = (CGFloat)[arrData count]/totalColumns;
    int totalRows = lroundf(rows)+1;
    [_collectionView setFrame:CGRectMake(_collectionView.frame.origin.x, _collectionView.frame.origin.y, _collectionView.frame.size.width, totalRows*(itemHeight+(iPhone?kIphoneItemGap:kIpadItemGap)))];
    mainScroll.contentSize = CGSizeMake(mainScroll.contentSize.width, _collectionView.frame.origin.y+_collectionView.frame.size.height);
     */
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
    NSLog(@"ProfileViewController dealloc called");
}


@end
