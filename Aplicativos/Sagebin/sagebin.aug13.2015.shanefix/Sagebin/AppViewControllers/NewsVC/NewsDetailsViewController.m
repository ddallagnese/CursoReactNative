//
//  NewsDetailsViewController.m
//  Sagebin
//
//  
//

#import "NewsDetailsViewController.h"
#import "CastViewController.h"
#import "DeviceTableViewController.h"

#define LEFT_MARGIN 10.0
#define PICTURE_HEIGHT 200.0

#define kTitleFontSize (iPad?20:25)
#define kDetailsFontSize (iPad?15:10)

@interface NewsDetailsViewController ()
{
    UITableView *newsDetailsTable;
    
    NSMutableArray *arrData;
    NSDictionary *newsDictionary;
    UIScrollView *mainScrollView;
    __weak ChromecastDeviceController *_chromecastController;
}
@end

@implementation NewsDetailsViewController

@synthesize strId;

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
    
    [self setViewImage:[UIImage imageNamed:@"news"] withTitle:NSLocalizedString(@"txtNewsTitle", nil)];
    [self.view setBackgroundColor:NewsDetailsViewBgColor];
    
    arrData = [[NSMutableArray alloc]init];
    
//    NSArray *arr = [NSArray arrayWithObjects:@"https://www.sagebin.com/test/wp-content/plugins/SagebinVideo/upload/video/_thumb/800x459.overlay_51e492a6606b3.jpg", nil];
//    newsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:arr, keyImage, @"hello", keyTitle, @"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum is simply dummy text of the printing and typesetting industry.", keyContent, nil];
    
    [self getApiData];
    UIView *lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
    NSInteger yPos = lbl.frame.origin.y+lbl.frame.size.height+10;
    
    mainScrollView = [SEGBIN_SINGLETONE_INSTANCE createScrollViewWithFrame:CGRectMake(0, yPos, self.view.frame.size.width, self.view.frame.size.height-yPos) bgColor:nil tag:-1 delegate:nil];
    [mainScrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:mainScrollView];
    
    //[self setupLayoutMethods];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

#pragma mark - Layout Methods
-(void)setupLayoutMethods
{
    [self createPictureView];
    [self createTitleView];
    [self createDetailsView];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (iPad)
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            [self reSetupLayoutMethodsWithOrientation:orientation Width:1024-LEFT_MARGIN];
        }
        else
        {
            [self reSetupLayoutMethodsWithOrientation:orientation Width:768-LEFT_MARGIN*2.0];
        }
    }
    else
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            if (IS_IPHONE_5)
            {
                [self reSetupLayoutMethodsWithOrientation:orientation Width:(568-LEFT_MARGIN)];
            }
            else
            {
                [self reSetupLayoutMethodsWithOrientation:orientation Width:(480-LEFT_MARGIN)];
            }
        }
        else
        {
            [self reSetupLayoutMethodsWithOrientation:orientation Width:(320-LEFT_MARGIN*2.0)];
        }
    }

}

-(void)reSetupLayoutMethodsWithOrientation:(UIInterfaceOrientation)orientation Width:(CGFloat)width
{
    if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        width = width/2;
        //h = 200.0;
        
        CGFloat textHeight = [self getHeightForText:[newsDictionary valueForKey:keyTitle] font:[UIFont fontWithName:kFontHelvetica size:kTitleFontSize] Width:width-LEFT_MARGIN*2.0];
        [titleView setFrame:CGRectMake(width, 0, width, textHeight+LEFT_MARGIN*2.0)];
        UILabel *lbl = (UILabel *)[titleView viewWithTag:TAG_ND_LBL_TITLE];
        [lbl setFrame:CGRectMake(LEFT_MARGIN, LEFT_MARGIN, width-LEFT_MARGIN*2.0, textHeight)];
        
        textHeight = [self getHeightForText:[newsDictionary valueForKey:keyContent] font:[UIFont fontWithName:kFontHelvetica size:kDetailsFontSize] Width:width-LEFT_MARGIN*2.0];
        [detailsView setFrame:CGRectMake(width, titleView.frame.origin.y+titleView.frame.size.height, width, textHeight+LEFT_MARGIN*2.0)];
        
        lbl = (UILabel *)[detailsView viewWithTag:TAG_ND_LBL_DETAILS];
        [lbl setFrame:CGRectMake(LEFT_MARGIN, LEFT_MARGIN, width-LEFT_MARGIN*2.0, textHeight)];
        
        [pictureView setFrame:CGRectMake(LEFT_MARGIN, 0, width, detailsView.frame.origin.y+detailsView.frame.size.height)];
        
        mainScrollView.contentSize = CGSizeMake(mainScrollView.contentSize.width, pictureView.frame.origin.y+pictureView.frame.size.height);
    }
    else
    {
        [pictureView setFrame:CGRectMake(LEFT_MARGIN, 0, width, PICTURE_HEIGHT)];
        
        CGFloat textHeight = [self getHeightForText:[newsDictionary valueForKey:keyTitle] font:[UIFont fontWithName:kFontHelvetica size:kTitleFontSize] Width:width-LEFT_MARGIN*2.0];
        [titleView setFrame:CGRectMake(LEFT_MARGIN, pictureView.frame.origin.y+pictureView.frame.size.height, width, textHeight+LEFT_MARGIN*2.0)];
        UILabel *lbl = (UILabel *)[detailsView viewWithTag:TAG_ND_LBL_TITLE];
        [lbl setFrame:CGRectMake(LEFT_MARGIN, LEFT_MARGIN, width-LEFT_MARGIN*2.0, textHeight)];
        
        textHeight = [self getHeightForText:[newsDictionary valueForKey:keyContent] font:[UIFont fontWithName:kFontHelvetica size:kDetailsFontSize] Width:width-LEFT_MARGIN*2.0];
        [detailsView setFrame:CGRectMake(LEFT_MARGIN, titleView.frame.origin.y+titleView.frame.size.height, width, textHeight+LEFT_MARGIN*2.0)];
        
        lbl = (UILabel *)[detailsView viewWithTag:TAG_ND_LBL_DETAILS];
        [lbl setFrame:CGRectMake(LEFT_MARGIN, LEFT_MARGIN, width-LEFT_MARGIN*2.0, textHeight)];
    
        mainScrollView.contentSize = CGSizeMake(width, detailsView.frame.origin.y+detailsView.frame.size.height);
    }
}

-(void)createPictureView
{
    CGFloat width = mainScrollView.frame.size.width - LEFT_MARGIN*2.0;
    
    NSString *strImageURL = @"";
    if([[newsDictionary valueForKey:keyImage] isKindOfClass:[NSArray class]])
    {
        if([[newsDictionary valueForKey:keyImage] count] > 0)
        {
            strImageURL = [[newsDictionary valueForKey:keyImage] objectAtIndex:0];
        }
    }
    pictureView = [APPDELEGATE createEventImageViewWithFrame:CGRectMake(LEFT_MARGIN, 0, width, PICTURE_HEIGHT) withImageURL:strImageURL Placeholder:kPlaceholderImage tag:TAG_ND_PICTURE_VIEW];
    [pictureView setContentMode:UIViewContentModeScaleAspectFill];
    [pictureView setClipsToBounds:YES];
    [mainScrollView addSubview:pictureView];
}

-(void)createTitleView
{
    CGFloat yPos = pictureView.frame.origin.y + pictureView.frame.size.height;
    CGFloat width = mainScrollView.frame.size.width - LEFT_MARGIN*2.0;
    //CGFloat height = 40.0;
    CGFloat height = [self getHeightForText:[newsDictionary valueForKey:keyTitle] font:[UIFont fontWithName:kFontHelvetica size:kTitleFontSize] Width:width-LEFT_MARGIN*2.0];
    
    titleView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(LEFT_MARGIN, yPos, width, height+LEFT_MARGIN*2) bgColor:[UIColor colorWithRed:44.0/255.0 green:44.0/255.0 blue:44.0/255.0 alpha:1.0] tag:TAG_ND_TITLE_VIEW alpha:1.0];
    [mainScrollView addSubview:titleView];
    
    UILabel *lblTitle = [APPDELEGATE createLabelWithFrame:CGRectMake(LEFT_MARGIN, LEFT_MARGIN, width-LEFT_MARGIN*2.0, height) withBGColor:[UIColor clearColor] withTXColor:[UIColor whiteColor] withText:[newsDictionary valueForKey:keyTitle] withFont:[UIFont fontWithName:kFontHelvetica size:kTitleFontSize] withTag:TAG_ND_LBL_TITLE withTextAlignment:NSTextAlignmentLeft];
    [titleView addSubview:lblTitle];
}

-(void)createDetailsView
{
    CGFloat yPos = titleView.frame.origin.y + titleView.frame.size.height;
    CGFloat width = mainScrollView.frame.size.width - LEFT_MARGIN*2.0;
    CGFloat height = [self getHeightForText:[newsDictionary valueForKey:keyContent] font:[UIFont fontWithName:kFontHelvetica size:kDetailsFontSize] Width:width-LEFT_MARGIN*2.0];
    
    detailsView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(LEFT_MARGIN, yPos, width, height+LEFT_MARGIN*2.0) bgColor:[UIColor whiteColor] tag:TAG_ND_DETAILS_VIEW alpha:1.0];
    [mainScrollView addSubview:detailsView];
    
    UILabel *lblTitle = [APPDELEGATE createLabelWithFrame:CGRectMake(LEFT_MARGIN, LEFT_MARGIN, width-LEFT_MARGIN*2.0, height) withBGColor:[UIColor clearColor] withTXColor:[UIColor lightGrayColor] withText:[newsDictionary valueForKey:keyContent] withFont:[UIFont fontWithName:kFontHelvetica size:kDetailsFontSize] withTag:TAG_ND_LBL_DETAILS withTextAlignment:NSTextAlignmentLeft];
    [detailsView addSubview:lblTitle];
    
    mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width, detailsView.frame.origin.y + detailsView.frame.size.height);
}

#define TEXT_MARGIN 10.0

- (CGFloat)constrainedHeight
{
    return 35.0;
}

- (CGFloat)TEXT_WIDTH
{
    NSLog(@"%f", mainScrollView.frame.size.width - LEFT_MARGIN*2.0);
    return (230);
}

- (CGFloat)getHeightForText:(NSString *)text font:(UIFont *)font Width:(CGFloat)width
{
    CGSize txtSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(width, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    return txtSize.height;
}

#pragma mark - Rotation Method

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //[self setupLayoutMethods];
    if (iPad)
    {
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            // return CGSizeMake(480, 148);
            //JM 1/7/2014
            [self reSetupLayoutMethodsWithOrientation:toInterfaceOrientation Width:(1004)];
            //
        }
        else
        {
            //return CGSizeMake(719, 148);
            //JM 1/7/2014
            [self reSetupLayoutMethodsWithOrientation:toInterfaceOrientation Width:(748-LEFT_MARGIN)];
            //
        }
    }
    else
    {
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            if (IS_IPHONE_5)
            {
                [self reSetupLayoutMethodsWithOrientation:toInterfaceOrientation Width:(568-LEFT_MARGIN)];
            }
            else
            {
                [self reSetupLayoutMethodsWithOrientation:toInterfaceOrientation Width:(480-LEFT_MARGIN)];
            }
        }
        else
        {
            [self reSetupLayoutMethodsWithOrientation:toInterfaceOrientation Width:(320-LEFT_MARGIN*2.0)];
        }
    }
    [self setSagebinLogoInCenterForOrientation:toInterfaceOrientation];
}

-(void)getApiData
{
    IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
    NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strParameter = [NSString stringWithFormat:NSLocalizedString(@"apiNewsDetails", nil), strId];
    strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], strParameter];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl]];
    NSData *postData = [NSData dataWithBytes:[strParameter UTF8String] length:[strParameter length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:kTAG_NEWS_DETAILS];
    [requestConnection startAsynchronousRequest];
    
    [SEGBIN_SINGLETONE_INSTANCE addLoader];
    [self.rightButton setUserInteractionEnabled:NO];
}

#pragma mark - IMDHTTPRequest Delegates
-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didFailWithError:(NSError*)error withTag:(int)tag
{
    [self.view makeToast:kServerError];
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    [self.rightButton setUserInteractionEnabled:YES];
}

-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didSuccessWithItems:(NSObject*)items withData:(NSData*)data withTag:(int)tag
{
    [self.rightButton setUserInteractionEnabled:YES];
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    if (tag==kTAG_NEWS_DETAILS)
    {
        NSDictionary *result = (NSDictionary *)items;
        if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
        {
            [self checkUserAlert:[result objectForKey:keyAlerts]];
            
            newsDictionary = [result objectForKey:keyNews];
            //[arrData addObject:[result objectForKey:keyNews]];
            NSLog(@"%@", newsDictionary);
            [self setupLayoutMethods];
        }
        else
        {
            [self.view makeToast:kServerError];
        }
    }
    
    //[APPDELEGATE.window setUserInteractionEnabled:YES];
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
    NSLog(@"NewsDetailsViewController dealloc called");
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
