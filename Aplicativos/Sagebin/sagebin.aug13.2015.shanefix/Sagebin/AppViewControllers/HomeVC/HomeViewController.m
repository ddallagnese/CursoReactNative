//
//  HomeViewController.m
//  Sagebin
//
// 
//  
//

#import "HomeViewController.h"
#import "FriendListVC.h"
#import "ReleaseVC.h"
#import "NewsViewController.h"
#import "MovieListViewController.h"
#import "SearchMovieListViewController.h"
#import "OfflineMovieListViewController.h"
#import "MovieDetailsViewController.h"
#import "CastViewController.h"
#import "DeviceTableViewController.h"
#import "ContactListViewController.h"

#define kPortraitScrollWidthIphone5 320
#define kPortraitScrollHeightIphone5 275
#define kLandScapeScrollWidthIphone5 381
#define kLandScapeScrollHeightIphone5 183

#define kPortraitScrollWidthIphone4 320
#define kPortraitScrollHeightIphone4 187
#define kLandScapeScrollWidthIphone4 320
#define kLandScapeScrollHeightIphone4 183

#define kPortraitScrollWidthIpad 768
#define kPortraitScrollHeightIpad 460
#define kLandScapeScrollWidthIpad 636
#define kLandScapeScrollHeightIpad 500


#define yPosition (iPad?60:40)
#define kRowHeight (iPad?54:35)
#define MARGIN (iPad?15:5)

static NSUInteger kNumberOfImages = 0;

@interface HomeViewController ()
{
    BOOL portraitInitDone,landscapeInitDone;
    __weak ChromecastDeviceController *_chromecastController;
}
@end

@implementation HomeViewController

@synthesize arrImageViews;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    NSLog(@"HomeViewController dealloc called");
}
#pragma mark - Life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification  object:nil];
    
           [self.view setBackgroundColor:HomeBgColor];
        currentOrientaion = [[UIDevice currentDevice] orientation];
        
        arrImageGalleryRecords = [[NSMutableArray alloc] init];
        arrImageUrls = [[NSMutableArray alloc]init];

    
    
}
-(void)getApiData
{
    IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
    NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strParameter = [NSString stringWithFormat:NSLocalizedString(@"apiHomeImages", nil), [APPDELEGATE getAppToken]];
    strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], strParameter];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl]];
    NSData *postData = [NSData dataWithBytes:[strParameter UTF8String] length:[strParameter length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:kTAG_HOME_IMAGES];
    [requestConnection startAsynchronousRequest];
    
    [SEGBIN_SINGLETONE_INSTANCE addLoader];
    [self.view setUserInteractionEnabled:FALSE];
}
-(void)getUserDataAPI
{
    IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
    NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], NSLocalizedString(@"apiSettings", nil)];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl]];
    NSData *postData = [NSData dataWithBytes:[strParameter UTF8String] length:[strParameter length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:kTAG_SETTINGS];
    [requestConnection startAsynchronousRequest];
    
    [SEGBIN_SINGLETONE_INSTANCE addLoader];
    [self.view setUserInteractionEnabled:FALSE];
}

#pragma mark - IMDHTTPRequest Delegate
-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didFailWithError:(NSError*)error withTag:(int)tag
{
    [self.view makeToast:kServerError];
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    [self.view setUserInteractionEnabled:TRUE];
}

-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didSuccessWithItems:(NSObject*)items withData:(NSData*)data withTag:(int)tag
{
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    [self.view setUserInteractionEnabled:TRUE];
    if (tag==kTAG_HOME_IMAGES)
    {
        NSDictionary *result = (NSDictionary *)items;
        NSArray *arrAlerts = [result objectForKey:keyAlerts];
        if(arrAlerts && arrAlerts.count > 0)
        {
            [self checkUserAlert:[result objectForKey:keyAlerts]];
        }
        
        //NSLog(@"%@", result);
        [arrImageGalleryRecords addObject:[result valueForKey:@"img1"]];
        [arrImageGalleryRecords addObject:[result valueForKey:@"img2"]];
        [arrImageGalleryRecords addObject:[result valueForKey:@"img3"]];
        [arrImageGalleryRecords addObject:[result valueForKey:@"img4"]];
        [arrImageGalleryRecords addObject:[result valueForKey:@"img5"]];
        kNumberOfImages = [arrImageGalleryRecords count];
        
        [arrImageUrls addObject:[result valueForKey:@"url1"]];
        [arrImageUrls addObject:[result valueForKey:@"url2"]];
        [arrImageUrls addObject:[result valueForKey:@"url3"]];
        [arrImageUrls addObject:[result valueForKey:@"url4"]];
        [arrImageUrls addObject:[result valueForKey:@"url5"]];
        
        [self createImageGalleryScroll];
    }
    if (tag==kTAG_SETTINGS)
    {
        NSDictionary *result = (NSDictionary *)items;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSLog(@"%@",[[result valueForKey:keyValue] valueForKey:keymovie_credits]);
        [defaults setObject:[[result valueForKey:keyValue] valueForKey:keymovie_credits] forKey:keymovie_credits];
        [defaults setObject:[[result valueForKey:keyValue] valueForKey:keymovie_shares] forKey:keymovie_shares];
        
         NSLog(@"%d",[[[NSUserDefaults standardUserDefaults] valueForKey:keymovie_credits]intValue]);
        
        [self checkUserAlert:[result objectForKey:keyAlerts]];
//        if([[[NSUserDefaults standardUserDefaults] valueForKey:keymovie_credits]intValue] != 0)
//        {
//            [self.alertButton setHidden:NO];
//        }
////        else
////        {
////            
////            [self.alertButton setHidden:YES];
////        }

       
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
   
    
    [super viewWillAppear:animated];
    // Do any additional setup after loading the view.
    
    [self getUserDataAPI];
    
    if (self.isFromRegistration)
    {
        UIStoryboard *storyboard = iPhone_storyboard;
        if (iPad)
        {
            storyboard = iPad_storyboard;
        }
        MovieListViewController *movieListVC = (MovieListViewController *) [storyboard instantiateViewControllerWithIdentifier:@"MovieListVC"];
        movieListVC.movieList = 4;
        self.isFromRegistration=FALSE;
        [self.navigationController performSelector:@selector(pushViewController:animated:) withObject:movieListVC afterDelay:1.0];
      // [self.navigationController pushViewController:movieListVC animated:YES];
       
        
        
    }
    else
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
        
        if(APPDELEGATE.netOnLink == 0)
        {
            [self.view makeToast:WARNING];
        }
        else
        {
            if(arrImageGalleryRecords.count == 0)
            {
                [self getApiData];
            }
        }
        
        [self setupView];
        [self initializeDefaultView];
        
        if(arrImageGalleryRecords.count > 0)
        {
            if(imageGalleryScroll.superview)
            {
                [imageGalleryScroll removeFromSuperview];
            }
            [self createImageGalleryScroll];
        }
        
        [self.leftButton setHidden:YES];
        [self setSagebinLogoInCenterForOrientation:[UIApplication sharedApplication].statusBarOrientation];
    }

}

-(void)viewWillDisappear:(BOOL)animated
{
    [txtSearch resignFirstResponder];
}
#pragma mark - ImageGallery Slider
-(void)setupImageGalleryScrollView
{
    // setup scrollview for image gallery slider
    NSMutableArray *arrayImageViews = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < kNumberOfImages; i++) {
        [arrayImageViews addObject:[NSNull null]];
    }
    self.arrImageViews = arrayImageViews;
    
    [imageGalleryScroll setContentSize:CGSizeMake((imageGalleryScroll.frame.size.width * kNumberOfImages), imageGalleryScroll.frame.size.height)];
	
    [self loadImageGalleryScrollViewWithPage:0];
    [self loadImageGalleryScrollViewWithPage:1];
}

- (void)loadImageGalleryScrollViewWithPage:(int)page {
    if (page < 0) return;
    if (page >= kNumberOfImages) return;
    
    // replace the placeholder if necessary
    if([self.arrImageViews count] > 0)
    {
        UIView *view = [self.arrImageViews objectAtIndex:page];
        if ((NSNull *)view == [NSNull null])
        {
            view = [self getImageGalleryViewWithFrame:imageGalleryScroll.frame Index:page];
            [self.arrImageViews replaceObjectAtIndex:page withObject:view];
        }
        
        if (nil == view.superview) {
            CGRect frame = imageGalleryScroll.frame;
            frame.origin.x = frame.size.width * page;
            frame.origin.y = 0;
            view.frame = frame;
            [imageGalleryScroll addSubview:view];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    if (pageControlUsed) {
        return;
    }
    
    CGFloat pageWidth = imageGalleryScroll.frame.size.width;
    int page = floor((imageGalleryScroll.contentOffset.x - pageWidth/2) / pageWidth) + 1;
    
    [self loadImageGalleryScrollViewWithPage:page - 1];
    [self loadImageGalleryScrollViewWithPage:page];
    [self loadImageGalleryScrollViewWithPage:page + 1];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

-(UIView *)getImageGalleryViewWithFrame:(CGRect)frame Index:(int)pageIndex
{
    NSString *strImageURL = @"";
    if([arrImageGalleryRecords count] > 0)
    {
        strImageURL = [arrImageGalleryRecords objectAtIndex:pageIndex];
    }
    
    IMDEventImageView *imageView = [APPDELEGATE createEventImageViewWithFrame:frame withImageURL:strImageURL Placeholder:kPlaceholderImage tag:pageIndex];
    [imageView setUserInteractionEnabled:TRUE];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView setClipsToBounds:YES];
    [imageView setEventImageDelegate:self];
    return imageView;
}

#pragma mark - Init Methods
-(void)addSearchBarView
{
    NSInteger yPos = [self.view viewWithTag:TAG_ViewFriendMovies].frame.origin.y;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        yPos = [self.view viewWithTag:TAG_ViewFriendMovies].frame.origin.y-5;
        
    }

//    searchView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake((iPad?26:12), yPos-60, self.view.frame.size.width-(iPad?52:24), kRowHeight) bgColor:[UIColor whiteColor] tag:-1 alpha:1.0];

    if(iPad)
    {
         searchView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake([self.view viewWithTag:TAG_ViewFriendMovies].frame.origin.x+5, yPos-190, self.view.frame.size.width-(iPad?52:24), kRowHeight) bgColor:[UIColor whiteColor] tag:-1 alpha:1.0];
    }
    else
    {
         searchView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake([self.view viewWithTag:TAG_ViewFriendMovies].frame.origin.x+5, imageGalleryScroll.frame.origin.y+imageGalleryScroll.frame.size.height-60, self.view.frame.size.width-(iPad?52:24), kRowHeight) bgColor:[UIColor whiteColor] tag:-1 alpha:1.0];
    }
    
   
    
   
    
    txtSearch = [SEGBIN_SINGLETONE_INSTANCE createTextFieldWithFrame:CGRectMake(MARGIN, kRowHeight/2-kRowHeight/4, searchView.frame.size.width-(iPad?54:30)-MARGIN,kRowHeight/2) placeHolder:NSLocalizedString(@"txtSearchMovie", nil) font:[APPDELEGATE Fonts_OpenSans_LightItalic:(iPad?18:10)] textColor:[UIColor blackColor] tag:TAG_SearchText];
    [txtSearch setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth];
    [txtSearch setDelegate:self];
    [txtSearch setClearButtonMode:UITextFieldViewModeWhileEditing];
    [txtSearch setReturnKeyType:UIReturnKeySearch];
    txtSearch.autocorrectionType=UITextAutocorrectionTypeNo;
    txtSearch.autocorrectionType=UITextSpellCheckingTypeNo;
    [searchView addSubview:txtSearch];
    
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSearch setTag:TAG_SearchButton];
    [btnSearch setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [btnSearch setImage:[UIImage imageNamed:@"friend_search"] forState:UIControlStateNormal];
    [btnSearch addTarget:self action:@selector(searchMovie:) forControlEvents:UIControlEventTouchUpInside];
    [btnSearch setFrame:CGRectMake(txtSearch.frame.origin.x + txtSearch.frame.size.width, 0,(iPad?54:30), searchView.frame.size.height)];
    [searchView addSubview:btnSearch];
    [self.view addSubview:searchView];
    
    
}
-(void)createImageGalleryScroll
{
    CGFloat width, height;
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        if(iPad)
        {
            width = kLandScapeScrollWidthIpad;
            height = kLandScapeScrollHeightIpad;
        }
        else
        {
            width = ((IS_IPHONE_5_GREATER)?kLandScapeScrollWidthIphone5:kLandScapeScrollWidthIphone4);
            height = ((IS_IPHONE_5_GREATER)?kLandScapeScrollHeightIphone5:kLandScapeScrollHeightIphone4);
        }
    }
    else // if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        if(iPad)
        {
            width = kPortraitScrollWidthIpad;
            height = kPortraitScrollHeightIpad;
        }
        else
        {
            if(IS_IPHONE_5_GREATER)
            {
                width = kPortraitScrollWidthIphone5;
                height = kPortraitScrollHeightIphone5;
            }
            else
            {
                width = kPortraitScrollWidthIphone4, height = kPortraitScrollHeightIphone4;
            }
        }
    }
    
    [imageGalleryScroll removeFromSuperview];
    imageGalleryScroll = [SEGBIN_SINGLETONE_INSTANCE createScrollViewWithFrame:CGRectMake(0,KTopBarHeight,width,height) bgColor:[UIColor clearColor] tag:-1 delegate:self];
    [imageGalleryScroll setPagingEnabled:YES];
    [imageGalleryScroll setScrollsToTop:NO];
    [self.view addSubview:imageGalleryScroll];
    
    if(!searchView)
    {
        [self addSearchBarView];
    }
    else
    {
        txtSearch.text=@"";
    }
    
     searchView.frame=CGRectMake([self.view viewWithTag:TAG_ViewFriendMovies].frame.origin.x+5, imageGalleryScroll.frame.origin.y+height-yPosition, width-10, searchView.frame.size.height);
    
    [self.view bringSubviewToFront:searchView];
    
    [self setupImageGalleryScrollView];
    
    if(timer)
    {
        [timer invalidate];
        timer = nil;
    }
    [self startTimer];
}

-(void)setupView
{
    [self clearCurrentView];
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        [self.view insertSubview:mainLandscapeView atIndex:0];
        
    }
    else if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
    {
        [self.view insertSubview:mainPortraitView atIndex:0];
    }
}
-(void) clearCurrentView {
    
    if (mainLandscapeView.superview)
    {
        [mainLandscapeView removeFromSuperview];
        
    }
    else if (mainPortraitView.superview)
    {
        [mainPortraitView removeFromSuperview];
    }
}
#pragma mark  set defualt layout
-(void)initializeDefaultView
{
   
    
    UILabel *lblFrndsMovieTitle = (UILabel *)[self.view viewWithTag:TAG_LBLFRIENDS_MOVIES];
    [lblFrndsMovieTitle setFont:[APPDELEGATE Fonts_OpenSans_Regular:(iPad?27:14)]];
    [lblFrndsMovieTitle setText:NSLocalizedString(@"lblFriendMovie", nil)];
    
    UILabel *lblMyMovieTitle = (UILabel *)[self.view viewWithTag:TAG_LBL_MYMOVIE];
    [lblMyMovieTitle setFont:[APPDELEGATE Fonts_OpenSans_Regular:(iPad?27:14)]];
    [lblMyMovieTitle setText:NSLocalizedString(@"lblMyMovie", nil)];
    
    UILabel *lblSearch = (UILabel *)[self.view viewWithTag:TAG_LBLSEARCH];
    [lblSearch setFont:[APPDELEGATE Fonts_OpenSans_Regular:(iPad?29:15)]];
    [lblSearch setText:NSLocalizedString(@"lblBin", nil)];
    
    UILabel *lblRelease = (UILabel *)[self.view viewWithTag:TAG_LBLNEWRELEASE];
    [lblRelease setFont:[APPDELEGATE Fonts_OpenSans_Regular:(iPad?29:15)]];
    [lblRelease setText:NSLocalizedString(@"lblNewRelease", nil)];
    
    UILabel *lblOfflineMov = (UILabel *)[self.view viewWithTag:TAG_LBLOFFLINE_MOVIES];
    [lblOfflineMov setFont:[APPDELEGATE Fonts_OpenSans_Regular:(iPad?27:14)]];
    [lblOfflineMov setText:NSLocalizedString(@"lblOfflineMovies", nil)];
    
    UILabel *lblNews = (UILabel *)[self.view viewWithTag:TAG_LBLNEWS];
    [lblNews setFont:[APPDELEGATE Fonts_OpenSans_Regular:(iPad?27:14)]];
    [lblNews setText:NSLocalizedString(@"lblFav", nil)];

    [self setupDefaultTapGesture];
    
    (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))?(landscapeInitDone=YES):(portraitInitDone=YES);
    
    
}

-(void)setupDefaultTapGesture
{
    
     UITapGestureRecognizer *tapGestureView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewDidTap:)];
    [[self.view viewWithTag:TAG_ViewFriendMovies] addGestureRecognizer:tapGestureView];
    [self.view viewWithTag:TAG_ViewFriendMovies].layer.borderWidth=6.0;
    [self.view viewWithTag:TAG_ViewFriendMovies].layer.borderColor=[UIColor whiteColor].CGColor;
    
    tapGestureView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewDidTap:)];
    [[self.view viewWithTag:TAG_ViewMyMovies] addGestureRecognizer:tapGestureView];
    [self.view viewWithTag:TAG_ViewMyMovies].layer.borderWidth=6.0;
    [self.view viewWithTag:TAG_ViewMyMovies].layer.borderColor=[UIColor whiteColor].CGColor;
    
    tapGestureView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewDidTap:)];
    [[self.view viewWithTag:TAG_ViewSearch] addGestureRecognizer:tapGestureView];
    [self.view viewWithTag:TAG_ViewSearch].layer.borderWidth=6.0;
    [self.view viewWithTag:TAG_ViewSearch].layer.borderColor=[UIColor whiteColor].CGColor;
    
    tapGestureView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewDidTap:)];
    [[self.view viewWithTag:TAG_ViewNewRelease] addGestureRecognizer:tapGestureView];
    [self.view viewWithTag:TAG_ViewNewRelease].layer.borderWidth=6.0;
    [self.view viewWithTag:TAG_ViewNewRelease].layer.borderColor=[UIColor whiteColor].CGColor;

    
    tapGestureView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewDidTap:)];
    [[self.view viewWithTag:TAG_ViewFriends] addGestureRecognizer:tapGestureView];
    [self.view viewWithTag:TAG_ViewFriends].layer.borderWidth=6.0;
    [self.view viewWithTag:TAG_ViewFriends].layer.borderColor=[UIColor whiteColor].CGColor;
    
    tapGestureView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewDidTap:)];
    [[self.view viewWithTag:TAG_ViewNews] addGestureRecognizer:tapGestureView];
    [self.view viewWithTag:TAG_ViewNews].layer.borderWidth=6.0;
    [self.view viewWithTag:TAG_ViewNews].layer.borderColor=[UIColor whiteColor].CGColor;
    
}
-(void)viewDidTap:(UITapGestureRecognizer *)tappedView
{
    switch (tappedView.view.tag)
    {
        case TAG_ViewFriendMovies:
            [self friendMovieViewTap:tappedView.view];
            break;
            
        case TAG_ViewMyMovies:
            [self myMovieViewTap:tappedView.view];
            break;
    
        case TAG_ViewSearch:
                [self searchViewTap:tappedView.view];
            break;
        case TAG_ViewNewRelease:
                [self newReleaseViewTap:tappedView.view];
            break;
        case TAG_ViewFriends:
                [self friendViewTap:tappedView.view];
            break;
        case TAG_ViewNews:
                [self newsViewTap:tappedView.view];
            break;
    }
    
}
#pragma mark - All View Events

-(void)myMovieViewTap:(UIView *)myMovieView
{
    UIStoryboard *storyboard = iPhone_storyboard;
    if (iPad)
    {
        storyboard = self.storyboard;
    }
    MovieListViewController *movieListVC = (MovieListViewController *) [storyboard instantiateViewControllerWithIdentifier:@"MovieListVC"];
    movieListVC.movieList = 1;
    [self.navigationController pushViewController:movieListVC animated:YES];
}

-(void)friendMovieViewTap:(UIView *)friendMovieView
{
    UIStoryboard *storyboard = iPhone_storyboard;
    if (iPad)
    {
        storyboard = self.storyboard;
    }
    MovieListViewController *movieListVC = (MovieListViewController *) [storyboard instantiateViewControllerWithIdentifier:@"MovieListVC"];
    movieListVC.movieList = 0;
    [self.navigationController pushViewController:movieListVC animated:YES];
   
}

-(void)searchViewTap:(UIView *)searchView
{
//    UIStoryboard *storyboard = iPhone_storyboard;
//    if (iPad)
//    {
//        storyboard = self.storyboard;
//    }
////    SearchMovieListViewController *searchMovieListVC = (SearchMovieListViewController *) [storyboard instantiateViewControllerWithIdentifier:@"SearchMovieListVC"];
////    [self.navigationController pushViewController:searchMovieListVC animated:YES];
//    
//    Bin_ViewController *searchMovieListVC = (Bin_ViewController *) [storyboard instantiateViewControllerWithIdentifier:@"BinVc"];
//    [self.navigationController pushViewController:searchMovieListVC animated:YES];

    UIStoryboard *storyboard = iPhone_storyboard;
    if (iPad)
    {
        storyboard = self.storyboard;
    }
    MovieListViewController *movieListVC = (MovieListViewController *) [storyboard instantiateViewControllerWithIdentifier:@"MovieListVC"];
    movieListVC.movieList = 2;
    [self.navigationController pushViewController:movieListVC animated:YES];
    
}
-(void)newReleaseViewTap:(UIView *)newReleaseView
{
    UIStoryboard *storyboard = iPhone_storyboard;
    if (iPad)
    {
        storyboard = self.storyboard;
    }
    ReleaseVC *obj_ReleaseVC = (ReleaseVC *) [storyboard instantiateViewControllerWithIdentifier:@"ReleaseVC"];
    [self.navigationController pushViewController:obj_ReleaseVC animated:YES];
}
-(void)friendViewTap:(UIView *)purchaseView
{
    NSMutableArray *arrOfflineVideos = [[NSMutableArray alloc]init];
    arrOfflineVideos = [SEGBIN_SINGLETONE_INSTANCE getOfflineVideos];
    if([arrOfflineVideos count] == 0)
    {
        [APPDELEGATE errorAlertMessageTitle:@"" andMessage:NSLocalizedString(@"strNoOfflineMovies", nil)];
    }else{
        UIStoryboard *storyboard = iPhone_storyboard;
        if (iPad)
        {
            storyboard = self.storyboard;
        }
        OfflineMovieListViewController *offlineVC = (OfflineMovieListViewController *) [storyboard instantiateViewControllerWithIdentifier:@"OfflineMovieListVC"];
        [self.navigationController pushViewController:offlineVC animated:YES];
    }
}
-(void)newsViewTap:(UIView *)downloadView
{
    UIStoryboard *storyboard = iPhone_storyboard;
    if (iPad)
    {
        storyboard = self.storyboard;
    }
    MovieListViewController *movieListVC = (MovieListViewController *) [storyboard instantiateViewControllerWithIdentifier:@"MovieListVC"];
    movieListVC.movieList = 3;
    [self.navigationController pushViewController:movieListVC animated:YES];
}

#pragma mark - Orientation Notification
-(void)didRotate:(NSNotification *)notification
{
    UIDeviceOrientation newOrientation = [[UIDevice currentDevice] orientation];
    if (newOrientation != UIDeviceOrientationUnknown && newOrientation != UIDeviceOrientationFaceUp && newOrientation != UIDeviceOrientationFaceDown)
    {
        currentOrientaion = newOrientation;
    }
    if ((currentOrientaion == UIDeviceOrientationLandscapeLeft || currentOrientaion == UIDeviceOrientationLandscapeRight))
    {
        // Clear the current view and insert the orientation specific view.
        
        [self clearCurrentView];
        [self.view addSubview:mainLandscapeView];
    }
    else if (currentOrientaion == UIDeviceOrientationPortrait || currentOrientaion == UIDeviceOrientationPortraitUpsideDown)
    {
        // Clear the current view and insert the orientation specific view.
        [self clearCurrentView];
        [self.view addSubview:mainPortraitView];
    }
   
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [timer invalidate];
    timer = nil;
    [txtSearch resignFirstResponder];
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        [self clearCurrentView];
        
        CGFloat width, height;
        if(iPad)
        {
            width = kLandScapeScrollWidthIpad;
            height = kLandScapeScrollHeightIpad;
        }
        else
        {
            width = kLandScapeScrollWidthIphone4, height = kLandScapeScrollHeightIphone4;
            if(IS_IPHONE_5_GREATER)
            {
                width = kLandScapeScrollWidthIphone5;
                height = kLandScapeScrollHeightIphone5;
            }
        }
        
        [imageGalleryScroll setFrame:CGRectMake(0,KTopBarHeight,width,height)];
        CGFloat xPos = 0;
        for(IMDEventImageView *i in imageGalleryScroll.subviews)
        {
            [i setFrame:CGRectMake(xPos, i.frame.origin.y, width, height)];
            xPos = xPos+width;
        }
        imageGalleryScroll.contentSize = CGSizeMake(kNumberOfImages*width, height);
        imageGalleryScroll.contentOffset = CGPointMake(0, 0);
        
        [self.view insertSubview:mainLandscapeView atIndex:0];
        if (!landscapeInitDone)
        {
            [self initializeDefaultView];
        }
        
         searchView.frame=CGRectMake([self.view viewWithTag:TAG_ViewFriendMovies].frame.origin.x+5, imageGalleryScroll.frame.origin.y+height-yPosition, width-10, searchView.frame.size.height);
    }
    else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        [self clearCurrentView];
        
        CGFloat width, height;
        if(iPad)
        {
            width = kPortraitScrollWidthIpad;
            height = kPortraitScrollHeightIpad;
        }
        else
        {
            if(IS_IPHONE_5_GREATER || ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.width - ( double )568 ) < DBL_EPSILON ))
            {
                width = kPortraitScrollWidthIphone5;
                height = kPortraitScrollHeightIphone5;
            }
            else
            {
                width = kPortraitScrollWidthIphone4, height = kPortraitScrollHeightIphone4;
            }
        }
        
        [imageGalleryScroll setFrame:CGRectMake(0,KTopBarHeight,width,height)];
        CGFloat xPos = 0;
        for(IMDEventImageView *i in imageGalleryScroll.subviews)
        {
            [i setFrame:CGRectMake(xPos, i.frame.origin.y, width, height)];
            xPos = xPos+width;
        }
        imageGalleryScroll.contentSize = CGSizeMake(kNumberOfImages*width, height);
        imageGalleryScroll.contentOffset = CGPointMake(0, 0);
        
        [self.view insertSubview:mainPortraitView atIndex:0];
        if (!portraitInitDone)
        {
            [self initializeDefaultView];
        }
         searchView.frame=CGRectMake([self.view viewWithTag:TAG_ViewFriendMovies].frame.origin.x+5, imageGalleryScroll.frame.origin.y+height-yPosition, width-10, searchView.frame.size.height);
    }
    
    
    [self startTimer];
    [self setSagebinLogoInCenterForOrientation:toInterfaceOrientation];
    
    
    
}
-(void)searchMovie:(UIButton *)btnserch
{
    /*if ([txtSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length>0)
     {
     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@",txtSearch.text];
     NSArray *arrResult = [arrOriginalData filteredArrayUsingPredicate:predicate];
     [arrData removeAllObjects];
     [arrData addObjectsFromArray:arrResult];
     }
     else
     {
     [arrData removeAllObjects];
     [arrData addObjectsFromArray:arrOriginalData];
     }
     [txtSearch resignFirstResponder];
     [_collectionView reloadData];*/
    
    [txtSearch resignFirstResponder];
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    if(txtSearch.text.length > 0)
    {
        UIStoryboard *storyboard = iPhone_storyboard;
        if (iPad)
        {
            storyboard = self.storyboard;
        }
        SearchMovieListViewController *searchMovieListVC = (SearchMovieListViewController *) [storyboard instantiateViewControllerWithIdentifier:@"SearchMovieListVC"];
        searchMovieListVC.movieName=txtSearch.text;
        [self.navigationController pushViewController:searchMovieListVC animated:YES];
    }
    else
    {
        [self.view makeToast:NSLocalizedString(@"txtSearchEmpty", nil)];
    }
}
#pragma mark - TextField Delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
     UIDeviceOrientation toInterfaceOrientation = [[UIDevice currentDevice] orientation];
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        if(iPad)
        {
            searchView.frame=CGRectMake([self.view viewWithTag:TAG_ViewFriendMovies].frame.origin.x+5, imageGalleryScroll.frame.origin.y+imageGalleryScroll.frame.size.height-235, searchView.frame.size.width, searchView.frame.size.height);
        }
        else
        {
            searchView.frame=CGRectMake([self.view viewWithTag:TAG_ViewFriendMovies].frame.origin.x+5, imageGalleryScroll.frame.origin.y+imageGalleryScroll.frame.size.height-125, searchView.frame.size.width, searchView.frame.size.height);
        }
        
    }
    else
    {
         searchView.frame=CGRectMake([self.view viewWithTag:TAG_ViewFriendMovies].frame.origin.x+5, imageGalleryScroll.frame.origin.y+imageGalleryScroll.frame.size.height-yPosition, searchView.frame.size.width, searchView.frame.size.height);
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UIDeviceOrientation toInterfaceOrientation = [[UIDevice currentDevice] orientation];
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
       
            searchView.frame=CGRectMake([self.view viewWithTag:TAG_ViewFriendMovies].frame.origin.x+5, imageGalleryScroll.frame.origin.y+imageGalleryScroll.frame.size.height-yPosition, searchView.frame.size.width, searchView.frame.size.height);
       
        
    }
    else
    {
        searchView.frame=CGRectMake([self.view viewWithTag:TAG_ViewFriendMovies].frame.origin.x+5, imageGalleryScroll.frame.origin.y+imageGalleryScroll.frame.size.height-yPosition, searchView.frame.size.width, searchView.frame.size.height);
    }

}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.text.length > 0)
    {
        [textField resignFirstResponder];
        UIStoryboard *storyboard = iPhone_storyboard;
        if (iPad)
        {
            storyboard = self.storyboard;
        }
        SearchMovieListViewController *searchMovieListVC = (SearchMovieListViewController *) [storyboard instantiateViewControllerWithIdentifier:@"SearchMovieListVC"];
        searchMovieListVC.movieName=txtSearch.text;
        [self.navigationController pushViewController:searchMovieListVC animated:YES];
    }
    else
    {
        [textField resignFirstResponder];
       
    }
    return YES;
}
#pragma mark - LOGOUT
-(void)logoutButtonClicked
{
//    if(APPDELEGATE == 0)
//    {
//        return;
//    }
    
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
        
        [APPDELEGATE setVideoDownloadMode:DefaultValueDownloadMode];
        [APPDELEGATE setNotificationType:DefaultValueNotificationType];
        [APPDELEGATE setNotificationPeriod:DefaultValueNotificationPeriod];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        NSLog(@"cancel");
    }
}

// Slide Images
-(void)startTimer
{
    timer = [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(imageChange:) userInfo:arrImageGalleryRecords repeats:YES];
}

-(void)imageChange:(NSTimer *)timer
{
    UIScrollView *_scrPages = imageGalleryScroll;
    
    //NSInteger index = _scrPages.contentOffset.x/_scrPages.frame.size.width;
    
    CGPoint offset = _scrPages.contentOffset;
    
    if (offset.x == (_scrPages.contentSize.width - _scrPages.frame.size.width))
    {
        offset.x = 0.0;
        [_scrPages setContentOffset:offset animated:NO];
    }
    else
    {
        offset.x += _scrPages.frame.size.width;
        [_scrPages setContentOffset:offset animated:YES];
    }
}

#pragma mark IMDEventImageView Delegate
-(void)eventImageView:(IMDEventImageView *)imageView didSelectWithURL:(NSString *)url
{
    NSLog(@"%d", imageView.tag);
    UIStoryboard *storyboard = iPhone_storyboard;
    if (iPad)
    {
        storyboard = self.storyboard;
    }
    
    NSString *strURL = [arrImageUrls objectAtIndex:imageView.tag];
    NSArray *arrComponents = [strURL componentsSeparatedByString:@"="];
    if([arrComponents count] > 1)
    {
        MovieDetailsViewController *movieDetailsVC = (MovieDetailsViewController *) [storyboard instantiateViewControllerWithIdentifier:@"MovieDetailsVC"];
        movieDetailsVC.strMovieId = [arrComponents objectAtIndex:1];
        movieDetailsVC.viewType = ViewTypeList;
        [self.navigationController pushViewController:movieDetailsVC animated:YES];
    }
}

#pragma mark - ChromecastControllerDelegate

/**
 * Called when chromecast devices are discoverd on the network.
 */
- (void)didDiscoverDeviceOnNetwork {
    
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
    // associated Media object.
    
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
