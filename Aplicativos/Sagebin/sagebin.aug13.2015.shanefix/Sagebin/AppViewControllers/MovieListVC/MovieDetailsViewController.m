//
//  MovieDetailsViewController.m
//  Sagebin
//
//  
//

#import "MovieDetailsViewController.h"
#import "ASIHTTPRequest.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CastViewController.h"
#import "LocalPlayerViewController.h"
#import "DeviceTableViewController.h"

static NSString * kReceiverAppID;

#define MARGIN (iPad?20.0:10.0)
#define PICTURE_HEIGHT (iPad?400:200)
#define TITLE_VIEW_HEIGHT (iPad?100:55)
#define STAR_VIEW_HEIGHT (iPad?20:10)
#define BUTTON_HEIGHT (iPad?50:35)
#define LABEL_HEIGHT (iPad?40:35)

#define kTitleFontSize (iPad?20:20)
#define kButtonFontSize (iPad?9:9)
#define kDetailsFontSize (iPad?15:12)
#define kPlayMessFontSize (iPad?15:12)

@interface MovieDetailsViewController ()
{
    __weak ChromecastDeviceController *_chromecastController;
}
@end

@implementation MovieDetailsViewController

@synthesize strMovieId;
@synthesize video;
@synthesize timerForCountdown;
@synthesize viewType;
@synthesize movieType;

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
  
    
    UIButton *btnSettings = [self rightButton];
    [btnSettings setHidden:YES];
    
    UIButton *btnAlert = [self alertButton];
    [btnAlert setHidden:YES];
    
    //Change : Remove condition comment
    
    [self.view setBackgroundColor:MovieDetailsViewBgColor];

    temporaryDownloadedVideos = [[NSMutableArray alloc]init];
    strMessage = NSLocalizedString(@"strDownlodingCancel", nil);
    
    UIView *lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
    NSInteger yPos = lbl.frame.origin.y;
    
    mainScrollView = [SEGBIN_SINGLETONE_INSTANCE createScrollViewWithFrame:CGRectMake(0, yPos, self.view.frame.size.width, self.view.frame.size.height-yPos-MARGIN) bgColor:nil tag:-1 delegate:nil];
    [mainScrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:mainScrollView];
    
    if(video)
    {
        if([[video valueForKey:keyOfflineMode] intValue] != 2) // remove movie details from local memory if it is not downloaded
        {
            [self removeOfflineMovieIfTimeOver];
        }
        self.viewType = ViewTypeOfflineList;
        [self setupLayoutMethods];
    }
    else
    {
        [self callMovieDetailApi];
    }
   
}

-(void)dealloc
{
    NSLog(@"MovieDetailsViewController dealloc called");
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([[NSUserDefaults standardUserDefaults] objectForKey:keyIsAlertAvailable])
    {
        [self.alertButton setHidden:YES];
    }
    
    // Assign ourselves as delegate ONLY in viewWillAppear of a view controller.
    _chromecastController = APPDELEGATE.chromecastDeviceController;
    _chromecastController.delegate = self;
    
    if (_chromecastController.deviceScanner.devices.count > 0)
    {
        UIButton *btnCast = (UIButton *)[self.view viewWithTag:kTagCastButton];
        if(!btnCast)
        {
            //btnCast = [self rightButton];
            btnCast = (UIButton *)_chromecastController.chromecastBarButton.customView;
            [btnCast setTag:kTagCastButton];
            [btnCast setHidden:NO];
            if(iPhone)
            {
                [btnCast setFrame:CGRectMake(self.view.frame.size.width - (btnCast.frame.size.width+5), (iOS7?35:15), btnCast.frame.size.width, btnCast.frame.size.height)];
            }
            else
            {
                [btnCast setFrame:CGRectMake(self.view.frame.size.width - (btnCast.frame.size.width+10), (iOS7?40:20), btnCast.frame.size.width, btnCast.frame.size.height)];
            }
            [self.view addSubview:btnCast];
        }
    }
    
  //  [self setSagebinLogoInCenterForOrientation:[UIApplication sharedApplication].statusBarOrientation];
    
    if(video == nil)
    {
        return;
    }
    
    if(APPDELEGATE.isFromBuyMovie)
    {
        APPDELEGATE.isFromBuyMovie = NO;
        [self removeUI];
        [self callMovieDetailApi];
        return;
    }
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (iPad)
    {
        //JM 1/7/2014
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
           // [self reSetupLayoutMethodsWithOrientation:orientation Width:(1004)];
             [self reSetupLayoutMethodsWithOrientation_iPad:orientation Width:(1004)];
        }
        else
        {
            [self reSetupLayoutMethodsWithOrientation:orientation Width:(748-MARGIN)];
        }
        //
    }
    else
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            if (IS_IPHONE_5_GREATER)
            {
                [self reSetupLayoutMethodsWithOrientation:orientation Width:(568-MARGIN)];
            }
            else
            {
                [self reSetupLayoutMethodsWithOrientation:orientation Width:(480-MARGIN)];
            }
        }
        else
        {
            [self reSetupLayoutMethodsWithOrientation:orientation Width:(320-MARGIN*2.0)];
        }
    }
    [self setSagebinLogoInCenterForOrientation:orientation];
}

- (void)viewDidAppear:(BOOL)animated {
    [_chromecastController updateToolbarForViewController:self];
   
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Layout Methods
-(void)setupLayoutMethods
{
    [self createProgressView];
    [self createPictureView];
    [self createTitleView];
    [self createDetailsView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeDownloading) name:@"resumeDownloading" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelDownloading) name:@"cancelDownloading" object:nil];
   
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (iPad)
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
//            [self reSetupLayoutMethodsWithOrientation:orientation Width:(1004)];
             [self reSetupLayoutMethodsWithOrientation_iPad:orientation Width:(1004)];
        }
        else
        {
            [self reSetupLayoutMethodsWithOrientation:orientation Width:(748-MARGIN)];
        }
    }
    else
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            if (IS_IPHONE_5_GREATER)
            {
                [self reSetupLayoutMethodsWithOrientation:orientation Width:(568-MARGIN)];
            }
            else
            {
                [self reSetupLayoutMethodsWithOrientation:orientation Width:(480-MARGIN)];
            }
        }
        else
        {
            [self reSetupLayoutMethodsWithOrientation:orientation Width:(320-MARGIN*2.0)];
        }
    }
   
}

#pragma mark - Called When Orientation Changes
-(void)reSetupLayoutMethodsWithOrientation:(UIInterfaceOrientation)orientation Width:(CGFloat)width
{
    if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        CGFloat viewWidth = width/2;
        CGFloat xPos=10;
        
        UIView *lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
        CGFloat yPos = lbl.frame.origin.y;
        [self resetFrameForProgressViewInView:self.view yPos:yPos width:width];
        
        //===========================================
        CGFloat textHeight = [self getHeightForText:[video valueForKey:keyTitle] font:[UIFont fontWithName:kFontHelvetica size:kTitleFontSize] constrainedWidth:viewWidth-MARGIN*2.0];
        
        //[titleView setFrame:CGRectMake(viewWidth, 0, viewWidth, titleView.frame.size.height)];
        UILabel *lblTitle = (UILabel *)[titleView viewWithTag:TAG_MD_LBL_TITLE];
        if(lblTitle)
        {
            [lblTitle setFrame:CGRectMake(MARGIN, MARGIN-5, viewWidth-MARGIN*2.0, textHeight)];
        }
        
        CGFloat videoRate = [[video valueForKey:keyItemRate] floatValue];
        yPos = lblTitle.frame.origin.y+lblTitle.frame.size.height;
        [SEGBIN_SINGLETONE_INSTANCE reuseStart:titleView withYpostion:(yPos+5) withPoint:videoRate*10.0];
        CGFloat starViewHeight = (iPad ? 20 : 10);
        
        UILabel *lblRating = (UILabel *)[titleView viewWithTag:TAG_MD_LBL_RATING];
        if(lblRating)
        {
            [lblRating setFrame:CGRectMake(viewWidth/2.0, yPos-3, viewWidth/3.0+10, lblRating.frame.size.height)];
        }

        CustomButton *favBtn = (CustomButton *)[titleView viewWithTag:TAG_MD_FAVOURITE_BTN];
        if(favBtn)
        {
            [favBtn setFrame:CGRectMake(lblRating.frame.origin.x+lblRating.frame.size.width+5, yPos-7, favBtn.frame.size.width, favBtn.frame.size.height)];
        }
        CustomButton *RemovefavBtn = (CustomButton *)[titleView viewWithTag:TAG_MD_REMOVE_FAVOURITE_BTN];
        if(RemovefavBtn)
        {
            [RemovefavBtn setFrame:CGRectMake(lblRating.frame.origin.x+lblRating.frame.size.width+5, yPos-7, RemovefavBtn.frame.size.width, RemovefavBtn.frame.size.height)];
        }

        
        
        [titleView setFrame:CGRectMake(viewWidth, 0, viewWidth, (yPos+5)+starViewHeight+MARGIN)];
        //===========================================
        
        //===========================================
        textHeight = [self getHeightForText:[video valueForKey:keyDescription] font:[UIFont fontWithName:kFontHelvetica size:kDetailsFontSize] constrainedWidth:viewWidth-MARGIN*2.0];
        [detailsView setFrame:CGRectMake(viewWidth, titleView.frame.origin.y+titleView.frame.size.height, viewWidth,textHeight+MARGIN*2.0)];
        yPos = MARGIN;
        UILabel *lblDetails = (UILabel *)[detailsView viewWithTag:TAG_MD_LBL_DETAILS];
        if(lblDetails)
        {
            [lblDetails setFrame:CGRectMake(MARGIN, MARGIN, viewWidth-MARGIN*2.0, textHeight)];
            yPos = lblDetails.frame.origin.y + lblDetails.frame.size.height + MARGIN;
        }
        
       
        
        UILabel *lblPlayMess = (UILabel *)[detailsView viewWithTag:TAG_MD_LBL_PLAYMESS];
        if(lblPlayMess)
        {
            [lblPlayMess setFrame:CGRectMake(MARGIN, yPos, viewWidth-MARGIN*2.0, LABEL_HEIGHT)];
            yPos = lblPlayMess.frame.origin.y + lblPlayMess.frame.size.height + MARGIN;
        }
        if ([[video objectForKey:keyCanPlay] isEqualToNumber:[NSNumber numberWithInt:1]])
        {
            CustomButton *btnTrailer = (CustomButton *)[detailsView viewWithTag:TAG_MD_BTN_TRAILER];
            if (btnTrailer)
            {
                [btnTrailer setFrame:CGRectMake(MARGIN, yPos, viewWidth-MARGIN*2.0, BUTTON_HEIGHT)];
                yPos = yPos + BUTTON_HEIGHT + MARGIN;
            }
            
        }
        
        if([[video objectForKey:keyIsMyVideo] isEqualToNumber:[NSNumber numberWithInt:1]]) // For my video
        {
            if([video objectForKey:keyLents]) //it means someone has borrowed your video
            {
                CustomButton *btnRevoke = (CustomButton *)[detailsView viewWithTag:VideoActionRevoke];
                if(btnRevoke)
                {
                    [btnRevoke setFrame:CGRectMake(MARGIN, yPos, viewWidth-MARGIN*2.0, BUTTON_HEIGHT)];
                    yPos = yPos + BUTTON_HEIGHT + MARGIN;
                }
            }
            else // it means you can give your video to anyone
            {
                BOOL flag = [APPDELEGATE checkForDownloadedVideo:video];
                if([[video valueForKey:keyOfflineMode] intValue] == 2)
                {
                    if(flag) // it means download is complete
                    {
                        if([[video valueForKey:keyIsAlreadyDownloaded] intValue] == 1) // it means already downloaded in this device
                        {
                            //resetFrameForOptionsAfterCompleteDownloadInView
                            yPos = [self resetFrameForRenewRemoveInView:detailsView yPos:yPos width:viewWidth];
                        }
                        else // it means video is downloaded but in other device
                        {
                            //resetFrameForDownloadToViewOfflineButtonInView
                            yPos = [self resetFrameForDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:viewWidth];
                        }
                    }
                    else // it means download is not complete (in progress)
                    {
                        if([video valueForKey:keyIsAlreadyDownloaded])
                        {
                            if([[video valueForKey:keyIsAlreadyDownloaded] intValue] == 0) // Download Button
                            {
                                //resetFrameForDownloadToViewOfflineButtonInView
                                yPos = [self resetFrameForDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:viewWidth];
                            }
                            else
                            { // Sell, Send, Gift Buttons
                                //resetFrameForOptionsForMyVideoInView
                                yPos = [self resetFrameForOptionsForMyVideoInView:detailsView yPos:yPos width:viewWidth];
                                //resetFrameForDownloadToViewOfflineButtonInView
                                //BOOL SellFlag = [[video objectForKey:keySaleFlag] integerValue];
                                //if(!SellFlag)
                                {
                                    yPos = [self resetFrameForDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:viewWidth];
                                }
                            }
                        }
                        else
                        {
                            //resetFrameForOptionsForMyVideoInView
                            yPos = [self resetFrameForOptionsForMyVideoInView:detailsView yPos:yPos width:viewWidth];
                            //resetFrameForDownloadToViewOfflineButtonInView
                            //BOOL SellFlag = [[video objectForKey:keySaleFlag] integerValue];
                            //if(!SellFlag)
                            {
                                yPos = [self resetFrameForDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:viewWidth];
                            }
                        }
                    }
                }
                else if([[video valueForKey:keyOfflineMode] intValue] == 0)
                {
                    //resetFrameForOptionsForMyVideoInView
                    yPos = [self resetFrameForOptionsForMyVideoInView:detailsView yPos:yPos width:viewWidth];
                    //resetFrameForDownloadToViewOfflineButtonInView
                    //BOOL SellFlag = [[video objectForKey:keySaleFlag] integerValue];
                    //if(!SellFlag)
                    {
                        yPos = [self resetFrameForDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:viewWidth];
                    }
                }
            }
        }
        else // for friend video
        {
            
            
            if ([[video objectForKey:keyCanBorrow] intValue] == 1)
            {
                int count = [[video objectForKey:keyBorrowFriends] count];
                for(int i=0;i<count;i++)
                {
                    //NSDictionary *user = [[video objectForKey:keyBorrowFriends] objectAtIndex:i];
                    
                    CustomButton *btnBorrow = (CustomButton *)[detailsView viewWithTag:(VideoActionBorrow+i)];
                    if(btnBorrow)
                    {
                        [btnBorrow setFrame:CGRectMake(MARGIN, yPos, viewWidth-MARGIN*2.0, BUTTON_HEIGHT)];
                        yPos = yPos + BUTTON_HEIGHT + MARGIN;
                    }
                }
                
               
            }
            else // it means you have already borrowed friend's video
            {
                NSDictionary *borrow = [video objectForKey:keyBorrow];
                if ([[borrow objectForKey:keyOwnerType] intValue] == 1)
                {// it means your borrow request is accepted
                    CustomButton *btnReturn = (CustomButton *)[detailsView viewWithTag:VideoActionReturn];
                    if(btnReturn)
                    {
                        [btnReturn setFrame:CGRectMake(MARGIN, yPos, viewWidth-MARGIN*2.0, BUTTON_HEIGHT)];
                        yPos = yPos + BUTTON_HEIGHT + MARGIN;
                    }
                    
                    BOOL flag = [APPDELEGATE checkForDownloadedVideo:video];
                    if([[video valueForKey:keyOfflineMode] intValue] == 2)
                    {// it means you have downloaded video (download request is set on server)
                        
                        if(flag) // it means download is complete
                        {
                            //resetFrameForOptionsAfterCompleteDownloadInView
                            yPos = [self resetFrameForRenewRemoveInView:detailsView yPos:yPos width:viewWidth];
                        }
                        else
                        {
                            //resetFrameForDownloadToViewOfflineButtonInView
                            yPos = [self resetFrameForDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:viewWidth];
                        }
                    }
                    else if([[video valueForKey:keyOfflineMode] intValue] == 0) // if video is not downloaded //offline-mode---
                    {
                        //resetFrameForDownloadToViewOfflineButtonInView
                        yPos = [self resetFrameForDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:viewWidth];
                    }
                }
            }
        }
        
        CustomButton *dvdBtn = (CustomButton *)[detailsView viewWithTag:DvdBtn];
        
        [dvdBtn setFrame:CGRectMake(MARGIN, yPos, dvdBtn.frame.size.width, BUTTON_HEIGHT)];
        
        CustomButton *BlurayyBtn = (CustomButton *)[detailsView viewWithTag:BlurayBtn];
        
        [BlurayyBtn setFrame:CGRectMake(dvdBtn.frame.origin.x+dvdBtn.frame.size.width+5, yPos,BlurayyBtn.frame.size.width-5, BUTTON_HEIGHT)];
        
        if(dvdBtn && BlurayyBtn)
        {
            [dvdBtn setFrame:CGRectMake(MARGIN, yPos,  (viewWidth-MARGIN*2.0)/2, BUTTON_HEIGHT)];
            [BlurayyBtn setFrame:CGRectMake(dvdBtn.frame.origin.x+dvdBtn.frame.size.width+5, yPos,  (viewWidth-MARGIN*2.0)/2-5, BUTTON_HEIGHT)];
            yPos = yPos + BUTTON_HEIGHT + MARGIN;
        }
        else if(dvdBtn && !BlurayyBtn)
        {
            [dvdBtn setFrame:CGRectMake(MARGIN, yPos,  viewWidth-MARGIN*2.0, BUTTON_HEIGHT)];
            yPos = yPos + BUTTON_HEIGHT + MARGIN;
        }
        else if(!dvdBtn && BlurayyBtn)
        {
            [BlurayyBtn setFrame:CGRectMake(MARGIN, yPos,  viewWidth-MARGIN*2.0, BUTTON_HEIGHT)];
            yPos = yPos + BUTTON_HEIGHT + MARGIN;
        }
        else
        {
            
        }

        [detailsView setFrame:CGRectMake(detailsView.frame.origin.x, detailsView.frame.origin.y, detailsView.frame.size.width,yPos)];
        //===========================================
        
        [pictureView setFrame:CGRectMake(MARGIN, 0, viewWidth, detailsView.frame.origin.y+detailsView.frame.size.height)];
        if ([[video objectForKey:keyCanPlay] isEqualToNumber:[NSNumber numberWithInt:1]])
        {
            CustomButton *btnPlay = (CustomButton *)[pictureView viewWithTag:TAG_MD_BTN_PLAY];
            //btnPlay.center = pictureView.center;
            if(btnPlay)
            {
                btnPlay.frame = CGRectMake(pictureView.frame.size.width/2-btnPlay.frame.size.width/2, pictureView.frame.size.height/2-btnPlay.frame.size.height/2, btnPlay.frame.size.width, btnPlay.frame.size.height);
            }
        }
        else
        {
            CustomButton *btnTrailer = (CustomButton *)[pictureView viewWithTag:TAG_MD_BTN_TRAILER];
            if (btnTrailer)
            {
                [btnTrailer setFrame:CGRectMake(pictureView.frame.size.width/2-btnTrailer.frame.size.width/2, pictureView.frame.size.height/2-btnTrailer.frame.size.height/2, btnTrailer.frame.size.width, btnTrailer.frame.size.height)];
                
            }
        }
        int btnWidth;
        if(![[video objectForKey:keyItemStreaming_360] isEqualToString:@""] && ![[video objectForKey:keyItemStreaming_720] isEqualToString:@""] && ![[video objectForKey:keyItemStreaming_1080] isEqualToString:@""])
        {
            btnWidth=pictureView.frame.size.width/3.3;
        }
        else
        {
            btnWidth=pictureView.frame.size.width/2.2;
        }
        CustomButton *btnLowDef = (CustomButton *)[pictureView viewWithTag:TAG_MD_BTN_LOWDEF];
        if(btnLowDef)
        {
            [btnLowDef setFrame:CGRectMake(xPos,pictureView.frame.size.height-(iPad?60:30)-5, btnWidth, btnLowDef.frame.size.height)];
            xPos=xPos+btnLowDef.frame.size.width+5;
        }
        
        CustomButton *btnHighDef = (CustomButton *)[pictureView viewWithTag:TAG_MD_BTN_HIGHDEF];
        if(btnHighDef)
        {
            [btnHighDef setFrame:CGRectMake(xPos,pictureView.frame.size.height-(iPad?60:30)-5, btnWidth, btnHighDef.frame.size.height)];
            xPos=xPos+btnHighDef.frame.size.width+5;
        }
        CustomButton *btnUltraDef = (CustomButton *)[pictureView viewWithTag:TAG_MD_BTN_ULTRADEF];
        if(btnUltraDef)
        {
            [btnUltraDef setFrame:CGRectMake(xPos,pictureView.frame.size.height-(iPad?60:30)-5, btnWidth, btnUltraDef.frame.size.height)];
            xPos=xPos+btnUltraDef.frame.size.width+5;
        }
        
        
        mainScrollView.contentSize = CGSizeMake(width, pictureView.frame.origin.y+pictureView.frame.size.height);
    }
    else //==================================== Portrait ========================================================
    {
        UIView *lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
        CGFloat yPos = lbl.frame.origin.y;
        CGFloat xPos=10;
        [self resetFrameForProgressViewInView:self.view yPos:yPos width:width];
        
        [pictureView setFrame:CGRectMake(MARGIN, 0, width, PICTURE_HEIGHT)];
        if ([[video objectForKey:keyCanPlay] isEqualToNumber:[NSNumber numberWithInt:1]])
        {
            CustomButton *btnPlay = (CustomButton *)[pictureView viewWithTag:TAG_MD_BTN_PLAY];
            //btnPlay.center = pictureView.center;
            if(btnPlay)
            {
                btnPlay.frame = CGRectMake(pictureView.frame.size.width/2-btnPlay.frame.size.width/2, pictureView.frame.size.height/2-btnPlay.frame.size.height/2, btnPlay.frame.size.width, btnPlay.frame.size.height);
            }
        }
        else
        {
            CustomButton *btnTrailer = (CustomButton *)[pictureView viewWithTag:TAG_MD_BTN_TRAILER];
            if (btnTrailer)
            {
                [btnTrailer setFrame:CGRectMake(pictureView.frame.size.width/2-btnTrailer.frame.size.width/2, pictureView.frame.size.height/2-btnTrailer.frame.size.height/2, btnTrailer.frame.size.width, btnTrailer.frame.size.height)];
               
            }
        }
        
        
        int btnWidth;
        if(![[video objectForKey:keyItemStreaming_360] isEqualToString:@""] && ![[video objectForKey:keyItemStreaming_720] isEqualToString:@""] && ![[video objectForKey:keyItemStreaming_1080] isEqualToString:@""])
        {
            btnWidth=pictureView.frame.size.width/3.3;
        }
        else
        {
            btnWidth=pictureView.frame.size.width/2.2;
        }
        
        CustomButton *btnLowDef = (CustomButton *)[pictureView viewWithTag:TAG_MD_BTN_LOWDEF];
        if(btnLowDef)
        {
            [btnLowDef setFrame:CGRectMake(xPos,pictureView.frame.size.height-(iPad?60:30)-5, btnWidth, btnLowDef.frame.size.height)];
            xPos=xPos+btnLowDef.frame.size.width+5;
        }
        
        CustomButton *btnHighDef = (CustomButton *)[pictureView viewWithTag:TAG_MD_BTN_HIGHDEF];
        if(btnHighDef)
        {
            [btnHighDef setFrame:CGRectMake(xPos,pictureView.frame.size.height-(iPad?60:30)-5, btnWidth, btnHighDef.frame.size.height)];
            xPos=xPos+btnHighDef.frame.size.width+5;
        }
        CustomButton *btnUltraDef = (CustomButton *)[pictureView viewWithTag:TAG_MD_BTN_ULTRADEF];
        if(btnUltraDef)
        {
            [btnUltraDef setFrame:CGRectMake(xPos,pictureView.frame.size.height-(iPad?60:30)-5, btnWidth, btnUltraDef.frame.size.height)];
            xPos=xPos+btnUltraDef.frame.size.width+5;
        }


        
        
        //===========================================
        CGFloat textHeight = [self getHeightForText:[video valueForKey:keyTitle] font:[UIFont fontWithName:kFontHelvetica size:kTitleFontSize] constrainedWidth:width-MARGIN*2.0];
        
        UILabel *lblTitle = (UILabel *)[titleView viewWithTag:TAG_MD_LBL_TITLE];
        if(lblTitle)
        {
            [lblTitle setFrame:CGRectMake(MARGIN, MARGIN-5, width-MARGIN*2.0, textHeight)];
        }
        
        CGFloat videoRate = [[video valueForKey:keyItemRate] floatValue];
        yPos = (lblTitle.frame.origin.y+lblTitle.frame.size.height);
        [SEGBIN_SINGLETONE_INSTANCE reuseStart:titleView withYpostion:(yPos+5) withPoint:videoRate*10.0];
        
        CGFloat starViewHeight = (iPad ? 20 : 10);
        UILabel *lblRating = (UILabel *)[titleView viewWithTag:TAG_MD_LBL_RATING];
        if(lblRating)
        {
            [lblRating setFrame:CGRectMake(width/2.0, yPos-3, width/3.0+10, lblRating.frame.size.height)];
        }
        
        CustomButton *favBtn = (CustomButton *)[titleView viewWithTag:TAG_MD_FAVOURITE_BTN];
        if(favBtn)
        {
            [favBtn setFrame:CGRectMake(lblRating.frame.origin.x+lblRating.frame.size.width+5, yPos-7,favBtn.frame.size.width, favBtn.frame.size.height)];
        }
        CustomButton *RemovefavBtn = (CustomButton *)[titleView viewWithTag:TAG_MD_REMOVE_FAVOURITE_BTN];
        if(RemovefavBtn)
        {
            [RemovefavBtn setFrame:CGRectMake(lblRating.frame.origin.x+lblRating.frame.size.width+5, yPos-7, RemovefavBtn.frame.size.width, RemovefavBtn.frame.size.height)];
        }
        
        [titleView setFrame:CGRectMake(MARGIN, pictureView.frame.origin.y+pictureView.frame.size.height, width, (yPos+5)+starViewHeight+MARGIN)];
        //===========================================
        
        //===========================================
        textHeight = [self getHeightForText:[video valueForKey:keyDescription] font:[UIFont fontWithName:kFontHelvetica size:kDetailsFontSize] constrainedWidth:width-MARGIN*2.0];
        [detailsView setFrame:CGRectMake(MARGIN, titleView.frame.origin.y+titleView.frame.size.height, width, textHeight+MARGIN*2.0)];
        
        yPos = MARGIN; // Description
        UILabel *lblDetails = (UILabel *)[detailsView viewWithTag:TAG_MD_LBL_DETAILS];
        if(lblDetails)
        {
            [lblDetails setFrame:CGRectMake(MARGIN, MARGIN, width-MARGIN*2.0, textHeight)];
            yPos = lblDetails.frame.origin.y + lblDetails.frame.size.height + MARGIN;
        }
        
        
        
        UILabel *lblPlayMess = (UILabel *)[detailsView viewWithTag:TAG_MD_LBL_PLAYMESS]; // play mess message
        if(lblPlayMess)
        {
            [lblPlayMess setFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, LABEL_HEIGHT)];
            yPos = lblPlayMess.frame.origin.y + lblPlayMess.frame.size.height + MARGIN;
        }
        
        if ([[video objectForKey:keyCanPlay] isEqualToNumber:[NSNumber numberWithInt:1]])
        {
            CustomButton *btnTrailer = (CustomButton *)[detailsView viewWithTag:TAG_MD_BTN_TRAILER];
            [btnTrailer setFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, BUTTON_HEIGHT)];
            yPos = yPos + BUTTON_HEIGHT + MARGIN;
        }
        
        if([[video objectForKey:keyIsMyVideo] isEqualToNumber:[NSNumber numberWithInt:1]])
        {
            if([video objectForKey:keyLents]) //it means someone has borrowed your video
            {
                CustomButton *btnRevoke =(CustomButton *)[detailsView viewWithTag:VideoActionRevoke];
                if(btnRevoke)
                {
                    [btnRevoke setFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, BUTTON_HEIGHT)];
                    yPos = yPos + BUTTON_HEIGHT + MARGIN;
                }
            }
            else // it means you can give your video to anyone
            {
                BOOL flag = [APPDELEGATE checkForDownloadedVideo:video];
                if([[video valueForKey:keyOfflineMode] intValue] == 2)
                {
                    if(flag) // it means download is complete
                    {
                        if([[video valueForKey:keyIsAlreadyDownloaded] intValue] == 1) // it means already downloaded in this device
                        {
                            //resetFrameForOptionsAfterCompleteDownloadInView
                            yPos = [self resetFrameForRenewRemoveInView:detailsView yPos:yPos width:width];
                        }
                        else // it means video is downloaded but in other device
                        {
                            //resetFrameForDownloadToViewOfflineButtonInView
                            yPos = [self resetFrameForDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:width];
                        }
                    }
                    else // it means download is not complete (in progress)
                    {
                        if([video valueForKey:keyIsAlreadyDownloaded])
                        {
                            if([[video valueForKey:keyIsAlreadyDownloaded] intValue] == 0) // Download Button
                            {
                                //resetFrameForDownloadToViewOfflineButtonInView
                                yPos = [self resetFrameForDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:width];
                            }
                            else
                            { // Sell, Send, Gift Buttons
                                //resetFrameForOptionsForMyVideoInView
                                yPos = [self resetFrameForOptionsForMyVideoInView:detailsView yPos:yPos width:width];
                                //resetFrameForDownloadToViewOfflineButtonInView
                                //BOOL SellFlag = [[video objectForKey:keySaleFlag] integerValue];
                                //if(!SellFlag)
                                {
                                    yPos = [self resetFrameForDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:width];
                                }
                            }
                        }
                        else
                        {
                            //resetFrameForOptionsForMyVideoInView
                            yPos = [self resetFrameForOptionsForMyVideoInView:detailsView yPos:yPos width:width];
                            //resetFrameForDownloadToViewOfflineButtonInView
                            //BOOL SellFlag = [[video objectForKey:keySaleFlag] integerValue];
                            //if(!SellFlag)
                            {
                                yPos = [self resetFrameForDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:width];
                            }
                        }
                    }
                }
                else if([[video valueForKey:keyOfflineMode] intValue] == 0)
                {
                    //resetFrameForOptionsForMyVideoInView
                    yPos = [self resetFrameForOptionsForMyVideoInView:detailsView yPos:yPos width:width];
                    //resetFrameForDownloadToViewOfflineButtonInView
                    //BOOL SellFlag = [[video objectForKey:keySaleFlag] integerValue];
                    //if(!SellFlag)
                    {
                        yPos = [self resetFrameForDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:width];
                    }
                }
            }
        }
        else // for friend video
        {
            
            
            if ([[video objectForKey:keyCanBorrow] intValue] == 1)
            {
                int count = [[video objectForKey:keyBorrowFriends] count];
                for(int i=0;i<count;i++)
                {
                    CustomButton *btnBorrow = (CustomButton *)[detailsView viewWithTag:(VideoActionBorrow+i)];
                    if(btnBorrow)
                    {
                        [btnBorrow setFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, BUTTON_HEIGHT)];
                        yPos = yPos + BUTTON_HEIGHT + MARGIN;
                    }
                }
                
                
            }
            else // it means you have already borrowed friend's video
            {
                NSDictionary *borrow = [video objectForKey:keyBorrow];
                if ([[borrow objectForKey:keyOwnerType] intValue] == 1)
                {// it means your borrow request is accepted
                    CustomButton *btnReturn = (CustomButton *)[detailsView viewWithTag:VideoActionReturn];
                    if(btnReturn)
                    {
                        [btnReturn setFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, BUTTON_HEIGHT)];
                        yPos = yPos + BUTTON_HEIGHT + MARGIN;
                    }
                    
                    BOOL flag = [APPDELEGATE checkForDownloadedVideo:video];
                    if([[video valueForKey:keyOfflineMode] intValue] == 2) // it means you have downloaded video (download request is set on server)
                    {
                        if(flag) // it means download is complete
                        {
                            //resetFrameForOptionsAfterCompleteDownloadInView
                            yPos = [self resetFrameForRenewRemoveInView:detailsView yPos:yPos width:width];
                        }
                        else
                        {
                            //resetFrameForDownloadToViewOfflineButtonInView
                            yPos = [self resetFrameForDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:width];
                        }
                    }
                    else if([[video valueForKey:keyOfflineMode] intValue] == 0)
                    {// if video is not downloaded //offline-mode--
                        //resetFrameForDownloadToViewOfflineButtonInView
                        yPos = [self resetFrameForDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:width];
                    }
                }
            }
        }
        CustomButton *dvdBtn = (CustomButton *)[detailsView viewWithTag:DvdBtn];
        
        [dvdBtn setFrame:CGRectMake(MARGIN, yPos, dvdBtn.frame.size.width, BUTTON_HEIGHT)];
        
        CustomButton *BlurayyBtn = (CustomButton *)[detailsView viewWithTag:BlurayBtn];
        
        [BlurayyBtn setFrame:CGRectMake(dvdBtn.frame.origin.x+dvdBtn.frame.size.width+5, yPos,BlurayyBtn.frame.size.width-5, BUTTON_HEIGHT)];
        
        if(dvdBtn && BlurayyBtn)
        {
            [dvdBtn setFrame:CGRectMake(MARGIN, yPos,  (width-MARGIN*2.0)/2, BUTTON_HEIGHT)];
            [BlurayyBtn setFrame:CGRectMake(dvdBtn.frame.origin.x+dvdBtn.frame.size.width+5, yPos,  (width-MARGIN*2.0)/2-5, BUTTON_HEIGHT)];
            yPos = yPos + BUTTON_HEIGHT + MARGIN;
        }
        else if(dvdBtn && !BlurayyBtn)
        {
            [dvdBtn setFrame:CGRectMake(MARGIN, yPos,  width-MARGIN*2.0, BUTTON_HEIGHT)];
            yPos = yPos + BUTTON_HEIGHT + MARGIN;
        }
        else if(!dvdBtn && BlurayyBtn)
        {
            [BlurayyBtn setFrame:CGRectMake(MARGIN, yPos,  width-MARGIN*2.0, BUTTON_HEIGHT)];
            yPos = yPos + BUTTON_HEIGHT + MARGIN;
        }
        else
        {
            
        }

        
       

        [detailsView setFrame:CGRectMake(detailsView.frame.origin.x, detailsView.frame.origin.y, detailsView.frame.size.width, yPos)];
        mainScrollView.contentSize = CGSizeMake(width, detailsView.frame.origin.y+detailsView.frame.size.height);
    }
}

-(void)reSetupLayoutMethodsWithOrientation_iPad:(UIInterfaceOrientation)orientation Width:(CGFloat)width
{
   
        CGFloat viewWidth = width/2;
        
        UIView *lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
        CGFloat yPos = lbl.frame.origin.y;
        CGFloat xPos=10;
        [self resetFrameForProgressViewInView:self.view yPos:yPos width:width];
        
        //===========================================
        CGFloat textHeight = [self getHeightForText:[video valueForKey:keyTitle] font:[UIFont fontWithName:kFontHelvetica size:kTitleFontSize] constrainedWidth:viewWidth-MARGIN*2.0];
        
        //[titleView setFrame:CGRectMake(viewWidth, 0, viewWidth, titleView.frame.size.height)];
        UILabel *lblTitle = (UILabel *)[titleView viewWithTag:TAG_MD_LBL_TITLE];
        if(lblTitle)
        {
            [lblTitle setFrame:CGRectMake(MARGIN, MARGIN-5, viewWidth-MARGIN*2.0, textHeight)];
        }
        
        CGFloat videoRate = [[video valueForKey:keyItemRate] floatValue];
        yPos = lblTitle.frame.origin.y+lblTitle.frame.size.height;
        [SEGBIN_SINGLETONE_INSTANCE reuseStart:titleView withYpostion:(yPos+5) withPoint:videoRate*10.0];
        CGFloat starViewHeight = (iPad ? 20 : 10);
        
        UILabel *lblRating = (UILabel *)[titleView viewWithTag:TAG_MD_LBL_RATING];
        if(lblRating)
        {
            [lblRating setFrame:CGRectMake(viewWidth/2.0, yPos-3, viewWidth/3.0+10, lblRating.frame.size.height)];
        }
        
        CustomButton *favBtn = (CustomButton *)[titleView viewWithTag:TAG_MD_FAVOURITE_BTN];
        if(favBtn)
        {
            [favBtn setFrame:CGRectMake(lblRating.frame.origin.x+lblRating.frame.size.width+5, yPos-7, favBtn.frame.size.width, favBtn.frame.size.height)];
        }
        CustomButton *RemovefavBtn = (CustomButton *)[titleView viewWithTag:TAG_MD_REMOVE_FAVOURITE_BTN];
        if(RemovefavBtn)
        {
            [RemovefavBtn setFrame:CGRectMake(lblRating.frame.origin.x+lblRating.frame.size.width+5, yPos-7, RemovefavBtn.frame.size.width, RemovefavBtn.frame.size.height)];
        }
        
        
        
        [titleView setFrame:CGRectMake(viewWidth, 100, viewWidth, (yPos+5)+starViewHeight+MARGIN)];
        //===========================================
        
        //===========================================
        textHeight = [self getHeightForText:[video valueForKey:keyDescription] font:[UIFont fontWithName:kFontHelvetica size:kDetailsFontSize] constrainedWidth:viewWidth-MARGIN*2.0];
        [detailsView setFrame:CGRectMake(viewWidth, titleView.frame.origin.y+titleView.frame.size.height, viewWidth,textHeight+MARGIN*2.0)];
        yPos = MARGIN;
        UILabel *lblDetails = (UILabel *)[detailsView viewWithTag:TAG_MD_LBL_DETAILS];
        if(lblDetails)
        {
            [lblDetails setFrame:CGRectMake(MARGIN, MARGIN, viewWidth-MARGIN*2.0, textHeight)];
            yPos = lblDetails.frame.origin.y + lblDetails.frame.size.height + MARGIN;
        }
        
    
        
        UILabel *lblPlayMess = (UILabel *)[detailsView viewWithTag:TAG_MD_LBL_PLAYMESS];
        if(lblPlayMess)
        {
            [lblPlayMess setFrame:CGRectMake(MARGIN, yPos, viewWidth-MARGIN*2.0, LABEL_HEIGHT)];
            yPos = lblPlayMess.frame.origin.y + lblPlayMess.frame.size.height + MARGIN;
        }
        if ([[video objectForKey:keyCanPlay] isEqualToNumber:[NSNumber numberWithInt:1]])
        {
            CustomButton *btnTrailer = (CustomButton *)[detailsView viewWithTag:TAG_MD_BTN_TRAILER];
            [btnTrailer setFrame:CGRectMake(MARGIN, yPos, viewWidth-MARGIN*2.0, BUTTON_HEIGHT)];
            yPos = yPos + BUTTON_HEIGHT + MARGIN;
        }

    
        if([[video objectForKey:keyIsMyVideo] isEqualToNumber:[NSNumber numberWithInt:1]]) // For my video
        {
            if([video objectForKey:keyLents]) //it means someone has borrowed your video
            {
                CustomButton *btnRevoke = (CustomButton *)[detailsView viewWithTag:VideoActionRevoke];
                if(btnRevoke)
                {
                    [btnRevoke setFrame:CGRectMake(MARGIN, yPos, viewWidth-MARGIN*2.0, BUTTON_HEIGHT)];
                    yPos = yPos + BUTTON_HEIGHT + MARGIN;
                }
            }
            else // it means you can give your video to anyone
            {
                BOOL flag = [APPDELEGATE checkForDownloadedVideo:video];
                if([[video valueForKey:keyOfflineMode] intValue] == 2)
                {
                    if(flag) // it means download is complete
                    {
                        if([[video valueForKey:keyIsAlreadyDownloaded] intValue] == 1) // it means already downloaded in this device
                        {
                            //resetFrameForOptionsAfterCompleteDownloadInView
                            yPos = [self resetFrameForRenewRemoveInView:detailsView yPos:yPos width:viewWidth];
                        }
                        else // it means video is downloaded but in other device
                        {
                            //resetFrameForDownloadToViewOfflineButtonInView
                            yPos = [self resetFrameForDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:viewWidth];
                        }
                    }
                    else // it means download is not complete (in progress)
                    {
                        if([video valueForKey:keyIsAlreadyDownloaded])
                        {
                            if([[video valueForKey:keyIsAlreadyDownloaded] intValue] == 0) // Download Button
                            {
                                //resetFrameForDownloadToViewOfflineButtonInView
                                yPos = [self resetFrameForDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:viewWidth];
                            }
                            else
                            { // Sell, Send, Gift Buttons
                                //resetFrameForOptionsForMyVideoInView
                                yPos = [self resetFrameForOptionsForMyVideoInView:detailsView yPos:yPos width:viewWidth];
                                //resetFrameForDownloadToViewOfflineButtonInView
                                //BOOL SellFlag = [[video objectForKey:keySaleFlag] integerValue];
                                //if(!SellFlag)
                                {
                                    yPos = [self resetFrameForDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:viewWidth];
                                }
                            }
                        }
                        else
                        {
                            //resetFrameForOptionsForMyVideoInView
                            yPos = [self resetFrameForOptionsForMyVideoInView:detailsView yPos:yPos width:viewWidth];
                            //resetFrameForDownloadToViewOfflineButtonInView
                            //BOOL SellFlag = [[video objectForKey:keySaleFlag] integerValue];
                            //if(!SellFlag)
                            {
                                yPos = [self resetFrameForDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:viewWidth];
                            }
                        }
                    }
                }
                else if([[video valueForKey:keyOfflineMode] intValue] == 0)
                {
                    //resetFrameForOptionsForMyVideoInView
                    yPos = [self resetFrameForOptionsForMyVideoInView:detailsView yPos:yPos width:viewWidth];
                    //resetFrameForDownloadToViewOfflineButtonInView
                    //BOOL SellFlag = [[video objectForKey:keySaleFlag] integerValue];
                    //if(!SellFlag)
                    {
                        yPos = [self resetFrameForDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:viewWidth];
                    }
                }
            }
        }
        else // for friend video
        {
            
            
            if ([[video objectForKey:keyCanBorrow] intValue] == 1)
            {
                int count = [[video objectForKey:keyBorrowFriends] count];
                for(int i=0;i<count;i++)
                {
                    //NSDictionary *user = [[video objectForKey:keyBorrowFriends] objectAtIndex:i];
                    
                    CustomButton *btnBorrow = (CustomButton *)[detailsView viewWithTag:(VideoActionBorrow+i)];
                    if(btnBorrow)
                    {
                        [btnBorrow setFrame:CGRectMake(MARGIN, yPos, viewWidth-MARGIN*2.0, BUTTON_HEIGHT)];
                        yPos = yPos + BUTTON_HEIGHT + MARGIN;
                    }
                }
                
               
            }
            else // it means you have already borrowed friend's video
            {
                NSDictionary *borrow = [video objectForKey:keyBorrow];
                if ([[borrow objectForKey:keyOwnerType] intValue] == 1)
                {// it means your borrow request is accepted
                    CustomButton *btnReturn = (CustomButton *)[detailsView viewWithTag:VideoActionReturn];
                    if(btnReturn)
                    {
                        [btnReturn setFrame:CGRectMake(MARGIN, yPos, viewWidth-MARGIN*2.0, BUTTON_HEIGHT)];
                        yPos = yPos + BUTTON_HEIGHT + MARGIN;
                    }
                    
                    BOOL flag = [APPDELEGATE checkForDownloadedVideo:video];
                    if([[video valueForKey:keyOfflineMode] intValue] == 2)
                    {// it means you have downloaded video (download request is set on server)
                        
                        if(flag) // it means download is complete
                        {
                            //resetFrameForOptionsAfterCompleteDownloadInView
                            yPos = [self resetFrameForRenewRemoveInView:detailsView yPos:yPos width:viewWidth];
                        }
                        else
                        {
                            //resetFrameForDownloadToViewOfflineButtonInView
                            yPos = [self resetFrameForDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:viewWidth];
                        }
                    }
                    else if([[video valueForKey:keyOfflineMode] intValue] == 0) // if video is not downloaded //offline-mode---
                    {
                        //resetFrameForDownloadToViewOfflineButtonInView
                        yPos = [self resetFrameForDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:viewWidth];
                    }
                }
            }
        }
        
    CustomButton *dvdBtn = (CustomButton *)[detailsView viewWithTag:DvdBtn];
    
    [dvdBtn setFrame:CGRectMake(MARGIN, yPos, dvdBtn.frame.size.width, BUTTON_HEIGHT)];
    
    CustomButton *BlurayyBtn = (CustomButton *)[detailsView viewWithTag:BlurayBtn];
    
    [BlurayyBtn setFrame:CGRectMake(dvdBtn.frame.origin.x+dvdBtn.frame.size.width+5, yPos,BlurayyBtn.frame.size.width-5, BUTTON_HEIGHT)];
    
    
    if(dvdBtn && BlurayyBtn)
    {
        [dvdBtn setFrame:CGRectMake(MARGIN, yPos,  (viewWidth-MARGIN*2.0)/2, BUTTON_HEIGHT)];
        [BlurayyBtn setFrame:CGRectMake(dvdBtn.frame.origin.x+dvdBtn.frame.size.width+5, yPos,  (viewWidth-MARGIN*2.0)/2-5, BUTTON_HEIGHT)];
        yPos = yPos + BUTTON_HEIGHT + MARGIN;
    }
    else if(dvdBtn && !BlurayyBtn)
    {
        [dvdBtn setFrame:CGRectMake(MARGIN, yPos,  viewWidth-MARGIN*2.0, BUTTON_HEIGHT)];
        yPos = yPos + BUTTON_HEIGHT + MARGIN;
    }
    else if(!dvdBtn && BlurayyBtn)
    {
        [BlurayyBtn setFrame:CGRectMake(MARGIN, yPos,  viewWidth-MARGIN*2.0, BUTTON_HEIGHT)];
        yPos = yPos + BUTTON_HEIGHT + MARGIN;
    }
    else
    {
        
    }

    
    
    
        [detailsView setFrame:CGRectMake(detailsView.frame.origin.x, detailsView.frame.origin.y, detailsView.frame.size.width,yPos)];
        //===========================================
        
        [pictureView setFrame:CGRectMake(MARGIN, 100, viewWidth, detailsView.frame.origin.y+detailsView.frame.size.height-100)];
        if ([[video objectForKey:keyCanPlay] isEqualToNumber:[NSNumber numberWithInt:1]])
        {
            CustomButton *btnPlay = (CustomButton *)[pictureView viewWithTag:TAG_MD_BTN_PLAY];
            //btnPlay.center = pictureView.center;
            if(btnPlay)
            {
                btnPlay.frame = CGRectMake(pictureView.frame.size.width/2-btnPlay.frame.size.width/2, pictureView.frame.size.height/2-btnPlay.frame.size.height/2, btnPlay.frame.size.width, btnPlay.frame.size.height);
            }
        }
        else
        {
            CustomButton *btnTrailer = (CustomButton *)[pictureView viewWithTag:TAG_MD_BTN_TRAILER];
            if (btnTrailer)
            {
                [btnTrailer setFrame:CGRectMake(pictureView.frame.size.width/2-btnTrailer.frame.size.width/2, pictureView.frame.size.height/2-btnTrailer.frame.size.height/2, btnTrailer.frame.size.width, btnTrailer.frame.size.height)];
                
            }

        }
    
    int btnWidth;
    if(![[video objectForKey:keyItemStreaming_360] isEqualToString:@""] && ![[video objectForKey:keyItemStreaming_720] isEqualToString:@""] && ![[video objectForKey:keyItemStreaming_1080] isEqualToString:@""])
    {
        btnWidth=pictureView.frame.size.width/3.3;
    }
    else
    {
        btnWidth=pictureView.frame.size.width/2.2;
    }
    
    CustomButton *btnLowDef = (CustomButton *)[pictureView viewWithTag:TAG_MD_BTN_LOWDEF];
    if(btnLowDef)
    {
        [btnLowDef setFrame:CGRectMake(xPos,pictureView.frame.size.height-(iPad?60:30)-5, btnWidth, btnLowDef.frame.size.height)];
        xPos=xPos+btnLowDef.frame.size.width+5;
    }
    
    CustomButton *btnHighDef = (CustomButton *)[pictureView viewWithTag:TAG_MD_BTN_HIGHDEF];
    if(btnHighDef)
    {
        [btnHighDef setFrame:CGRectMake(xPos,pictureView.frame.size.height-(iPad?60:30)-5, btnWidth, btnHighDef.frame.size.height)];
        xPos=xPos+btnHighDef.frame.size.width+5;
    }
    CustomButton *btnUltraDef = (CustomButton *)[pictureView viewWithTag:TAG_MD_BTN_ULTRADEF];
    if(btnUltraDef)
    {
        [btnUltraDef setFrame:CGRectMake(xPos,pictureView.frame.size.height-(iPad?60:30)-5, btnWidth, btnUltraDef.frame.size.height)];
        xPos=xPos+btnUltraDef.frame.size.width+5;
    }
    
        mainScrollView.contentSize = CGSizeMake(width, pictureView.frame.origin.y+pictureView.frame.size.height);
    
}

-(int)resetFrameForProgressViewInView:(UIView *)view yPos:(CGFloat)yPos width:(CGFloat)width
{
    //UIView *lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
    //CGFloat yPos = lbl.frame.origin.y;
    
    CustomButton *btnProgress = (CustomButton *)[view viewWithTag:DOWNLOADING_MOVIE_PROGRESS_OFFLINE];
    if(btnProgress)
    {
        [btnProgress setFrame:CGRectMake(MARGIN, yPos, width, BUTTON_HEIGHT)];
    }
    
    UILabel *lbl = (UILabel *)[btnProgress viewWithTag:DOWNLOADING_PROGRESS_LABEL];
    if(lbl)
    {
        [lbl setFrame:CGRectMake((iPad?0:5), (iPad?0:0), (iPad?50:35), (iPad?50:35))];
    }
    
    CustomProgressSubClass *progressView = (CustomProgressSubClass *)[btnProgress viewWithTag:DOWNLOADING_PROGRESS_BAR];
    if(progressView)
    {
        [progressView setFrame:CGRectMake(lbl.frame.origin.x+lbl.frame.size.width, (iPad?22:13), btnProgress.frame.size.width - (iPad?95:75), 10)];
    }
    
    CustomButton *btnCancelDownload = (CustomButton *)[btnProgress viewWithTag:DOWNLOAD_MOVIE_OFFLINE_CANCEL];
    if(btnCancelDownload)
    {
        [btnCancelDownload setFrame:CGRectMake(progressView.frame.origin.x+progressView.frame.size.width+10, (iPad?18:12), (iPad?15:12), (iPad?15:12))];
    }
    
    //UILabel *lbl = (UILabel *)[self.view viewWithTag:TOP_ViewLbl_Tag];
    //yPos = lbl.frame.origin.y;
    mainScrollView.frame = CGRectMake(mainScrollView.frame.origin.x, yPos, mainScrollView.frame.size.width, self.view.frame.size.height - yPos);
    if([[video objectForKey:keyIsMyVideo] isEqualToNumber:[NSNumber numberWithInt:1]])
    {
        BOOL flag = [APPDELEGATE checkForDownloadedVideo:video];
        if([[video valueForKey:keyOfflineMode] intValue] == 2)
        {
            if(flag) // it means download is complete
            {
                if([[video valueForKey:keyIsAlreadyDownloaded] intValue] == 1)
                {
                    CustomButton *btnOffline = (CustomButton *)[view viewWithTag:DOWNLOAD_MOVIE_OFFLINE_ENABLED];
                    if(btnOffline)
                    {
                        [btnOffline setFrame:CGRectMake(MARGIN, yPos, width, BUTTON_HEIGHT)];
                        yPos = yPos + BUTTON_HEIGHT + MARGIN;
                    }
                    
                    UILabel *lblTimerHeader = (UILabel *)[view viewWithTag:TAG_MD_LBL_TIMERHEADER];
                    if(lblTimerHeader)
                    {
                        [lblTimerHeader setFrame:CGRectMake(MARGIN, yPos, width, LABEL_HEIGHT)];
                        yPos = lblTimerHeader.frame.origin.y + lblTimerHeader.frame.size.height + MARGIN;
                    }
                   
                    mainScrollView.frame = CGRectMake(mainScrollView.frame.origin.x, yPos, mainScrollView.frame.size.width, self.view.frame.size.height-yPos);
                }
            }
        }
    }
    else
    {
        BOOL flag = [APPDELEGATE checkForDownloadedVideo:video];
        if([[video valueForKey:keyOfflineMode] intValue] == 2)
        {// it means you have downloaded video (download request is set on server)
            if(flag) // it means download is complete
            {
                CustomButton *btnOffline = (CustomButton *)[view viewWithTag:DOWNLOAD_MOVIE_OFFLINE_ENABLED];
                if(btnOffline)
                {
                    [btnOffline setFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, BUTTON_HEIGHT)];
                    yPos = yPos + BUTTON_HEIGHT + MARGIN;
                }
                
                UILabel *lblTimerHeader = (UILabel *)[view viewWithTag:TAG_MD_LBL_TIMERHEADER];
                if(lblTimerHeader)
                {
                    [lblTimerHeader setFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, LABEL_HEIGHT)];
                    yPos = lblTimerHeader.frame.origin.y + lblTimerHeader.frame.size.height + MARGIN;
                }
                
                mainScrollView.frame = CGRectMake(mainScrollView.frame.origin.x, yPos, mainScrollView.frame.size.width, self.view.frame.size.height-yPos);
            }
            else
            {
                UILabel *lblTimerHeader = (UILabel *)[view viewWithTag:TAG_MD_LBL_TIMERHEADER];
                if(lblTimerHeader)
                {
                    if(!btnProgress.isHidden)
                    {
                        yPos = btnProgress.frame.origin.y + btnProgress.frame.size.height;
                    }
                    [lblTimerHeader setFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, LABEL_HEIGHT)];
                    yPos = lblTimerHeader.frame.origin.y + lblTimerHeader.frame.size.height + MARGIN;
                }
                
                mainScrollView.frame = CGRectMake(mainScrollView.frame.origin.x, yPos, mainScrollView.frame.size.width, self.view.frame.size.height-yPos);
            }
        }
        else if([[video valueForKey:keyOfflineMode] intValue] == 0)
        {// if video is not downloaded //offline-mode---
            UILabel *lblTimerHeader = (UILabel *)[view viewWithTag:TAG_MD_LBL_TIMERHEADER];
            if(lblTimerHeader)
            {
                [lblTimerHeader setFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, LABEL_HEIGHT)];
                yPos = lblTimerHeader.frame.origin.y + lblTimerHeader.frame.size.height + MARGIN;
            }
            
            mainScrollView.frame = CGRectMake(mainScrollView.frame.origin.x, yPos, mainScrollView.frame.size.width, self.view.frame.size.height-yPos);
        }
    }
    return yPos;
}

-(int)resetFrameForOptionsForMyVideoInView:(UIView *)view yPos:(CGFloat)yPos width:(CGFloat)width
{
    /*
    CustomButton *btnSell = (CustomButton *)[view viewWithTag:VideoActionSell];
    [btnSell setFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, BUTTON_HEIGHT)];
    yPos = yPos + BUTTON_HEIGHT + MARGIN;
    
    CustomButton *btnSellToFrnd = (CustomButton *)[view viewWithTag:VideoActionSellToFriend];
    [btnSellToFrnd setFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, BUTTON_HEIGHT)];
    yPos = yPos + BUTTON_HEIGHT + MARGIN;
     */
    
    CustomButton *btnSendToFrnd = (CustomButton *)[view viewWithTag:VideoActionSend];
    if(btnSendToFrnd)
    {
        [btnSendToFrnd setFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, BUTTON_HEIGHT)];
        yPos = yPos + BUTTON_HEIGHT + MARGIN;
    }
    
    
    /*
    CustomButton *btnGiftToFrnd = (CustomButton *)[view viewWithTag:VideoActionGiftToFriend];
    [btnGiftToFrnd setFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, BUTTON_HEIGHT)];
    yPos = yPos + BUTTON_HEIGHT + MARGIN;
     */
    
    return yPos;
}

-(int)resetFrameForRenewRemoveInView:(UIView *)view yPos:(CGFloat)yPos width:(CGFloat)width
{
    /*
    CustomButton *btnOffline = (CustomButton *)[view viewWithTag:DOWNLOAD_MOVIE_OFFLINE_ENABLED];
    [btnOffline setFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, BUTTON_HEIGHT)];
    yPos = yPos + BUTTON_HEIGHT + MARGIN;
     */
    
    CGFloat btnWidth = width/2;
    CustomButton *btnRenew = (CustomButton *)[view viewWithTag:DOWNLOAD_MOVIE_OFFLINE_RENEW_MOVIE];
    if(btnRenew)
    {
        [btnRenew setFrame:CGRectMake(MARGIN, yPos, btnWidth-MARGIN*2.0, BUTTON_HEIGHT)];
    }
    
    //yPos = yPos + BUTTON_HEIGHT + MARGIN;
    
    CustomButton *btnRemove = (CustomButton *)[view viewWithTag:DOWNLOAD_MOVIE_OFFLINE_REMOVE_MOVIE];
    if(btnRemove)
    {
        [btnRemove setFrame:CGRectMake(btnRenew.frame.origin.x+btnRenew.frame.size.width+MARGIN*2, yPos, btnWidth-MARGIN*2.0, BUTTON_HEIGHT)];
        yPos = yPos + BUTTON_HEIGHT + MARGIN;
    }
    
    return yPos;
}

-(int)resetFrameForOptionsForRemaingTimeInView:(UIView *)view yPos:(CGFloat)yPos width:(CGFloat)width
{
    UILabel *lblTimerHeader = (UILabel *)[view viewWithTag:TAG_MD_LBL_TIMERHEADER];
    if(lblTimerHeader)
    {
        [lblTimerHeader setFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, LABEL_HEIGHT)];
        yPos = lblTimerHeader.frame.origin.y + lblTimerHeader.frame.size.height + MARGIN;
    }
    return yPos;
}

-(int)resetFrameForDownloadToViewOfflineButtonInView:(UIView *)view yPos:(CGFloat)yPos width:(CGFloat)width
{
    CustomButton *btnDownload = (CustomButton *)[view viewWithTag:DOWNLOAD_MOVIE_OFFLINE];
    if(btnDownload)
    {
        [btnDownload setFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, BUTTON_HEIGHT)];
        yPos = yPos + BUTTON_HEIGHT + MARGIN;
    }
    
    NSString *tempDownloadPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[APPDELEGATE getTitleForVideo:video]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    asiRequest = [APPDELEGATE getObjectForKey:[APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]]];
    if(asiRequest!=nil)
    {
        CGFloat btnWidth = width/2;
        [btnDownload setFrame:CGRectMake(MARGIN, btnDownload.frame.origin.y, btnWidth-MARGIN*2.0, BUTTON_HEIGHT)];
        
        CustomButton *btnPause = (CustomButton *)[view viewWithTag:PAUSE_DOWNLOAD];
        if(btnPause)
        {
            [btnPause setFrame:CGRectMake(btnDownload.frame.origin.x+btnDownload.frame.size.width+MARGIN*2.0, btnDownload.frame.origin.y, btnWidth-MARGIN*2.0, BUTTON_HEIGHT)];
            [btnPause setHidden:NO];
        }
        
        CustomButton *btnProgress = (CustomButton *) [self.view viewWithTag:DOWNLOADING_MOVIE_PROGRESS_OFFLINE];
        if(btnProgress)
        {
            CGFloat yPos = btnProgress.frame.origin.y + btnProgress.frame.size.height;
            UILabel *lbl = (UILabel *)[self.view viewWithTag:TAG_MD_LBL_TIMERHEADER];
            if(lbl && lbl.text.length != 0)
            {
                [lbl setHidden:NO];
                [lbl setFrame:CGRectMake(lbl.frame.origin.x, yPos, lbl.frame.size.width, lbl.frame.size.height)];
                yPos = lbl.frame.origin.y + lbl.frame.size.height;
            }
            else
            {
                [lbl setHidden:YES];
            }
            
            mainScrollView.frame = CGRectMake(mainScrollView.frame.origin.x,yPos, mainScrollView.frame.size.width,self.view.frame.size.height-(yPos));
            //mainScrollView.frame = CGRectMake(mainScrollView.frame.origin.x, btnProgress.frame.origin.y+btnProgress.frame.size.height, mainScrollView.frame.size.width, self.view.frame.size.height-(btnProgress.frame.origin.y+btnProgress.frame.size.height));
        }
    }
    else if([fileManager fileExistsAtPath:tempDownloadPath])
    {
        CGFloat btnWidth = width/2;
        [btnDownload setFrame:CGRectMake(MARGIN, btnDownload.frame.origin.y, btnWidth-MARGIN*2.0, BUTTON_HEIGHT)];
        
        CustomButton *btnPause = (CustomButton *)[view viewWithTag:PAUSE_DOWNLOAD];
        if(btnPause)
        {
            [btnPause setTitle:NSLocalizedString(@"strResumeDownload", nil) forState:UIControlStateNormal];
            [btnPause setFrame:CGRectMake(btnDownload.frame.origin.x+btnDownload.frame.size.width+MARGIN*2.0, btnDownload.frame.origin.y, btnWidth-MARGIN*2.0, BUTTON_HEIGHT)];
            [btnPause setHidden:NO];
        }
        
        CustomButton *btnProgress = (CustomButton *) [self.view viewWithTag:DOWNLOADING_MOVIE_PROGRESS_OFFLINE];
        if(btnProgress)
        {
            [btnProgress setHidden:NO];
            CGFloat yPos = btnProgress.frame.origin.y + btnProgress.frame.size.height;
            UILabel *lbl = (UILabel *)[self.view viewWithTag:TAG_MD_LBL_TIMERHEADER];
            if(lbl && lbl.text.length != 0)
            {
                [lbl setHidden:NO];
                [lbl setFrame:CGRectMake(lbl.frame.origin.x, yPos, lbl.frame.size.width, lbl.frame.size.height)];
                yPos = lbl.frame.origin.y + lbl.frame.size.height;
            }
            else
            {
                [lbl setHidden:YES];
            }
            
            mainScrollView.frame = CGRectMake(mainScrollView.frame.origin.x,yPos, mainScrollView.frame.size.width,self.view.frame.size.height-(yPos));
        }
    }
    
    return yPos;
}

-(void)createProgressView // For progress View & Offline Enabled Button
{
    UIView *lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
    CGFloat yPos = lbl.frame.origin.y;
    
    CustomButton *btnProgress = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(MARGIN, yPos, self.view.frame.size.width-MARGIN*2.0, BUTTON_HEIGHT) withTitle:@"" withImage:nil withTag:DOWNLOADING_MOVIE_PROGRESS_OFFLINE Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:MovieDetailsViewBgColor];
    btnProgress.buttonTag = DOWNLOADING_MOVIE_PROGRESS_OFFLINE;
    [btnProgress setHidden:YES];
    [btnProgress setUserInteractionEnabled:YES];
    [self.view addSubview:btnProgress];
    
    UILabel *progressLabel = [[UILabel alloc] initWithFrame:CGRectMake((iPad?0:5), (iPad?0:0), (iPad?50:35), (iPad?50:35))];
    progressLabel.backgroundColor = [UIColor clearColor];
    progressLabel.textAlignment = NSTextAlignmentLeft;
    progressLabel.textColor=[UIColor whiteColor];
    progressLabel.tag = DOWNLOADING_PROGRESS_LABEL;
    progressLabel.font = [UIFont fontWithName:kFontHelvetica size:(iPad?16:12)];
    [btnProgress addSubview:progressLabel];
    
    CustomProgressSubClass *progressView = [[CustomProgressSubClass alloc] init];
    progressView.frame = CGRectMake(progressLabel.frame.origin.x+progressLabel.frame.size.width, (iPad?22:13), btnProgress.frame.size.width - (iPad?95:75), 10);
    progressView.tag = DOWNLOADING_PROGRESS_BAR;
    if(iOS7)
    {
        [progressView setProgressTintColor:[UIColor blueColor]];
        [progressView setTrackTintColor:[UIColor lightGrayColor]];
    }
    [progressView setProgress:0.0];
    [btnProgress addSubview:progressView];
    
    UIImage *cancelImg = [UIImage imageNamed:@"cancel"];
    CustomButton *btnCancelDownload = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(progressView.frame.origin.x+progressView.frame.size.width+10, (iPad?18:12), (iPad?15:12), (iPad?15:12)) withTitle:nil withImage:cancelImg withTag:DOWNLOAD_MOVIE_OFFLINE_CANCEL Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:[UIColor clearColor]];
    btnCancelDownload.buttonTag = DOWNLOAD_MOVIE_OFFLINE_CANCEL;
    [btnCancelDownload addTarget:self action:@selector(cancelDownload:) forControlEvents:UIControlEventTouchUpInside];
    [btnCancelDownload setUserInteractionEnabled:YES];
    [btnProgress addSubview:btnCancelDownload];
    
    NSString *tempDownloadPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[APPDELEGATE getTitleForVideo:video]];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    //If download is already in progress then we need to update progress bar with current progress.
    asiRequest = [APPDELEGATE getObjectForKey:[APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]]];
    if(asiRequest!=nil)
    {
        [APPDELEGATE setProgressViewForDownloadingRequest:asiRequest withProgressView:progressView];
        if(!updateProgressTimer){
            updateProgressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateProgressLabel) userInfo:nil repeats:YES];
        }
        
        [btnProgress setHidden:NO];
    }
    else if([fileManager fileExistsAtPath:tempDownloadPath])
    {
        [APPDELEGATE setProgressViewForDownloadingRequest:asiRequest withProgressView:progressView];
        if(!updateProgressTimer){
            updateProgressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateProgressLabel) userInfo:nil repeats:YES];
        }
        
        [btnProgress setHidden:NO];
    }
    
    lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
    yPos = lbl.frame.origin.y;
    mainScrollView.frame = CGRectMake(mainScrollView.frame.origin.x, yPos, mainScrollView.frame.size.width, mainScrollView.frame.size.height);
    if([[video objectForKey:keyIsMyVideo] isEqualToNumber:[NSNumber numberWithInt:1]])
    {
        BOOL flag = [APPDELEGATE checkForDownloadedVideo:video];
        if([[video valueForKey:keyOfflineMode] intValue] == 2)
        {
            if(flag) // it means download is complete
            {
                if([[video valueForKey:keyIsAlreadyDownloaded] intValue] == 1)
                {
                    CustomButton *btnOffline = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(MARGIN, yPos, mainScrollView.frame.size.width-MARGIN*2.0, BUTTON_HEIGHT) withTitle:@"OFF-LINE ENABLED" withImage:nil withTag:DOWNLOAD_MOVIE_OFFLINE_ENABLED Font:[APPDELEGATE Fonts_OpenSans_Bold:(iPad?25:25)] BGColor:MovieDetailsViewBgColor];
                    btnOffline.buttonTag = DOWNLOAD_MOVIE_OFFLINE_ENABLED;
                    [btnOffline addTarget:self action:@selector(playVideoWithOptions:) forControlEvents:UIControlEventTouchUpInside];
                    [self.view addSubview:btnOffline];
                    yPos = yPos + BUTTON_HEIGHT + MARGIN;
                
                    if([video valueForKey:keyMessage])
                    {
                        NSString *message = [video valueForKey:keyMessage];
                        if([video valueForKey:keyExpiryDate] && [video valueForKey:keyServerDate])
                        {
                            if([video valueForKey:keyNewServerDate])
                            {
                                message = [self getCurrentRemainingTimeMessage];
                            }
                        }
                        if (message && message.length)
                        {
                            UILabel *lblTimerHeader = [APPDELEGATE createLabelWithFrame:CGRectMake(MARGIN, yPos, mainScrollView.frame.size.width-MARGIN*2.0, LABEL_HEIGHT) withBGColor:[UIColor clearColor] withTXColor:[UIColor whiteColor] withText:message withFont:[APPDELEGATE Fonts_OpenSans_Bold:(iPad?18:15)] withTag:TAG_MD_LBL_TIMERHEADER withTextAlignment:NSTextAlignmentCenter];
                            [self.view addSubview:lblTimerHeader];
                            yPos = lblTimerHeader.frame.origin.y + lblTimerHeader.frame.size.height + MARGIN;
                        }
                    }
                    
                    mainScrollView.frame = CGRectMake(mainScrollView.frame.origin.x, yPos, mainScrollView.frame.size.width, self.view.frame.size.height-yPos);
                }
            }
        }
    }
    else
    {
        BOOL flag = [APPDELEGATE checkForDownloadedVideo:video];
        if([[video valueForKey:keyOfflineMode] intValue] == 2)
        {// it means you have downloaded video (download request is set on server)
            if(flag) // it means download is complete
            {
                CustomButton *btnOffline = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(MARGIN, yPos, mainScrollView.frame.size.width-MARGIN*2.0, BUTTON_HEIGHT) withTitle:@"OFF-LINE ENABLED" withImage:nil withTag:DOWNLOAD_MOVIE_OFFLINE_ENABLED Font:[APPDELEGATE Fonts_OpenSans_Bold:(iPad?18:25)] BGColor:MovieDetailsViewBgColor];
                btnOffline.buttonTag = DOWNLOAD_MOVIE_OFFLINE_ENABLED;
                [btnOffline addTarget:self action:@selector(playVideoWithOptions:) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:btnOffline];
                yPos = yPos + BUTTON_HEIGHT + MARGIN;
                
                if([video valueForKey:keyMessage])
                {
                    NSString *message = [video valueForKey:keyMessage];
                    if([video valueForKey:keyExpiryDate] && [video valueForKey:keyServerDate])
                    {
                        if([video valueForKey:keyNewServerDate])
                        {
                            message = [self getCurrentRemainingTimeMessage];
                        }
                    }
                    if (message && message.length)
                    {
                        UILabel *lblTimerHeader = [APPDELEGATE createLabelWithFrame:CGRectMake(MARGIN, yPos, mainScrollView.frame.size.width-MARGIN*2.0, LABEL_HEIGHT) withBGColor:[UIColor clearColor] withTXColor:[UIColor whiteColor] withText:message withFont:[APPDELEGATE Fonts_OpenSans_Bold:(iPad?18:15)] withTag:TAG_MD_LBL_TIMERHEADER withTextAlignment:NSTextAlignmentCenter];
                        [self.view addSubview:lblTimerHeader];
                        yPos = lblTimerHeader.frame.origin.y + lblTimerHeader.frame.size.height + MARGIN;
                    }
                }
            }
            else
            {
                if([video valueForKey:keyMessage])
                {
                    NSString *message = [video valueForKey:keyMessage];
                    if([video valueForKey:keyExpiryDate] && [video valueForKey:keyServerDate])
                    {
                        if([video valueForKey:keyNewServerDate])
                        {
                            message = [self getCurrentRemainingTimeMessage];
                        }
                    }
                    if (message && message.length)
                    {
                        if(!btnProgress.isHidden)
                        {
                            yPos = btnProgress.frame.origin.y + btnProgress.frame.size.height;
                        }
                        UILabel *lblTimerHeader = [APPDELEGATE createLabelWithFrame:CGRectMake(MARGIN, yPos, mainScrollView.frame.size.width-MARGIN*2.0, LABEL_HEIGHT) withBGColor:[UIColor clearColor] withTXColor:[UIColor whiteColor] withText:message withFont:[APPDELEGATE Fonts_OpenSans_Bold:(iPad?18:15)] withTag:TAG_MD_LBL_TIMERHEADER withTextAlignment:NSTextAlignmentCenter];
                        [self.view addSubview:lblTimerHeader];
                        yPos = lblTimerHeader.frame.origin.y + lblTimerHeader.frame.size.height + MARGIN;
                    }
                }
            }
        }
        else if([[video valueForKey:keyOfflineMode] intValue] == 0)
        {// if video is not downloaded //offline-mode---
            if([video valueForKey:keyMessage])
            {
                NSString *message = [video valueForKey:keyMessage];
                if([video valueForKey:keyExpiryDate] && [video valueForKey:keyServerDate])
                {
                    if([video valueForKey:keyNewServerDate])
                    {
                        message = [self getCurrentRemainingTimeMessage];
                    }
                }
                if (message && message.length)
                {
                    UILabel *lblTimerHeader = [APPDELEGATE createLabelWithFrame:CGRectMake(MARGIN, yPos, mainScrollView.frame.size.width-MARGIN*2.0, LABEL_HEIGHT) withBGColor:[UIColor clearColor] withTXColor:[UIColor whiteColor] withText:message withFont:[APPDELEGATE Fonts_OpenSans_Bold:(iPad?18:15)] withTag:TAG_MD_LBL_TIMERHEADER withTextAlignment:NSTextAlignmentCenter];
                    [self.view addSubview:lblTimerHeader];
                    yPos = lblTimerHeader.frame.origin.y + lblTimerHeader.frame.size.height + MARGIN;
                }
            }
        }
        mainScrollView.frame = CGRectMake(mainScrollView.frame.origin.x, yPos, mainScrollView.frame.size.width, self.view.frame.size.height-yPos);
    }
}

-(void)createPictureView
{
    CGFloat width = mainScrollView.frame.size.width - MARGIN*2.0;
    CGFloat xPos = 10;

    pictureView = [APPDELEGATE createEventImageViewWithFrame:CGRectMake(MARGIN, 0, width, PICTURE_HEIGHT) withImageURL:[video valueForKey:keyPoster1] Placeholder:kMoviePlaceholderImage tag:TAG_MD_PICTURE_VIEW];
    [pictureView setContentMode:UIViewContentModeScaleAspectFill];
    [pictureView setClipsToBounds:YES];
    [pictureView setUserInteractionEnabled:YES];
    [mainScrollView addSubview:pictureView];
    
    // play button
    if ([[video objectForKey:keyCanPlay] isEqualToNumber:[NSNumber numberWithInt:1]])
    {
        UIImage *imgPlay = [UIImage imageNamed:@"play-movies"];
        CustomButton *btnPlay = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(pictureView.frame.size.width/2-imgPlay.size.width/2, pictureView.frame.size.height/2-imgPlay.size.height/2, imgPlay.size.width, imgPlay.size.height) withTitle:nil withImage:imgPlay withTag:TAG_MD_BTN_PLAY];
        [btnPlay addTarget:self action:@selector(playVideoWithOptions:) forControlEvents:UIControlEventTouchUpInside];
        [btnPlay setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [pictureView addSubview:btnPlay];
    }
    else
    {
        //Trailor button
        if(![[video objectForKey:keyTrailer] isEqualToString:@""])
        {
            CustomButton *btnTrailer = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(pictureView.frame.size.width/2-(iPad?65:45), pictureView.frame.size.height/2-(iPad?30:15), (iPad?130:90), (iPad?60:30)) withTitle:@"PLAY TRAILER" withImage:nil withTag:TAG_MD_BTN_TRAILER Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:MovieDetailsViewBgColor];
            
            [btnTrailer addTarget:self action:@selector(playTrailer:) forControlEvents:UIControlEventTouchUpInside];
            [btnTrailer setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
            [pictureView addSubview:btnTrailer];
        }
    }
    //change size of button
    int btnWidth;
    if(![[video objectForKey:keyItemStreaming_360] isEqualToString:@""] && ![[video objectForKey:keyItemStreaming_720] isEqualToString:@""] && ![[video objectForKey:keyItemStreaming_1080] isEqualToString:@""])
    {
        btnWidth=pictureView.frame.size.width/3.3;
    }
    else
    {
        btnWidth=pictureView.frame.size.width/2.2;
    }
    if(![[video objectForKey:keyItemStreaming_360] isEqualToString:@""])
    {
        CustomButton *btnLowDef = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(xPos, pictureView.frame.size.height-(iPad?60:30)-5,btnWidth,(iPad?60:30)) withTitle:@"LOW DEF" withImage:nil withTag:TAG_MD_BTN_LOWDEF Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:MovieDetailsViewBgColor];
        btnLowDef.alpha=0.6f;
        [btnLowDef addTarget:self action:@selector(playVideoWithOptions:) forControlEvents:UIControlEventTouchUpInside];
        [btnLowDef setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [pictureView addSubview:btnLowDef];
        xPos=xPos+btnLowDef.frame.size.width+5;
    }
    if(![[video objectForKey:keyItemStreaming_720] isEqualToString:@""])
    {
        CustomButton *btnHighwDef = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(xPos, pictureView.frame.size.height-(iPad?60:30)-5,btnWidth,(iPad?60:30)) withTitle:@"HIGH DEF" withImage:nil withTag:TAG_MD_BTN_HIGHDEF Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:MovieDetailsViewBgColor];
        btnHighwDef.alpha=0.6f;
        [btnHighwDef addTarget:self action:@selector(playVideoWithOptions:) forControlEvents:UIControlEventTouchUpInside];
        [btnHighwDef setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [pictureView addSubview:btnHighwDef];
        xPos=xPos+btnHighwDef.frame.size.width+5;
    }
    if(![[video objectForKey:keyItemStreaming_1080] isEqualToString:@""])
    {
        CustomButton *btnUltraDef = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(xPos, pictureView.frame.size.height-(iPad?60:30)-5,btnWidth,(iPad?60:30)) withTitle:@"ULTRA HD" withImage:nil withTag:TAG_MD_BTN_ULTRADEF Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:MovieDetailsViewBgColor];
        btnUltraDef.alpha=0.6f;
        [btnUltraDef addTarget:self action:@selector(playVideoWithOptions:) forControlEvents:UIControlEventTouchUpInside];
        [btnUltraDef setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [pictureView addSubview:btnUltraDef];
        xPos=xPos+btnUltraDef.frame.size.width+5;
    }
    


    
}

-(void)createTitleView
{
    CGFloat width = mainScrollView.frame.size.width - MARGIN*2.0;
    
    
    titleView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(MARGIN, pictureView.frame.origin.y + pictureView.frame.size.height, width, TITLE_VIEW_HEIGHT) bgColor:[UIColor colorWithRed:44.0/255.0 green:44.0/255.0 blue:44.0/255.0 alpha:1.0] tag:TAG_MD_TITLE_VIEW alpha:1.0];
    [mainScrollView addSubview:titleView];
    
    CGFloat height = [self getHeightForText:[video valueForKey:keyTitle] font:[UIFont fontWithName:kFontHelvetica size:kTitleFontSize] constrainedWidth:width-MARGIN*2.0];
    
    UILabel *lblTitle = [APPDELEGATE createLabelWithFrame:CGRectMake(MARGIN, MARGIN-5, width-MARGIN*2.0, height) withBGColor:[UIColor clearColor] withTXColor:[UIColor whiteColor] withText:[video valueForKey:keyTitle] withFont:[UIFont fontWithName:kFontHelvetica size:kTitleFontSize] withTag:TAG_MD_LBL_TITLE withTextAlignment:NSTextAlignmentLeft];
    [titleView addSubview:lblTitle];
    
    CGFloat yPos = lblTitle.frame.origin.y+lblTitle.frame.size.height;
    CGFloat videoRate = [[video valueForKey:keyItemRate] floatValue];
    [SEGBIN_SINGLETONE_INSTANCE addStart:titleView withYpostion:(yPos+5) withPoint:videoRate*10];
    
    CGFloat starViewHeight = (iPad ? 13 : 10);
    UILabel *lblRating = [SEGBIN_SINGLETONE_INSTANCE createLabelWithFrame:CGRectMake(titleView.frame.size.width/2.0, yPos-3, titleView.frame.size.width/4.0+10, starViewHeight*2) withFont:[APPDELEGATE Fonts_OpenSans_Regular:starViewHeight*2] withTextColor:[UIColor whiteColor] withTextAlignment:NSTextAlignmentRight withTag:TAG_MD_LBL_RATING];
    [lblRating setText:[video valueForKey:keyItemRating]];
    [titleView addSubview:lblRating];
    
    NSDictionary *user = [[video objectForKey:keyLents] objectAtIndex:0];
   // NSLog(@"%@",[NSString stringWithFormat:NSLocalizedString(@"apiFavouriteMovie", nil), [user objectForKey:keyIID]]);
    
    NSLog(@"%@",[video valueForKey:keyFavourite]);
    if([[video valueForKey:keyFavourite] boolValue]==YES)
    {
        //already favourite so image is already selected and WS is called unfavourite on click
        CustomButton *btnFovourite = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(lblRating.frame.origin.x+lblRating.frame.size.width+5, yPos-7,  (iPad ? 30 : 24), (iPad ? 30 : 24)) withTitle:nil withImage:[UIImage imageNamed:@"movie_frv_select"] withTag:TAG_MD_REMOVE_FAVOURITE_BTN Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:nil];
        [btnFovourite.dictData setValue:nil forKey:KeyButtonValue];
        btnFovourite.buttonTag = TAG_MD_REMOVE_FAVOURITE_BTN;
        [btnFovourite addTarget:self action:@selector(detailVideoAction:) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:btnFovourite];
    }
    else
    {
        //not a favourite button so images is blank star and ws called become favourite movie
        
        CustomButton *btnFovourite = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(lblRating.frame.origin.x+lblRating.frame.size.width+5, yPos-7, (iPad ? 30 : 24), (iPad ? 30 : 24)) withTitle:nil withImage:[UIImage imageNamed:@"movie_frv_unselect_white"] withTag:TAG_MD_FAVOURITE_BTN Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:nil];
        [btnFovourite.dictData setValue:nil forKey:KeyButtonValue];
        btnFovourite.buttonTag = TAG_MD_FAVOURITE_BTN;
        [btnFovourite addTarget:self action:@selector(detailVideoAction:) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:btnFovourite];
    }

    [titleView setFrame:CGRectMake(MARGIN, pictureView.frame.origin.y + pictureView.frame.size.height, width, (yPos+5)+starViewHeight+MARGIN)];
}

-(void)createDetailsView
{
    CGFloat yPos = titleView.frame.origin.y + titleView.frame.size.height;
    CGFloat width = mainScrollView.frame.size.width - MARGIN*2.0;
    CGFloat height = [self getHeightForText:[video valueForKey:keyDescription] font:[UIFont fontWithName:kFontHelvetica size:kDetailsFontSize] constrainedWidth:width-MARGIN*2.0];
    
    detailsView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(MARGIN, yPos, width, height+MARGIN*2.0) bgColor:[UIColor whiteColor] tag:TAG_MD_DETAILS_VIEW alpha:1.0];
    [mainScrollView addSubview:detailsView];
    
    yPos = MARGIN;
    if(![[video valueForKey:keyDescription] isEqualToString:@""])
    {
        UILabel *lblDetails = [APPDELEGATE createLabelWithFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, height) withBGColor:[UIColor clearColor] withTXColor:[UIColor lightGrayColor] withText:[video valueForKey:keyDescription] withFont:[UIFont fontWithName:kFontHelvetica size:kDetailsFontSize] withTag:TAG_MD_LBL_DETAILS withTextAlignment:NSTextAlignmentLeft];
        [detailsView addSubview:lblDetails];
        yPos = lblDetails.frame.origin.y + lblDetails.frame.size.height + MARGIN;
    }
    
    
    // if video is purchased successfully from sagebin
    if([[video valueForKey:keyIsPurchasedFromSagebin] intValue] == 1)
    {
        UILabel *lblPurchase = [APPDELEGATE createLabelWithFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, LABEL_HEIGHT) withBGColor:[UIColor clearColor] withTXColor:[UIColor blackColor] withText:[video valueForKey:keyIsPurchasedFromSagebinMsg] withFont:[UIFont fontWithName:kFontHelvetica size:kPlayMessFontSize] withTag:TAG_MD_LBL_PURCHASE withTextAlignment:NSTextAlignmentCenter];
        [detailsView addSubview:lblPurchase];
        yPos = lblPurchase.frame.origin.y + lblPurchase.frame.size.height + MARGIN;
        
        [detailsView setFrame:CGRectMake(detailsView.frame.origin.x, detailsView.frame.origin.y, detailsView.frame.size.width, yPos)];
        mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width, detailsView.frame.origin.y + detailsView.frame.size.height);
        return;
    }
    
    if ([[video objectForKey:keyCanPlay] isEqualToNumber:[NSNumber numberWithInt:1]])
    {
        CustomButton *btnTrailer = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, BUTTON_HEIGHT) withTitle:@"PLAY TRAILER" withImage:nil withTag:TAG_MD_BTN_TRAILER Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:MovieDetailsViewBgColor];
        
        [btnTrailer addTarget:self action:@selector(playTrailer:) forControlEvents:UIControlEventTouchUpInside];
        [btnTrailer setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [detailsView addSubview:btnTrailer];
        yPos = yPos + BUTTON_HEIGHT + MARGIN;
    }

    
    if (![[video objectForKey:keyCanPlayMess] isEqualToString:@""])
    {
        UILabel *lblPlayMess = [APPDELEGATE createLabelWithFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, LABEL_HEIGHT) withBGColor:[UIColor clearColor] withTXColor:[UIColor blackColor] withText:[[video valueForKey:keyCanPlayMess] capitalizedString] withFont:[UIFont fontWithName:kFontHelvetica size:kPlayMessFontSize] withTag:TAG_MD_LBL_PLAYMESS withTextAlignment:NSTextAlignmentCenter];
        [detailsView addSubview:lblPlayMess];
        yPos = lblPlayMess.frame.origin.y + lblPlayMess.frame.size.height + MARGIN;
    }
    
    if([[video objectForKey:keyIsMyVideo] isEqualToNumber:[NSNumber numberWithInt:1]]) // For my video
    {
       
        if([video objectForKey:keyLents]) //it means someone has borrowed your video
        {
            NSDictionary *user = [[video objectForKey:keyLents] objectAtIndex:0];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if(![[defaults valueForKey:keyDisplayName] isEqualToString:[user objectForKey:keyName]])
            {
                CustomButton *btnRevoke = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, BUTTON_HEIGHT) withTitle:[NSString stringWithFormat:@"REVOKE FROM %@", [user objectForKey:keyName]] withImage:nil withTag:VideoActionRevoke Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:MovieDetailsViewBgColor];
                [btnRevoke.dictData setValue:[NSString stringWithFormat:NSLocalizedString(@"apiRemoveLent", nil), [user objectForKey:keyIID]] forKey:KeyButtonValue];
                btnRevoke.buttonTag = VideoActionRevoke;
                [btnRevoke addTarget:self action:@selector(detailVideoAction:) forControlEvents:UIControlEventTouchUpInside];
                [detailsView addSubview:btnRevoke];
                yPos = yPos + BUTTON_HEIGHT + MARGIN;
            }
        }
        else // it means you can give your video to anyone
        {
            BOOL flag = [APPDELEGATE checkForDownloadedVideo:video];
            if([[video valueForKey:keyOfflineMode] intValue] == 2)
            {
                if(flag) // it means download is complete
                {
                    if([[video valueForKey:keyIsAlreadyDownloaded] intValue] == 1)
                    {// it means already downloaded in this device
                        yPos = [self addOptionsRenewRemoveInView:detailsView yPos:yPos width:width];
                    }
                    else
                    {// it means video is downloaded but in other device
                        yPos = [self addDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:width];
                    }
                }
                else // it means download is not complete (in progress)
                {
                    if([video valueForKey:keyIsAlreadyDownloaded])
                    {
                        if([[video valueForKey:keyIsAlreadyDownloaded] intValue] == 0)
                        { // Download Button
                            yPos = [self addDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:width];
                        }
                        else
                        { // Sell, Send, Gift Buttons
                            yPos = [self addOptionsForMyVideoInView:detailsView yPos:yPos width:width];
                            //offline_mode can be 0(not requested), 1(pending) or 2(accepted)
                            //BOOL SellFlag = [[video objectForKey:keySaleFlag] integerValue];
                            //if(!SellFlag)
                            {
                                yPos = [self addDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:width];
                            }
                        }
                    }
                    else
                    {
                        yPos = [self addOptionsForMyVideoInView:detailsView yPos:yPos width:width];
                        //BOOL SellFlag = [[video objectForKey:keySaleFlag] integerValue];
                        //if(!SellFlag)
                        {
                            yPos = [self addDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:width];
                        }
                    }
                }
            }
            else if([[video valueForKey:keyOfflineMode] intValue] == 0)
            {
                yPos = [self addOptionsForMyVideoInView:detailsView yPos:yPos width:width];
                //BOOL SellFlag = [[video objectForKey:keySaleFlag] integerValue];
                //if(!SellFlag)
                {
                    yPos = [self addDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:width];
                }
            }
        }
    }
    else // for friend video
    {
        if ([[video objectForKey:keyCanBorrow] intValue] == 1)
        {
            int count = [[video objectForKey:keyBorrowFriends] count];
            for(int i=0;i<count;i++)
            {
                NSDictionary *user = [[video objectForKey:keyBorrowFriends] objectAtIndex:i];
                
                CustomButton *btnBorrow = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, BUTTON_HEIGHT) withTitle:[NSString stringWithFormat:@"BORROW FROM %@", [user objectForKey:keyName]] withImage:nil withTag:(VideoActionBorrow+i) Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:MovieDetailsViewBgColor];
                [btnBorrow.dictData setValue:[NSString stringWithFormat:NSLocalizedString(@"apiBorrowWithIDAndUID", nil), [user objectForKey:keyIID], [user objectForKey:keyUID]] forKey:KeyButtonValue];
                [btnBorrow addTarget:self action:@selector(detailVideoAction:) forControlEvents:UIControlEventTouchUpInside];
                btnBorrow.buttonTag = VideoActionBorrow;
                [detailsView addSubview:btnBorrow];
                yPos = yPos + BUTTON_HEIGHT + MARGIN;
            }
           
        }
        else // it means you have already borrowed friend's video
        {
            NSDictionary *borrow = [video objectForKey:keyBorrow];
            if ([[borrow objectForKey:keyOwnerType] intValue] == 1)
            {// it means your borrow request is accepted
                CustomButton *btnReturn = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, BUTTON_HEIGHT) withTitle:[NSString stringWithFormat:@"RETURN TO %@", [borrow objectForKey:keyDisplayName]] withImage:nil withTag:VideoActionReturn Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:MovieDetailsViewBgColor];
                [btnReturn.dictData setValue:[NSString stringWithFormat:NSLocalizedString(@"apiRemoveLent", nil), [borrow objectForKey:keyIID]] forKey:KeyButtonValue];
                [btnReturn addTarget:self action:@selector(detailVideoAction:) forControlEvents:UIControlEventTouchUpInside];
                btnReturn.buttonTag = VideoActionReturn;
                [detailsView addSubview:btnReturn];
                yPos = yPos + BUTTON_HEIGHT + MARGIN;
                
                BOOL flag = [APPDELEGATE checkForDownloadedVideo:video];
                if([[video valueForKey:keyOfflineMode] intValue] == 2)
                {// it means you have downloaded video (download request is set on server)
                    if(flag) // it means download is complete
                    {
                        yPos = [self addOptionsRenewRemoveInView:detailsView yPos:yPos width:width];
                    }
                    else
                    {
                        yPos = [self addDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:width];
                    }
                }
                else if([[video valueForKey:keyOfflineMode] intValue] == 0)
                {// if video is not downloaded //offline-mode---
                    yPos = [self addDownloadToViewOfflineButtonInView:detailsView yPos:yPos width:width];
                }
            }
        }
    }
    
    NSString *dvdPrice,*blurayPrice;
    if(movieType==BIN_MOVIE)
    {
       
        dvdPrice=[video objectForKey:keyBinPrice];
        blurayPrice=[video objectForKey:keyBinBliurayPrice];
        
        NSLog(@"%d",self.movieType);
        NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        if ([dvdPrice rangeOfCharacterFromSet:notDigits].location == NSNotFound)
        {
            // newString consists only of the digits 0 through 9
            dvdPrice=[NSString stringWithFormat:@"$%@ : DVD",dvdPrice];
        }
        if ([blurayPrice rangeOfCharacterFromSet:notDigits].location == NSNotFound)
        {
            // newString consists only of the digits 0 through 9
            blurayPrice=[NSString stringWithFormat:@"$%@ : BLURAY",blurayPrice];
        }
    }
    else
    {
        dvdPrice=[video objectForKey:keySagebinPrice];
        blurayPrice=[video objectForKey:keySagebinBliurayPrice];
        
        NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        if ([dvdPrice rangeOfCharacterFromSet:notDigits].location == NSNotFound)
        {
            // newString consists only of the digits 0 through 9
            dvdPrice=[NSString stringWithFormat:@"$%@ : DVD",dvdPrice];
        }
        if ([blurayPrice rangeOfCharacterFromSet:notDigits].location == NSNotFound)
        {
            // newString consists only of the digits 0 through 9
            blurayPrice=[NSString stringWithFormat:@"$%@ : BLURAY",blurayPrice];
        }
    }
   // NSLog(@"%@",video);
    
    CustomButton *dvdBtn = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(MARGIN, yPos, (width-MARGIN*2.0)/2, BUTTON_HEIGHT) withTitle:dvdPrice withImage:nil withTag:DvdBtn Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:MovieDetailsViewBgColor];
    [dvdBtn.dictData setValue:dvdPrice forKey:KeyButtonValue];
    dvdBtn.buttonTag = DvdBtn;
    [dvdBtn addTarget:self action:@selector(detailVideoAction:) forControlEvents:UIControlEventTouchUpInside];
    //  [detailsView addSubview:dvdBtn];
    
    CustomButton *blurayBtn = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(dvdBtn.frame.origin.x+dvdBtn.frame.size.width+2, yPos, ((width-MARGIN*2.0)/2)-5, BUTTON_HEIGHT) withTitle:blurayPrice withImage:nil withTag:BlurayBtn Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:MovieDetailsViewBgColor];
    [blurayBtn.dictData setValue:blurayPrice forKey:KeyButtonValue];
    blurayBtn.buttonTag = BlurayBtn;
    [blurayBtn addTarget:self action:@selector(detailVideoAction:) forControlEvents:UIControlEventTouchUpInside];
    //    [detailsView addSubview:blurayBtn];
    
    if(!([[dvdBtn.dictData valueForKey:KeyButtonValue] isEqualToString:@"0"] || [[dvdBtn.dictData valueForKey:KeyButtonValue] isEqualToString:@""])  && !([[blurayBtn.dictData valueForKey:KeyButtonValue] isEqualToString:@"0"]|| [[blurayBtn.dictData valueForKey:KeyButtonValue ] isEqualToString:@""]))
    {
        [detailsView addSubview:blurayBtn];
        [detailsView addSubview:dvdBtn];
        yPos = yPos + BUTTON_HEIGHT + MARGIN;
    }
    else if(([[dvdBtn.dictData valueForKey:KeyButtonValue] isEqualToString:@"0"] || [[dvdBtn.dictData valueForKey:KeyButtonValue] isEqualToString:@""]) && !([[blurayBtn.dictData valueForKey:KeyButtonValue] isEqualToString:@"0"]|| [[blurayBtn.dictData valueForKey:KeyButtonValue ] isEqualToString:@""]))
    {
        // dvdBtn.alpha=0.8;
        
        [blurayBtn setFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, BUTTON_HEIGHT)];
        [detailsView addSubview:blurayBtn];
        yPos = yPos + BUTTON_HEIGHT + MARGIN;
        
        
    }
    else if(([[blurayBtn.dictData valueForKey:KeyButtonValue] isEqualToString:@"0"]|| [[blurayBtn.dictData valueForKey:KeyButtonValue ] isEqualToString:@""]) && !([[dvdBtn.dictData valueForKey:KeyButtonValue] isEqualToString:@"0"] || [[dvdBtn.dictData valueForKey:KeyButtonValue] isEqualToString:@""]))
    {
        // blurayBtn.alpha=0.8;
        
        [dvdBtn setFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, BUTTON_HEIGHT)];
        [detailsView addSubview:dvdBtn];
        yPos = yPos + BUTTON_HEIGHT + MARGIN;
        
    }
    else
    {
        
    }
    
    
    
    
    [detailsView setFrame:CGRectMake(detailsView.frame.origin.x, detailsView.frame.origin.y, detailsView.frame.size.width, 237)];
    mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width, detailsView.frame.origin.y + detailsView.frame.size.height);
}

//offline-mode---
-(int)addOptionsRenewRemoveInView:(UIView *)view yPos:(CGFloat)yPos width:(CGFloat)width
{
    CGFloat btnWidth = width/2.0;
    CustomButton *btnRenew = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(MARGIN, yPos, btnWidth-MARGIN*2.0, BUTTON_HEIGHT) withTitle:@"RENEW OFF-LINE" withImage:nil withTag:DOWNLOAD_MOVIE_OFFLINE_RENEW_MOVIE Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:MovieDetailsViewBgColor];
    btnRenew.buttonTag = DOWNLOAD_MOVIE_OFFLINE_RENEW_MOVIE;
    [btnRenew addTarget:self action:@selector(renewOffline:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnRenew];
    //yPos = yPos + BUTTON_HEIGHT + MARGIN;
    
    CustomButton *btnRemove = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(btnRenew.frame.origin.x+btnRenew.frame.size.width+MARGIN*2, yPos, btnWidth-MARGIN*2.0, BUTTON_HEIGHT) withTitle:@"REMOVE MOVIE" withImage:nil withTag:DOWNLOAD_MOVIE_OFFLINE_REMOVE_MOVIE Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:MovieDetailsViewBgColor];
    btnRemove.buttonTag = DOWNLOAD_MOVIE_OFFLINE_REMOVE_MOVIE;
    [btnRemove addTarget:self action:@selector(removeMovie:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnRemove];
    yPos = yPos + BUTTON_HEIGHT + MARGIN;
    
    return yPos;
}

-(int)addOptionsForMyVideoInView:(UIView *)view yPos:(CGFloat)yPos width:(CGFloat)width
{
    BOOL SellFlag;
    if([video valueForKey:keySaleFlag] != [NSNull null])
    {
        SellFlag = [[video objectForKey:keySaleFlag] integerValue];
    }
    
    CustomButton *btnSendToFrnd = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, BUTTON_HEIGHT) withTitle:@"SEND MOVIE TO FRIEND" withImage:nil withTag:VideoActionSend Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:MovieDetailsViewBgColor];
    btnSendToFrnd.buttonTag = VideoActionSend;
    [btnSendToFrnd.dictData setValue:[NSString stringWithFormat:@"%@",[video objectForKey:keyId]] forKey:KeyButtonValue];
    [btnSendToFrnd addTarget:self action:@selector(buttonSellClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnSendToFrnd];
    yPos = yPos + BUTTON_HEIGHT + MARGIN;

    return yPos;
}

-(int)addDownloadToViewOfflineButtonInView:(UIView *)view yPos:(CGFloat)yPos width:(CGFloat)width
{
    CustomButton *btnDownload = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, BUTTON_HEIGHT) withTitle:@"DOWNLOAD TO VIEW OFFLINE" withImage:nil withTag:DOWNLOAD_MOVIE_OFFLINE Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:MovieDetailsViewBgColor];
    btnDownload.buttonTag = DOWNLOAD_MOVIE_OFFLINE;
    [btnDownload addTarget:self action:@selector(requestDownloadVideo) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnDownload];
    yPos = yPos + BUTTON_HEIGHT + MARGIN;
    
    CustomButton *btnPause = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(MARGIN, yPos, width-MARGIN*2.0, BUTTON_HEIGHT) withTitle:NSLocalizedString(@"strPauseDownload", nil) withImage:nil withTag:PAUSE_DOWNLOAD Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:MovieDetailsViewBgColor];
    btnPause.buttonTag = DOWNLOAD_MOVIE_OFFLINE;
    [btnPause addTarget:self action:@selector(pauseDownloadVideo:) forControlEvents:UIControlEventTouchUpInside];
    [btnPause setHidden:YES];
    [view addSubview:btnPause];
    //yPos = yPos + BUTTON_HEIGHT + MARGIN;
    
    NSString *tempDownloadPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[APPDELEGATE getTitleForVideo:video]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //If download is already in progress then we need to update progress bar with current progress.
    asiRequest = [APPDELEGATE getObjectForKey:[APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]]];
    if(asiRequest!=nil)
    {
        [btnDownload setTitle:NSLocalizedString(@"strWatchNow", nil) forState:UIControlStateNormal];
        [btnDownload removeTarget:self action:@selector(requestDownloadVideo) forControlEvents:UIControlEventTouchUpInside];
//        [btnDownload addTarget:self action:@selector(playMovieWhileDownloading:) forControlEvents:UIControlEventTouchUpInside];
        [btnDownload addTarget:self action:@selector(playVideoWithOptions:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat btnWidth = width/2;
        [btnDownload setFrame:CGRectMake(MARGIN, btnDownload.frame.origin.y, btnWidth-MARGIN*2.0, BUTTON_HEIGHT)];
        [btnPause setFrame:CGRectMake(btnDownload.frame.origin.x+btnDownload.frame.size.width+MARGIN*2.0, btnDownload.frame.origin.y, btnWidth-MARGIN*2.0, BUTTON_HEIGHT)];
        [btnPause setHidden:NO];
        
        CustomButton *btnProgress = (CustomButton *) [self.view viewWithTag:DOWNLOADING_MOVIE_PROGRESS_OFFLINE];
        CGFloat yPos = btnProgress.frame.origin.y + btnProgress.frame.size.height;
        UILabel *lbl = (UILabel *)[self.view viewWithTag:TAG_MD_LBL_TIMERHEADER];
        if(lbl && lbl.text.length != 0)
        {
            [lbl setHidden:NO];
            [lbl setFrame:CGRectMake(lbl.frame.origin.x, yPos, lbl.frame.size.width, lbl.frame.size.height)];
            yPos = lbl.frame.origin.y + lbl.frame.size.height;
        }
        else
        {
            [lbl setHidden:YES];
        }
        
        mainScrollView.frame = CGRectMake(mainScrollView.frame.origin.x,yPos, mainScrollView.frame.size.width,self.view.frame.size.height-(yPos));
        //mainScrollView.frame = CGRectMake(mainScrollView.frame.origin.x, btnProgress.frame.origin.y+btnProgress.frame.size.height, mainScrollView.frame.size.width, self.view.frame.size.height-(btnProgress.frame.origin.y+btnProgress.frame.size.height));
    }
    else if([fileManager fileExistsAtPath:tempDownloadPath])
    {
        //[btnDownload setTitle:NSLocalizedString(@"strResumeDownload", nil) forState:UIControlStateNormal];
        [btnDownload setTitle:NSLocalizedString(@"strWatchNow", nil) forState:UIControlStateNormal];
        [btnDownload removeTarget:self action:@selector(requestDownloadVideo) forControlEvents:UIControlEventTouchUpInside];
//        [btnDownload addTarget:self action:@selector(playMovieWhileDownloading:) forControlEvents:UIControlEventTouchUpInside];
        [btnDownload addTarget:self action:@selector(playVideoWithOptions:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat btnWidth = width/2;
        [btnDownload setFrame:CGRectMake(MARGIN, btnDownload.frame.origin.y, btnWidth-MARGIN*2.0, BUTTON_HEIGHT)];
        [btnPause setFrame:CGRectMake(btnDownload.frame.origin.x+btnDownload.frame.size.width+MARGIN*2.0, btnDownload.frame.origin.y, btnWidth-MARGIN*2.0, BUTTON_HEIGHT)];
        [btnPause setTitle:NSLocalizedString(@"strResumeDownload", nil) forState:UIControlStateNormal];
        [btnPause setHidden:NO];
        
        CustomButton *btnProgress = (CustomButton *) [self.view viewWithTag:DOWNLOADING_MOVIE_PROGRESS_OFFLINE];
        CGFloat yPos = btnProgress.frame.origin.y + btnProgress.frame.size.height;
        UILabel *lbl = (UILabel *)[self.view viewWithTag:TAG_MD_LBL_TIMERHEADER];
        if(lbl && lbl.text.length != 0)
        {
            [lbl setHidden:NO];
            [lbl setFrame:CGRectMake(lbl.frame.origin.x, yPos, lbl.frame.size.width, lbl.frame.size.height)];
            yPos = lbl.frame.origin.y + lbl.frame.size.height;
        }
        else
        {
            [lbl setHidden:YES];
        }
        
        mainScrollView.frame = CGRectMake(mainScrollView.frame.origin.x,yPos, mainScrollView.frame.size.width,self.view.frame.size.height-(yPos));
        //mainScrollView.frame = CGRectMake(mainScrollView.frame.origin.x, btnProgress.frame.origin.y+btnProgress.frame.size.height, mainScrollView.frame.size.width, self.view.frame.size.height-(btnProgress.frame.origin.y+btnProgress.frame.size.height));
    }
    
    return yPos;
}

#pragma mark - Button Action Handle
-(void)buttonUnSellClicked:(CustomButton *)sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Are you sure ?" message:@"you want to unsell this movie" delegate:self cancelButtonTitle:@"Confirm" otherButtonTitles:@"Cancel", nil];
    alert.tag =VideoActionUnCell;
    currentSendButton = sender;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == DOWNLOAD_MOVIE_OFFLINE_REMOVE_MOVIE)
    {
        if(buttonIndex!=[alertView cancelButtonIndex])
        {
            [self removeOfflineMovie];
        }
        return;
    }
    else if (alertView.tag == VideoActionUnCell)
    {
        if (buttonIndex == 0)
        {
            NSString *stringComing = [currentSendButton.dictData valueForKey:KeyButtonValue];
            NSArray *array = [stringComing componentsSeparatedByString:@"||"];
            NSString *strVideoId = [array objectAtIndex:0];
            BOOL flag = [[array objectAtIndex:1] boolValue];
            NSString *strRequest= [NSString stringWithFormat:NSLocalizedString(@"apiUnsellMovie", nil), strVideoId, !flag];
            NSLog(@"%@",strRequest);
            [self request:strRequest withTag:kTAG_OTHER_REQUEST];
        }
    }
}

-(void)buttonSendClicked:(CustomButton *)sender
{
    currentSendButton = sender;
    [self showAlertForAction:sender withFriendsArray:nil];
}

-(void)buttonSellClicked:(CustomButton *)sender
{
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    
    NSString *downloadPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[APPDELEGATE getTitleForVideo:video]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:downloadPath])
    {
        [self.view makeToast:@"To send movie please cancel download."];
        return;
    }
    downloadPath = [APPDELEGATE getPathForDownloadedVideo:video];
    if([fileManager fileExistsAtPath:downloadPath])
    {
        //[self.view makeToast:@"To send movie please cancel download."];
        return;
    }
    
    [self disableAllButtons];
    currentSendButton = sender;
    [self request:[NSString stringWithFormat:@"%@",NSLocalizedString(@"apiMyFriends", nil)] withTag:kTAG_MY_FRIENDS];
}

-(void)detailVideoAction:(CustomButton *)btn
{
    currentSelectedButton = btn;
    
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    
    switch (btn.buttonTag) {
            
        case VideoActionBorrow:
        {
            objView = [[CustomPopupView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            [objView setTag:TAG_POPUP_VIEW];
            [objView setDelegate:self];
            [self.view addSubview:objView];
            
            [objView setStrViewTitle:[btn titleForState:UIControlStateNormal]];
            [objView setStrViewMessage:@"How long do you want to borrow the movie for?"];
            [objView customizeViewForType:VideoActionBorrow];
            [objView adjustForOrientation:[UIApplication sharedApplication].statusBarOrientation];
        }
            break;
            
        case VideoActionReturn:
        {
            [self disableAllButtons];
            NSString *strRequest = [btn.dictData valueForKey:KeyButtonValue];
            [self request:strRequest withTag:kTAG_REMOVE_LENT];
        }
            break;
            
        case VideoActionRevoke:
        {
            [self disableAllButtons];
            NSString *strRequest = [btn.dictData valueForKey:KeyButtonValue];
            [self request:strRequest withTag:kTAG_REMOVE_LENT];
        }
            break;
            
        case TAG_MD_FAVOURITE_BTN:
        {
            [self disableAllButtons];
            NSString *strRequest =[NSString stringWithFormat:NSLocalizedString(@"apiFavouriteMovie", nil), strMovieId, [APPDELEGATE getAppToken]];;
            [self request:strRequest withTag:TAG_MD_FAVOURITE_BTN];
        }
            break;
            
        case TAG_MD_REMOVE_FAVOURITE_BTN:
        {
            [self disableAllButtons];
            NSString *strRequest =[NSString stringWithFormat:NSLocalizedString(@"apiRemoveFavouriteMovie", nil), strMovieId, [APPDELEGATE getAppToken]];;
            [self request:strRequest withTag:TAG_MD_REMOVE_FAVOURITE_BTN];
        }
            break;
        case DvdBtn:
        {
            
        }
            break;
        case BlurayBtn:
        {
            
        }
            break;
            
        default:
            break;
    }
}

-(void)showAlertForAction:(CustomButton *)button withFriendsArray:(NSArray *)arrayFriends
{
    switch (button.buttonTag) {
        
        case VideoActionSend:
        {
            objView = [[CustomPopupView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            [objView setTag:TAG_POPUP_VIEW];
            [objView setDelegate:self];
            [self.view addSubview:objView];
            
            [objView setArrayOptions:arrayFriends];
            [objView setStrViewTitle:@"Send Movie to Friend"];
            [objView setStrViewMessage:@"How long would you like the offer to exist?"];
            [objView customizeViewForType:VideoActionSend];
            [objView adjustForOrientation:[UIApplication sharedApplication].statusBarOrientation];
            
        }
            break;
            
        case VideoActionSell:
        {
            objView = [[CustomPopupView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            [objView setTag:TAG_POPUP_VIEW];
            [objView setDelegate:self];
            [self.view addSubview:objView];
            
            [objView setStrTextFieldPlaceHodlder:@"Amount"];
            [objView setStrViewTitle:[NSString stringWithFormat:@"Sell this Movie \n\n Amount"]];
            [objView setStrConfirmTitle:@"Sell it"];
            [objView customizeViewForType:VideoActionSell];
            [objView adjustForOrientation:[UIApplication sharedApplication].statusBarOrientation];
        }
            break;
            
        case VideoActionSellToFriend:
        {
            objView = [[CustomPopupView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            [objView setTag:TAG_POPUP_VIEW];
            [objView setDelegate:self];
            [self.view addSubview:objView];
            
            [objView setArrayOptions:arrayFriends];
            [objView setStrViewTitle:@"Sell Movie to Friend"];
            [objView setStrTextFieldPlaceHodlder:@"Special Price"];
            [objView setStrViewMessage:@"How long the offer will exist?"];
            [objView customizeViewForType:VideoActionSellToFriend];
            [objView adjustForOrientation:[UIApplication sharedApplication].statusBarOrientation];
        }
            break;
            
        case VideoActionGiftToFriend:
        {
            objView = [[CustomPopupView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            [objView setTag:TAG_POPUP_VIEW];
            [objView setDelegate:self];
            [self.view addSubview:objView];
            
            [objView setArrayOptions:arrayFriends];
            [objView setStrViewTitle:@"Gift Movie to Friend"];
            [objView setStrViewMessage:@"How long the offer will exist?"];
            [objView customizeViewForType:VideoActionGiftToFriend];
            [objView adjustForOrientation:[UIApplication sharedApplication].statusBarOrientation];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Pause / Resume Download Movie
-(void)pauseDownloadVideo:(CustomButton *)btn
{
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    currentSelectedButton = btn;
    if(asiRequest)
    {// pause
        [asiRequest clearDelegatesAndCancel];
        [btn setTitle:NSLocalizedString(@"strResumeDownload", nil) forState:UIControlStateNormal];
        [APPDELEGATE.requestObjects removeObjectForKey:[APPDELEGATE getKeyForTag:[[video objectForKey:keyId] intValue]]];
        asiRequest = nil;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"applicationWillEnterForeground" object:nil];
    }
    else
    {// resume
        [btn setTitle:NSLocalizedString(@"strPauseDownload", nil) forState:UIControlStateNormal];
        //[self afterDownloadFromSelection];
        [self downloadOwnerVideo];
    }
    [self enableAllButtons];
}

- (void) requestDownloadVideo
{
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    
    if([[video valueForKey:keyCanPlay] intValue] == 1 && [[video valueForKey:keyIsMyVideo] intValue] == 0) {
        //no need to resend request for offline download
        [self directRequest];
    }
    else
    {// give options for how much time offline-downloading is needed before downloading
        if([[video valueForKey:keyOfflineMode] intValue] == 2)
        {
            BOOL flag = [APPDELEGATE checkForDownloadedVideo:video];
            if(flag)
            {// if completely downloaded in this device
            }
            else
            {
                [self afterDownloadFromSelection];
            }
        }
        else if([[video valueForKey:keyOfflineMode] intValue] == 0)
        {// if not downloaded
            [self afterDownloadFromSelection];
        }
    }
}

- (void)directRequest
{
    //if video is already borrowed no no need to send offline request again
    
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    
    [self disableAllButtons];
    
    NSString *strVideoId = [video valueForKey:keyId];
    NSString *sendRequest= [NSString stringWithFormat:NSLocalizedString(@"apiOfflineDownloadMovie", nil), strVideoId,[APPDELEGATE getAppToken]];
    [self request:sendRequest withTag:kTAG_OFFLINE_DOWNLOAD_MOVIE];
}

- (BOOL)checkIfConnectedOnWifi {
    
    // -1 checking
    // 0 no access
    // 1 cellular
    // 2 wifi connected
    
    if(APPDELEGATE.netOnLink == 2) {
        return YES;
    }
    
    return NO;
}

- (BOOL)checkIfConnectedOnCellular {
    
    if(APPDELEGATE.netOnLink == 1) {
        return YES;
    }
    
    return NO;
}

- (void) afterDownloadFromSelection
{
    /*[temporaryDownloadedVideos removeAllObjects];
     temporaryDownloadedVideos = [appDelegate readFromListForKey:kVideosArray];
     for(int i=0; i<temporaryDownloadedVideos.count; i++)
     {
     NSDictionary *dictionary = [temporaryDownloadedVideos objectAtIndex:i];
     if([[dictionary valueForKey:@"id"] intValue] == [[self.video valueForKey:@"id"] intValue])
     {
     [self downloadOwnerVideo];
     return;
     }
     }*/ // Edited On 18/01/2014
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:DefaultKeyDownloadMode])
    {
        downloadOption = [[NSUserDefaults standardUserDefaults] integerForKey:DefaultKeyDownloadMode];
    }
    if(downloadOption == DownLoadModeWIFI) //wifi only
    {
        if([self checkIfConnectedOnWifi] == NO) {
            //if cellular is selected
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"strMovieUsesData", nil) message:NSLocalizedString(@"strDownloadFromMobileProvider", nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    if(downloadOption == DownLoadModeBoth)
    {
        if([self checkIfConnectedOnWifi])
        {
        }
        else if([self checkIfConnectedOnCellular])
        {
            if([[NSUserDefaults standardUserDefaults] objectForKey:DefaultKeySettingsChanged])
            {
                [APPDELEGATE removeOldPrefrencesForKey:DefaultKeySettingsChanged];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"strDeviceNeedsWifi", nil) message:NSLocalizedString(@"strChangeSettings", nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else
        {
            [self.view makeToast:WARNING];
            return;
        }
    }
    
    CustomButton *button = (CustomButton *)[detailsView viewWithTag:DOWNLOAD_MOVIE_OFFLINE];
    
    objView = [[CustomPopupView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [objView setTag:TAG_POPUP_VIEW];
    [objView setDelegate:self];
    [self.view addSubview:objView];
    
    [objView setStrViewTitle:[button titleForState:UIControlStateNormal]];
    [objView setStrViewMessage:@"How long would you like this movie offline for?"];
    [objView customizeViewForType:VideoDownloadOffline];
    [objView adjustForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (void) removeMovie:(CustomButton *)button {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[button titleForState:UIControlStateNormal] message:@"Are you sure you want to remove the movie?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    alert.tag = button.buttonTag;
    [alert show];
}

-(void)removeOfflineMovie
{
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    
    [self disableAllButtons];
    NSString *strVideoId = [video valueForKey:keyId];
    NSString *strRequest = [NSString stringWithFormat:NSLocalizedString(@"apiRemoveOffline", nil), strVideoId, [APPDELEGATE getAppToken]];
    [self request:strRequest withTag:kTAG_REMOVE_OFFLINE];
}

- (void) renewOffline:(UIButton *)button
{
    double seconds = [self getDuration:[video valueForKey:keyTime]];
    int hours = seconds / 3600;
    int days = hours / 24;
    if(days > 2)
    {
        [self.view makeToast:NSLocalizedString(@"strEnoughDaysForRenew", nil)];
        return;
    }
    
    objView = [[CustomPopupView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [objView setTag:TAG_POPUP_VIEW];
    [objView setDelegate:self];
    [self.view addSubview:objView];
    
    [objView setStrViewTitle:[button titleForState:UIControlStateNormal]];
    [objView setStrViewMessage:@"How long would you like to renew this movie offline for?"];
    [objView customizeViewForType:VideoDownloadOfflineRenew];
    [objView adjustForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (void) renewOfflineBeforeHour
{
    objView = [[CustomPopupView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [objView setTag:TAG_POPUP_VIEW];
    [objView setDelegate:self];
    [self.view addSubview:objView];
    
    [objView setStrViewTitle:@"Offline movie expires within an hour"];
    [objView setStrViewMessage:@"How long would you like to renew this movie offline for?"];
    [objView customizeViewForType:VideoDownloadOfflineRenew];
    [objView adjustForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (CGFloat)getHeightForText:(NSString *)text font:(UIFont *)font constrainedWidth:(CGFloat)width
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
//            [self reSetupLayoutMethodsWithOrientation:toInterfaceOrientation Width:(1004)];
             [self reSetupLayoutMethodsWithOrientation_iPad:toInterfaceOrientation Width:(1004)];
            //
        }
        else
        {
            //return CGSizeMake(719, 148);
            //JM 1/7/2014
            [self reSetupLayoutMethodsWithOrientation:toInterfaceOrientation Width:(748-MARGIN)];
            //
        }
    }
    else
    {
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            if (IS_IPHONE_5_GREATER)
            {
                [self reSetupLayoutMethodsWithOrientation:toInterfaceOrientation Width:(568-MARGIN)];
            }
            else
            {
                [self reSetupLayoutMethodsWithOrientation:toInterfaceOrientation Width:(480-MARGIN)];
            }
        }
        else
        {
            [self reSetupLayoutMethodsWithOrientation:toInterfaceOrientation Width:(320-MARGIN*2.0)];
        }
    }
    if(objView)
    {
        [objView adjustForOrientation:toInterfaceOrientation];
       
    }
    [self setSagebinLogoInCenterForOrientation:toInterfaceOrientation];
}

#pragma mark - Reload Screen With Movie Details Api
-(void)callMovieDetailApi
{
    [self.timerForCountdown invalidate];
    self.timerForCountdown = nil;
    
    IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
    NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strParameter = [NSString stringWithFormat:NSLocalizedString(@"apiMovieDetails", nil), strMovieId, [APPDELEGATE getAppToken]];
    strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], strParameter];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl]];
    NSData *postData = [NSData dataWithBytes:[strParameter UTF8String] length:[strParameter length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:kTAG_MOVIE_DETAILS];
    [requestConnection startAsynchronousRequest];
    
    [SEGBIN_SINGLETONE_INSTANCE addLoader];
    [self disableAllButtons];
}

#pragma mark - IMDHTTPRequest Delegate
-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didFailWithError:(NSError*)error withTag:(int)tag
{
    [self.view makeToast:kServerError];
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    [self enableAllButtons];
}

-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didSuccessWithItems:(NSObject*)items withData:(NSData*)data withTag:(int)tag
{
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    [self enableAllButtons];
    if (tag==kTAG_MOVIE_DETAILS)
    {
        NSDictionary *result = (NSDictionary *)items;
        if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
        {
            [self checkUserAlert:[result objectForKey:keyAlerts]];
            
            video = [result objectForKey:keyValue];
            if([video valueForKey:keySaleFlag] == [NSNull null])
            {
                [video setValue:0 forKey:keySaleFlag];
            }
            if([video valueForKey:keyItemStreaming] == [NSNull null])
            {
                [video setValue:@"" forKey:keyItemStreaming];
            }
            if([[video valueForKey:keyOfflineMode] intValue] == 2)
            {
                if([[video valueForKey:keyIsAlreadyDownloaded] intValue] == 0)
                {
                }
                else
                {
                    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:[appDelegate getKeyForTag:[[video valueForKey:@"id"] intValue]]];
                    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:[APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]]];
                    NSString *strServerDate, *strNewExpiryDate;
                    if([dic objectForKey:keyNewServerDate])
                    {
                        if([[dic valueForKey:keyExpiryDate] isEqualToString:[video valueForKey:keyExpiryDate]])
                        {
                            NSLog(@"same expiry date");
                            strServerDate = [dic valueForKey:keyNewServerDate];
                            strNewExpiryDate = [dic valueForKey:keyNewExpiryDate];
                        }
                        else
                        {
                            NSLog(@"different expiry date");
                            NSDateFormatter *df = [[NSDateFormatter alloc]init];
                            [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                            strServerDate = [df stringFromDate:[NSDate date]];
                            
                            double totalSeconds = [self getDuration:[video valueForKey:keyTime]];
                            NSDate *d = [[NSDate date] dateByAddingTimeInterval:totalSeconds];
                            strNewExpiryDate = [df stringFromDate:d];
                        }
                    }
                    else
                    {
                        NSDateFormatter *df = [[NSDateFormatter alloc]init];
                        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        strServerDate = [df stringFromDate:[NSDate date]];
                        
                        double totalSeconds = [self getDuration:[video valueForKey:keyTime]];
                        NSDate *d = [[NSDate date] dateByAddingTimeInterval:totalSeconds];
                        strNewExpiryDate = [df stringFromDate:d];
                    }
                    [video setValue:strServerDate forKey:keyNewServerDate];
                    [video setValue:strNewExpiryDate forKey:keyNewExpiryDate];
                    
                    [APPDELEGATE removeOldPrefrencesForKey:[APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]]]; // Edited On 31/01/2014
                    [APPDELEGATE setNewPrefrencesForObject:video forKey:[APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]]];
                }
                
                //remove from temp plist file
                [temporaryDownloadedVideos removeAllObjects];
                temporaryDownloadedVideos = [APPDELEGATE readFromListForKey:kVideosArray];
                for(int i=0;i<temporaryDownloadedVideos.count;i++)
                {
                    NSDictionary *dictionary = [temporaryDownloadedVideos objectAtIndex:i];
                    if([[dictionary valueForKey:keyId] intValue] == [[video valueForKey:keyId] intValue])
                    {
                        [temporaryDownloadedVideos removeObject:dictionary];
                    }
                }
                [APPDELEGATE writeToListToDeleteAllVideosForKey:kVideosArray];
                for(int i=0;i<temporaryDownloadedVideos.count;i++)
                {
                    NSDictionary *dictionary = [temporaryDownloadedVideos objectAtIndex:i];
                    [APPDELEGATE writeToListForKey:kVideosArray content:dictionary];
                }
                //remove from temp plist file
            }
            else if([[video valueForKey:keyOfflineMode] intValue] == 0)
            {
                if([video valueForKey:keyMessage])
                {
                    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:[APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]]];
                    NSString *strServerDate, *strNewExpiryDate;
                    if([dic objectForKey:keyNewServerDate])
                    {
                        strServerDate = [dic valueForKey:keyNewServerDate];
                        strNewExpiryDate = [dic valueForKey:keyNewExpiryDate];
                    }
                    else
                    {
                        NSDateFormatter *df = [[NSDateFormatter alloc]init];
                        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        strServerDate = [df stringFromDate:[NSDate date]];
                        
                        double totalSeconds = [self getDuration:[video valueForKey:keyTime]];
                        NSDate *d = [[NSDate date] dateByAddingTimeInterval:totalSeconds];
                        strNewExpiryDate = [df stringFromDate:d];
                    }
                    [video setValue:strServerDate forKey:keyNewServerDate];
                    [video setValue:strNewExpiryDate forKey:keyNewExpiryDate];
                    
                    [APPDELEGATE removeOldPrefrencesForKey:[APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]]]; // Edited On 31/01/2014
                    [APPDELEGATE setNewPrefrencesForObject:video forKey:[APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]]];
                }
                else
                {
                    [APPDELEGATE removeOldPrefrencesForKey:[APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]]]; // Edited On 31/01/2014
                    [APPDELEGATE setNewPrefrencesForObject:video forKey:[APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]]];
                }
            }
            
            [self setupLayoutMethods];
        }
        else
        {
            [self.view makeToast:kServerError];
        }
    }
    else if(tag==kTAG_OTHER_REQUEST)
    {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
        {
            [self checkUserAlert:[result objectForKey:keyAlerts]];
            if([[result valueForKey:keyValue] isKindOfClass:[NSString class]])
            {
                if([[result valueForKey:keyValue] length] > 0)
                {
                    [self.view makeToast:[result valueForKey:keyValue]];
                    if(currentRequestType == VideoDownloadOfflineRenew)
                    {
                        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:video];
                        [dic removeObjectForKey:keyNewServerDate];
                        [dic removeObjectForKey:keyNewExpiryDate];
                        video = dic;
                        [APPDELEGATE removeOldPrefrencesForKey:[APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]]];
                        [APPDELEGATE setNewPrefrencesForObject:video forKey:[APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]]];
                    }
                }
            }
            
            [self removeUI];
            [self callMovieDetailApi];
        }
        else if ([[result objectForKey:keyCode] isEqualToString:keyFailure])
        {
            if([[result valueForKey:keyValue] isKindOfClass:[NSString class]])
            {
                if([[result valueForKey:keyValue] length] > 0)
                {
                    [self.view makeToast:[result valueForKey:keyValue]];
                }
            }
        }
        else{
            // force login
            [self.view makeToast:kServerError];
        }
    }
    else if(tag==kTAG_SEND_MOVIE_TO_FRIEND_REQUEST)
    {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
        {
            [self checkUserAlert:[result objectForKey:keyAlerts]];
            if([[result valueForKey:keyValue] isKindOfClass:[NSString class]])
            {
                if([[result valueForKey:keyValue] length] > 0)
                {
                    [self.view makeToast:[result valueForKey:keyValue]];
                }
            }
        }
        else if ([[result objectForKey:keyCode] isEqualToString:keyFailure])
        {
            if([[result valueForKey:keyValue] isKindOfClass:[NSString class]])
            {
                if([[result valueForKey:keyValue] length] > 0)
                {
                    [self.view makeToast:[result valueForKey:keyValue]];
                }
            }
        }
        else{
            // force login
            [self.view makeToast:kServerError];
        }
    }
    else if(tag==kTAG_CANCEL_REMOVE_OFFLINE)
    {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
        {
            [self checkUserAlert:[result objectForKey:keyAlerts]];
            [self removeUI];
            [self callMovieDetailApi];
        }else{
            // force login
            [self.view makeToast:kServerError];
        }
    }
    else if(tag==kTAG_REMOVE_OFFLINE)
    {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
        {
            //if success remove local video file
            [APPDELEGATE removeOldPrefrencesForKey:[APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]]];
            //remove ASI object from dictionary
            [APPDELEGATE.requestObjects removeObjectForKey:[APPDELEGATE getKeyForTag:[[video objectForKey:keyId] intValue]]];
            NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:[APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]]]);
            NSLog(@"%@", APPDELEGATE.requestObjects);
            
            NSString *downloadPath = [APPDELEGATE getPathForDownloadedVideo:video];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if(fileManager) {
                if([fileManager fileExistsAtPath:downloadPath]) {
                    NSError *error = nil;
                    [fileManager removeItemAtPath:downloadPath error:&error];
                    if(error) {
                        NSLog(@"Error while removing file %@",[error localizedDescription]);
                    }else{
                        NSLog(@"Video deleted.. now deleting offline video content..");
                        [self.view makeToast:@"video removed successfully"];
                        
                        [APPDELEGATE removeOldPrefrencesForKey:[APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]]];
                        
                        [self removeUI];
                        [self callMovieDetailApi];
                    }
                }
                else
                {
                    [APPDELEGATE removeOldPrefrencesForKey:[APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]]];
                    
                    [self removeUI];
                    [self callMovieDetailApi];
                }
            }
        }else{
            // force login
            [self.view makeToast:kServerError];
        }
    }
    else if(tag==kTAG_MY_FRIENDS)
    {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
        {
            if([[result valueForKey:keyUsers] count] > 0)
            {
                [self showAlertForAction:currentSendButton withFriendsArray:[result valueForKey:keyUsers]];
            }
            else
            {
                [self.view makeToast:@"You do not have any friends yet."];
            }
        }else{
            // force login
            [self.view makeToast:kServerError];
        }
    }
    else if(tag==kTAG_OFFLINE_DOWNLOAD_MOVIE)
    {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
        {
            [self checkUserAlert:[result objectForKey:keyAlerts]];
            //start download here
            [self downloadOwnerVideo];
        }else if([[result objectForKey:keyCode] isEqualToString:keyError]){
            [self.view makeToast:[result valueForKey:keyValue]];
        }else{
            // force login
            [self.view makeToast:kServerError];
        }
    }
    else if(tag==kTAG_OFFLINE_DOWNLOAD_MOVIE_DURATION)
    {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
        {
            if(currentSelectedButton.tag == PAUSE_DOWNLOAD)
            {
                [currentSelectedButton setTitle:NSLocalizedString(@"strPauseDownload", nil) forState:UIControlStateNormal];
            }
            [self checkUserAlert:[result objectForKey:keyAlerts]];
            if([[result valueForKey:keyValue] isKindOfClass:[NSString class]])
            {
                if([[result valueForKey:keyValue] length] > 0)
                {
                    //[self.viewC.view makeToast:[result valueForKey:@"value"]];
                    //if([[self.video objectForKey:@"offline_mode"] intValue] == 0)
                    if([video objectForKey:keyLents])
                    {
                        [self.view makeToast:[result valueForKey:keyValue]];
                    }
                    else
                    {
                        [self downloadOwnerVideo];
                    }
                }
            }
        }
        else{
            [self.view makeToast:kServerError];
        }
    }
    else if(tag==kTAG_REMOVE_LENT)
    {
        //[self enableAllButtons];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        NSArray *arrResponse = [string componentsSeparatedByString:@":"];
        if([arrResponse count] > 1)
        {
            if([[arrResponse objectAtIndex:1] isEqualToString:keySuccess])
            {
                if([[video valueForKey:keyOfflineMode] intValue] == 2)
                {
                    //[self removeOfflineMovie];
                    if(asiRequest)
                    {
                        //cancel ASI request
                        [asiRequest cancel];
                        asiRequest = nil;
                        
                        //cancel timer
                        if(updateProgressTimer) {
                            [updateProgressTimer invalidate];
                            updateProgressTimer = nil;
                        }
                        
                        //remove ASI object from dictionary
                        //[appDelegate.requestObjects removeObjectForKey:[appDelegate getKeyForTag:[self.video objectForKey:@"id"]]];
                    }
                    
                    //remove ASI object from dictionary
                    [APPDELEGATE.requestObjects removeObjectForKey:[APPDELEGATE getKeyForTag:[[video objectForKey:keyId] intValue]]];
                    
                    [APPDELEGATE removeOldPrefrencesForKey:[APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]]];
                    
                    NSString *downloadPath = [APPDELEGATE getPathForDownloadedVideo:video];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    if(fileManager) {
                        if([fileManager fileExistsAtPath:downloadPath]) {
                            NSError *error = nil;
                            [fileManager removeItemAtPath:downloadPath error:&error];
                            NSLog(@"Video deleted.. now deleting offline video content..");
                            [self removeUI];
                            [self callMovieDetailApi];
                        }
                    }
                }
                else if([[video valueForKey:keyOfflineMode] intValue] == 0)
                {
                    if(asiRequest)
                    {
                        //cancel ASI request
                        [asiRequest cancel];
                        asiRequest = nil;
                        
                        //cancel timer
                        if(updateProgressTimer) {
                            [updateProgressTimer invalidate];
                            updateProgressTimer = nil;
                        }
                        
                        //remove ASI object from dictionary
                        //[appDelegate.requestObjects removeObjectForKey:[appDelegate getKeyForTag:[self.video objectForKey:@"id"]]];
                    }
                    
                    //remove ASI object from dictionary
                    [APPDELEGATE.requestObjects removeObjectForKey:[APPDELEGATE getKeyForTag:[[video objectForKey:keyId] intValue]]];
                    
                    [APPDELEGATE removeOldPrefrencesForKey:[APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]]];
                    
                    NSString *downloadPath = [APPDELEGATE getPathForDownloadedVideo:video];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    if(fileManager) {
                        if([fileManager fileExistsAtPath:downloadPath]) {
                            NSError *error = nil;
                            [fileManager removeItemAtPath:downloadPath error:&error];
                            NSLog(@"Video deleted.. now deleting offline video content..");
                            //[self loadDetail:[self.video objectForKey:@"id"]];
                        }
                    }
                    
                    // remove temporary video details from plist after successful download
                    [temporaryDownloadedVideos removeAllObjects];
                    temporaryDownloadedVideos = [APPDELEGATE readFromListForKey:kVideosArray];
                    for(int i=0;i<temporaryDownloadedVideos.count;i++)
                    {
                        NSDictionary *dictionary = [temporaryDownloadedVideos objectAtIndex:i];
                        if([[dictionary valueForKey:keyId] intValue] == [[video objectForKey:keyId] intValue])
                        {
                            [temporaryDownloadedVideos removeObject:dictionary];
                        }
                    }
                    [APPDELEGATE writeToListToDeleteAllVideosForKey:kVideosArray];
                    for(int i=0;i<temporaryDownloadedVideos.count;i++)
                    {
                        NSDictionary *dictionary = [temporaryDownloadedVideos objectAtIndex:i];
                        [APPDELEGATE writeToListForKey:kVideosArray content:dictionary];
                    }
                    // remove tempory video file from NSTemporaryDirectory()
                    downloadPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[APPDELEGATE getTitleForVideo:video]];
                    if([fileManager fileExistsAtPath:downloadPath])
                    {
                        [fileManager removeItemAtPath:downloadPath error:nil];
                    }
                    
                    [self removeUI];
                    [self callMovieDetailApi];
                }
            }
        }
        [self callMovieDetailApi];
    }
    else if(tag==TAG_MD_FAVOURITE_BTN)
    {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
        {
            [self.view makeToast:[result valueForKey:keyValue]];
            [self callMovieDetailApi];
            
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
            [self callMovieDetailApi];
            
        }else if([[result objectForKey:keyCode] isEqualToString:keyError]){
            [self.view makeToast:[result valueForKey:keyValue]];
        }else{
            // force login
            [self.view makeToast:kServerError];
        }
    }


}


-(void)updateTimerLabel:(NSTimer *)timer
{
    //NSLog(@"%@", [timer userInfo]);
    UILabel *lbl = [timer userInfo];
    NSArray *arrayTime = [lbl.text componentsSeparatedByString:@":"];
    if(arrayTime.count > 1)
    {
        int hours = [[arrayTime objectAtIndex:0] intValue];
        int minutes = [[arrayTime objectAtIndex:1] intValue];
        int seconds = [[arrayTime objectAtIndex:2] intValue];
        
        if(seconds > 0)
        {
            seconds = seconds - 1;
        }
        else if(seconds == 0)
        {
            if(minutes > 0)
            {
                minutes = minutes - 1;
                seconds = 59;
            }
            else if(minutes == 0)
            {
                if(hours > 0)
                {
                    hours = hours - 1;
                    minutes = 59;
                }
                else if(hours <= 0)
                {
                    [self.timerForCountdown invalidate];
                    self.timerForCountdown = nil;
                    [self removeOfflineMovie];
                }
            }	
            else
            {
                [self.timerForCountdown invalidate];
                self.timerForCountdown = nil;
                [self removeOfflineMovie];
            }
        }
        else
        {
            [self.timerForCountdown invalidate];
            self.timerForCountdown = nil;
            [self removeOfflineMovie];
        }
        lbl.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    }
}

#pragma mark - Get Timing Details
-(NSString *)getCurrentRemainingTime
{
    if(self.viewType == ViewTypeOfflineList)
    {// from offline video list screen
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date1 = [df dateFromString:[video valueForKey:keyNewServerDate]];
        NSString *strCurrentDate = [df stringFromDate:[NSDate date]];
        NSDate *currentDate = [df dateFromString:strCurrentDate];
        NSTimeInterval dis = [currentDate timeIntervalSinceDate:date1];
        double minutesInAnHour = 60;
        
        NSDate *date2 = [df dateFromString:[video valueForKey:keyNewExpiryDate]];
        NSTimeInterval distanceBetweenDates = [date2 timeIntervalSinceDate:date1];
        distanceBetweenDates = distanceBetweenDates - dis;
        
        NSInteger minutesBetweenDates = distanceBetweenDates / minutesInAnHour;
        
        int hours = ((minutesBetweenDates) / 60);
        int minutes = (minutesBetweenDates) % 60; // + 1;
        int seconds = 0;
        return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    }
    else if(self.viewType == ViewTypeList)
    {// from my video list screen
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date1 = [df dateFromString:[video valueForKey:keyServerDate]];
        NSDate *date2 = [df dateFromString:[video valueForKey:keyExpiryDate]];
        NSTimeInterval distanceBetweenDates = [date2 timeIntervalSinceDate:date1];
        
        double minutesInAnHour = 60;
        NSInteger minutesBetweenDates = distanceBetweenDates / minutesInAnHour;
        
        int hours = ((minutesBetweenDates) / 60);// + 5;
        int minutes = (minutesBetweenDates) % 60;
        int seconds = 0;
        return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    }
    return nil;
}

-(NSString *)getCurrentRemainingTimeMessage
{
    if(self.viewType == ViewTypeOfflineList)
    {// from offline video list screen
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date1 = [df dateFromString:[video valueForKey:keyNewServerDate]];
        NSString *strCurrentDate = [df stringFromDate:[NSDate date]];
        NSDate *currentDate = [df dateFromString:strCurrentDate];
        NSTimeInterval dis = [currentDate timeIntervalSinceDate:date1];
        double minutesInAnHour = 60;
        
        NSDate *date2 = [df dateFromString:[video valueForKey:keyNewExpiryDate]];
        NSTimeInterval distanceBetweenDates = [date2 timeIntervalSinceDate:date1];
        distanceBetweenDates = distanceBetweenDates - dis;
        
        NSInteger minutesBetweenDates = distanceBetweenDates / minutesInAnHour;
        //NSLog(@"%d", minutesBetweenDates);
        
        int minutes = (minutesBetweenDates) % 60;
        int totalHours = ((minutesBetweenDates) / 60);
        int days = totalHours / 24;
        int hours = totalHours % 24;
        
        return [NSString stringWithFormat:@"%d day(s) %d hour(s) %d min left", days, hours, minutes];
    }
    else if(self.viewType == ViewTypeList)
    {// from my video list screen
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date1 = [df dateFromString:[video valueForKey:keyServerDate]];
        NSDate *date2 = [df dateFromString:[video valueForKey:keyExpiryDate]]; // [df dateFromString:@"2013-12-20 00:00:00"];
        NSTimeInterval distanceBetweenDates = [date2 timeIntervalSinceDate:date1];
        
        double minutesInAnHour = 60;
        NSInteger minutesBetweenDates = distanceBetweenDates / minutesInAnHour;
        //NSLog(@"%d", minutesBetweenDates);
        
        int minutes = (minutesBetweenDates) % 60;
        int totalHours = ((minutesBetweenDates) / 60);// + 5;
        int days = totalHours / 24;
        int hours = totalHours % 24;
        
        return [NSString stringWithFormat:@"%d day(s) %d hour(s) %d min left", days, hours, minutes];
    }
    return nil;
}

-(double)getDuration:(NSString *)strTime
{
    NSArray *arrayTime = [strTime componentsSeparatedByString:@":"];
    double totalSeconds;
    int hours = [[arrayTime objectAtIndex:0] intValue];
    int minutes = [[arrayTime objectAtIndex:1] intValue];
    //int seconds = [[arrayTime objectAtIndex:2] intValue];
    
    totalSeconds = (hours*3600) + (minutes*60);
    return totalSeconds;
}

#pragma mark - CustomPopupView Delegate
- (void)confirmButtonClicked:(CustomPopupView *)customView forType:(VideoAction)requestType withValues:(NSDictionary *)result
{
    [customView removeFromSuperview];
    currentRequestType = requestType;
    if(requestType == VideoActionBorrow)
    {
        NSString *string = [currentSelectedButton.dictData valueForKey:KeyButtonValue];
        
        NSArray *array = [string componentsSeparatedByString:@"&"];
        NSString *iid = @"";
        NSString *uid = @"";
        NSString *duration = [NSString stringWithFormat:@"%d",[[result valueForKey:keyDuration] intValue]];
        for (NSString *str in array) {
            if ([str hasPrefix:@"id"]) {
                iid = [str substringWithRange:NSMakeRange(3, str.length - 3)];;
            }
            if ([str hasPrefix:@"uid"]) {
                uid = [str substringWithRange:NSMakeRange(4, str.length - 4)];
            }
        }
        NSString *strComment = [result valueForKey:keyComment];
        NSString *strRequest= [NSString stringWithFormat:NSLocalizedString(@"apiRequestForBorrow", nil), strComment, duration,iid, uid];
        NSLog(@"Request(Borrow) %@",strRequest);
        [self request:strRequest withTag:kTAG_OTHER_REQUEST];
    }
    else if(requestType == VideoDownloadOffline)
    {
        [self callOfflineRequestForCustomAlert:result];
    }
    else if(requestType == VideoDownloadOfflineFrom)
    {
        [self afterDownloadFromSelection];
    }
    else if(requestType == VideoDownloadOfflineRenew)
    {
        //call API to update renew time for the downloaded moview
        NSString *strDuration = [NSString stringWithFormat:@"%d",[[result valueForKey:keyDuration] intValue]];
        NSString *strVideoId = [video valueForKey:keyId];
        NSString *strRequest= [NSString stringWithFormat:NSLocalizedString(@"apiRenewOffline", nil), strDuration, strVideoId, [APPDELEGATE getAppToken]];
        NSLog(@"%@",strRequest);
        [self request:strRequest withTag:kTAG_OTHER_REQUEST];
    }
    else if(requestType == VideoActionGiftToFriend)
    {
        NSString *strComment = [result valueForKey:keyComment];
        NSArray *arrayFriendsSelected = (NSArray *)[result objectForKey:keyFriendsSelected];
        NSString *strUserList = [arrayFriendsSelected componentsJoinedByString:@","];
        NSString *strDuration = [NSString stringWithFormat:@"%d", [[result valueForKey:keyDuration] intValue]];
        if (strUserList.length != 0)
        {
            NSString *strVideoId = [currentSendButton.dictData valueForKey:KeyButtonValue];
            NSString *strRequest= [NSString stringWithFormat:NSLocalizedString(@"apiGiftMovie", nil), strComment, strVideoId,[arrayFriendsSelected objectAtIndex:0], strDuration];
            NSLog(@"Request(GiftToFriend) %@", strRequest);
            [self request:strRequest withTag:kTAG_OTHER_REQUEST];
        }
    }
    else if(requestType == VideoActionSellToFriend)
    {
        NSString *strPrice = [result valueForKey:keyPrice];
        NSArray *arrayFriendsSelected = (NSArray *)[result objectForKey:keyFriendsSelected];
        NSString *strUserList = [arrayFriendsSelected componentsJoinedByString:@","];
        NSString *strDuration = [NSString stringWithFormat:@"%d", [[result valueForKey:keyDuration] intValue]];
        if (strUserList.length != 0)
        {
            NSString *strVideoId = [currentSendButton.dictData valueForKey:KeyButtonValue];
            NSString *strRequest = [NSString stringWithFormat:NSLocalizedString(@"apiSellMovieToFriend", nil), strPrice, strVideoId, strUserList, strDuration];
            NSLog(@"Request(SellToFriend) %@", strRequest);
            [self request:strRequest withTag:kTAG_OTHER_REQUEST];
        }
    }
    else if(requestType == VideoActionSend)
    {
        NSString *strComment = [result valueForKey:keyComment];
        NSArray *arrayFriendsSelected = (NSArray *)[result objectForKey:keyFriendsSelected];
        NSString *strUserList = [arrayFriendsSelected componentsJoinedByString:@","];
        if (strUserList.length != 0)
        {
            NSString *strVideoId = [currentSendButton.dictData valueForKey:KeyButtonValue];
            NSString *strRequest= [NSString stringWithFormat:NSLocalizedString(@"apiSendMovieToFriend", nil), strComment, strVideoId, strUserList];
            NSLog(@"Request(VideoSend) %@",strRequest);
            [self request:strRequest withTag:kTAG_SEND_MOVIE_TO_FRIEND_REQUEST];
        }
    }
    else if(requestType == VideoActionSell)
    {
        NSString *strPrice = [result valueForKey:keyPrice];
        NSString *stringComing = [currentSendButton.dictData valueForKey:KeyButtonValue];
        NSArray *array = [stringComing componentsSeparatedByString:@"||"];
        NSString *strVideoId = [array objectAtIndex:0];
        BOOL flag = [[array objectAtIndex:1] boolValue];
        NSString *sendRequest= [NSString stringWithFormat:NSLocalizedString(@"apiSellMovie", nil), strPrice, strVideoId, !flag];
        NSLog(@"Request(Sell Video)%@",sendRequest);
        [self request:sendRequest withTag:kTAG_OTHER_REQUEST];
    }
}

- (void)cancelButtonClicked:(CustomPopupView *)customView {
    [customView removeFromSuperview];
    
}

#pragma mark - Call Other Requests
- (void)request:(NSString *)currentReq withTag:(int)tag
{
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    
    [self disableAllButtons];
    
    IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
    NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
    //if(tag==kTAG_MOVIE_VIEW_COUNT)
    //{
    //    apiUrl = NSLocalizedString(@"appAjaxApi", nil);
    //}
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strParameter = [NSString stringWithFormat:currentReq, strMovieId, [APPDELEGATE getAppToken]];
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

- (void) updateProgressLabel
{
    
    uint64_t freeDiskSpace = [APPDELEGATE getFreeDiskspace];
    if(((freeDiskSpace/1024ll)/1024ll) < ((asiRequest.contentLength/1024ll)/1024ll))
    {
        [[IMDGlobal sharedGlobal] removeCachedImage];
    }
    //NSLog(@"available: %llu MB", ((freeDiskSpace/1024ll)/1024ll));
    //NSLog(@"required:  %llu MB", ((asiRequest.contentLength/1024ll)/1024ll));
    freeDiskSpace = [APPDELEGATE getFreeDiskspace];
    if(((freeDiskSpace/1024ll)/1024ll) < ((asiRequest.contentLength/1024ll)/1024ll))
    {
        strMessage = NSLocalizedString(@"strNoEnoughSpace", nil);
        [self cancelDownload:nil];
        strMessage = NSLocalizedString(@"strDownlodingCancel", nil);
    }
    
    CustomProgressSubClass *progressBar = (CustomProgressSubClass *)[self.view viewWithTag:DOWNLOADING_PROGRESS_BAR];
    UILabel *lbl = (UILabel *)[self.view viewWithTag:DOWNLOADING_PROGRESS_LABEL];
    if([progressBar respondsToSelector:@selector(setProgress:)]) {
        if(progressBar.progress < 1.0f) {
            if([lbl respondsToSelector:@selector(setText:)]) {
                float p = progressBar.progress;
                lbl.text = [NSString stringWithFormat:@"%.f%%",p * 100];
                //lbl.text = @"100%";
                //appDelegate.strProgress = lbl.text;
            }
        }else{
            if([lbl respondsToSelector:@selector(setText:)]) {
                lbl.text = @"100%";
            }
            if(updateProgressTimer) {
                [updateProgressTimer invalidate];
                updateProgressTimer = nil;
            }
            
            //here need to update UI for the page
            [self removeUI];
            [self callMovieDetailApi];
            
            asiRequest = nil;
        }
    }
}

- (void) removeUI {
    for (UIView *view in mainScrollView.subviews){
        [view removeFromSuperview];
    }
    
    UIView *view = [self.view viewWithTag:DOWNLOADING_MOVIE_PROGRESS_OFFLINE];
    if(view)
    {
        [view removeFromSuperview];
    }
    view = [self.view viewWithTag:DOWNLOAD_MOVIE_OFFLINE_ENABLED];
    if(view)
    {
        [view removeFromSuperview];
    }
    view = [self.view viewWithTag:TAG_MD_LBL_TIMERHEADER];
    if(view)
    {
        [view removeFromSuperview];
    }
}

- (void) disableAllButtons {
    for(id obj in detailsView.subviews) {
        if([obj isKindOfClass:[CustomButton class]]) {
            CustomButton *button = (CustomButton *)obj;
            //NSLog(@"no: %@", [button titleForState:UIControlStateNormal]);
            [button setUserInteractionEnabled:NO];
        }
    }
    [self.rightButton setUserInteractionEnabled:NO];
}

- (void) enableAllButtons {
    for(id obj in detailsView.subviews) {
        if([obj isKindOfClass:[CustomButton class]]) {
            CustomButton *button = (CustomButton *)obj;
            //NSLog(@"yes: %@", [button titleForState:UIControlStateNormal]);
            [button setUserInteractionEnabled:YES];
        }
    }
    [self.rightButton setUserInteractionEnabled:YES];
}

- (void) cancelDownload:(CustomButton *)sender // cross(cancel) button clicked
{
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    //cancel ASI request
    [asiRequest cancel];
    asiRequest = nil;
    
    //cancel timer
    if(updateProgressTimer) {
        [updateProgressTimer invalidate];
        updateProgressTimer = nil;
    }
    
    //remove ASI object from dictionary
    [APPDELEGATE.requestObjects removeObjectForKey:[APPDELEGATE getKeyForTag:[[video objectForKey:keyId] intValue]]];
    [self.view makeToast:strMessage];
    
    // remove temporary video details from plist after successful download
    [temporaryDownloadedVideos removeAllObjects];
    temporaryDownloadedVideos = [APPDELEGATE readFromListForKey:kVideosArray];
    for(int i=0;i<temporaryDownloadedVideos.count;i++)
    {
        NSDictionary *dictionary = [temporaryDownloadedVideos objectAtIndex:i];
        if([[dictionary valueForKey:keyId] intValue] == [[video objectForKey:keyId] intValue])
        {
            [temporaryDownloadedVideos removeObject:dictionary];
        }
    }
    [APPDELEGATE writeToListToDeleteAllVideosForKey:kVideosArray];
    for(int i=0;i<temporaryDownloadedVideos.count;i++)
    {
        NSDictionary *dictionary = [temporaryDownloadedVideos objectAtIndex:i];
        [APPDELEGATE writeToListForKey:kVideosArray content:dictionary];
    }
    // remove tempory video file from NSTemporaryDirectory()
    NSString *downloadPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[APPDELEGATE getTitleForVideo:video]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:downloadPath])
    {
        [fileManager removeItemAtPath:downloadPath error:nil];
    }
    [APPDELEGATE removeOldPrefrencesForKey:[APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]]];
    
    [self disableAllButtons];
    NSString *iid = [video valueForKey:keyId];
    NSString *strRequest = [NSString stringWithFormat:NSLocalizedString(@"apiRemoveOffline", nil),iid,[APPDELEGATE getAppToken]];
    [self request:strRequest withTag:kTAG_CANCEL_REMOVE_OFFLINE];
}

- (void) removeOfflineMovieIfTimeOver
{
    @try
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if(userDefaults && video) {
            if([video valueForKey:keyId]) {
                NSString *objectKey = [APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]];
                if ([userDefaults objectForKey:objectKey]){
                    NSDictionary *offlineMovie = [userDefaults objectForKey:objectKey];
                    if(offlineMovie) {
                        
                        NSString *downloadPath = [APPDELEGATE getPathForDownloadedVideo:video];
                        if(downloadPath) {
                            NSFileManager *fileManager = [NSFileManager defaultManager];
                            if(fileManager) {
                                NSError *error = nil;
                                if([fileManager fileExistsAtPath:downloadPath]) {
                                    //removing local video file
                                    [fileManager removeItemAtPath:downloadPath error:&error];
                                    if(error) {
                                        NSLog(@"%@",[error localizedDescription]);
                                    }
                                    
                                    //removing video object from local // Edited On 31/01/2014
                                    [APPDELEGATE removeOldPrefrencesForKey:[APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]]];
                                }
                            }
                        }
                    }
                }
            }
        }
        [APPDELEGATE removeOldPrefrencesForKey:[APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]]];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception while deleting local video file! %@",[exception description]);
    }
    @finally {
    }
}

-(void)downloadOwnerVideo
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationWillEnterForeground_MovieDetails) name:@"applicationWillEnterForeground" object:nil];
    
    NSString *url = @"";
    NSString *fileName = @"video";
    
    if([video valueForKey:keyTitle]) {
        fileName = [video valueForKey:keyTitle];
        //NSString *strPathExtention = [[video valueForKey:@"item_streaming"] pathExtension];
        //fileName = [fileName stringByAppendingFormat:@".mp4"];
        fileName = [fileName stringByAppendingPathExtension:[APPDELEGATE getPathExtensionForVideoFile:[video valueForKey:keyItemStreaming]]];
        NSLog(@"video file name %@", fileName);
    }
    
    if([video valueForKey:keyItemStreaming]) {
        url = [video valueForKey:keyItemStreaming];
        NSLog(@"video file download URL %@",url);
    }
    
    int downloadTag = arc4random()%1000;
    if([video valueForKey:keyId])
    {
        downloadTag = [[video valueForKey:keyId] intValue];
    }
    
    //url = @"http://techslides.com/demos/sample-videos/small.mp4";
    //url = @"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"; //For Testing
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:video];
    
    //Downloading starts here
    asiRequest =[APPDELEGATE startDownloadingWithUrl:url withFileNameToSave:fileName withTag:downloadTag withUserInfo:userInfo];
    CustomButton *btnProgress = (CustomButton *) [self.view viewWithTag:DOWNLOADING_MOVIE_PROGRESS_OFFLINE];
    if([btnProgress isKindOfClass:[CustomButton class]])
    {
        btnProgress.hidden = NO;
    }
    CGFloat yPos = btnProgress.frame.origin.y + btnProgress.frame.size.height;
    UILabel *lbl = (UILabel *)[self.view viewWithTag:TAG_MD_LBL_TIMERHEADER];
    if(lbl && lbl.text.length != 0)
    {
        [lbl setHidden:NO];
        [lbl setFrame:CGRectMake(lbl.frame.origin.x, yPos, lbl.frame.size.width, lbl.frame.size.height)];
        yPos = lbl.frame.origin.y + lbl.frame.size.height;
    }
    else
    {
        [lbl setHidden:YES];
    }
    
    mainScrollView.frame = CGRectMake(mainScrollView.frame.origin.x,yPos, mainScrollView.frame.size.width,self.view.frame.size.height-(yPos));
    
    CustomProgressSubClass *pv = (CustomProgressSubClass *)[btnProgress viewWithTag:DOWNLOADING_PROGRESS_BAR];
    if([pv isKindOfClass:[CustomProgressSubClass class]])
    {
        NSLog(@"setProgressViewForDownloadingRequest called");
        [APPDELEGATE setProgressViewForDownloadingRequest:asiRequest withProgressView:pv];
    }
    
    CustomButton *button = (CustomButton *) [detailsView viewWithTag:DOWNLOAD_MOVIE_OFFLINE];
    if([button isKindOfClass:[CustomButton class]])
    {
        CGFloat btnWidth = detailsView.frame.size.width/2;
        [button setFrame:CGRectMake(MARGIN, button.frame.origin.y, btnWidth-MARGIN*2.0, BUTTON_HEIGHT)];
        
        CustomButton *btnPause = (CustomButton *)[detailsView viewWithTag:PAUSE_DOWNLOAD];
        if(btnPause)
        {
            [btnPause setFrame:CGRectMake(button.frame.origin.x+button.frame.size.width+MARGIN*2.0, button.frame.origin.y, btnWidth-MARGIN*2.0, BUTTON_HEIGHT)];
            [btnPause setHidden:NO];
        }
        
        [button setTitle:NSLocalizedString(@"strWatchNow", nil) forState:UIControlStateNormal];
        [button removeTarget:self action:@selector(requestDownloadVideo) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(playMovieWhileDownloading:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        UIView *lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
        CGFloat yPos = lbl.frame.origin.y;
        [btnProgress setFrame:CGRectMake(MARGIN, yPos, [UIScreen mainScreen].bounds.size.height-MARGIN*2.0, BUTTON_HEIGHT)];
    }
    else
    {
        UIView *lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
        CGFloat yPos = lbl.frame.origin.y;
        [btnProgress setFrame:CGRectMake(MARGIN, yPos, [UIScreen mainScreen].bounds.size.width-MARGIN*2.0, BUTTON_HEIGHT)];
    }
    
    if(!updateProgressTimer){
        updateProgressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateProgressLabel) userInfo:nil repeats:YES];
    }
    
    // --- add currently downloading video to plist
    [temporaryDownloadedVideos removeAllObjects];
    temporaryDownloadedVideos = [APPDELEGATE readFromListForKey:kVideosArray];
    BOOL found = NO;
    if(temporaryDownloadedVideos.count > 0)
    {
        for(int i=0;i<temporaryDownloadedVideos.count;i++)
        {
            NSDictionary *dictionary = [temporaryDownloadedVideos objectAtIndex:i];
            if([[dictionary valueForKey:keyId] intValue] == [[video valueForKey:keyId] intValue])
            {
                found = YES;
                break;
            }
        }
        if(!found)
        {
            [APPDELEGATE writeToListForKey:kVideosArray content:video];
        }
    }
    else
    {
        [APPDELEGATE writeToListForKey:kVideosArray content:video];
    }
}

- (void) callOfflineRequestForCustomAlert:(NSDictionary *)result
{
    NSDictionary *videoSelected = video;
    //if([videoSelected valueForKey:@"borrow_friends"])
    NSArray *borrowFriends = [videoSelected valueForKey:keyBorrowFriends];
    if([borrowFriends count] > 1)
    {
        NSString *uid = @"", *iid = @"";
        if([borrowFriends count] > 1)
        {
            NSString *selectedUIDVideo = [[result objectForKey:keyFriendsSelected] lastObject];
            for(NSDictionary *vd in borrowFriends)
            {
                if([[vd valueForKey:keyUID] isEqualToString:selectedUIDVideo])
                {
                    uid = [vd valueForKey:keyUID];
                    iid = [vd valueForKey:keyIID];
                    break;
                }
            }
        }else{
            NSDictionary *vd = [borrowFriends objectAtIndex:0];
            uid = [vd valueForKey:keyUID];
            iid = [vd valueForKey:keyIID];
        }
        
        NSString *duration = [NSString stringWithFormat:@"%d",[[result valueForKey:keyDuration] intValue]];
        NSString *sendRequest= [NSString stringWithFormat:NSLocalizedString(@"apiBorrowWithOffline", nil), duration, iid, uid, [APPDELEGATE getAppToken]];
        NSLog(@"%@",sendRequest);
        [self request:sendRequest withTag:kTAG_OTHER_REQUEST];
    }
    else //Send request to pass duration for download offline my video
    {
        if(APPDELEGATE.netOnLink == 0)
        {
            [self.view makeToast:WARNING];
            return;
        }
        [self disableAllButtons];
        
        NSString *sendRequest= [NSString stringWithFormat:NSLocalizedString(@"apiOfflineDownloadMovieWithDuration", nil), [video valueForKey:keyId],[APPDELEGATE getAppToken], [result valueForKey:keyDuration]];
        [self request:sendRequest withTag:kTAG_OFFLINE_DOWNLOAD_MOVIE_DURATION];
    }
}

#pragma mark - Play Movie
-(void)eventImageView:(IMDEventImageView *)imageView didSelectWithURL:(NSString *)url
{
    //[self playVideo];
}

- (void)playVideoWithOptions:(CustomButton *)btn
{
    currentSelectedButton=btn;
//    NSURL *url = [NSURL URLWithString:[video objectForKey:keyItemStreaming]];
//    MPMoviePlayerViewController *movieController = [[MPMoviePlayerViewController alloc]initWithContentURL:url];
    
    if(_chromecastController.deviceScanner.devices.count > 0)
    {
        //if(movieController.moviePlayer.isAirPlayVideoActive)
        if([AirPlayDetector defaultDetector].isAirPlayAvailable)
        {
            UIActionSheet *actionSheet =
            [[UIActionSheet alloc] initWithTitle:@""
                                        delegate:self
                               cancelButtonTitle:@"Cancel"
                          destructiveButtonTitle:nil
                               otherButtonTitles:NSLocalizedString(@"strPlay on this device", nil), NSLocalizedString(@"strPlay on Chromecast", nil), NSLocalizedString(@"strPlay on Apple TV", nil), nil];
            actionSheet.tag = TAG_MD_ACTIONSHEET_PLAY_APPLETV;
           // [actionSheet setValue:btn forKey:@"customButton"];
            [actionSheet showInView:self.view];
        }
        else
        {
            UIActionSheet *actionSheet =
            [[UIActionSheet alloc] initWithTitle:@""
                                        delegate:self
                               cancelButtonTitle:@"Cancel"
                          destructiveButtonTitle:nil
                               otherButtonTitles:NSLocalizedString(@"strPlay on this device", nil), NSLocalizedString(@"strPlay on Chromecast", nil), nil];
            actionSheet.tag = TAG_MD_ACTIONSHEET_PLAY;
          //  [actionSheet setValue:@"" forKey:@"customButton"];
            [actionSheet showInView:self.view];
        }
    }
    else
    {
        [self playVideo:btn];
    }
}

-(void)playVideo:(CustomButton *)btn
{
    if(asiRequest)
    {
        [self playMovieWhileDownloading:nil];
        return;
    }
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:DefaultKeyDownloadMode])
    {
        downloadOption = [[NSUserDefaults standardUserDefaults] integerForKey:DefaultKeyDownloadMode];
    }
    //offline-mode---
    if([[video valueForKey:keyOfflineMode] intValue] == 2)
    {
        if([video valueForKey:keyIsAlreadyDownloaded])
        {
            if([[video valueForKey:keyIsAlreadyDownloaded] intValue] == 0)
            {// this is for online playing
                if(APPDELEGATE.netOnLink == 0)
                {
                    [self.view makeToast:WARNING];
                    return;
                }
                if(downloadOption == DownLoadModeWIFI) //wifi only
                {
                    if([self checkIfConnectedOnWifi] == NO) {
                        //if cellular is selected
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"strMovieUsesData", nil) message:NSLocalizedString(@"strDownloadFromMobileProvider", nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                        return;
                    }
                }
                if(downloadOption == DownLoadModeBoth)
                {
                    if([self checkIfConnectedOnWifi])
                    {
                    }
                    else if([self checkIfConnectedOnCellular])
                    {
                        if([[NSUserDefaults standardUserDefaults] objectForKey:DefaultKeySettingsChanged])
                        {
                            [APPDELEGATE removeOldPrefrencesForKey:DefaultKeySettingsChanged];
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"strDeviceNeedsWifi", nil) message:NSLocalizedString(@"strChangeSettings", nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                            [alert show];
                        }
                    }
                    else
                    {
                        [self.view makeToast:WARNING];
                        return;
                    }
                }
                
                [self playVideo:video Button:btn];
            }
            else //play video locally..
            {// video is downloaded in this device
                NSString *downloadPath = [APPDELEGATE getPathForDownloadedVideo:video];
                NSString *strTempDownloadPath = [NSTemporaryDirectory() stringByAppendingString:[APPDELEGATE getTitleForVideo:video]];
                
                /*
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:[NSNumber numberWithInt:511] forKey:NSFilePosixPermissions]; //511 is Decimal for the 777 octal
                NSError *error1;
                [fileManager setAttributes:dict ofItemAtPath:downloadPath error:&error1];
                 */
                NSFileManager *fileManager = [NSFileManager defaultManager];
                if(fileManager) {
                    if([fileManager fileExistsAtPath:downloadPath])
                    {
                        NSURL *fileURL = [NSURL fileURLWithPath:downloadPath];
                        [self playVideoWithFileUrl:fileURL];
                    }
                    else if([fileManager fileExistsAtPath:strTempDownloadPath])
                    {
                        NSURL *fileURL = [NSURL fileURLWithPath:strTempDownloadPath];
                        [self playVideoWithFileUrl:fileURL];
                    }
                }
            }
        }
    }
    else if([[video valueForKey:keyOfflineMode] intValue] == 0)
    {
        NSString *downloadPath = [APPDELEGATE getPathForDownloadedVideo:video];
        NSString *strTempDownloadPath = [NSTemporaryDirectory() stringByAppendingString:[APPDELEGATE getTitleForVideo:video]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(fileManager) {
            if([fileManager fileExistsAtPath:downloadPath])
            {
                NSURL *fileURL = [NSURL fileURLWithPath:downloadPath];
                [self playVideoWithFileUrl:fileURL];
            }
            else if([fileManager fileExistsAtPath:strTempDownloadPath])
            {
                NSURL *fileURL = [NSURL fileURLWithPath:strTempDownloadPath];
                [self playVideoWithFileUrl:fileURL];
            }
            else
            {//play video from stream.. (online)
                if(APPDELEGATE.netOnLink == 0)
                {
                    [self.view makeToast:WARNING];
                    return;
                }
                if(downloadOption == DownLoadModeWIFI) //wifi only
                {
                    if([self checkIfConnectedOnWifi] == NO) {
                        //if cellular is selected
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"strMovieUsesData", nil) message:NSLocalizedString(@"strDownloadFromMobileProvider", nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                        return;
                    }
                }
                if(downloadOption == DownLoadModeBoth)
                {
                    if([self checkIfConnectedOnWifi])
                    {
                    }
                    else if([self checkIfConnectedOnCellular])
                    {
                        if([[NSUserDefaults standardUserDefaults] objectForKey:DefaultKeySettingsChanged])
                        {
                            [APPDELEGATE removeOldPrefrencesForKey:DefaultKeySettingsChanged];
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"strDeviceNeedsWifi", nil) message:NSLocalizedString(@"strChangeSettings", nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                            [alert show];
                        }
                    }
                    else
                    {
                        [self.view makeToast:WARNING];
                        return;
                    }
                }
                
                [self playVideo:video Button:btn];
            }
        }
    }
    else if([[video valueForKey:keyOfflineMode] intValue] == 4)
    {
        if(APPDELEGATE.netOnLink == 0)
        {
            [self.view makeToast:WARNING];
            return;
        }
        if(downloadOption == DownLoadModeWIFI) //wifi only
        {
            if([self checkIfConnectedOnWifi] == NO) {
                //if cellular is selected
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"strMovieUsesData", nil) message:NSLocalizedString(@"strDownloadFromMobileProvider", nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
        }
        if(downloadOption == DownLoadModeBoth)
        {
            if([self checkIfConnectedOnWifi])
            {
            }
            else if([self checkIfConnectedOnCellular])
            {
                if([[NSUserDefaults standardUserDefaults] objectForKey:DefaultKeySettingsChanged])
                {
                    [APPDELEGATE removeOldPrefrencesForKey:DefaultKeySettingsChanged];
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"strDeviceNeedsWifi", nil) message:NSLocalizedString(@"strChangeSettings", nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
            else
            {
                [self.view makeToast:WARNING];
                return;
            }
        }
        
        [self playVideo:video Button:btn];
    }
}

- (void) playMovieWhileDownloading:(CustomButton *)button
{
    NSString *strTempDownloadPath = [NSTemporaryDirectory() stringByAppendingString:[APPDELEGATE getTitleForVideo:video]];
    NSURL *fileURL = [NSURL fileURLWithPath:strTempDownloadPath];
    if(fileURL) {
        //isPlayWhileDownloading = YES;
        [self playVideoWithFileUrl:fileURL];
    }else{
        NSLog(@"Offline play not possible!");
    }
    return;
    
    /*
    if(asiRequest)
    {
        //NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *path = [asiRequest temporaryFileDownloadPath];
     
        NSString *string = path;
        NSString *slink = @"";
        NSString *strPathExtension = [APPDELEGATE getPathExtensionForVideoFile:[video valueForKey:keyItemStreaming]];
        if ([string rangeOfString:strPathExtension].location == NSNotFound) {
            slink = [path stringByAppendingPathExtension:strPathExtension];
        }
        else
        {
            slink = path;
        }
    
        NSURL *fileURL = [NSURL fileURLWithPath:slink];
        if(fileURL) {
            //isPlayWhileDownloading = YES;
            [self playVideoWithFileUrl:fileURL];
        }else{
            NSLog(@"Offline play not possible!");
        }
    }
    else
    {
        NSString *strTempDownloadPath = [NSTemporaryDirectory() stringByAppendingString:[APPDELEGATE getTitleForVideo:video]];
        NSURL *fileURL = [NSURL fileURLWithPath:strTempDownloadPath];
        if(fileURL) {
            //isPlayWhileDownloading = YES;
            [self playVideoWithFileUrl:fileURL];
        }else{
            NSLog(@"Offline play not possible!");
        }
    }
     */
}

- (void) playVideo:(NSDictionary *)item Button:(CustomButton *)btn{
    
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    
    //[self request:[NSString stringWithFormat:@"action=action_ajax&do=video_view_count&id=%@", [video objectForKey:keyId]] withTag:kTAG_MOVIE_VIEW_COUNT];
	[self request:[NSString stringWithFormat:@"page=video_view_count&id=%@", [video objectForKey:keyId]] withTag:kTAG_MOVIE_VIEW_COUNT];
    
    NSString *streaming;
    switch (btn.tag)
    {
        case TAG_MD_BTN_LOWDEF:
        {
            streaming=keyItemStreaming_360
            ;
        }
             break;
        case TAG_MD_BTN_HIGHDEF:
        {
            streaming=keyItemStreaming_720
            ;
        }
              break;
        case TAG_MD_BTN_ULTRADEF:
        {
            streaming=keyItemStreaming_1080
            ;
        }
            break;
        default:
        {
            streaming=keyItemStreaming;
        }
            break;
    }
   
    NSURL *url = [NSURL URLWithString:[video objectForKey:streaming]];
    MPMoviePlayerViewController *movieController = [[MPMoviePlayerViewController alloc]initWithContentURL:url];
    [[movieController moviePlayer] setAllowsAirPlay:YES];
    [self presentMoviePlayerViewControllerAnimated:movieController];
    movieController.moviePlayer.useApplicationAudioSession = NO;
}
-(void)playTrailer:(CustomButton *)btn
{
     NSURL *url = [NSURL URLWithString:[video objectForKey:keyTrailer]];
    [self playVideoWithFileUrl:url];
}
- (void) playVideoWithFileUrl:(NSURL *)url // locally
{
    MPMoviePlayerViewController *movieController = [[MPMoviePlayerViewController alloc]initWithContentURL:url];
    [self presentMoviePlayerViewControllerAnimated:movieController];
    movieController.moviePlayer.useApplicationAudioSession = NO;
    [[movieController moviePlayer] prepareToPlay];
    [[movieController moviePlayer] play];
}

#pragma mark - Internet Status Changes
-(void)resumeDownloading // called when internet connection restarts with cellular data
{
    [self enableAllButtons];
    [self checkForInternetDuringDownloadInProgressForResume];
}

-(void)cancelDownloading // called when no internet connection
{
    [self enableAllButtons];
    //[self removeOldPrefrencesForKey:[appDelegate getKeyForTag:[[self.video valueForKey:@"id"] intValue]]];
    [self checkForInternetDuringDownloadInProgress];
}

- (void) checkForInternetDuringDownloadInProgress {
    
    if(APPDELEGATE.netOnLink != 0)
    {
        if([self checkIfConnectedOnWifi])
        {
            //if wifi available, no need to do anything
        }
        else //if wifi off
        {
            if(downloadOption == DownLoadModeBoth) //wifi and cellular both
            {
                if([self checkIfConnectedOnCellular]) {
                    //cellular is available
                    //download will be continue
                }else{
                    //need to [pause] downloading, invalidate timer
                    //show appropriate message
                    
                    if(iPad)
                    {
                        [self.view makeToast:@"No connection, please check internet settings"];
                    }
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cancelDownloading" object:nil];
                    //[self.navigationController popViewControllerAnimated:YES];
                    if(asiRequest)
                    {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
            }
            else
            {//only wifi is selected in setting, but cellular may available, check if available then show proper message
                if([self checkIfConnectedOnCellular]) {
                    //please allow cellular use under the ‘settings’ area to watch movies
                    //need to [pause] downloading, invalidate timer
                    if(updateProgressTimer) {
                        [updateProgressTimer invalidate];
                        updateProgressTimer = nil;
                    }
                    //[self.viewC.view makeToast:@"Please allow cellular use under the ‘settings’ area to watch movies"];
                    [asiRequest cancel];
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cancelDownloading" object:nil];
                    //[self.navigationController popViewControllerAnimated:YES];
                    if(asiRequest)
                    {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
                else{
                    //show no internet connection message
                    if(updateProgressTimer) {
                        [updateProgressTimer invalidate];
                        updateProgressTimer = nil;
                    }
                    [self.view makeToast:@"No connection, please check internet settings"];
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cancelDownloading" object:nil];
                    //[self.navigationController popViewControllerAnimated:YES];
                    if(asiRequest)
                    {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
            }
        }
    }
    else{//show no internet connection message
        //[self.navigationController popViewControllerAnimated:YES];
        if(asiRequest)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void) checkForInternetDuringDownloadInProgressForResume {
    
    if(APPDELEGATE.netOnLink != 0)
    {
        if([self checkIfConnectedOnWifi])
        {
            //if wifi available, no need to do anything
        }
        else //if wifi off
        {
            if(downloadOption == DownLoadModeBoth) //wifi and cellular both
            {
                if([self checkIfConnectedOnCellular]) {
                    //cellular is available
                    //download will be continue
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"resumeDownloading" object:nil];
                }else{
                    //need to [pause] downloading, invalidate timer
                    //show appropriate message
                    
                    if(updateProgressTimer) {
                        [updateProgressTimer invalidate];
                        updateProgressTimer = nil;
                    }
                    [self.view makeToast:@"No connection, please check internet settings"];
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"resumeDownloading" object:nil];
                    //[self.navigationController popViewControllerAnimated:YES];
                    if(asiRequest)
                    {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
            }
            else
            {//only wifi is selected in setting, but cellular may available, check if available then show proper message
                if([self checkIfConnectedOnCellular]) {
                    //please allow cellular use under the ‘settings’ area to watch movies
                    //need to [pause] downloading, invalidate timer
                    if(updateProgressTimer) {
                        [updateProgressTimer invalidate];
                        updateProgressTimer = nil;
                    }
                    //[self.viewC.view makeToast:@"Please allow cellular use under the ‘settings’ area to watch movies"];
                    [asiRequest cancel];
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"resumeDownloading" object:nil];
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cancelDownloading" object:nil];
                    //[self.navigationController popViewControllerAnimated:YES];
                    if(asiRequest)
                    {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
                else{
                    //show no internet connection message
                    
                    if(updateProgressTimer) {
                        [updateProgressTimer invalidate];
                        updateProgressTimer = nil;
                    }
                    [self.view makeToast:@"No connection, please check internet settings"];
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"resumeDownloading" object:nil];
                    //[self.navigationController popViewControllerAnimated:YES];
                    if(asiRequest)
                    {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
            }
        }
    }
    else{//show no internet connection message
    }
}

//============================= Chrome Casting =============================
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(actionSheet.tag == TAG_MD_ACTIONSHEET_PLAY)
    {
        if (buttonIndex == 1)
        {
            if(_chromecastController.deviceScanner.devices.count > 0)
            {
                UIStoryboard *storyboard = iPhone_storyboard;
                if (iPad)
                {
                    storyboard = self.storyboard;
                }
                LocalPlayerViewController *objLPVC = (LocalPlayerViewController *) [storyboard instantiateViewControllerWithIdentifier:@"LocalPlayerVC"];
                objLPVC.objVideo = video;
                [self.navigationController pushViewController:objLPVC animated:YES];
            }
            else
            {
                [self.view makeToast:NSLocalizedString(@"Please connect to Cast device", nil)];
            }
        }
        else if (buttonIndex == 0)
        {
            /*
            [self request:[NSString stringWithFormat:@"action=action_ajax&page=video_view_count&id=%@", [video objectForKey:keyId]] withTag:kTAG_MOVIE_VIEW_COUNT];
            
            NSURL *fileURL = [NSURL URLWithString:[video objectForKey:keyItemStreaming]];
            MPMoviePlayerViewController *movieController = [[MPMoviePlayerViewController alloc]initWithContentURL:fileURL];
            [[movieController moviePlayer] setAllowsAirPlay:YES];
            [self presentMoviePlayerViewControllerAnimated:movieController];
            movieController.moviePlayer.useApplicationAudioSession = NO;
             */
           
            [self playVideo:currentSelectedButton];
        }
    }
    else if(actionSheet.tag == TAG_MD_ACTIONSHEET_PLAY_APPLETV)
    {
        if (buttonIndex == 1 || buttonIndex == 2)
        {
            if(_chromecastController.deviceScanner.devices.count > 0)
            {
                UIStoryboard *storyboard = iPhone_storyboard;
                if (iPad)
                {
                    storyboard = self.storyboard;
                }
                LocalPlayerViewController *objLPVC = (LocalPlayerViewController *) [storyboard instantiateViewControllerWithIdentifier:@"LocalPlayerVC"];
                objLPVC.objVideo = video;
                [self.navigationController pushViewController:objLPVC animated:YES];
            }
            else
            {
                [self.view makeToast:NSLocalizedString(@"Please connect to Cast device", nil)];
            }
        }
        else if (buttonIndex == 0)
        {
            /*
            [self request:[NSString stringWithFormat:@"action=action_ajax&page=video_view_count&id=%@", [video objectForKey:keyId]] withTag:kTAG_MOVIE_VIEW_COUNT];
            
            NSURL *fileURL = [NSURL URLWithString:[video objectForKey:keyItemStreaming]];
            MPMoviePlayerViewController *movieController = [[MPMoviePlayerViewController alloc]initWithContentURL:fileURL];
            [[movieController moviePlayer] setAllowsAirPlay:YES];
            [self presentMoviePlayerViewControllerAnimated:movieController];
            movieController.moviePlayer.useApplicationAudioSession = NO;
             */
            [self playVideo:currentSelectedButton];
        }
    }
}

//=======================================================
#pragma mark - ChromecastControllerDelegate

/**
 * Called when chromecast devices are discoverd on the network.
 */
- (void)didDiscoverDeviceOnNetwork {
    // Add the chromecast icon if not present.
    //self.navigationItem.rightBarButtonItem = _chromecastController.chromecastBarButton;
    
    UIButton *btnCast = (UIButton *)[self.view viewWithTag:kTagCastButton];
    if(!btnCast)
    {        
        btnCast = [self rightButton];
        btnCast = (UIButton *)_chromecastController.chromecastBarButton.customView;
        [btnCast setTag:kTagCastButton];
        [btnCast setHidden:NO];
        if(iPhone)
        {
            [btnCast setFrame:CGRectMake(self.view.frame.size.width - (btnCast.frame.size.width+5), (iOS7?35:15), btnCast.frame.size.width, btnCast.frame.size.height)];
        }
        else
        {
            [btnCast setFrame:CGRectMake(self.view.frame.size.width - (btnCast.frame.size.width+10), (iOS7?40:20), btnCast.frame.size.width, btnCast.frame.size.height)];
        }
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
    NSString *title =
    [_chromecastController.mediaInformation.metadata stringForKey:kGCKMetadataKeyTitle];
    
    if([[video objectForKey:keyCanPlay] isEqualToNumber:[NSNumber numberWithInt:0]])
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
    objCastVC.objVideo = video;
    [self.navigationController pushViewController:objCastVC animated:YES];
}

#pragma mark - Pause Downloading Forcefully
-(void)pauseDownloadingFromBG
{
    if([video valueForKey:keyNewServerDate] && [video valueForKey:keyNewExpiryDate])
    {
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date1 = [df dateFromString:[video valueForKey:keyNewServerDate]];
        NSString *strCurrentDate = [df stringFromDate:[NSDate date]];
        NSDate *currentDate = [df dateFromString:strCurrentDate];
        NSTimeInterval dis = [currentDate timeIntervalSinceDate:date1];
        //double minutesInAnHour = 60;
        
        NSDate *date2 = [df dateFromString:[video valueForKey:keyNewExpiryDate]];
        NSTimeInterval distanceBetweenDates = [date2 timeIntervalSinceDate:date1];
        distanceBetweenDates = distanceBetweenDates - dis;
        //NSLog(@"distanceBetweenDates : %f", distanceBetweenDates);
        
        if(distanceBetweenDates < 0)
        {
            [self removeOfflineMovieIfTimeOver];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }
    
    CustomButton *btn = (CustomButton *)[detailsView viewWithTag:PAUSE_DOWNLOAD];
    if(APPDELEGATE.netOnLink == 0)
    {
        if(asiRequest)
        {// pause
            [asiRequest clearDelegatesAndCancel];
            [btn setTitle:NSLocalizedString(@"strResumeDownload", nil) forState:UIControlStateNormal];
            [APPDELEGATE.requestObjects removeObjectForKey:[APPDELEGATE getKeyForTag:[[video objectForKey:keyId] intValue]]];
            asiRequest = nil;
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"applicationWillEnterForeground" object:nil];
        }
    }
    else
    {
        if([[btn titleForState:UIControlStateNormal] isEqualToString:NSLocalizedString(@"strPauseDownload", nil)])
        {
            //if(![UIApplication sharedApplication].isNetworkActivityIndicatorVisible)
            if(![asiRequest isExecuting])
            {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"applicationWillEnterForeground" object:nil];
                [self downloadOwnerVideo];
            }
        }
    }
}

- (void)applicationWillEnterForeground_MovieDetails
{
    [self pauseDownloadingFromBG];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end