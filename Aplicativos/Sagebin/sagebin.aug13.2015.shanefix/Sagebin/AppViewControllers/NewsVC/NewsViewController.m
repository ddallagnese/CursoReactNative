//
//  NewsViewController.m
//  Sagebin
//
//  
//

#import "NewsViewController.h"
#import "NewsDetailsViewController.h"
#import "CastViewController.h"
#import "DeviceTableViewController.h"

@interface NewsViewController () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
    
    NSMutableArray *arrData;
    __weak ChromecastDeviceController *_chromecastController;
}

@end

@implementation NewsViewController

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
    
    //[self setViewImage:[UIImage imageNamed:@"news"] withTitle:NSLocalizedString(@"txtNewsTitle", nil)];
    [self.view setBackgroundColor:NewsViewBgColor];
    
    arrData = [[NSMutableArray alloc]init];
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    
    
//    NSArray *arr = [NSArray arrayWithObjects:@"https://www.sagebin.com/test/wp-content/plugins/SagebinVideo/upload/video/_thumb/800x459.overlay_522794eaa4b0e.jpg", nil];
//    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:arr, @"image", @"hello", @"title", @"1", @"ID", nil];
//    [arrData addObject:dic];
//    [arrData addObject:dic];
    
    
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

-(void)getApiData
{
    IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
    NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], NSLocalizedString(@"apiNews", nil)];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl]];
    NSData *postData = [NSData dataWithBytes:[strParameter UTF8String] length:[strParameter length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:kTAG_NEWS];
    [requestConnection startAsynchronousRequest];
    
    [SEGBIN_SINGLETONE_INSTANCE addLoader];
    [self.rightButton setUserInteractionEnabled:NO];
}

#pragma mark - IMDHTTPRequest Delegates
//When fail parssing with error then get error for url tag
-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didFailWithError:(NSError*)error withTag:(int)tag
{
    [self.rightButton setUserInteractionEnabled:YES];
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    [self.view makeToast:kServerError];
}
//when success parssing then get nsdata and NSObject (NSArray,NSMutableDictionary,NSString) with url tag
-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didSuccessWithItems:(NSObject*)items withData:(NSData*)data withTag:(int)tag
{
    [self.rightButton setUserInteractionEnabled:YES];
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    
    if (tag==kTAG_NEWS)
    {
        NSDictionary *result = (NSDictionary *)items;
        if ([result isKindOfClass:[NSDictionary class]] && [result objectForKey:keyCode])
        {
            if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
            {
                [self checkUserAlert:[result objectForKey:keyAlerts]];
                [arrData addObjectsFromArray:[result objectForKey:keyNews]];
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
    //[APPDELEGATE.window setUserInteractionEnabled:YES];
}

#pragma mark - Layout Methods
-(void)setupLayoutMethods
{
    //UIView *lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
    //NSInteger yPos = lbl.frame.origin.y+lbl.frame.size.height+10;
    
    UIView *lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
    NSInteger yPos = lbl.frame.origin.y+lbl.frame.size.height+10;
    [self setViewImage:[UIImage imageNamed:@"news"] withTitle:NSLocalizedString(@"txtNewsTitle", nil)];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        yPos = lbl.frame.origin.y;
        [self hideImageAndTitle];
    }
    [self resetTopViewLogoFrameForOrientation:orientation withImage:[UIImage imageNamed:@"news"] withTitle:NSLocalizedString(@"txtNewsTitle", nil)];
    
    UICollectionViewFlowLayout *viewLayout = [[UICollectionViewFlowLayout alloc]init];
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, yPos, self.view.frame.size.width - 20, self.view.frame.size.height-yPos) collectionViewLayout:viewLayout];
    [_collectionView setShowsVerticalScrollIndicator:NO];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    [_collectionView setTag:TAG_NEWS_MAIN];
    [self.view addSubview:_collectionView];
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
    
    UIView *view = [cell.contentView viewWithTag:TAG_NEWS_CELL];
    if (!view) {
        
        //[self createView:cell.contentView atIndexPath:indexPath];
        [self createCell:cell.contentView withData:[arrData objectAtIndex:indexPath.item]];
    }
    else
    {
        
        //[self reuseView:cell.contentView atIndexPath:indexPath];
        [self reuseCell:cell.contentView withData:[arrData objectAtIndex:indexPath.item]];
        
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
    NewsDetailsViewController *newsDetailsVC = (NewsDetailsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"NewsDetailsVC"];
    newsDetailsVC.strId = [[arrData objectAtIndex:indexPath.item] valueForKey:keyID];
    [self.navigationController pushViewController:newsDetailsVC animated:YES];
}

-(void)createView:(UIView *)baseview atIndexPath:(NSIndexPath *)indexPath
{
    UIView *subView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(0, 0, CGRectGetWidth(baseview.frame), CGRectGetHeight(baseview.frame)) bgColor:[UIColor whiteColor] tag:TAG_NEWS_CELL alpha:1.0];
    [baseview addSubview:subView];
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

-(void)createCell:(UIView *)baseView withData:(NSDictionary *)withData {
    
    NSLog(@"%@", withData);
    
    UIButton *tempButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tempButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin |
     UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth |
     UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin];
    
    [tempButton setFrame:CGRectMake(0, 0, baseView.frame.size.width ,baseView.frame.size.height)];
    [tempButton setBackgroundColor:[UIColor whiteColor]];
    [tempButton setTag:TAG_NEWS_CELL];
    [tempButton setUserInteractionEnabled:NO];
    [baseView addSubview:tempButton];
    
    CGFloat Gap = 5;
    CGFloat imageWidth = (baseView.frame.size.width/4) + (baseView.frame.size.width/8);
    CGFloat otherViewX= (baseView.frame.size.width/4) + (baseView.frame.size.width/8) + (2*Gap) ;
    CGFloat otherViewWidth = baseView.frame.size.width - imageWidth -(4*Gap);
    CGFloat Height = baseView.frame.size.height;// - Gap;
    
    NSString *strImageURL = @"";
    if([[withData valueForKey:keyImage] isKindOfClass:[NSArray class]])
    {
        if([[withData valueForKey:keyImage] count] > 0)
        {
            strImageURL = [[withData valueForKey:keyImage] objectAtIndex:0];
        }
    }
    
    IMDEventImageView *icon_View =[APPDELEGATE createEventImageViewWithFrame:CGRectMake(0, 0, imageWidth ,Height) withImageURL:strImageURL Placeholder:kPlaceholderImage tag:TAG_NEWS_ICON_VIEW];
    [icon_View setContentMode:UIViewContentModeScaleAspectFill];
    [icon_View setClipsToBounds:YES];
    [tempButton addSubview:icon_View];
    
    UIView *otherView =[self CreateDiscriptionViewWithFrame:CGRectMake(otherViewX, 0, otherViewWidth, Height) withData:withData];
    [otherView setTag:TAG_NEWS_OTHER_VIE];
    [otherView setBackgroundColor:[UIColor clearColor]];
    [baseView addSubview:otherView];
}

-(UIButton *)createButtonWithFrame:(CGRect)frame withData:(NSDictionary *)dictionary withBgColor:(UIColor*)clr
{
    UIButton *tempButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tempButton setFrame:frame];
    [tempButton setBackgroundColor:clr];
    [tempButton setTag:TAG_NEWS_CELL];
    return tempButton;
}

-(UIView *)CreateDiscriptionViewWithFrame:(CGRect)frame withData:(NSDictionary *)dictionary{
    
    UIView *innerView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:frame bgColor:[UIColor clearColor] tag:TAG_NEWS_OTHER_VIE alpha:1.0];
    
    CGFloat gap = 5;
    CGFloat YPOS = 5;
    //JM 1/7/2014 change in height of label for ipad.
    CGFloat lblHeight =(iPad?22:15);
    //
    UILabel *lblMoviewTitle = [self createLabelWithFrame:CGRectMake(gap, YPOS, frame.size.width - 2*gap, lblHeight)  withTXColor:[UIColor grayColor] withText:[dictionary valueForKey:keyTitle] withFont:[APPDELEGATE Fonts_OpenSans_Light:(iPad?17:12)] withTag:TAG_NEWS_LBL_TITLE withTextAlignment:NSTextAlignmentLeft];
    [lblMoviewTitle setNumberOfLines:1];
    [innerView addSubview:lblMoviewTitle];
    YPOS = (YPOS*2 + lblHeight);
     
     UIColor *viewMoreColor = [UIColor colorWithRed:29.0/255.0 green:123.0/255.0 blue:127.0/255.0 alpha:1.0];
     UIButton *button1 = [self createButtonWithFrame:CGRectMake(innerView.frame.size.width-((innerView.frame.size.width/3)+5), innerView.frame.size.height - gap -((iPad?35:20)) , (innerView.frame.size.width/3)+5,(iPad?35:20))  withData:dictionary withBgColor:viewMoreColor];
     [button1.titleLabel setFont:[APPDELEGATE Fonts_OpenSans_Light:(iPad?12:8)]];
     [button1 setTag:TAG_NEWS_VIEW_MORE];
    [button1 setTitle:NSLocalizedString(@"viewMore", nil) forState:UIControlStateNormal];
    [button1 setUserInteractionEnabled:FALSE];
     [innerView addSubview:button1];
    
    return innerView;
    
}


#pragma mark -
#pragma mark reuse Cell

-(void)reuseView:(UIView *)baseView atIndexPath:(NSIndexPath *)indexPath
{
    UIView *subView = [baseView viewWithTag:TAG_NEWS_CELL];
    subView.frame = CGRectMake(0, 0, CGRectGetWidth(baseView.frame), CGRectGetHeight(baseView.frame));
    
}


-(void)reuseCell:(UIView *)baseView withData:(NSDictionary *)withData{
    
    
    UIView *view = [baseView viewWithTag:TAG_NEWS_CELL];
    CGFloat Gap = 5;
    CGFloat imageWidth = (baseView.frame.size.width/4) + (baseView.frame.size.width/8);
    CGFloat otherViewX= (baseView.frame.size.width/4) + (baseView.frame.size.width/8) + (2*Gap) ;
    CGFloat otherViewWidth = baseView.frame.size.width - imageWidth -(4*Gap);
    CGFloat Height = baseView.frame.size.height;// - Gap;
    
    
    [view setFrame:CGRectMake(0, 0, baseView.frame.size.width ,baseView.frame.size.height)];
    
    NSString *strImageURL = @"";
    if([[withData valueForKey:keyImage] isKindOfClass:[NSArray class]])
    {
        if([[withData valueForKey:keyImage] count] > 0)
        {
            strImageURL = [[withData valueForKey:keyImage] objectAtIndex:0];
        }
    }
    
    IMDEventImageView *icon_View = (IMDEventImageView *)[baseView viewWithTag:TAG_NEWS_ICON_VIEW];
    [icon_View setFrame:CGRectMake(0, 0, imageWidth ,Height)];
    [icon_View setImageWithURL:strImageURL placeholderImage:kPlaceholderImage];
    
    UIView *otherView =[baseView viewWithTag:TAG_NEWS_OTHER_VIE];
    [otherView setFrame:CGRectMake(otherViewX, 0, otherViewWidth, Height)];
    
    CGFloat gap = 5;
    CGFloat YPOS = 5;
    CGFloat lblHeight =(iPad?20:15);
    
    UILabel *lblMoviewTitle = (UILabel *) [otherView viewWithTag:TAG_NEWS_LBL_TITLE];
    [lblMoviewTitle setFrame:CGRectMake(gap, YPOS, otherView.frame.size.width -2*gap, lblHeight)];
    [lblMoviewTitle setText:[withData valueForKey:keyTitle]];
    YPOS = (YPOS*2 + lblHeight);
    
    /*UILabel *lblMovieDescription = (UILabel *) [otherView viewWithTag:TAG_ML_DESCRIPTION];
     [lblMovieDescription setFrame:CGRectMake(gap, YPOS, otherView.frame.size.width -2*gap, lblHeight*5)];
     [lblMovieDescription setText:[withData objectForKey:@"description"]];
     YPOS = (YPOS + lblHeight);*/
     
     UIButton *button1 = (UIButton *)[otherView viewWithTag:TAG_NEWS_VIEW_MORE];
     [button1 setFrame:CGRectMake(otherView.frame.size.width-((otherView.frame.size.width/3)+5), otherView.frame.size.height - gap -((iPad?35:20)), (otherView.frame.size.width/3)+5,(iPad?35:20))];
    
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
            
            if (IS_IPHONE_5_GREATER)
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
//    [_collectionView reloadData];
    [_collectionView performSelector:@selector(reloadData) withObject:self afterDelay:0.2];
    //==========================
    UIView *lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
    NSInteger yPos = lbl.frame.origin.y+lbl.frame.size.height+10;
    [self setViewImage:[UIImage imageNamed:@"news"] withTitle:NSLocalizedString(@"txtNewsTitle", nil)];
    
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        yPos = lbl.frame.origin.y;
        [self hideImageAndTitle];
    }
    
    _collectionView.frame = CGRectMake(10, yPos, self.view.frame.size.width - 20, self.view.frame.size.height-yPos);
    [self resetTopViewLogoFrameForOrientation:toInterfaceOrientation withImage:[UIImage imageNamed:@"news"] withTitle:NSLocalizedString(@"txtNewsTitle", nil)];
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
    NSLog(@"NewsViewController dealloc called");
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
