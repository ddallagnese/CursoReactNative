//
//  MovieListViewController.m
//  Sagebin
//
//  
//

#import "MovieListViewController.h"
#import "MovieDetailsViewController.h"
#import "FriendListVC.h"
#import "CastViewController.h"
#import "DeviceTableViewController.h"
#import "ContactListViewController.h"

#define K_STAR_TAG 756894

@interface MovieListViewController () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
    
    NSMutableArray *arrData,*sendMovieList;
    __weak ChromecastDeviceController *_chromecastController;
}

@end

@implementation MovieListViewController
@synthesize movieList;

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
    
    //[self setViewImage:[UIImage imageNamed:@"icon_friendlist"] withTitle:NSLocalizedString(@"txtFrienTitle", nil)];
    //[self.view setBackgroundColor:FriendViewBgColor];
    
    arrData = [[NSMutableArray alloc]init];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:keyIsAlertAvailable])
    {
        [self.alertButton setHidden:YES];
    }
    
    if(arrData.count == 0)
    {
        switch (movieList) {
            case TYPE_FRIEND_MOVIE:
            {
                [self setViewImage:[UIImage imageNamed:@"friends-movies"] withTitle:NSLocalizedString(@"friendMoviesTitle", nil)];
                [self.view setBackgroundColor:FriendMoviesViewBgColor];
                [self setSagebinLogoInCenterForOrientation:[UIApplication sharedApplication].statusBarOrientation];
                [self setFriendsBtnFrameForOrientation:[UIApplication sharedApplication].statusBarOrientation];
                [self.friendsButton addTarget:self action:@selector(btnFriendsClicked:) forControlEvents:UIControlEventTouchUpInside];
                
                if(APPDELEGATE.netOnLink == 0)
                {
                    [self.view makeToast:WARNING];
                    return;
                }
                moviePageNo = 1;
                movieCount = 10;
                [self getApiDataWithTag:kTAG_FRIEND_MOVIE];
            }
                break;
                
            case TYPE_MY_MOVIE:
            {
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
                
                [self.view setBackgroundColor:MyMoviesViewBgColor];
                if(APPDELEGATE.netOnLink == 0)
                {
                    [self.view makeToast:WARNING];
                    return;
                }
                moviePageNo = 1;
                movieCount = 10;
                [self getApiDataWithTag:kTAG_MY_MOVIE];
            }
                break;
            case TYPE_BIN_MOVIE:
            {
                [self setViewImage:[UIImage imageNamed:@"bin"] withTitle:NSLocalizedString(@"BinMoviesTitle", nil)];
                [self.view setBackgroundColor:SearchMoviesViewBgColor];
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
                moviePageNo = 1;
                movieCount = 10;
                [self getApiDataWithTag:kTAG_BIN_MOVIE];
            }
                break;
            case TYPE_FAV_MOVIE:
            {
                [self setViewImage:[UIImage imageNamed:@"fev"] withTitle:NSLocalizedString(@"FavouoriteMoviesTitle", nil)];
                [self.view setBackgroundColor:NewsViewBgColor];
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
                moviePageNo = 1;
                movieCount = 10;
                [self getApiDataWithTag:kTAG_FAV_MOVIE];
            }
                break;
            case TYPE_GIVE_MOVIE:
            {
                [self.claimButton setHidden:NO];
                [self.alertButton setHidden:YES];
                 [self setSagebinLogoInCenterForOrientation:[UIApplication sharedApplication].statusBarOrientation];
                [self setViewImage:nil withTitle:[NSString stringWithFormat:@"PICK %@ MOVIES,GIVE ONE AWAY",[[NSUserDefaults standardUserDefaults] valueForKey:keymovie_credits]]];
                
                UIView *lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
                [lbl setFrame:CGRectMake(lbl.frame.origin.x, lbl.frame.origin.y, (iPad?400:250), lbl.frame.size.height)];
                
                [self.view setBackgroundColor:SearchMoviesViewBgColor];
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
                moviePageNo = 1;
                movieCount = 10;
                [self getApiDataWithTag:kTAG_BIN_MOVIE];
            }
                break;
            case TYPE_GIVE_MOVIE_FRIEND:
            {
                [self.alertButton setHidden:YES];
                [self setSagebinLogoInCenterForOrientation:[UIApplication sharedApplication].statusBarOrientation];
                [self setViewImage:nil withTitle:@"TAP ON MOVIE TO GIVE FRIEND"];
                
                UIView *lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
                [lbl setFrame:CGRectMake(lbl.frame.origin.x, lbl.frame.origin.y, (iPad?400:250), lbl.frame.size.height)];
                
                [self.view setBackgroundColor:SearchMoviesViewBgColor];
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
                moviePageNo = 1;
                movieCount = 10;
                [self getApiDataWithTag:kTAG_BIN_MOVIE];
            }
                break;
                
            default:
                break;
        }
        
        [self setupLayoutMethods];
    }
    else
    {
        [self reloadCollectionView:[UIApplication sharedApplication].statusBarOrientation];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
   // [self setSagebinLogoInCenterForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

-(void)getApiDataWithTag:(int)tag
{
    IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
    NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strParameter;
    if(tag == kTAG_MY_MOVIE)
    {
        //strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], NSLocalizedString(@"apiMyMovie", nil)];
        strParameter = [NSString stringWithFormat:NSLocalizedString(@"apiMyMovie", nil), moviePageNo, movieCount];
        strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], strParameter];
    }
    else if(tag == kTAG_BORROWED_MOVIE)
    {
        strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], NSLocalizedString(@"apiBorrowedMovie", nil)];
    }
    else if(tag == kTAG_FRIEND_MOVIE)
    {
        strParameter = [NSString stringWithFormat:NSLocalizedString(@"apiFriendMovie", nil), moviePageNo, movieCount];
        strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], strParameter];
    }
    else if (tag==kTAG_BIN_MOVIE)
    {
        strParameter = [NSString stringWithFormat:NSLocalizedString(@"apiBINMovie", nil), moviePageNo, movieCount];
        strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], strParameter];
    }
    else if (tag==kTAG_FAV_MOVIE)
    {
        strParameter = [NSString stringWithFormat:NSLocalizedString(@"apiFavMovieList", nil), moviePageNo, movieCount];
        strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], strParameter];
    }
    else if (tag==kTAG_CLAIM_MOVIE)
    {
        NSString *tempmovieList;
        tempmovieList=@"";
        for (int i=0; i<[sendMovieList count]; i++)
        {
            if (i==[sendMovieList count]-1)
            {
                tempmovieList=[tempmovieList stringByAppendingString:[NSString stringWithFormat:@"%@",[sendMovieList objectAtIndex:i]]];
            }
            else
            {
                tempmovieList=[tempmovieList stringByAppendingString:[NSString stringWithFormat:@"%@,",[sendMovieList objectAtIndex:i]]];
            }
            
        }

        
        strParameter = [NSString stringWithFormat:NSLocalizedString(@"apiClaimedMovie", nil), tempmovieList]; //162
        strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], strParameter];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl]];
    NSData *postData = [NSData dataWithBytes:[strParameter UTF8String] length:[strParameter length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:tag];
    [requestConnection startAsynchronousRequest];
    
    if(arrData.count == 0)
    {
        [SEGBIN_SINGLETONE_INSTANCE addLoader];
    }
    [self enableDisableUI:NO];
}

-(void)enableDisableUI:(BOOL)status
{
    [self.rightButton setUserInteractionEnabled:status];
    [self.friendsButton setUserInteractionEnabled:status];
}
-(void)detailVideoAction:(CustomButton *)btn
{

    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    
    favIndex = [arrData indexOfObjectPassingTest:
                        ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop)
                        {
                            return [[dict objectForKey:keyId] isEqual:[btn.dictData valueForKey:KeyButtonValue]];
                        }
                        ];
    
    
  
   
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
-(void)btnClaimClicked:(UIButton *)button
{
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
     NSLog(@"%d",[[[NSUserDefaults standardUserDefaults] valueForKey:keymovie_credits]intValue]);
    if(sendMovieList.count==0)
    {
        [self.view makeToast:@"Please select atleast one movie"];
        return;
    }
    else if(sendMovieList.count>5)
    {
        [self.view makeToast:@"You can't select more than 5 movie"];
        return;
    }
    else if([[[NSUserDefaults standardUserDefaults] valueForKey:keymovie_credits]intValue] == 0 || [[[NSUserDefaults standardUserDefaults] valueForKey:keymovie_credits]intValue]<sendMovieList.count)
    {
        [self.view makeToast:@"You dont have sufficient movie creadit for movies"];
        return;
    }
    else
    {
         [SEGBIN_SINGLETONE_INSTANCE addLoader];
        [self getApiDataWithTag:kTAG_CLAIM_MOVIE];
    }
}
#pragma mark - IMDHTTPRequest Delegates
-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didFailWithError:(NSError*)error withTag:(int)tag
{
    [self.view makeToast:kServerError];
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    isRefresh = NO;
    [self enableDisableUI:YES];
}

-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didSuccessWithItems:(NSObject*)items withData:(NSData*)data withTag:(int)tag
{
    [self enableDisableUI:YES];
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    
    if (tag==kTAG_MY_MOVIE)
    {
        NSDictionary *result = (NSDictionary *)items;
        if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
        {
            [self checkUserAlert:[result objectForKey:keyAlerts]];
            if([result valueForKey:keyValue] == [NSNull null] || [[result valueForKey:keyValue] count] == 0)
            {
                if(arrData.count == 0)
                {
                    [self.view makeToast:NSLocalizedString(@"noMoviesAvailable", nil)];
                    
                }else
                {
                    [_collectionView reloadData];
                }
                [_collectionView.pullToRefreshView stopAnimating];
                [_collectionView.infiniteScrollingView stopAnimatingWithNoUpdate];
                [_collectionView setShowsInfiniteScrolling:NO];
            }
            else{
                if(isRefresh)
                {
                    [arrData removeAllObjects];
                    isRefresh = NO;
                }
                totalCount = [[result valueForKey:keyTotalCount] intValue];
                [arrData addObjectsFromArray:[result objectForKey:keyValue]];
                [_collectionView reloadData];
                //[self getApiDataWithTag:kTAG_BORROWED_MOVIE];
                
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
        }
        else
        {
            [self.view makeToast:kServerError];
            [_collectionView.pullToRefreshView stopAnimating];
            [_collectionView.infiniteScrollingView stopAnimatingWithNoUpdate];
            [_collectionView setShowsInfiniteScrolling:NO];
        }
    }
    if (tag==kTAG_BIN_MOVIE)
    {
        NSDictionary *result = (NSDictionary *)items;
        if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
        {
            if(movieList==TYPE_GIVE_MOVIE)
            {
                [self.alertButton setHidden:YES];
                [self.claimButton setHidden:NO];
                [self.claimButton addTarget:self action:@selector(btnClaimClicked:) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                [self checkUserAlert:[result objectForKey:keyAlerts]];
            }
            
            if([result valueForKey:keyValue] == [NSNull null] || [[result valueForKey:keyValue] count] == 0)
            {
                if(arrData.count == 0)
                {
                    [self.view makeToast:NSLocalizedString(@"noMoviesAvailable", nil)];
                    
                }else{
                    [_collectionView reloadData];
                }
                [_collectionView.pullToRefreshView stopAnimating];
                [_collectionView.infiniteScrollingView stopAnimatingWithNoUpdate];
                [_collectionView setShowsInfiniteScrolling:NO];
            }
            else{
                if(isRefresh)
                {
                    [arrData removeAllObjects];
                    isRefresh = NO;
                }
                totalCount = [[result valueForKey:keyTotalCount] intValue];
                [arrData addObjectsFromArray:[result objectForKey:keyValue]];
                [_collectionView reloadData];
                //[self getApiDataWithTag:kTAG_BORROWED_MOVIE];
                
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
        }
        else
        {
            [self.view makeToast:kServerError];
            [_collectionView.pullToRefreshView stopAnimating];
            [_collectionView.infiniteScrollingView stopAnimatingWithNoUpdate];
            [_collectionView setShowsInfiniteScrolling:NO];
        }
    }
    if (tag==kTAG_FAV_MOVIE)
    {
        NSDictionary *result = (NSDictionary *)items;
        if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
        {
            [self checkUserAlert:[result objectForKey:keyAlerts]];
            if([result valueForKey:keyValue] == [NSNull null] || [[result valueForKey:keyValue] count] == 0)
            {
                if(arrData.count == 0)
                {
                    [self.view makeToast:NSLocalizedString(@"noMoviesAvailable", nil)];
                    
                }else{
                    [_collectionView reloadData];
                }
                [_collectionView.pullToRefreshView stopAnimating];
                [_collectionView.infiniteScrollingView stopAnimatingWithNoUpdate];
                [_collectionView setShowsInfiniteScrolling:NO];
            }
            else{
                if(isRefresh)
                {
                    [arrData removeAllObjects];
                    isRefresh = NO;
                }
                totalCount = [[result valueForKey:keyTotalCount] intValue];
                [arrData addObjectsFromArray:[result objectForKey:keyValue]];
                [_collectionView reloadData];
                //[self getApiDataWithTag:kTAG_BORROWED_MOVIE];
                
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
        }
        else
        {
            [self.view makeToast:kServerError];
            [_collectionView.pullToRefreshView stopAnimating];
            [_collectionView.infiniteScrollingView stopAnimatingWithNoUpdate];
            [_collectionView setShowsInfiniteScrolling:NO];
        }
    }

    else if (tag==kTAG_BORROWED_MOVIE)
    {
        NSDictionary *result = (NSDictionary *)items;
        if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
        {
            [self checkUserAlert:[result objectForKey:keyAlerts]];
            if([result valueForKey:keyValue] == [NSNull null] || [[result valueForKey:keyValue] count] == 0)
            {
                if(arrData.count == 0)
                {
                    [self.view makeToast:NSLocalizedString(@"noMoviesAvailable", nil)];
                }else{
                    [_collectionView reloadData];
                }
            }
            else{
                totalCount = totalCount + [[result valueForKey:keyTotalCount] intValue];
                [arrData addObjectsFromArray:[result objectForKey:keyValue]];
                [_collectionView reloadData];
                
                
                if([arrData count] < totalCount)
                {
                    //Load more data
                    __unsafe_unretained typeof(self) weakSelf = self;
                    [_collectionView.infiniteScrollingView setHidden:YES];
                    [_collectionView addInfiniteScrollingWithActionHandler:^{
                        [weakSelf insertRowAtBottom];
                    }];
                }
            }
        }
        else
        {
            [self.view makeToast:kServerError];
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
    else if (tag==kTAG_FRIEND_MOVIE)
    {
        NSDictionary *result = (NSDictionary *)items;
        if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
        {
            [self checkUserAlert:[result objectForKey:keyAlerts]];
            if([result valueForKey:keyValue] == [NSNull null] || [[result valueForKey:keyValue] count] == 0)
            {
                if(arrData.count == 0)
                {
                    [self.view makeToast:NSLocalizedString(@"noMoviesAvailable", nil)];
                }else{
                    [_collectionView reloadData];
                }
                [_collectionView.pullToRefreshView stopAnimating];
                [_collectionView.infiniteScrollingView stopAnimatingWithNoUpdate];
                [_collectionView setShowsInfiniteScrolling:NO];
            }
            else{
                if(isRefresh)
                {
                    [arrData removeAllObjects];
                    isRefresh = NO;
                }
                [arrData addObjectsFromArray:[result objectForKey:keyValue]];
                totalCount = [[result valueForKey:keyTotalCount] intValue];
                [_collectionView reloadData];
                
                //
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
        }
        else
        {
            [self.view makeToast:kServerError];
            [_collectionView.pullToRefreshView stopAnimating];
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
            
            if(movieList == TYPE_FAV_MOVIE)
            {
                [arrData removeObjectAtIndex:favIndex];
            }
            else
            {
                [arrData replaceObjectAtIndex:favIndex withObject:dic];
            }
            
            [_collectionView reloadData];

            
        }else if([[result objectForKey:keyCode] isEqualToString:keyError]){
            [self.view makeToast:[result valueForKey:keyValue]];
        }else{
            // force login
            [self.view makeToast:kServerError];
        }
    }
    else if(tag==kTAG_CLAIM_MOVIE)
    {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
        {
            
            [[NSUserDefaults standardUserDefaults]setObject:[result valueForKey:keymovie_credits] forKey:keymovie_credits];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            [self setViewImage:nil withTitle:[NSString stringWithFormat:@"PICK %@ MOVIES,GIVE ONE AWAY",[[NSUserDefaults standardUserDefaults] valueForKey:keymovie_credits]]];
            
            [sendMovieList removeAllObjects];
            [_collectionView reloadData];
             [self.view makeToast:[result valueForKey:keyValue]];
        }
        else if([[result objectForKey:keyCode] isEqualToString:keyError])
        {
            [self.view makeToast:[result valueForKey:keyValue]];
        }
        else if([[result objectForKey:keyCode] isEqualToString:keyFailure])
        {
            [self.view makeToast:[result valueForKey:keyValue]];
        }

        else
        {
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
    
    if(movieList == TYPE_MY_MOVIE)
    {
        [self setViewImage:[UIImage imageNamed:@"my-movies"] withTitle:NSLocalizedString(@"myMoviesTitle", nil)];
        
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
        {
            yPos = lbl.frame.origin.y;
            [self hideImageAndTitle];
        }
        [self resetTopViewLogoFrameForOrientation:orientation withImage:[UIImage imageNamed:@"my-movies"] withTitle:NSLocalizedString(@"myMoviesTitle", nil)];
    }
    
    ProfileCollectionLayout *viewLayout = [[ProfileCollectionLayout alloc]init];
    //UICollectionViewFlowLayout *viewLayout = [[UICollectionViewFlowLayout alloc]init];
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, yPos, self.view.frame.size.width - 20, self.view.frame.size.height-yPos-10) collectionViewLayout:viewLayout];
    [_collectionView setShowsVerticalScrollIndicator:NO];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    [_collectionView setTag:TAG_ML_MAIN];
    [self.view addSubview:_collectionView];
    
    //Pull to refresh
     __unsafe_unretained typeof(self) weakSelf = self;
    [_collectionView addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
}
#pragma mark - UICollection Delegates
//- (void)viewWillLayoutSubviews
//{
//    [super viewWillLayoutSubviews];
//    [_collectionView.collectionViewLayout invalidateLayout];
//}

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
   [cell.contentView setBackgroundColor:[UIColor clearColor]];
    
    
  //  UIView *remocveMyview=(UIView *)[cell viewWithTag:TAG_ML_OTHER_VIE];
    
    
    UIButton *view = (UIButton *)[cell viewWithTag:TAG_ML_CELL];
   // [remocveMyview removeFromSuperview];
    if (!view) {
        
        [self createCell:cell withData:[arrData objectAtIndex:indexPath.item]];
    }
    else
    {
        
        [self reuseCell:cell withData:[arrData objectAtIndex:indexPath.item]];
       // [self createCell:cell withData:[arrData objectAtIndex:indexPath.item]];
        //[self createCell:cell withData:[arrData objectAtIndex:indexPath.item]];
        
    }
    
    return cell;
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

-(void)createCell:(UICollectionViewCell *)baseView withData:(NSDictionary *)withData {
    
    
    UIButton *tempButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tempButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin |
     UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth |
     UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin];
    
    [tempButton setFrame:CGRectMake(0, 0, baseView.frame.size.width ,baseView.frame.size.height)];
    [tempButton setBackgroundColor:[UIColor whiteColor]];
    [tempButton setTag:TAG_ML_CELL];
    [tempButton setUserInteractionEnabled:FALSE];
    [baseView addSubview:tempButton];
    
   
    if([sendMovieList containsObject:[withData valueForKey:@"id"]])
    {
        tempButton.backgroundColor=[UIColor colorWithRed:129.0/255 green:190.0/255 blue:247.0/255 alpha:1.0];
    }
    else
    {
        tempButton.backgroundColor=[UIColor whiteColor];
        // [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
    }
    

    
    
    CGFloat Gap = 5;
    //JM 1/7/2014
    CGFloat imageWidth = (iPhone?91:91) ;// (baseView.frame.size.width/4) + (baseView.frame.size.width/8);
    //
    CGFloat otherViewX= imageWidth+Gap;// (baseView.frame.size.width/4) + (baseView.frame.size.width/8) + (2*Gap) ;
    CGFloat otherViewWidth = baseView.frame.size.width - imageWidth -(Gap)+5;
    
    CGFloat Height = baseView.frame.size.height; // - Gap
    
    NSString *strImageURL = @"";
    if([withData objectForKey:keyPoster] != [NSNull null])
    {
        strImageURL = [withData objectForKey:keyPoster];
    }
    IMDEventImageView *icon_View =[APPDELEGATE createEventImageViewWithFrame:CGRectMake(0, 0, imageWidth ,Height) withImageURL:strImageURL Placeholder:kPlaceholderImg tag:TAG_ML_ICON_VIEW];
    //[icon_View setContentMode:UIViewContentModeScaleAspectFill];
    //[icon_View setClipsToBounds:YES];
    [tempButton addSubview:icon_View];
    
    if (![[withData objectForKey:keySaleFlag] isKindOfClass:[NSNull class]] && [[withData objectForKey:keySaleFlag] integerValue] == 1) {
        UIImage *image = [UIImage imageNamed:@"Sell.png"];
        UIImageView *sellImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageWidth - image.size.width -3, 2, image.size.width, image.size.height)];
        [sellImageView setImage:image];
        [sellImageView setTag:TAG_ML_IMGVW_SELL];
        [icon_View addSubview:sellImageView];
    }
    
    UIView *otherView =[self CreateDiscriptionViewWithFrame:CGRectMake(otherViewX, 0, otherViewWidth, Height) withData:withData];
    [otherView setTag:TAG_ML_OTHER_VIE];
    [baseView addSubview:otherView];
}

-(UIView *)CreateDiscriptionViewWithFrame:(CGRect)frame withData:(NSDictionary *)dictionary{
    
    UIView *innerView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:frame bgColor:[UIColor clearColor] tag:TAG_ML_OTHER_VIE alpha:1.0];
    
    CGFloat gap = (iPad?5:0);
    CGFloat YPOS = 5;
    CGFloat lblHeight =(iPad?20:15);
    UILabel *lblMoviewTitle = [self createLabelWithFrame:CGRectMake(gap, YPOS, frame.size.width - 2*gap, lblHeight)  withTXColor:[UIColor grayColor] withText:[dictionary valueForKey:keyTitle] withFont:[APPDELEGATE Fonts_OpenSans_Light:(iPad?17:12)] withTag:TAG_ML_LBL_TITLE withTextAlignment:NSTextAlignmentLeft];
    [lblMoviewTitle setNumberOfLines:1];
    [innerView addSubview:lblMoviewTitle];
    YPOS = lblMoviewTitle.frame.origin.y + lblMoviewTitle.frame.size.height+(iPhone?3:5); //(YPOS*2 + lblHeight);
    
    int ratePoint = [[dictionary objectForKey:keyItemRate] intValue];
    [self addStart:innerView withYpostion:YPOS withPoint:ratePoint*10];
    
    UILabel *lblRating = [self createLabelWithFrame:CGRectMake(innerView.frame.size.width/2.0-(iPad?10:3), YPOS-2, innerView.frame.size.width/2.0, lblHeight)  withTXColor:[UIColor blackColor] withText:[NSString stringWithFormat:@"Rated:%@", [dictionary valueForKey:keyItemRating]] withFont:[APPDELEGATE Fonts_OpenSans_Regular:(iPad?17:10)] withTag:TAG_ML_LBL_RATING withTextAlignment:NSTextAlignmentRight];
    [lblRating setNumberOfLines:1];
    [innerView addSubview:lblRating];
    YPOS = lblRating.frame.origin.y + lblRating.frame.size.height;
    
    UILabel *lblDescription = [self createLabelWithFrame:CGRectMake(gap, YPOS, innerView.frame.size.width-gap*2-(iPad?10:3)-20, innerView.frame.size.height-YPOS)  withTXColor:[UIColor blackColor] withText:[NSString stringWithFormat:@"%@", [dictionary valueForKey:keyDescription]] withFont:[APPDELEGATE Fonts_OpenSans_Regular:(iPad?15:10)] withTag:TAG_ML_LBL_DESCRIPTION withTextAlignment:NSTextAlignmentLeft];
    [innerView addSubview:lblDescription];
    YPOS = lblDescription.frame.origin.y + lblDescription.frame.size.height;
    
   
        //remove from favourite
        CustomButton *btnFovourite = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(gap+lblDescription.frame.size.width-(iPad?-5:1),innerView.frame.size.height  -((iPad?25:20)), (iPad ? 20 : 20), (iPad ? 20 : 20)) withTitle:nil withImage:[UIImage imageNamed:@"movie_frv_select"] withTag:TAG_MD_REMOVE_FAVOURITE_BTN Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:nil];
        [btnFovourite.dictData setValue:[dictionary valueForKey:keyId] forKey:KeyButtonValue];
        btnFovourite.buttonTag = TAG_MD_REMOVE_FAVOURITE_BTN;
        [btnFovourite addTarget:self action:@selector(detailVideoAction:) forControlEvents:UIControlEventTouchUpInside];
        [innerView addSubview:btnFovourite];
        
   
        //add as a favourite
        CustomButton *btnFovourite1 = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(gap+lblDescription.frame.size.width-(iPad?-5:1),innerView.frame.size.height -((iPad?25:20)), (iPad ? 20 : 20), (iPad ? 20 : 20)) withTitle:nil withImage:[UIImage imageNamed:@"movie_frv_unselect"] withTag:TAG_MD_FAVOURITE_BTN Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:nil];
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


#pragma mark -
#pragma mark reuse Cell
-(void)reuseCell:(UICollectionViewCell *)baseView withData:(NSDictionary *)withData
{
    //withData = [arrData objectAtIndex:indexPath.item];
    
    UIView *view = [baseView viewWithTag:TAG_ML_CELL];
    CGFloat Gap = 5;
    CGFloat imageWidth = (iPhone?91:91); //135
    CGFloat otherViewX=imageWidth+Gap;// (baseView.frame.size.width/4) + (baseView.frame.size.width/8) + (2*Gap) ;
    CGFloat otherViewWidth = baseView.frame.size.width - imageWidth -(2*Gap)+5;
    CGFloat Height = baseView.frame.size.height;// - Gap;
    
    [view setFrame:CGRectMake(0, 0, baseView.frame.size.width ,baseView.frame.size.height)];
    
    if([sendMovieList containsObject:[withData valueForKey:@"id"]])
    {
        view.backgroundColor=[UIColor colorWithRed:129.0/255 green:190.0/255 blue:247.0/255 alpha:1.0];
    }
    else
    {
        view.backgroundColor=[UIColor whiteColor];
        // [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
    }
    
    IMDEventImageView *icon_View = (IMDEventImageView *)[baseView viewWithTag:TAG_ML_ICON_VIEW];
    [icon_View setFrame:CGRectMake(0, 0, imageWidth ,Height)];
    NSString *strImageURL = @"";
    if([withData objectForKey:keyPoster] != [NSNull null])
    {
        strImageURL = [withData objectForKey:keyPoster];
    }
    [icon_View setImageWithURL:strImageURL placeholderImage:kPlaceholderImg];
    
    if (![[withData objectForKey:keySaleFlag] isKindOfClass:[NSNull class]] && [[withData objectForKey:keySaleFlag] integerValue] == 1) {
        UIImage *image = [UIImage imageNamed:@"Sell.png"];
        UIImageView *sellImageView = (UIImageView *)[icon_View viewWithTag:TAG_ML_IMGVW_SELL];
        if(sellImageView)
        {
            [sellImageView setFrame:CGRectMake(imageWidth - image.size.width -3, 2, image.size.width, image.size.height)];
            [sellImageView setHidden:NO];
        }
        else
        {
            sellImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageWidth - image.size.width -3, 2, image.size.width, image.size.height)];
            [sellImageView setImage:image];
            [sellImageView setTag:TAG_ML_IMGVW_SELL];
            [icon_View addSubview:sellImageView];
        }
    }
    else
    {
        UIImageView *sellImageView = (UIImageView *)[icon_View viewWithTag:TAG_ML_IMGVW_SELL];
        if(sellImageView)
        {
            [sellImageView setHidden:YES];
        }
    }
    
    UIView *otherView =[baseView viewWithTag:TAG_ML_OTHER_VIE];
    [otherView setFrame:CGRectMake(otherViewX, 0, otherViewWidth, Height)];
    
    CGFloat gap = (iPad?5:0);
    CGFloat YPOS = 5;
    CGFloat lblHeight =(iPad?20:15);
    
    UILabel *lblMoviewTitle = (UILabel *) [otherView viewWithTag:TAG_ML_LBL_TITLE];
    [lblMoviewTitle setFrame:CGRectMake(gap, YPOS, otherView.frame.size.width -2*gap, lblHeight)];
    [lblMoviewTitle setText:[withData valueForKey:keyTitle]];
    YPOS = lblMoviewTitle.frame.origin.y + lblMoviewTitle.frame.size.height+(iPhone?3:5); //(YPOS*2 + lblHeight);
    
    int ratePoint = [[withData objectForKey:keyItemRate] intValue];
    [self reuseStart:otherView withYpostion:YPOS withPoint:ratePoint*10];
    
    UILabel *lblRating = (UILabel *) [otherView viewWithTag:TAG_ML_LBL_RATING];
    [lblRating setFrame:CGRectMake(otherView.frame.size.width/2.0-(iPad?10:3), YPOS-2, otherView.frame.size.width/2.0, lblHeight)];
    [lblRating setText:[NSString stringWithFormat:@"Rated:%@", [withData valueForKey:keyItemRating]]];
    YPOS = lblRating.frame.origin.y + lblRating.frame.size.height;
    
    UILabel *lblDescription = (UILabel *) [otherView viewWithTag:TAG_ML_LBL_DESCRIPTION];
    [lblDescription setFrame:CGRectMake(gap, YPOS, otherView.frame.size.width-gap*2.0-(iPad?10:3)-20, otherView.frame.size.height-YPOS)];
    [lblDescription setText:[NSString stringWithFormat:@"%@", [withData valueForKey:keyDescription]]];
    
    
    CustomButton *btnFovourite1 =(CustomButton *)[otherView viewWithTag:TAG_MD_FAVOURITE_BTN];
    [btnFovourite1 setFrame:CGRectMake(otherView.frame.size.width-gap-(iPad?20:20),otherView.frame.size.height - gap -((iPad?25:20)), (iPad ? 20 : 20), (iPad ? 20 : 20))];
    [btnFovourite1 setImage:[UIImage imageNamed:@"movie_frv_unselect"] forState:UIControlStateNormal];
    [btnFovourite1.dictData setValue:[withData valueForKey:keyId] forKey:KeyButtonValue];
    [btnFovourite1 addTarget:self action:@selector(detailVideoAction:) forControlEvents:UIControlEventTouchUpInside];
    
    CustomButton *btnFovourite =(CustomButton *)[otherView viewWithTag:TAG_MD_REMOVE_FAVOURITE_BTN];
    [btnFovourite setFrame:CGRectMake(otherView.frame.size.width-gap-(iPad?20:20),otherView.frame.size.height - gap -((iPad?25:20)), (iPad ? 20 : 20), (iPad ? 20 : 20))];
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    
    UIStoryboard *storyboard = iPhone_storyboard;
    if (iPad)
    {
        storyboard = self.storyboard;
    }
    MovieDetailsViewController *movieDetailsVC = (MovieDetailsViewController *) [storyboard instantiateViewControllerWithIdentifier:@"MovieDetailsVC"];
    NSDictionary *movieDictionary = [arrData objectAtIndex:indexPath.item];
    movieDetailsVC.movieType=movieList;
    movieDetailsVC.strMovieId = [movieDictionary valueForKey:keyId];
    movieDetailsVC.viewType = ViewTypeList;

    if(movieList==TYPE_GIVE_MOVIE)
    {
        if(!sendMovieList)
        {
            sendMovieList=[[NSMutableArray alloc]init];
        }
        if([sendMovieList containsObject:[movieDictionary valueForKey:@"id"]])
        {
            [sendMovieList removeObject:[movieDictionary valueForKey:@"id"]];
        }
        else
        {
            [sendMovieList addObject:[movieDictionary valueForKey:@"id"]];
        }
        [_collectionView reloadData];
    }
    else if (movieList == TYPE_GIVE_MOVIE_FRIEND)
    {
        UIStoryboard *storyboard = iPhone_storyboard;
        if (iPad)
        {
            storyboard = self.storyboard;
        }
        ContactListViewController *contactListVC = (ContactListViewController *) [storyboard instantiateViewControllerWithIdentifier:@"ContactlistVC"];
        contactListVC.inviteType=0;
        contactListVC.strMovieId = [movieDictionary valueForKey:keyId];
        contactListVC.strMovieTitle = [movieDictionary valueForKey:keyTitle];
        [self.navigationController pushViewController:contactListVC animated:YES];

    }
    else
    {
        [self.navigationController pushViewController:movieDetailsVC animated:YES];
    }
    
   
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
    
    CGFloat Xpos = (iPad?5:0);
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self viewItemSizefor:[UIApplication sharedApplication].statusBarOrientation];
}


#pragma mark -
#pragma mark change size

-(CGSize)viewItemSizefor:(UIInterfaceOrientation)toOrientation
{
    if (iPad)
    {
        if (UIInterfaceOrientationIsLandscape(toOrientation))
        {
            return CGSizeMake(480, 120); //150
        }
        else
        {
            return CGSizeMake(719, 120); //150
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

#pragma mark - Reload Collection View

- (void)reloadCollectionView:(UIInterfaceOrientation)toInterfaceOrientation
{
    UICollectionViewFlowLayout *Layout = (UICollectionViewFlowLayout *) _collectionView.collectionViewLayout;
    
    Layout.itemSize = [self viewItemSizefor:toInterfaceOrientation];
    [Layout invalidateLayout];
    [_collectionView reloadData];
    
    if(movieList == TYPE_FRIEND_MOVIE)
    {
        [self setFriendsBtnFrameForOrientation:toInterfaceOrientation];
        [self setSagebinLogoInCenterForOrientation:toInterfaceOrientation];
    }
    
    if(movieList == TYPE_MY_MOVIE)
    {
        //==========================
        
        UIView *lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
        NSInteger yPos = lbl.frame.origin.y+lbl.frame.size.height+10;
        [self setViewImage:[UIImage imageNamed:@"my-movies"] withTitle:NSLocalizedString(@"myMoviesTitle", nil)];
        
        if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            yPos = lbl.frame.origin.y;
            [self hideImageAndTitle];
        }
        
        _collectionView.frame = CGRectMake(10, yPos, self.view.frame.size.width - 20, self.view.frame.size.height-yPos);
        [self resetTopViewLogoFrameForOrientation:toInterfaceOrientation withImage:[UIImage imageNamed:@"my-movies"] withTitle:NSLocalizedString(@"myMoviesTitle", nil)];
    }
    if(movieList == TYPE_BIN_MOVIE || movieList == TYPE_FAV_MOVIE || movieList ==TYPE_GIVE_MOVIE || movieList==TYPE_GIVE_MOVIE_FRIEND)
    {
        [self setSagebinLogoInCenterForOrientation:toInterfaceOrientation];
    }
    
    
}
#pragma mark - Rotation Method

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self reloadCollectionView:toInterfaceOrientation];
}

#pragma mark - IMDEventImageView Click Handle
-(void)eventImageView:(IMDEventImageView *)imageView didSelectWithURL:(NSString *)url
{
    NSLog(@"%@", imageView.superview.superview);
    NSIndexPath *indexPath = [_collectionView indexPathForCell:(UICollectionViewCell *)imageView.superview.superview];
    NSLog(@"%d", indexPath.item);
    
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
    switch (movieList) {
        case TYPE_FRIEND_MOVIE:
        {
            [self getApiDataWithTag:kTAG_FRIEND_MOVIE];
        }
            break;
            
        case TYPE_MY_MOVIE:
        {
            [self getApiDataWithTag:kTAG_MY_MOVIE];
        }
            break;
            
        case TYPE_BIN_MOVIE:
        {
            [self getApiDataWithTag:kTAG_BIN_MOVIE];
        }
            break;
        case TYPE_FAV_MOVIE:
        {
            [self getApiDataWithTag:kTAG_FAV_MOVIE];
        }
            break;
        case TYPE_GIVE_MOVIE:
        {
            [self getApiDataWithTag:kTAG_BIN_MOVIE];
        }
            break;
        case TYPE_GIVE_MOVIE_FRIEND:
        {
            [self getApiDataWithTag:kTAG_BIN_MOVIE];
        }
            break;
            
        default:
            break;
    }
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
        switch (movieList) {
            case TYPE_FRIEND_MOVIE:
            {
                [self getApiDataWithTag:kTAG_FRIEND_MOVIE];
            }
                break;
                
            case TYPE_MY_MOVIE:
            {
                [self getApiDataWithTag:kTAG_MY_MOVIE];
            }
                break;
            case TYPE_BIN_MOVIE:
            {
                [self getApiDataWithTag:kTAG_BIN_MOVIE];
            }
                break;
            case TYPE_FAV_MOVIE:
            {
                [self getApiDataWithTag:kTAG_FAV_MOVIE];
            }
                break;
            case TYPE_GIVE_MOVIE:
            {
                [self getApiDataWithTag:kTAG_BIN_MOVIE];
            }
                break;
            case TYPE_GIVE_MOVIE_FRIEND:
            {
                [self getApiDataWithTag:kTAG_BIN_MOVIE];
            }
                break;
        }
    }
    else
    {
        [_collectionView.infiniteScrollingView setHidden:YES];
    }
}

-(void)btnFriendsClicked:(CustomButton *)btn
{
    UIStoryboard *storyboard = iPhone_storyboard;
    if (iPad)
    {
        storyboard = self.storyboard;
    }
    FriendListVC *friendVC = (FriendListVC *) [storyboard instantiateViewControllerWithIdentifier:@"FriendViewVC"];
    [self.navigationController pushViewController:friendVC animated:YES];
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
    NSLog(@"MovieListViewController dealloc called");
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
