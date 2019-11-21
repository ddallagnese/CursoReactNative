//
//  ReleaseVC.m
//  Sagebin
//
//  
//  
//

#import "ReleaseVC.h"
#import "MovieDetailsViewController.h"
#import "CastViewController.h"
#import "DeviceTableViewController.h"

#define K_STAR_TAG 756894


@interface ReleaseVC ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
    
    NSMutableArray *arrData;
    __weak ChromecastDeviceController *_chromecastController;
}
@end

@implementation ReleaseVC

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

    //[self setViewImage:[UIImage imageNamed:@"icon_newrelease"] withTitle:NSLocalizedString(@"txtNewReleaseTitle", nil)];
    [self.view setBackgroundColor:NewReleaseViewBgColor];
    
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    arrData = [[NSMutableArray alloc]init];
    moviePageNo = 1;
    movieCount = 10;
    

    // Do any additional setup after loading the view.
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
    
    if(arrData.count == 0)
    {
        [self getApiData];
        [self setupLayoutMethods];
    }
    else
    {
        [self reloadCollectionView:[UIApplication sharedApplication].statusBarOrientation];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getApiData
{
    IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
    NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strParameter = [NSString stringWithFormat:NSLocalizedString(@"apiNewRelease", nil), moviePageNo, movieCount];
    strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], strParameter];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl]];
    NSData *postData = [NSData dataWithBytes:[strParameter UTF8String] length:[strParameter length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:kTAG_NEW_RELEASE];
    [requestConnection startAsynchronousRequest];
    
    if(arrData.count == 0)
    {
        [SEGBIN_SINGLETONE_INSTANCE addLoader];
    }
    [self.rightButton setUserInteractionEnabled:FALSE];
}

#pragma mark - IMDHTTPRequest Delegates
//When fail parssing with error then get error for url tag
-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didFailWithError:(NSError*)error withTag:(int)tag
{
    [self.rightButton setUserInteractionEnabled:TRUE];
    if (tag==kTAG_NEW_RELEASE)
    {
        [self.view makeToast:kServerError];
    }
    
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    isRefresh = NO;
}

-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didSuccessWithItems:(NSObject*)items withData:(NSData*)data withTag:(int)tag
{
    [self.rightButton setUserInteractionEnabled:TRUE];
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    if (tag==kTAG_NEW_RELEASE)
    {
        NSDictionary *result = (NSDictionary *)items;
        if ([result isKindOfClass:[NSDictionary class]] && [result objectForKey:keyCode])
        {
            if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
            {
                [self checkUserAlert:[result objectForKey:keyAlerts]];                
                if(isRefresh)
                {
                    [arrData removeAllObjects];
                    isRefresh = NO;
                }
                totalCount = [[result valueForKey:keyTotalCount] intValue];
                [arrData addObjectsFromArray:[result objectForKey:keyValue]];
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
        if([arrData count] < totalCount)
        {
            //Load more data
             __unsafe_unretained typeof(self) weakSelf = self;
            [_collectionView.infiniteScrollingView setHidden:YES];
            [_collectionView addInfiniteScrollingWithActionHandler:^{
                [weakSelf insertRowAtBottom];
            }];
        }
        
        [_collectionView.pullToRefreshView stopAnimating];
        
        if ([arrData count] !=  totalCount && ([arrData count] < totalCount))
        {
            [_collectionView.infiniteScrollingView stopAnimating];
            [_collectionView setShowsInfiniteScrolling:YES];
            
        }
        else
        {
            [_collectionView.infiniteScrollingView stopAnimatingWithNoUpdate];
            [_collectionView setShowsInfiniteScrolling:NO];
        }
    }
    else if(tag==TAG_MD_FAVOURITE_BTN)
    {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
        {
            [self.view makeToast:[result valueForKey:keyValue]];
            NSMutableDictionary *dic= [arrData objectAtIndex:favIndex];
            if([[dic valueForKey:keyFavourite] intValue]==1)
            {
                [dic setObject:[NSNumber numberWithInt:0] forKey:keyFavourite];
            }
            else
            {
                [dic setObject:[NSNumber numberWithInt:1] forKey:keyFavourite];
            }
            [arrData replaceObjectAtIndex:favIndex withObject:dic];
            [_collectionView reloadData];
            
        }else if([[result objectForKey:keyCode] isEqualToString:keyError]){
            [self.view makeToast:[result valueForKey:keyValue]];
        }else{
            // force login
            [self.view makeToast:kServerError];
        }
    }
    else if(tag==TAG_MD_REMOVE_FAVOURITE_BTN)
    {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
        {
            [self.view makeToast:[result valueForKey:keyValue]];
            NSMutableDictionary *dic= [arrData objectAtIndex:favIndex];
            if([[dic valueForKey:keyFavourite] intValue]==1)
            {
                [dic setObject:[NSNumber numberWithInt:0] forKey:keyFavourite];
            }
            else
            {
                [dic setObject:[NSNumber numberWithInt:1] forKey:keyFavourite];
            }
            [arrData replaceObjectAtIndex:favIndex withObject:dic];
            [_collectionView reloadData];
        }else if([[result objectForKey:keyCode] isEqualToString:keyError]){
            [self.view makeToast:[result valueForKey:keyValue]];
        }else{
            // force login
            [self.view makeToast:kServerError];
        }
    }

}

#pragma mark - Layout Methods
-(void)setupLayoutMethods
{
    UIView *lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
    NSInteger yPos = lbl.frame.origin.y+lbl.frame.size.height+10;
    [self setViewImage:[UIImage imageNamed:@"icon_newrelease"] withTitle:NSLocalizedString(@"txtNewReleaseTitle", nil)];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        yPos = lbl.frame.origin.y;
        [self hideImageAndTitle];
    }
    [self resetTopViewLogoFrameForOrientation:orientation withImage:[UIImage imageNamed:@"icon_newrelease"] withTitle:NSLocalizedString(@"txtNewReleaseTitle", nil)];

    UICollectionViewFlowLayout *viewLayout = [[UICollectionViewFlowLayout alloc]init];
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, yPos, self.view.frame.size.width - 20, self.view.frame.size.height-yPos) collectionViewLayout:viewLayout];
    [_collectionView setShowsVerticalScrollIndicator:NO];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    [_collectionView setTag:TAG_REL_MAIN];
    [self.view addSubview:_collectionView];
    
    //Pull to refresh
    __unsafe_unretained typeof(self) weakSelf = self;
    [_collectionView addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];

}
#pragma mark - UICollection Delegates
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [arrData count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[UICollectionViewCell alloc]init];
    }
    [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
    [cell.contentView setBackgroundColor:[UIColor clearColor]];

    UIView *view = [cell viewWithTag:TAG_REL_CELL];
    if (!view) {
        
        [self createCell:cell withData:[arrData objectAtIndex:indexPath.item] IndexPath:indexPath];
    }
    else
    {
        [self reuseCell:cell withData:[arrData objectAtIndex:indexPath.item] IndexPath:indexPath];
       // [self createCell:cell withData:[arrData objectAtIndex:indexPath.item] IndexPath:indexPath];
    }

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
    movieDetailsVC.viewType = ViewTypeList; // not neccessary
    [self.navigationController pushViewController:movieDetailsVC animated:YES];
}

-(UILabel *)createLabelWithFrame:(CGRect)frame withTXColor:(UIColor *)txcolor withText:(NSString *)lblTitle withFont:(UIFont *)font withTag:(int)tag withTextAlignment:(NSTextAlignment)alignment
{
    
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:frame] ;
    tempLabel.backgroundColor = [UIColor clearColor];
    tempLabel.textColor = txcolor;
    [tempLabel setText:lblTitle];
    [tempLabel setFont:font];
    [tempLabel setTag:tag];
    [tempLabel setTextAlignment:alignment];
    tempLabel.numberOfLines = 0;
    return tempLabel;
}

-(void)createCell:(UICollectionViewCell *)baseView withData:(NSDictionary *)withData IndexPath:(NSIndexPath *)indexPath
{
     UIButton *tempButton = [UIButton buttonWithType:UIButtonTypeCustom];
     [tempButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin |
     UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth |
     UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin];
    
    [tempButton setFrame:CGRectMake(0, 0, baseView.frame.size.width ,baseView.frame.size.height)];
    [tempButton setBackgroundColor:[UIColor whiteColor]];
    [tempButton setTag:TAG_REL_CELL];
    [tempButton setUserInteractionEnabled:NO];
    [baseView addSubview:tempButton];
    
    CGFloat Gap = 5;
    CGFloat imageWidth = (iPhone?91:91) ;
    CGFloat otherViewX= imageWidth+Gap;
    CGFloat otherViewWidth = baseView.frame.size.width - imageWidth -(2*Gap)+5;
    CGFloat Height = baseView.frame.size.height;

    IMDEventImageView *icon_View = [APPDELEGATE createEventImageViewWithFrame:CGRectMake(0, 0, imageWidth ,Height) withImageURL:[withData valueForKey:keyPoster] Placeholder:kPlaceholderImg tag:TAG_REL_ICON_VIEW];
    [icon_View setContentMode:UIViewContentModeScaleAspectFill];
    [icon_View setClipsToBounds:YES];
    [tempButton addSubview:icon_View];
    
    UIView *otherView =[self CreateDiscriptionViewWithFrame:CGRectMake(otherViewX, Gap/2, otherViewWidth, Height) withData:withData];
    [otherView setTag:TAG_REL_OTHER_VIE];
    [otherView setBackgroundColor:[UIColor clearColor]];
   // [otherView setUserInteractionEnabled:NO];
    [baseView addSubview:otherView];
}

-(UIButton *)createButtonWithFrame:(CGRect)frame withData:(NSDictionary *)dictionary withBgColor:(UIColor*)clr
{
    UIButton *tempButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tempButton setFrame:frame];
    [tempButton setBackgroundColor:clr];
    [tempButton setTag:TAG_REL_CELL];
    return tempButton;
}

-(UIView *)CreateDiscriptionViewWithFrame:(CGRect)frame withData:(NSDictionary *)dictionary{
   
    UIView *innerView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:frame bgColor:[UIColor clearColor] tag:TAG_REL_OTHER_VIE alpha:1.0];
    
    CGFloat gap = 0;
    CGFloat YPOS = 0;
    CGFloat lblHeight =(iPad?25:15);
    UILabel *lblMoviewTitle = [self createLabelWithFrame:CGRectMake(gap, YPOS, frame.size.width - 2*gap, lblHeight)  withTXColor:[UIColor grayColor] withText:[dictionary valueForKey:keyItemTitle] withFont:[APPDELEGATE Fonts_OpenSans_Light:(iPad?17:12)] withTag:TAG_REL_MOV_TITLE withTextAlignment:NSTextAlignmentLeft];
    [lblMoviewTitle setNumberOfLines:1];
    [innerView addSubview:lblMoviewTitle];
    YPOS = lblMoviewTitle.frame.origin.y+lblMoviewTitle.frame.size.height+(iPhone?3:5);

    CGFloat itemRate = [[dictionary valueForKey:keyItemRate] floatValue];
    [self addStart:innerView withYpostion:YPOS withPoint:itemRate*10];
    
    UILabel *lblRating = [self createLabelWithFrame:CGRectMake(innerView.frame.size.width/2.0-(iPad?10:3), YPOS-2, innerView.frame.size.width/2.0, lblHeight)  withTXColor:[UIColor blackColor] withText:[NSString stringWithFormat:@"Rated:%@", [dictionary valueForKey:keyItemRating]] withFont:[APPDELEGATE Fonts_OpenSans_Regular:(iPad?17:10)] withTag:TAG_REL_LBL_RETTING withTextAlignment:NSTextAlignmentRight];
    [lblRating setNumberOfLines:1];
    [innerView addSubview:lblRating];
    YPOS = lblRating.frame.origin.y + lblRating.frame.size.height+(iPhone?0:5);
    
    UILabel *lblDescription = [self createLabelWithFrame:CGRectMake(gap, YPOS, innerView.frame.size.width-gap*2-(iPad?10:3), (iPhone?(innerView.frame.size.height/2):20))  withTXColor:[UIColor blackColor] withText:[NSString stringWithFormat:@"%@", [dictionary valueForKey:keyItemDescription]] withFont:[APPDELEGATE Fonts_OpenSans_Regular:(iPad?17:10)] withTag:TAG_REL_LBL_DESCRIPTION withTextAlignment:NSTextAlignmentLeft];
    if(iPad)
    {
        [lblDescription setNumberOfLines:1];
    }
    [innerView addSubview:lblDescription];
    YPOS = lblDescription.frame.origin.y + lblDescription.frame.size.height;
    
    gap = 5;
    UIColor *purchaseColor = [UIColor colorWithRed:0.0/255.0 green:51.0/255.0 blue:153.0/255.0 alpha:1.0];
    CustomButton *button1 = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(0, innerView.frame.size.height - gap -((iPad?25:20)) , innerView.frame.size.width/3+(iPhone?5:0),(iPad?25:20)) withTitle:@"More Details" withImage:nil withTag:TAG_PURCHASE Font:[APPDELEGATE Fonts_OpenSans_Regular:(iPad?12:7)] BGColor:purchaseColor];
    [button1 setButtonTag:[[dictionary valueForKey:keyId] intValue]];
    [button1 setUserInteractionEnabled:FALSE];
    [innerView addSubview:button1];
    
    
        //remove from favourite
        CustomButton *btnFovourite = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(innerView.frame.size.width-gap*2-(iPad?10:3)-10,innerView.frame.size.height - gap -((iPad?25:20)), (iPad ? 20 : 20), (iPad ? 20 : 20)) withTitle:nil withImage:[UIImage imageNamed:@"movie_frv_select"] withTag:TAG_MD_REMOVE_FAVOURITE_BTN Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:nil];
        [btnFovourite.dictData setValue:[dictionary valueForKey:keyId] forKey:KeyButtonValue];
        btnFovourite.buttonTag = TAG_MD_REMOVE_FAVOURITE_BTN;
        [btnFovourite addTarget:self action:@selector(detailVideoAction:) forControlEvents:UIControlEventTouchUpInside];
        [innerView addSubview:btnFovourite];
    
        //add as a favourite
        CustomButton *btnFovourite1 = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(innerView.frame.size.width-gap*2-(iPad?10:3)-10,innerView.frame.size.height - gap -((iPad?25:20)), (iPad ? 20 : 20), (iPad ? 20 : 20)) withTitle:nil withImage:[UIImage imageNamed:@"movie_frv_unselect"] withTag:TAG_MD_FAVOURITE_BTN Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:nil];
        [btnFovourite1.dictData setValue:[dictionary valueForKey:keyId] forKey:KeyButtonValue];
        btnFovourite1.buttonTag = TAG_MD_FAVOURITE_BTN;
        [btnFovourite1 addTarget:self action:@selector(detailVideoAction:) forControlEvents:UIControlEventTouchUpInside];
        [innerView addSubview:btnFovourite1];
   
    
    if([[dictionary valueForKey:keyFavourite]boolValue]==YES)
    {
        btnFovourite1.hidden=TRUE;
        btnFovourite.hidden=FALSE;
    }
    else
    {
        btnFovourite.hidden=TRUE;
        btnFovourite1.hidden=FALSE;
        
    }


    return innerView;
    
}
-(void)detailVideoAction:(CustomButton *)btn
{
   
    favIndex = [arrData indexOfObjectPassingTest:
                ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop)
                {
                    return [[dict objectForKey:keyId] isEqual:[btn.dictData valueForKey:KeyButtonValue]];
                }
                ];
    
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    
    switch (btn.buttonTag) {
        case TAG_MD_FAVOURITE_BTN:
        {
           
            NSString *strRequest =[NSString stringWithFormat:NSLocalizedString(@"apiFavouriteMovie", nil), [btn.dictData valueForKey:KeyButtonValue], [APPDELEGATE getAppToken]];;
            [self request:strRequest withTag:TAG_MD_FAVOURITE_BTN customBtn:btn];
        }
            break;
        case TAG_MD_REMOVE_FAVOURITE_BTN:
        {
            
            NSString *strRequest =[NSString stringWithFormat:NSLocalizedString(@"apiRemoveFavouriteMovie", nil), [btn.dictData valueForKey:KeyButtonValue], [APPDELEGATE getAppToken]];;
            [self request:strRequest withTag:TAG_MD_REMOVE_FAVOURITE_BTN customBtn:btn];
        }
            break;
        default:
            break;
    }
}
- (void)request:(NSString *)currentReq withTag:(int)tag customBtn:(CustomButton *)btn
{
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }

    IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
    NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
    //if(tag==kTAG_MOVIE_VIEW_COUNT)
    //{
    //    apiUrl = NSLocalizedString(@"appAjaxApi", nil);
    //}
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strParameter = [NSString stringWithFormat:currentReq, [btn.dictData valueForKey:KeyButtonValue], [APPDELEGATE getAppToken]];
    strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], strParameter];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl]];
    NSData *postData = [NSData dataWithBytes:[strParameter UTF8String] length:[strParameter length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:tag];
    [requestConnection startAsynchronousRequest];
    
    [SEGBIN_SINGLETONE_INSTANCE addLoader];
}

#pragma mark -
#pragma mark reuse Cell

-(void)reuseCell:(UICollectionViewCell *)baseView withData:(NSDictionary *)withData IndexPath:(NSIndexPath *)indexPath{
    
    UIButton *view = (UIButton *)[baseView viewWithTag:TAG_REL_CELL];
    
    CGFloat Gap = 5;
    CGFloat imageWidth = (iPhone?91:91);
    CGFloat otherViewX=imageWidth+Gap;
    CGFloat otherViewWidth = baseView.frame.size.width - imageWidth -(2*Gap)+5;
    CGFloat Height = baseView.frame.size.height;
    
    
    [view setFrame:CGRectMake(0, 0, baseView.frame.size.width ,baseView.frame.size.height)];
    
    IMDEventImageView *icon_View = (IMDEventImageView *)[view viewWithTag:TAG_REL_ICON_VIEW];
    [icon_View setFrame:CGRectMake(0, 0, imageWidth ,Height)];
    [icon_View setImageWithURL:[withData valueForKey:keyPoster] placeholderImage:kPlaceholderImg];
    
    
    UIView *otherView =[baseView viewWithTag:TAG_REL_OTHER_VIE];
    [otherView setFrame:CGRectMake(otherViewX, Gap/2, otherViewWidth, Height)];
    
    CGFloat gap = 0;
    CGFloat YPOS = 0;
    CGFloat lblHeight =(iPad?25:15);
    
    UILabel *lblMoviewTitle = (UILabel *) [otherView viewWithTag:TAG_REL_MOV_TITLE];
    [lblMoviewTitle setFrame:CGRectMake(gap, YPOS, otherView.frame.size.width -2*gap, lblHeight)];
    [lblMoviewTitle setText:[withData valueForKey:keyItemTitle]];
    YPOS = lblMoviewTitle.frame.origin.y + lblMoviewTitle.frame.size.height+(iPhone?3:5);
    
    CGFloat itemRate = [[withData valueForKey:keyItemRate] floatValue];
    [self reuseStart:otherView withYpostion:YPOS withPoint:itemRate*10];
    
    UILabel *lblRating = (UILabel *) [otherView viewWithTag:TAG_REL_LBL_RETTING];
    [lblRating setFrame:CGRectMake(otherView.frame.size.width/2.0-(iPad?10:3), YPOS-2, otherView.frame.size.width/2.0,lblHeight)];
    [lblRating setText:[NSString stringWithFormat:@"Rated:%@", [withData valueForKey:keyItemRating]]];
    YPOS = lblRating.frame.origin.y + lblRating.frame.size.height+(iPhone?0:5);
    
    UILabel *lblDescription = (UILabel *) [otherView viewWithTag:TAG_REL_LBL_DESCRIPTION];
    [lblDescription setFrame:CGRectMake(gap, YPOS, otherView.frame.size.width-gap*2.0-(iPad?10:3), (iPhone?(otherView.frame.size.height/2):20))];
    [lblDescription setText:[NSString stringWithFormat:@"%@", [withData valueForKey:keyItemDescription]]];
    
    gap = 5;
    CustomButton *button1 = (CustomButton *)[otherView viewWithTag:TAG_PURCHASE];
    [button1 setButtonTag:[[withData valueForKey:keyId] intValue]];
    [button1 setFrame:CGRectMake(0, otherView.frame.size.height - gap -((iPad?25:20)), otherView.frame.size.width/3+(iPhone?5:0),(iPad?25:20))];
    
    /*UIButton *button2 = (UIButton *)[otherView viewWithTag:TAG_DOWNLOAD];
    [button2 setFrame:CGRectMake(otherView.frame.size.width/2 + gap, otherView.frame.size.height - gap*2 -((iPad?35:20)), otherView.frame.size.width/2 - gap*2,(iPad?35:20))];
    */
    
    CustomButton *btnFovourite1 =(CustomButton *)[otherView viewWithTag:TAG_MD_FAVOURITE_BTN];
    [btnFovourite1 setFrame:CGRectMake(otherView.frame.size.width-gap*2-(iPad?10:3)-10,otherView.frame.size.height - gap -((iPad?25:20)), (iPad ? 20 : 20), (iPad ? 20 : 20))];
    btnFovourite1.buttonTag = TAG_MD_FAVOURITE_BTN;
    [btnFovourite1 setImage:[UIImage imageNamed:@"movie_frv_unselect"] forState:UIControlStateNormal];
    [btnFovourite1.dictData setValue:[withData valueForKey:keyId] forKey:KeyButtonValue];
    [btnFovourite1 addTarget:self action:@selector(detailVideoAction:) forControlEvents:UIControlEventTouchUpInside];
    
   
    CustomButton *btnFovourite =(CustomButton *)[otherView viewWithTag:TAG_MD_REMOVE_FAVOURITE_BTN];
    [btnFovourite setFrame:CGRectMake(otherView.frame.size.width-gap*2-(iPad?10:3)-10,otherView.frame.size.height - gap -((iPad?25:20)), (iPad ? 20 : 20), (iPad ? 20 : 20))];
    btnFovourite.buttonTag = TAG_MD_REMOVE_FAVOURITE_BTN;
    [btnFovourite setImage:[UIImage imageNamed:@"movie_frv_select"] forState:UIControlStateNormal];
    [btnFovourite.dictData setValue:[withData valueForKey:keyId] forKey:KeyButtonValue];
    
    [btnFovourite addTarget:self action:@selector(detailVideoAction:) forControlEvents:UIControlEventTouchUpInside];

    
   
    
    if([[withData valueForKey:keyFavourite]boolValue]==YES)
    {
        btnFovourite1.hidden=TRUE;
        btnFovourite.hidden=FALSE;
    }
    else
    {
        btnFovourite.hidden=TRUE;
        btnFovourite1.hidden=FALSE;
        
    }
    
    
}




- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self viewItemSizefor:[UIApplication sharedApplication].statusBarOrientation];
}


#pragma mark -
#pragma mark Add and Reuse star
-(void)reuseStart:(UIView *)view withYpostion:(CGFloat)yPOS withPoint:(CGFloat)point{
    
    int totalPoint = point *10;
    int div = 100 ;
    
    int TotalDisplayStar = totalPoint/div;
    int TotalYellowStar = TotalDisplayStar / 2;
    int WhileStar =TotalDisplayStar%2;
    if (WhileStar == 0) {
        int count = 0;
        for (int yStar =0 ; yStar <TotalYellowStar ; yStar++) {
            
            UIImageView *imageView = (UIImageView *)[view viewWithTag:K_STAR_TAG +count];
            [imageView setImage:[UIImage imageNamed:@"star_score"]];
            count ++;
        }
        for (int dStar= 0; dStar < (5-TotalYellowStar) ; dStar++) {
            UIImageView *imageView = (UIImageView *)[view viewWithTag:K_STAR_TAG +count];
            [imageView setImage:[UIImage imageNamed:@"star_score1"]];
            count ++;
            
            //count++;
        }
        
    }
    else
    {
        
        
        int count = 0;
        for (int yStar =0 ; yStar <TotalYellowStar ; yStar++)
        {
            UIImageView *imageView = (UIImageView *)[view viewWithTag:K_STAR_TAG +count];
            [imageView setImage:[UIImage imageNamed:@"star_score"]];
            count ++;
        }
        UIImageView *imageView = (UIImageView *)[view viewWithTag:K_STAR_TAG +count];
        [imageView setImage:[UIImage imageNamed:@"HelfStar"]];
        count ++;
        
        int reminStar = count;
        for (int dStar= 0; dStar < (5-reminStar) ; dStar++) {
            UIImageView *imageView =(UIImageView *)[view viewWithTag:K_STAR_TAG + count];
            [imageView setImage:[UIImage imageNamed:@"star_score1"]];
            count ++;
        }
        
    }
}



-(void)addStart:(UIView *)view withYpostion:(CGFloat)yPOS withPoint:(CGFloat)point{
    
    int totalPoint = point *10;
    int div = 100 ;
    
    int TotalDisplayStar = totalPoint/div;
    int TotalYellowStar = TotalDisplayStar / 2;
    int WhileStar =TotalDisplayStar%2;
    
    CGFloat Xpos = (iPad?0:0);
    CGFloat GAP  = (iPad?5:1);
    CGFloat Height = (iPad?20:10);
    if (WhileStar == 0) {
        
        
        int count = 0;
        for (int yStar =0 ; yStar <TotalYellowStar ; yStar++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(Xpos, yPOS, Height, Height)];
            [imageView setImage:[UIImage imageNamed:@"star_score"]];
            [imageView setTag:K_STAR_TAG +count];
            [view addSubview:imageView];
            Xpos = Xpos +GAP + Height;
            count ++;
        }
        
        for (int dStar= 0; dStar < (5-TotalYellowStar) ; dStar++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(Xpos, yPOS, Height, Height)];
            [imageView setImage:[UIImage imageNamed:@"star_score1"]];
            [imageView setTag:K_STAR_TAG +count];
            [view addSubview:imageView];
            Xpos = Xpos+GAP + Height;
            count ++;
            
        }
        
        
    }
    else
    {
        int count = 0;
        for (int yStar =0 ; yStar <TotalYellowStar ; yStar++)
        {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(Xpos, yPOS, Height, Height)];
            [imageView setImage:[UIImage imageNamed:@"star_score"]];
            [imageView setTag:K_STAR_TAG +count];
            [view addSubview:imageView];
            Xpos = Xpos +GAP + Height;
            
            count ++;
        }
        
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(Xpos, yPOS, Height, Height)];
        [imageView setImage:[UIImage imageNamed:@"HelfStar"]];
        [imageView setTag:K_STAR_TAG +count];
        [view addSubview:imageView];
        Xpos = Xpos +GAP + Height;
        count ++;
        
        int reminStar = count;
        for (int dStar= 0; dStar < (5-reminStar) ; dStar++)
        {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(Xpos, yPOS, Height, Height)];
            [imageView setImage:[UIImage imageNamed:@"star_score1"]];
            [imageView setTag:K_STAR_TAG +count];
            [view addSubview:imageView];
            Xpos = Xpos +GAP + Height;
            count ++;
        }
    }
}



#pragma mark -
#pragma mark change size

/*
-(CGSize)viewItemSizefor:(UIInterfaceOrientation)toOrientation
{
    if (iPad)
    {
        if (UIInterfaceOrientationIsLandscape(toOrientation))
        {
            return CGSizeMake(480, 148);
        }
        else
        {
            return CGSizeMake(719, 148);
        }
    }
    else
    {
        if (UIInterfaceOrientationIsLandscape(toOrientation))
        {
            
            if (IS_IPHONE_5)
            {
                return  CGSizeMake(258, 80);
            }
            else
            {
                return CGSizeMake(215, 75);
            }
        }
        else
        {
            return  CGSizeMake(280, 82);
        }
    }
}*/
-(CGSize)viewItemSizefor:(UIInterfaceOrientation)toOrientation
{
    if (iPad)
    {
        if (UIInterfaceOrientationIsLandscape(toOrientation))
        {
            return CGSizeMake(480, 120); // 148
        }
        else
        {
            return CGSizeMake(719, 120); //148
        }
    }
    else
    {
        if (UIInterfaceOrientationIsLandscape(toOrientation))
        {
            
            if (IS_IPHONE_5_GREATER)
            {
                return  CGSizeMake(258, 120);//80
            }
            else
            {
                return CGSizeMake(215, 120);//75
            }
        }
        else
        {
            return  CGSizeMake(280, 120); //82
        }
    }
}

// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 20, 10);
}
#pragma mark - Rotation Method

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{

}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self reloadCollectionView:toInterfaceOrientation];
}

- (void)reloadCollectionView:(UIInterfaceOrientation)toInterfaceOrientation
{
    UICollectionViewFlowLayout *Layout = (UICollectionViewFlowLayout *) _collectionView.collectionViewLayout;
    
    Layout.itemSize = [self viewItemSizefor:toInterfaceOrientation];
    [Layout invalidateLayout];
    [_collectionView reloadData];
    
    //==========================
    UIView *lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
    NSInteger yPos = lbl.frame.origin.y+lbl.frame.size.height+10;
    [self setViewImage:[UIImage imageNamed:@"icon_newrelease"] withTitle:NSLocalizedString(@"txtNewReleaseTitle", nil)];
    
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        yPos = lbl.frame.origin.y;
        [self hideImageAndTitle];
    }
    
    _collectionView.frame = CGRectMake(10, yPos, self.view.frame.size.width - 20, self.view.frame.size.height-yPos);
    [self resetTopViewLogoFrameForOrientation:toInterfaceOrientation withImage:[UIImage imageNamed:@"icon_newrelease"] withTitle:NSLocalizedString(@"txtNewReleaseTitle", nil)];
}

#pragma mark PULL TO REFRESH
-(void)insertRowAtTop
{
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    isRefresh = YES;
    moviePageNo = 1;
    [self getApiData];
}
#pragma mark LOAD MORE
-(void)insertRowAtBottom
{
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    
    if(isRefresh)
    {
        return;
    }
    
    //send request for Load more data
    if ([arrData count] !=  totalCount)
    {
        [_collectionView.infiniteScrollingView setHidden:NO];
        [_collectionView setShowsInfiniteScrolling:YES];
        moviePageNo = moviePageNo + 1;
        [self getApiData];
    }
    else
    {
        [_collectionView.infiniteScrollingView setHidden:YES];
    }
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
    NSLog(@"ReleaseViewController dealloc called");
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
