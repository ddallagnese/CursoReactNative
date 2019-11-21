// Copyright 2014 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "CastViewController.h"
#import "LocalPlayerViewController.h"
#import "DeviceTableViewController.h"

@interface CastViewController ()<VolumeChangeControllerDelegate> {
  NSTimeInterval _mediaStartTime;
  BOOL _currentlyDraggingSlider;
  BOOL _readyToShowInterface;
  BOOL _joinExistingSession;
  __weak ChromecastDeviceController* _chromecastController;
}
@property(strong, nonatomic) UIPopoverController* masterPopoverController;
@property IBOutlet UIImageView* thumbnailImage;
@property IBOutlet UILabel* castingToLabel;
@property(weak, nonatomic) IBOutlet UILabel* mediaTitleLabel;
@property(weak, nonatomic) IBOutlet UIActivityIndicatorView* castActivityIndicator;
@property(weak, nonatomic) NSTimer* updateStreamTimer;

@property(nonatomic) UIBarButtonItem* currTime;
@property(nonatomic) UIBarButtonItem* totalTime;
@property(nonatomic) UISlider* slider;
@property(nonatomic) NSArray* playToolbar;
@property(nonatomic) NSArray* pauseToolbar;
@end

@implementation CastViewController

- (id)initWithCoder:(NSCoder*)decoder {
  self = [super initWithCoder:decoder];
  if (self) {
    [self initControls];
  }

  return self;
}

- (void)dealloc {
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  //self.navigationItem.rightBarButtonItem = _chromecastController.chromecastBarButton;
    
  self.castingToLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Casting to %@", nil),
      _chromecastController.deviceName];
    self.mediaTitleLabel.text = [self.objVideo valueForKey:keyTitle];
    
    [self.thumbnailImage setFrame:CGRectMake(0, KTopBarHeight, self.thumbnailImage.frame.size.width, self.thumbnailImage.frame.size.height)];
    [self.thumbnailImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.thumbnailImage setClipsToBounds:YES];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Managing the detail item

- (void)setMediaToPlay:(NSDictionary*)newDetailItem {
  [self setMediaToPlay:newDetailItem withStartingTime:0];
}

- (void)setMediaToPlay:(NSDictionary*)newMedia withStartingTime:(NSTimeInterval)startTime {
  _mediaStartTime = startTime;
  if (_objVideo != newMedia) {
    _objVideo = newMedia;

    // Update the view.
    [self configureView];
  }
}

- (void)resetInterfaceElements {
  self.totalTime.title = @"";
  self.currTime.title = @"";
  [self.slider setValue:0];
  [self.castActivityIndicator startAnimating];
  _currentlyDraggingSlider = NO;
  self.navigationController.toolbarHidden = YES;
  _readyToShowInterface = NO;
}

- (void)mediaNowPlaying {
  _readyToShowInterface = YES;
  [self updateInterfaceFromCast:nil];
  self.navigationController.toolbarHidden = NO;
}

- (void)updateInterfaceFromCast:(NSTimer*)timer {
  [_chromecastController updateStatsFromDevice];

  if (!_readyToShowInterface)
    return;

  if (_chromecastController.playerState != GCKMediaPlayerStateBuffering) {
    [self.castActivityIndicator stopAnimating];
  } else {
    [self.castActivityIndicator startAnimating];
  }

  if (_chromecastController.streamDuration > 0 && !_currentlyDraggingSlider) {
    self.currTime.title = [self getFormattedTime:_chromecastController.streamPosition];
    self.totalTime.title = [self getFormattedTime:_chromecastController.streamDuration];
    [self.slider
        setValue:(_chromecastController.streamPosition / _chromecastController.streamDuration)
        animated:YES];
  }
  if (_chromecastController.playerState == GCKMediaPlayerStatePaused ||
      _chromecastController.playerState == GCKMediaPlayerStateIdle) {
    self.toolbarItems = self.playToolbar;
  } else if (_chromecastController.playerState == GCKMediaPlayerStatePlaying ||
             _chromecastController.playerState == GCKMediaPlayerStateBuffering) {
    self.toolbarItems = self.pauseToolbar;
  }
}

// Little formatting option here

- (NSString*)getFormattedTime:(NSTimeInterval)timeInSeconds {
  NSInteger seconds = (NSInteger) round(timeInSeconds);
  NSInteger hours = seconds / (60 * 60);
  seconds %= (60 * 60);

  NSInteger minutes = seconds / 60;
  seconds %= 60;

  if (hours > 0) {
    return [NSString stringWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
  } else {
    return [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
  }
}

- (void)configureView {
  if (self.objVideo && _chromecastController.isConnected) {
    NSURL* url = [NSURL URLWithString:[self.objVideo valueForKey:keyItemStreaming]];
    self.castingToLabel.text =
        [NSString stringWithFormat:@"Casting to %@", _chromecastController.deviceName];
    self.mediaTitleLabel.text = [self.objVideo valueForKey:keyTitle];
    NSLog(@"Casting movie %@ at starting time %f", url, _mediaStartTime);

    //Loading thumbnail async
      self.thumbnailImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.objVideo valueForKey:keyPoster1]]]];
      [self.view setNeedsLayout];
      /*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      UIImage* image = [UIImage
          imageWithData:[SimpleImageFetcher getDataFromImageURL:[NSURL URLWithString:[self.objVideo valueForKey:keyPoster1]]]];

      dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Loaded thumbnail image");
        self.thumbnailImage.image = image;
          [self.view setNeedsLayout];
      });
    });
       */

    // If the newMedia is already playing, join the existing session.
    if (![[self.objVideo valueForKey:keyTitle] isEqualToString:[_chromecastController.mediaInformation.metadata
            stringForKey:kGCKMetadataKeyTitle]]) {
      //Cast the movie!!
      [_chromecastController loadMedia:url
                         thumbnailPath:[self.objVideo valueForKey:keyPoster1]
                                 title:[self.objVideo valueForKey:keyTitle]
                              subtitle:@""
                              mimeType:@"video/mp4"
                             startTime:_mediaStartTime
                              autoPlay:YES
                                strURL:[self.objVideo valueForKey:keyItemStreaming]];
      _joinExistingSession = NO;
        APPDELEGATE.currentVideoObj = self.objVideo; // edited for common cast button
        
        [APPDELEGATE setNewPrefrencesForObject:APPDELEGATE.currentVideoObj forKey:keyCastVideo];
    } else {
        
      _joinExistingSession = YES;
      [self mediaNowPlaying];
    }

    // Start the timer
    if (self.updateStreamTimer) {
      [self.updateStreamTimer invalidate];
      self.updateStreamTimer = nil;
    }

    self.updateStreamTimer =
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(updateInterfaceFromCast:)
                                       userInfo:nil
                                        repeats:YES];

  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
    
    // Edited
    //self.navigationController.navigationBarHidden = NO;
    //self.navigationController.navigationBar.backgroundColor = TopBgColor;
    //self.view.backgroundColor = TopBgColor;
    [self setSagebinLogoInCenterForOrientation:[UIApplication sharedApplication].statusBarOrientation];
    
    // Store a reference to the chromecast controller.
    _chromecastController = APPDELEGATE.chromecastDeviceController;
    // Assign ourselves as delegate ONLY in viewWillAppear of a view controller.
    _chromecastController.delegate = self;
    
    UIButton *btnSettings = [self rightButton];
    [btnSettings setHidden:YES];
    
    UIButton *btnAlert = [self alertButton];
    [btnAlert setHidden:YES];
    if (_chromecastController.deviceScanner.devices.count > 0)
    {
        UIButton *btnCast = (UIButton *)[self.view viewWithTag:kTagCastButton];
        if(!btnCast)
        {
            //UIButton *btnCast = [self rightButton];
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
    // Edited

  if (!_chromecastController.isConnected) {
    return;
  }

  // Make the navigation bar transparent.
//  [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
//                                                forBarMetrics:UIBarMetricsDefault];
//  self.navigationController.navigationBar.shadowImage = [UIImage new];

  // We want a transparent toolbar.
  [self.navigationController.toolbar setBackgroundImage:[UIImage new]
                                     forToolbarPosition:UIBarPositionBottom
                                             barMetrics:UIBarMetricsDefault];
  [self.navigationController.toolbar setShadowImage:[UIImage new]
                                 forToolbarPosition:UIBarPositionBottom];
  self.navigationController.toolbarHidden = YES;
  self.toolbarItems = self.playToolbar;

  [self resetInterfaceElements];

  if (_joinExistingSession == YES) {
    [self mediaNowPlaying];
  }

  [self configureView];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  // I think we can safely stop the timer here
  [self.updateStreamTimer invalidate];
  self.updateStreamTimer = nil;

//  [self.navigationController.navigationBar setBackgroundImage:nil
//                                                forBarMetrics:UIBarMetricsDefault];
  [self.navigationController.toolbar setBackgroundImage:nil
                                     forToolbarPosition:UIBarPositionBottom
                                             barMetrics:UIBarMetricsDefault];
    self.navigationController.toolbarHidden = YES;
    
//    self.navigationController.navigationBarHidden = YES; // Edited
}

#pragma mark - On - screen UI elements
- (IBAction)pauseButtonClicked:(id)sender {
  [_chromecastController pauseCastMedia:YES];
}

- (IBAction)playButtonClicked:(id)sender {
  [_chromecastController pauseCastMedia:NO];
}

// Unsed, but if you wanted a stop, as opposed to a pause button, this is probably
// what you would call
- (IBAction)stopButtonClicked:(id)sender {
  [_chromecastController stopCastMedia];
  [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onTouchDown:(id)sender {
  _currentlyDraggingSlider = YES;
}

// This is continuous, so we can update the current/end time labels
- (IBAction)onSliderValueChanged:(id)sender {
  float pctThrough = [self.slider value];
  if (_chromecastController.streamDuration > 0) {
    self.currTime.title =
        [self getFormattedTime:(pctThrough * _chromecastController.streamDuration)];
  }
}
// This is called only on one of the two touch up events
- (void)touchIsFinished {
  [_chromecastController setPlaybackPercent:[self.slider value]];
  _currentlyDraggingSlider = NO;
}

- (IBAction)onTouchUpInside:(id)sender {
  NSLog(@"Touch up inside");
  [self touchIsFinished];

}
- (IBAction)onTouchUpOutside:(id)sender {
  NSLog(@"Touch up outside");
  [self touchIsFinished];
}

#pragma mark - ChromecastControllerDelegate

/**
 * Called when connection to the device was closed.
 */
- (void)didDisconnect {
    
    if(APPDELEGATE.isFromLocalPlayerScreen)
    {
        //[self.navigationController popViewControllerAnimated:YES];
        int viewToPop = 2;
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-viewToPop-1] animated:YES];
    }
  else
  {
      [self.navigationController popViewControllerAnimated:YES];
  }
    APPDELEGATE.isFromLocalPlayerScreen = NO;
}

/**
 * Called when the playback state of media on the device changes.
 */
- (void)didReceiveMediaStateChange {
  _readyToShowInterface = YES;
  self.navigationController.toolbarHidden = NO;

  if (_chromecastController.playerState == GCKMediaPlayerStateIdle) {
    [self.navigationController popViewControllerAnimated:YES];
  }
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

#pragma mark - implementation.
- (void)initControls {
  UIBarButtonItem* playButton =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                    target:self
                                                    action:@selector(playButtonClicked:)];
    playButton.tintColor = [UIColor whiteColor];
    
  UIBarButtonItem* pauseButton =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause
                                                    target:self
                                                    action:@selector(pauseButtonClicked:)];
  pauseButton.tintColor = [UIColor whiteColor];
  self.currTime = [[UIBarButtonItem alloc] initWithTitle:@"00:00"
                                                   style:UIBarButtonItemStylePlain
                                                  target:nil
                                                  action:nil];
  self.currTime.tintColor = [UIColor whiteColor];
  self.totalTime = [[UIBarButtonItem alloc] initWithTitle:@"100:00"
                                                    style:UIBarButtonItemStylePlain
                                                   target:nil
                                                   action:nil];
  self.totalTime.tintColor = [UIColor whiteColor];
  UIBarButtonItem* flexibleSpace =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                    target:nil
                                                    action:nil];
  UIBarButtonItem* flexibleSpace2 =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                    target:nil
                                                    action:nil];
  UIBarButtonItem* flexibleSpace3 =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                    target:nil
                                                    action:nil];

  self.slider = [[UISlider alloc] init];
    //self.slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
  [self.slider addTarget:self
                  action:@selector(onSliderValueChanged:)
        forControlEvents:UIControlEventValueChanged];
  [self.slider addTarget:self
                  action:@selector(onTouchDown:)
        forControlEvents:UIControlEventTouchDown];
  [self.slider addTarget:self
                  action:@selector(onTouchUpInside:)
        forControlEvents:UIControlEventTouchUpInside];
  [self.slider addTarget:self
                  action:@selector(onTouchUpOutside:)
        forControlEvents:UIControlEventTouchUpOutside];
    self.slider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  UIBarButtonItem* sliderItem = [[UIBarButtonItem alloc] initWithCustomView:self.slider];
  sliderItem.tintColor = [UIColor yellowColor];
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    sliderItem.width = 500;
  }
    else
    {
        sliderItem.width = 100;
    }

  self.playToolbar = [NSArray arrayWithObjects:flexibleSpace,
      playButton, flexibleSpace2, self.currTime, sliderItem, self.totalTime, flexibleSpace3, nil];
  self.pauseToolbar = [NSArray arrayWithObjects:flexibleSpace,
      pauseButton, flexibleSpace2, self.currTime, sliderItem, self.totalTime, flexibleSpace3, nil];
}

//Edited
-(void)setSagebinLogoInCenterForOrientation:(UIInterfaceOrientation)orientation
{
    UIView *topView = [self.view viewWithTag:TopView_Tag];
    UIImageView *imgVw = (UIImageView *)[topView viewWithTag:Top_Logo_Tag];
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    if(orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft)
    {
        frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    
    [imgVw setFrame:CGRectMake(frame.size.width/2-imgVw.frame.size.width/2, imgVw.frame.origin.y, imgVw.frame.size.width, imgVw.frame.size.height)];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setSagebinLogoInCenterForOrientation:toInterfaceOrientation];
}

//-(BOOL)shouldAutorotate
//{
//    return NO;
//}
//
//-(NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskPortrait;
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return UIInterfaceOrientationPortrait;
//}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}

@end