//
//  OfflineMovieListViewController.m
//  Sagebin
//
//  
//

#import "OfflineMovieListViewController.h"
#import "MovieDetailsViewController.h"
#import "CastViewController.h"
#import "DeviceTableViewController.h"

#define K_STAR_TAG 756894

@interface OfflineMovieListViewController () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
    
    NSMutableArray *arrOfflineVideos;
    __weak ChromecastDeviceController *_chromecastController;
}

@end

@implementation OfflineMovieListViewController

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
    
    //[self setViewImage:[UIImage imageNamed:@"offline-movie"] withTitle:NSLocalizedString(@"txtOfflineMovies", nil)];
    [self.view setBackgroundColor:FriendViewBgColor];
    
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
    
    arrOfflineVideos = [SEGBIN_SINGLETONE_INSTANCE getOfflineVideos];
    if([arrOfflineVideos count] > 0)
    {
        if(_collectionView)
        {
            [_collectionView removeFromSuperview];
        }
        [self setupLayoutMethods];
    }
    else
    {
        
//        if(_collectionView)
//        {
//            [_collectionView setHidden:YES];
//        }
        //[self performSelector:@selector(gotoBackScreen) withObject:nil afterDelay:1.0];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if([arrOfflineVideos count] == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
        [APPDELEGATE.window makeToast:NSLocalizedString(@"strNoOfflineMovies", nil)];
    }
}

-(void)gotoBackScreen
{
    [self.navigationController popViewControllerAnimated:YES];
    [APPDELEGATE.window makeToast:NSLocalizedString(@"strNoOfflineMovies", nil)];
}

#pragma mark - Layout Methods
-(void)setupLayoutMethods
{
    UIView *lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
    NSInteger yPos = lbl.frame.origin.y+lbl.frame.size.height+10;
    [self setViewImage:[UIImage imageNamed:@"offline-movie"] withTitle:NSLocalizedString(@"txtOfflineMovies", nil)];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        yPos = lbl.frame.origin.y;
        [self hideImageAndTitle];
    }
    [self resetTopViewLogoFrameForOrientation:orientation withImage:[UIImage imageNamed:@"offline-movie"] withTitle:NSLocalizedString(@"txtOfflineMovies", nil)];
    
    UICollectionViewFlowLayout *viewLayout = [[UICollectionViewFlowLayout alloc]init];
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, yPos, self.view.frame.size.width - 20, self.view.frame.size.height-yPos) collectionViewLayout:viewLayout];
    [_collectionView setShowsVerticalScrollIndicator:NO];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    [_collectionView setTag:TAG_OFF_MAIN];
    [self.view addSubview:_collectionView];
}
#pragma mark - UICollection Delegates
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [arrOfflineVideos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[UICollectionViewCell alloc]init];
    }
    [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    
    UIButton *view = (UIButton *)[cell viewWithTag:TAG_OFF_CELL];
    if (!view) {
        
        [self createCell:cell withData:[arrOfflineVideos objectAtIndex:indexPath.item]];
    }
    else
    {
        [self reuseCell:cell withData:[arrOfflineVideos objectAtIndex:indexPath.item]];
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
    [tempButton setTag:TAG_OFF_CELL];
    [tempButton setUserInteractionEnabled:FALSE];
    [baseView addSubview:tempButton];
    
    CGFloat Gap = 5;
    //JM 1/7/2014
    CGFloat imageWidth = (iPhone?91:91) ;// (baseView.frame.size.width/4) + (baseView.frame.size.width/8);
    //
    CGFloat otherViewX= imageWidth+Gap;// (baseView.frame.size.width/4) + (baseView.frame.size.width/8) + (2*Gap) ;
    CGFloat otherViewWidth = baseView.frame.size.width - imageWidth -(2*Gap)+5;
    CGFloat Height = baseView.frame.size.height; // - Gap
    
    NSString *strImageURL = @"";
    if([withData objectForKey:keyPoster] != [NSNull null])
    {
        strImageURL = [withData objectForKey:keyPoster];
    }
    IMDEventImageView *icon_View =[APPDELEGATE createEventImageViewWithFrame:CGRectMake(0, 0, imageWidth ,Height) withImageURL:strImageURL Placeholder:kPlaceholderImg tag:TAG_OFF_ICON_VIEW];
    [icon_View setContentMode:UIViewContentModeScaleAspectFill];
    [icon_View setClipsToBounds:YES];
    [tempButton addSubview:icon_View];
    
    if (![[withData objectForKey:keySaleFlag] isKindOfClass:[NSNull class]] && [[withData objectForKey:keySaleFlag] integerValue] == 1) {
        UIImage *image = [UIImage imageNamed:@"Sell.png"];
        UIImageView *sellImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageWidth - image.size.width -3, 2, image.size.width, image.size.height)];
        [sellImageView setImage:image];
        [sellImageView setTag:TAG_OFF_IMGVW_SELL];
        [icon_View addSubview:sellImageView];
    }
    
    UIView *otherView =[self CreateDiscriptionViewWithFrame:CGRectMake(otherViewX, 0, otherViewWidth, Height) withData:withData];
    [otherView setTag:TAG_OFF_OTHER_VIE];
    [otherView setBackgroundColor:[UIColor clearColor]];
    [baseView addSubview:otherView];
}

-(UIView *)CreateDiscriptionViewWithFrame:(CGRect)frame withData:(NSDictionary *)dictionary{
    
    UIView *innerView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:frame bgColor:[UIColor clearColor] tag:TAG_OFF_OTHER_VIE alpha:1.0];
    
    CGFloat gap = (iPad?5:0);
    CGFloat YPOS = 5;
    CGFloat lblHeight =(iPad?20:15);
    UILabel *lblMoviewTitle = [self createLabelWithFrame:CGRectMake(gap, YPOS, frame.size.width - 2*gap, lblHeight)  withTXColor:[UIColor grayColor] withText:[dictionary valueForKey:keyTitle] withFont:[APPDELEGATE Fonts_OpenSans_Light:(iPad?17:12)] withTag:TAG_OFF_LBL_TITLE withTextAlignment:NSTextAlignmentLeft];
    [lblMoviewTitle setNumberOfLines:1];
    [innerView addSubview:lblMoviewTitle];
    YPOS = lblMoviewTitle.frame.origin.y+lblMoviewTitle.frame.size.height+(iPhone?3:5);
    
    int ratePoint = [[dictionary objectForKey:keyItemRate] intValue];
    [self addStart:innerView withYpostion:YPOS withPoint:ratePoint*10];
    
    UILabel *lblRating = [self createLabelWithFrame:CGRectMake(innerView.frame.size.width/2.0-(iPad?10:3), YPOS-2, innerView.frame.size.width/2.0, lblHeight)  withTXColor:[UIColor blackColor] withText:[NSString stringWithFormat:@"Rated:%@", [dictionary valueForKey:keyItemRating]] withFont:[APPDELEGATE Fonts_OpenSans_Regular:(iPad?17:10)] withTag:TAG_OFF_LBL_RATING withTextAlignment:NSTextAlignmentRight];
    [lblRating setNumberOfLines:1];
    [innerView addSubview:lblRating];
    YPOS = lblRating.frame.origin.y + lblRating.frame.size.height;
    
    UILabel *lblDescription = [self createLabelWithFrame:CGRectMake(gap, YPOS, innerView.frame.size.width-gap*2-(iPad?10:3), innerView.frame.size.height-YPOS)  withTXColor:[UIColor blackColor] withText:[NSString stringWithFormat:@"%@", [dictionary valueForKey:keyDescription]] withFont:[APPDELEGATE Fonts_OpenSans_Regular:(iPad?15:10)] withTag:TAG_OFF_LBL_DESCRIPTION withTextAlignment:NSTextAlignmentLeft];
    [innerView addSubview:lblDescription];
    YPOS = lblDescription.frame.origin.y + lblDescription.frame.size.height;
    
    return innerView;
}


#pragma mark -
#pragma mark reuse Cell
-(void)reuseCell:(UICollectionViewCell *)baseView withData:(NSDictionary *)withData
{
    //withData = [arrData objectAtIndex:indexPath.item];
    
    UIView *view = [baseView viewWithTag:TAG_OFF_CELL];
    CGFloat Gap = 5;
    CGFloat imageWidth = (iPhone?91:91);
    CGFloat otherViewX=imageWidth+Gap;// (baseView.frame.size.width/4) + (baseView.frame.size.width/8) + (2*Gap) ;
    CGFloat otherViewWidth = baseView.frame.size.width - imageWidth -(2*Gap)+5;
    CGFloat Height = baseView.frame.size.height;// - Gap;
    
    [view setFrame:CGRectMake(0, 0, baseView.frame.size.width ,baseView.frame.size.height)];
    
    IMDEventImageView *icon_View = (IMDEventImageView *)[baseView viewWithTag:TAG_OFF_ICON_VIEW];
    [icon_View setFrame:CGRectMake(0, 0, imageWidth ,Height)];
    NSString *strImageURL = @"";
    if([withData objectForKey:keyPoster] != [NSNull null])
    {
        strImageURL = [withData objectForKey:keyPoster];
    }
    [icon_View setImageWithURL:strImageURL placeholderImage:kPlaceholderImg];
    
    if (![[withData objectForKey:keySaleFlag] isKindOfClass:[NSNull class]] && [[withData objectForKey:keySaleFlag] integerValue] == 1) {
        UIImage *image = [UIImage imageNamed:@"Sell.png"];
        UIImageView *sellImageView = (UIImageView *)[icon_View viewWithTag:TAG_OFF_IMGVW_SELL];
        if(sellImageView)
        {
            [sellImageView setFrame:CGRectMake(imageWidth - image.size.width -3, 2, image.size.width, image.size.height)];
            [sellImageView setHidden:NO];
        }
        else
        {
            sellImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageWidth - image.size.width -3, 2, image.size.width, image.size.height)];
            [sellImageView setImage:image];
            [sellImageView setTag:TAG_OFF_IMGVW_SELL];
            [icon_View addSubview:sellImageView];
        }
    }
    else
    {
        UIImageView *sellImageView = (UIImageView *)[icon_View viewWithTag:TAG_OFF_IMGVW_SELL];
        if(sellImageView)
        {
            [sellImageView setHidden:YES];
        }
    }
    
    UIView *otherView =[baseView viewWithTag:TAG_OFF_OTHER_VIE];
    [otherView setFrame:CGRectMake(otherViewX, 0, otherViewWidth, Height)];
    
    CGFloat gap = (iPad?5:0);
    CGFloat YPOS = 5;
    CGFloat lblHeight =(iPad?20:15);
    
    UILabel *lblMoviewTitle = (UILabel *) [otherView viewWithTag:TAG_OFF_LBL_TITLE];
    [lblMoviewTitle setFrame:CGRectMake(gap, YPOS, otherView.frame.size.width -2*gap, lblHeight)];
    [lblMoviewTitle setText:[withData valueForKey:keyTitle]];
    YPOS = lblMoviewTitle.frame.origin.y+lblMoviewTitle.frame.size.height+(iPhone?3:5);
    
    int ratePoint = [[withData objectForKey:keyItemRate] intValue];
    [self reuseStart:otherView withYpostion:YPOS withPoint:ratePoint*10];
    
    UILabel *lblRating = (UILabel *) [otherView viewWithTag:TAG_OFF_LBL_RATING];
    [lblRating setFrame:CGRectMake(otherView.frame.size.width/2.0-(iPad?10:3), YPOS-2, otherView.frame.size.width/2.0, lblHeight)];
    [lblRating setText:[NSString stringWithFormat:@"Rated:%@", [withData valueForKey:keyItemRating]]];
    YPOS = lblRating.frame.origin.y + lblRating.frame.size.height;
    
    UILabel *lblDescription = (UILabel *) [otherView viewWithTag:TAG_OFF_LBL_DESCRIPTION];
    [lblDescription setFrame:CGRectMake(gap, YPOS, otherView.frame.size.width-gap*2.0-(iPad?10:3), otherView.frame.size.height-YPOS)];
    [lblDescription setText:[NSString stringWithFormat:@"%@", [withData valueForKey:keyDescription]]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = iPhone_storyboard;
    if (iPad)
    {
        storyboard = self.storyboard;
    }
    MovieDetailsViewController *movieDetailsVC = (MovieDetailsViewController *) [storyboard instantiateViewControllerWithIdentifier:@"MovieDetailsVC"];
    NSDictionary *movieDictionary = [arrOfflineVideos objectAtIndex:indexPath.item];
    movieDetailsVC.strMovieId = [movieDictionary valueForKey:keyId];
    movieDetailsVC.video = movieDictionary;
    movieDetailsVC.viewType = ViewTypeOfflineList;
    [self.navigationController pushViewController:movieDetailsVC animated:YES];
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
            
            if (IS_IPHONE_5)
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
    
    //==========================
    UIView *lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
    NSInteger yPos = lbl.frame.origin.y+lbl.frame.size.height+10;
    [self setViewImage:[UIImage imageNamed:@"offline-movie"] withTitle:NSLocalizedString(@"txtOfflineMovies", nil)];
    
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        yPos = lbl.frame.origin.y;
        [self hideImageAndTitle];
    }
    
    _collectionView.frame = CGRectMake(10, yPos, self.view.frame.size.width - 20, self.view.frame.size.height-yPos);
    [self resetTopViewLogoFrameForOrientation:toInterfaceOrientation withImage:[UIImage imageNamed:@"offline-movie"] withTitle:NSLocalizedString(@"txtOfflineMovies", nil)];
}
#pragma mark - Rotation Method

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self reloadCollectionView:toInterfaceOrientation];
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
    NSLog(@"OfflineMovieListViewController dealloc called");
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
