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

//#import "AppDelegate.h"
#import "LocalPlayerViewController.h"
#import "CastViewController.h"
#import "DeviceTableViewController.h"

#define MOVIE_CONTAINER_TAG 1

@interface LocalPlayerViewController () {
  int lastKnownPlaybackTime;
  __weak IBOutlet UIImageView *_thumbnailView;
  __weak ChromecastDeviceController *_chromecastController;
}
@property(weak, nonatomic) IBOutlet UIButton *playPauseButton;

@property MPMoviePlayerController *moviePlayer;

@end

@implementation LocalPlayerViewController

- (id)initWithCoder:(NSCoder *)decoder {
  self = [super initWithCoder:decoder];
  if (self) {
  }

  return self;
}

- (void)dealloc {
}

#pragma mark State management
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"castMedia"])
  {
    [(CastViewController *)[segue destinationViewController] setMediaToPlay:self.objVideo
                                                           withStartingTime:lastKnownPlaybackTime];
  }
}

- (IBAction)playPauseButtonPressed:(id)sender {
    
  if (_chromecastController.isConnected) {
    if (self.playPauseButton.selected == NO) {
      [_chromecastController pauseCastMedia:NO];
    }
      
      if([[self.objVideo objectForKey:keyCanPlay] isEqualToNumber:[NSNumber numberWithInt:0]])
      {
          [APPDELEGATE errorAlertMessageTitle:@"Alert" andMessage:NSLocalizedString(@"strYou can not play this movie", nil)];
          [self.navigationController popViewControllerAnimated:YES];
          return;
      }
      
    //[self performSegueWithIdentifier:@"castMedia" sender:self];
      APPDELEGATE.isFromLocalPlayerScreen = YES;
      UIStoryboard *storyboard = iPhone_storyboard;
      if (iPad)
      {
          storyboard = self.storyboard;
      }
      CastViewController *objCastVC = (CastViewController *) [storyboard instantiateViewControllerWithIdentifier:@"CastVC"];
      objCastVC.objVideo = self.objVideo;
      [self.navigationController pushViewController:objCastVC animated:YES];
  } else {
    [self playMovieIfExists];
  }
}

#pragma mark - Managing the detail item

- (void)setMediaToPlay:(id)newMediaToPlay {
  if (_objVideo != newMediaToPlay) {
    _objVideo = newMediaToPlay;
  }
}

- (void)moviePlayBackDidChange:(NSNotification *)notification {
  NSLog(@"Movie playback state did change %d", _moviePlayer.playbackState);
}

- (void)moviePlayBackDidFinish:(NSNotification *)notification {
  NSLog(@"Looks like playback is over.");
  int reason = [[[notification userInfo]
      valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
  if (reason == MPMovieFinishReasonPlaybackEnded) {
    NSLog(@"Playback has ended normally!");
  }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)playMovieIfExists {
  if (self.objVideo) {
    if (_chromecastController.isConnected) {
      // Asynchronously load the table view image
        _thumbnailView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.objVideo valueForKey:keyPoster1]]]];
        [_thumbnailView setNeedsLayout];
        /*
      dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);

      dispatch_async(queue, ^{
        UIImage *image = [UIImage
            imageWithData:[SimpleImageFetcher getDataFromImageURL:[NSURL URLWithString:[self.objVideo valueForKey:keyPoster1]]]];

        dispatch_sync(dispatch_get_main_queue(), ^{
          _thumbnailView.image = image;
          [_thumbnailView setNeedsLayout];
        });
      });
         */
    } else {
      NSURL *url = [NSURL URLWithString:[self.objVideo valueForKey:keyItemStreaming]];
      NSLog(@"Playing movie %@", url);
      self.moviePlayer.contentURL = url;
      self.moviePlayer.allowsAirPlay = YES;
      self.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
      self.moviePlayer.repeatMode = MPMovieRepeatModeNone;
      self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
      self.moviePlayer.shouldAutoplay = YES;

      UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
      if (UIInterfaceOrientationIsLandscape(orientation) &&
          [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.moviePlayer.fullscreen = YES;
      } else {
        self.moviePlayer.fullscreen = NO;
      }

      [self.moviePlayer prepareToPlay];
      [self.moviePlayer play];
    }
    self.moviePlayer.view.hidden = _chromecastController.isConnected;

    self.mediaTitle.text = [self.objVideo valueForKey:keyTitle];
  }
}

// TODO: Perhaps just make this lazy instantiation
- (void)createMoviePlayer {
  //Create movie player controller and add it to the view
  if (!self.moviePlayer) {
    // Next create the movie player, on top of the thumbnail view.
    self.moviePlayer = [[MPMoviePlayerController alloc] init];
    self.moviePlayer.view.frame = _thumbnailView.frame;
    //self.moviePlayer.view.hidden = _chromecastController.isConnected;
    self.moviePlayer.view.hidden = YES;
    [self.view addSubview:self.moviePlayer.view];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.moviePlayer];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(moviePlayBackDidChange:)
               name:MPMoviePlayerPlaybackStateDidChangeNotification
             object:self.moviePlayer];
  }
  if (!_thumbnailView.image) {
    // Asynchronously load the table view image
      _thumbnailView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.objVideo valueForKey:keyPoster1]]]];
      [_thumbnailView setContentMode:UIViewContentModeScaleAspectFill];
      [_thumbnailView setClipsToBounds:YES];
      [_thumbnailView setNeedsLayout];
      /*
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);

    dispatch_async(queue, ^{
      UIImage *image = [UIImage
                        imageWithData:[SimpleImageFetcher getDataFromImageURL:[NSURL URLWithString:[self.objVideo valueForKey:keyPoster1]]]];

      dispatch_sync(dispatch_get_main_queue(), ^{
        _thumbnailView.image = image;
          [_thumbnailView setContentMode:UIViewContentModeScaleAspectFill];
          [_thumbnailView setClipsToBounds:YES];
        [_thumbnailView setNeedsLayout];
      });
    });
       */
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Click on this screen OR" message:@"Please press Play Button" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];

  //Add cast button
    //self.navigationItem.rightBarButtonItem = _chromecastController.chromecastBarButton;  // see viewWillApear

  // Set an empty image for selected ("pause") state.
  [self.playPauseButton setImage:[UIImage new] forState:UIControlStateSelected];
    
    UIView *topView = [self.view viewWithTag:TopView_Tag];
    NSInteger yPos = topView.frame.origin.y+topView.frame.size.height;
    [self.playPauseButton setFrame:CGRectMake(0, yPos, self.view.frame.size.width, self.view.frame.size.height-yPos)];
    [_thumbnailView setFrame:CGRectMake(0, yPos, self.view.frame.size.width, self.view.frame.size.height-yPos)];
    //[_thumbnailView setImage:kPlaceholderImage];
    [_thumbnailView setContentMode:UIViewContentModeCenter];
    [_thumbnailView setClipsToBounds:YES];

  [self createMoviePlayer];

  // Listen to orientation changes.
  [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(deviceOrientationDidChange:)
                                               name:UIDeviceOrientationDidChangeNotification
                                             object:nil];
    
    self.mediaTitle.text = [self.objVideo valueForKey:keyTitle];
}

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

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

    [self setSagebinLogoInCenterForOrientation:[UIApplication sharedApplication].statusBarOrientation];
    if([[NSUserDefaults standardUserDefaults] objectForKey:keyIsAlertAvailable])
    {
        [self.alertButton setHidden:YES];
    }
  
    // Store a reference to the chromecast controller.
    _chromecastController = APPDELEGATE.chromecastDeviceController;
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
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  if (self.moviePlayer) {
    self.moviePlayer.view.frame = _thumbnailView.frame;
    self.moviePlayer.view.hidden = YES;
  }
  [self updateControls];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  // TODO Pause the player if navigating to a different view other than fullscreen movie view.
  if (self.moviePlayer && self.moviePlayer.fullscreen == NO) {
    [self.moviePlayer pause];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
  // Respond to orientation only when not connected.
  if (_chromecastController.isConnected == YES) {
    return;
  }
  //Obtaining the current device orientation
    
    /*
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  if (UIInterfaceOrientationIsLandscape(orientation)) {
    [self.moviePlayer setFullscreen:YES animated:YES];
  } else {
    [self.moviePlayer setFullscreen:NO animated:YES];
  }
     */
    
  if (self.moviePlayer) {
    self.moviePlayer.view.frame = _thumbnailView.frame;
  }
}

#pragma mark - ChromecastControllerDelegate

- (void)didDiscoverDeviceOnNetwork {
  // Add the chromecast icon if not present.
  //self.navigationItem.rightBarButtonItem = _chromecastController.chromecastBarButton;
    
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

/**
 * Called when connection to the device was established.
 *
 * @param device The device to which the connection was established.
 */
- (void)didConnectToDevice:(GCKDevice *)device {
  lastKnownPlaybackTime = [self.moviePlayer currentPlaybackTime];
  [self.moviePlayer stop];
  //[self performSegueWithIdentifier:@"castMedia" sender:self];
    
    if([[self.objVideo objectForKey:keyCanPlay] isEqualToNumber:[NSNumber numberWithInt:0]])
    {
        [APPDELEGATE errorAlertMessageTitle:@"Alert" andMessage:NSLocalizedString(@"strYou can not play this movie", nil)];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    APPDELEGATE.isFromLocalPlayerScreen = YES;
    UIStoryboard *storyboard = iPhone_storyboard;
    if (iPad)
    {
        storyboard = self.storyboard;
    }
    CastViewController *objCastVC = (CastViewController *) [storyboard instantiateViewControllerWithIdentifier:@"CastVC"];
    objCastVC.objVideo = self.objVideo;
    [self.navigationController pushViewController:objCastVC animated:YES];
}

/**
 * Called when connection to the device was closed.
 */
- (void)didDisconnect {
  [self updateControls];
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * Called when the playback state of media on the device changes.
 */
- (void)didReceiveMediaStateChange {
  [self updateControls];
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
  //[self performSegueWithIdentifier:@"castMedia" sender:self];
    
    if([[self.objVideo objectForKey:keyCanPlay] isEqualToNumber:[NSNumber numberWithInt:0]])
    {
        [APPDELEGATE errorAlertMessageTitle:@"Alert" andMessage:NSLocalizedString(@"strYou can not play this movie", nil)];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    APPDELEGATE.isFromLocalPlayerScreen = YES;
    UIStoryboard *storyboard = iPhone_storyboard;
    if (iPad)
    {
        storyboard = self.storyboard;
    }
    CastViewController *objCastVC = (CastViewController *) [storyboard instantiateViewControllerWithIdentifier:@"CastVC"];
    objCastVC.objVideo = self.objVideo;
    [self.navigationController pushViewController:objCastVC animated:YES];
}

#pragma mark - Implementation

- (void)updateControls {
  // Check if the selected media is also playing on the screen. If so display the pause button.
  NSString *title =
      [_chromecastController.mediaInformation.metadata stringForKey:kGCKMetadataKeyTitle];
  self.playPauseButton.selected = (_chromecastController.isConnected &&
      ([title isEqualToString:[self.objVideo valueForKey:keyTitle]] &&
       (_chromecastController.playerState == GCKMediaPlayerStatePlaying ||
        _chromecastController.playerState == GCKMediaPlayerStateBuffering)));
  self.playPauseButton.highlighted = NO;

  [_chromecastController updateToolbarForViewController:self];
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
////- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
////{
////    return UIInterfaceOrientationPortrait;
////}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}

@end