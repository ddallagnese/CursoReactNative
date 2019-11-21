//
//  SearchMovieListViewController.m
//  Sagebin
//
//  
//

#import "SearchMovieListViewController.h"
#import "MovieDetailsViewController.h"
#import "CastViewController.h"
#import "DeviceTableViewController.h"

#define kRowHeight (iPad?54:35)
#define MARGIN (iPad?15:5)

#define kSectionTitles @"MOVIE NAME"

@interface SearchMovieListViewController ()
{
    __weak ChromecastDeviceController *_chromecastController;
}
@end

@implementation SearchMovieListViewController
@synthesize movieName;

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
    
    //[self setViewImage:[UIImage imageNamed:@"search"] withTitle:NSLocalizedString(@"searchMoviesTitle", nil)];
    [self.view setBackgroundColor:SearchMoviesViewBgColor];
    
    arrData = [[NSMutableArray alloc]init];
    
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
        [self setupLayoutMethods];
        
        //add this becuase direct search from the HomePage
        moviePageNo = 1;
        movieCount = (iPad?20:10);
        txtSearch.text=movieName;
        [self getApiData];
    }
    else
    {
        [self reloadCollectionView:[UIApplication sharedApplication].statusBarOrientation];
    }
   
    
    
    
   
}

#pragma mark - Layout Methods
-(void)setupLayoutMethods
{
    UIView *lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
    NSInteger yPos = lbl.frame.origin.y+lbl.frame.size.height;
    [self setViewImage:[UIImage imageNamed:@"search"] withTitle:NSLocalizedString(@"searchMoviesTitle", nil)];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        yPos = lbl.frame.origin.y+5;
        [self hideImageAndTitle];
    }
    [self resetTopViewLogoFrameForOrientation:orientation withImage:[UIImage imageNamed:@"search"] withTitle:NSLocalizedString(@"searchMoviesTitle", nil)];
    
    // Search Bar
    searchView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake((iPad?26:12), yPos+13, self.view.frame.size.width-(iPad?52:24), kRowHeight) bgColor:[UIColor whiteColor] tag:-1 alpha:1.0];
    [searchView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    txtSearch = [SEGBIN_SINGLETONE_INSTANCE createTextFieldWithFrame:CGRectMake(MARGIN, kRowHeight/2-kRowHeight/4, searchView.frame.size.width-(iPad?54:30)-MARGIN,kRowHeight/2) placeHolder:NSLocalizedString(@"txtSearchMovie", nil) font:[APPDELEGATE Fonts_OpenSans_LightItalic:(iPad?18:10)] textColor:[UIColor blackColor] tag:TAG_SearchText];
    [txtSearch setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth];
    [txtSearch setDelegate:self];
    [txtSearch setClearButtonMode:UITextFieldViewModeWhileEditing];
    [txtSearch setReturnKeyType:UIReturnKeySearch];
    [searchView addSubview:txtSearch];
    
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSearch setTag:TAG_SearchButton];
    [btnSearch setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [btnSearch setImage:[UIImage imageNamed:@"friend_search"] forState:UIControlStateNormal];
    [btnSearch addTarget:self action:@selector(searchMovie:) forControlEvents:UIControlEventTouchUpInside];
    [btnSearch setFrame:CGRectMake(txtSearch.frame.origin.x + txtSearch.frame.size.width, 0,(iPad?54:30), searchView.frame.size.height)];
    [searchView addSubview:btnSearch];
    [self.view addSubview:searchView];
    
    arraySectionTitles = [[NSMutableArray alloc]init];
    [arraySectionTitles addObjectsFromArray:[kSectionTitles componentsSeparatedByString:@","]];

    yPos = searchView.frame.size.height+searchView.frame.origin.y+20;
    searchTable = [[UITableView alloc]initWithFrame:CGRectMake((iPad?26:12), yPos, self.view.frame.size.width-(iPad?26:12)*2, self.view.frame.size.height-yPos-10) style:UITableViewStylePlain];
    searchTable.tag = TAG_SearchTable;
    searchTable.delegate = self;
    searchTable.dataSource = self;
    searchTable.backgroundView = nil;
    searchTable.backgroundColor = [UIColor clearColor];
    [searchTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [searchTable setShowsVerticalScrollIndicator:NO];
    [searchTable setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    if ([searchTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [searchTable setSeparatorInset:UIEdgeInsetsZero];
    }
    [self.view addSubview:searchTable];
    [searchTable setHidden:YES];
    
    //Pull to refresh
    __unsafe_unretained typeof(self) weakSelf = self;
    [searchTable addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
}

#pragma mark - TextField Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.text.length > 0)
    {
        if(APPDELEGATE.netOnLink == 0)
        {
            [self.view makeToast:WARNING];
        }
        else
        {
            [arrData removeAllObjects];
            moviePageNo = 1;
            movieCount = (iPad?20:10);
            [self getApiData];
        }
    }
    else
    {
        [self.view makeToast:NSLocalizedString(@"txtSearchEmpty", nil)];
    }
    
    return [textField resignFirstResponder];
}

#pragma mark - Search Button Action
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
        [arrData removeAllObjects];
        moviePageNo = 1;
        movieCount = (iPad?20:10);
        [self getApiData];
    }
    else
    {
        [self.view makeToast:NSLocalizedString(@"txtSearchEmpty", nil)];
    }
}

-(void)getApiData
{
    IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
    NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *strParameter = [NSString stringWithFormat:NSLocalizedString(@"apiSearchMovie", nil), txtSearch.text, moviePageNo, movieCount];
    strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], strParameter];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl]];
    NSData *postData = [NSData dataWithBytes:[strParameter UTF8String] length:[strParameter length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:kTAG_SEARCH_MOVIE];
    [requestConnection startAsynchronousRequest];
    
    if(arrData.count == 0)
    {
        [SEGBIN_SINGLETONE_INSTANCE addLoader];
    }
    
    [self enableDisableUI:FALSE];
}

-(void)enableDisableUI:(BOOL)status
{
    [self.rightButton setUserInteractionEnabled:status];
    [searchView setUserInteractionEnabled:status];
    [searchTable setUserInteractionEnabled:status];
}

#pragma mark - IMDHTTPRequest Delegates
-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didFailWithError:(NSError*)error withTag:(int)tag
{
    [self.view makeToast:kServerError];
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    isRefresh = NO;
    [self enableDisableUI:TRUE];
}

-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didSuccessWithItems:(NSObject*)items withData:(NSData*)data withTag:(int)tag
{
    [self enableDisableUI:TRUE];
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    if (tag==kTAG_SEARCH_MOVIE)
    {
        NSDictionary *result = (NSDictionary *)items;
        if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
        {
            [self checkUserAlert:[result objectForKey:keyAlerts]];
            if([result valueForKey:keyValue] == [NSNull null] || [[result valueForKey:keyValue] count] == 0)
            {
                //UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert Dialog" message:@"No video(s) available!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                //[alert show];
                [self.view makeToast:NSLocalizedString(@"noMoviesAvailable", nil)];
                [searchTable setHidden:YES];
            }
            else{
        
                if(isRefresh)
                {
                    [arrData removeAllObjects];
                    isRefresh = NO;
                }
                totalCount = [[result valueForKey:keyTotalCount] intValue];
                [arrData addObjectsFromArray:[result objectForKey:keyValue]];
                [searchTable setHidden:NO];
                [searchTable reloadData];
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
            [searchTable.infiniteScrollingView setHidden:YES];
            [searchTable addInfiniteScrollingWithActionHandler:^{
                [weakSelf insertRowAtBottom];
            }];
        }
        
        [searchTable.pullToRefreshView stopAnimating];
        
        if ([arrData count] !=  totalCount && ([arrData count] < totalCount))
        {
            [searchTable.infiniteScrollingView stopAnimating];
            [searchTable setShowsInfiniteScrolling:YES];
        }
        else
        {
            [searchTable.infiniteScrollingView stopAnimatingWithNoUpdate];
            [searchTable setShowsInfiniteScrolling:NO];
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

    UILabel *lbl = [APPDELEGATE createLabelWithFrame:CGRectMake(MARGIN, kRowHeight/2-kRowHeight/4, 280-MARGIN*2.0, kRowHeight/2) withBGColor:[UIColor clearColor] withTXColor:[UIColor colorWithRed:94.0/255.0 green:173.0/255.0 blue:221.0/255.0 alpha:1.0] withText:[NSString stringWithFormat:@"%@", [arraySectionTitles objectAtIndex:section]] withFont:[UIFont fontWithName:kFontHelvetica size:(iPad?18:14)] withTag:-1 withTextAlignment:NSTextAlignmentLeft];
    [view addSubview:lbl];
    
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

    return cell;
}

- (void)setupCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    NSDictionary *movieDictionary = [arrData objectAtIndex:indexPath.row];
    
    UIView *whiteBGView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(0, 0, searchTable.frame.size.width, kRowHeight) bgColor:[UIColor whiteColor] tag:TAG_SearchReuseView alpha:1.0];
    [cell addSubview:whiteBGView];
    
    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(MARGIN, kRowHeight/2-kRowHeight/4, searchTable.frame.size.width-MARGIN*2, kRowHeight/2.0)];
    [lblTitle setFont:[UIFont fontWithName:kFontHelvetica size:(iPad?18:14)]];
    [lblTitle setTag:TAG_Search_LblTitle];
    [lblTitle setTextColor:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:[movieDictionary valueForKey:keyTitle]];
    [cell addSubview:lblTitle];
    
    CGFloat lineHeight = 1.0/[UIScreen mainScreen].scale;
    UIView *line = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(0, kRowHeight - lineHeight, self.view.frame.size.width-10*2, lineHeight) bgColor:[UIColor blackColor] tag:Tag_Search_ViewLine alpha:0.3];
    [cell addSubview:line];
}

- (void)updateCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    NSDictionary *movieDictionary = [arrData objectAtIndex:indexPath.row];
    
    UIView *whiteBGView = (UIView *)[cell viewWithTag:TAG_SearchReuseView];
    [whiteBGView setFrame:CGRectMake(0, 0, searchTable.frame.size.width, kRowHeight)];
    
    CGRect frame = CGRectMake(MARGIN, kRowHeight/2-kRowHeight/4, searchTable.frame.size.width-MARGIN*2, kRowHeight/2.0);
    UILabel *label = (UILabel *)[cell viewWithTag:TAG_Search_LblTitle];
    [label setText:[movieDictionary valueForKey:keyTitle]];
    label.frame = frame;
    
    CGFloat lineHeight = 1.0/[UIScreen mainScreen].scale;
    UIView *line = (UIView *)[cell viewWithTag:Tag_Search_ViewLine];
    [line setFrame:CGRectMake(0, kRowHeight - lineHeight, self.view.frame.size.width-10*2, lineHeight)];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrData count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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
    NSDictionary *movieDictionary = [arrData objectAtIndex:indexPath.row];
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
        [searchTable.infiniteScrollingView setHidden:NO];
        [searchTable setShowsInfiniteScrolling:YES];
        moviePageNo = moviePageNo + 1;
        [self getApiData];
    }
    else
    {
        [searchTable.infiniteScrollingView setHidden:YES];
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

- (void)reloadCollectionView:(UIInterfaceOrientation)toInterfaceOrientation
{
    [searchTable reloadData];
    
    //==========================
    UIView *lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
    NSInteger yPos = lbl.frame.origin.y+lbl.frame.size.height;
    [self setViewImage:[UIImage imageNamed:@"search"] withTitle:NSLocalizedString(@"searchMoviesTitle", nil)];
    
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        yPos = lbl.frame.origin.y;
        [self hideImageAndTitle];
    }
    
    searchView.frame = CGRectMake(searchView.frame.origin.x, yPos+13, searchView.frame.size.width, searchView.frame.size.height);
    yPos = searchView.frame.size.height+searchView.frame.origin.y+20;
    searchTable.frame = CGRectMake(searchTable.frame.origin.x, yPos, searchTable.frame.size.width, self.view.frame.size.height-yPos-10);
    NSLog(@"%f  %f",searchTable.frame.size.height,self.view.frame.size.height);
    
    [self resetTopViewLogoFrameForOrientation:toInterfaceOrientation withImage:[UIImage imageNamed:@"search"] withTitle:NSLocalizedString(@"searchMoviesTitle", nil)];
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
    NSLog(@"SearchMovieListViewController dealloc called");
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
