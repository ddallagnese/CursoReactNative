//
//  EditProfileViewController.m
//  Sagebin
//
//  
//

#import "EditProfileViewController.h"
#import "CastViewController.h"
#import "DeviceTableViewController.h"

#define MARGIN 20

@interface EditProfileViewController ()
{
    __weak ChromecastDeviceController *_chromecastController;
}
@end

@implementation EditProfileViewController

@synthesize strImageURL;
@synthesize popover = _popover;

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
    [self.view setBackgroundColor:ProfileViewBgColor];
    [self.rightButton setHidden:YES];
    
    [self registerForKeyboardNotifications];
    [self setUpView];
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

#pragma mark -
#pragma mark - Set up view

-(void)setUpView
{
    CGFloat yPos = [self.view viewWithTag:TopView_Tag].frame.size.height;
    mainScroll = [SEGBIN_SINGLETONE_INSTANCE createScrollViewWithFrame:CGRectMake(0, yPos, self.view.frame.size.width, self.view.frame.size.height- yPos) bgColor:[UIColor clearColor] tag:-1 delegate:nil];
    [mainScroll setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [mainScroll setScrollEnabled:YES];
    [self.view addSubview:mainScroll];
    
    [self createProfileView];
}

-(void)createProfileView
{
    CGFloat width = 150.0;
    CGFloat xPos = mainScroll.frame.size.width/2.0 - width/2.0;
    CGFloat height = width;
    
    imgVwProfile = [APPDELEGATE createEventImageViewWithFrame:CGRectMake(xPos, 50, width,width) withImageURL:nil Placeholder:nil tag:TAG_IMGVW_PROFILE];
    [imgVwProfile setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [imgVwProfile setImage:APPDELEGATE.latestProfImg];
    [imgVwProfile setEventImageDelegate:self];
    [imgVwProfile setUserInteractionEnabled:TRUE];
    [imgVwProfile setContentMode:UIViewContentModeScaleAspectFill];
    [imgVwProfile setClipsToBounds:YES];
    [mainScroll addSubview:imgVwProfile];
    
    width = mainScroll.frame.size.width - MARGIN*2.0;
    xPos = mainScroll.frame.size.width/2.0 - width/2.0;
    height = 40.0;
    
    UIView *oldPassView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(xPos, imgVwProfile.frame.origin.y+imgVwProfile.frame.size.height+MARGIN, width, height) bgColor:[UIColor whiteColor] tag:-1 alpha:1.0];
    [oldPassView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
    [mainScroll addSubview:oldPassView];
    
    txtOldPass = [SEGBIN_SINGLETONE_INSTANCE createTextFieldWithFrame:CGRectMake(0, 0, width, height) placeHolder:NSLocalizedString(@"txtPlaceHolderOldPass", nil) font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:14)] textColor:[UIColor lightGrayColor] tag:TAG_TXT_OLDPASS];
    [txtOldPass setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
    [txtOldPass setDelegate:self];
    [oldPassView addSubview:txtOldPass];

    UIView *newPassView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(xPos, oldPassView.frame.origin.y+oldPassView.frame.size.height+MARGIN, width, height) bgColor:[UIColor whiteColor] tag:-1 alpha:1.0];
    [newPassView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleWidth];
    [mainScroll addSubview:newPassView];
    
    txtNewPass = [SEGBIN_SINGLETONE_INSTANCE createTextFieldWithFrame:CGRectMake(0, 0, width, height) placeHolder:NSLocalizedString(@"txtPlaceHolderNewPass", nil) font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:14)] textColor:[UIColor lightGrayColor] tag:TAG_TXT_NEWPASS];
    [txtNewPass setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
    [txtNewPass setDelegate:self];
    [newPassView addSubview:txtNewPass];
    
    UIView *confirmPassView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(xPos, newPassView.frame.origin.y+newPassView.frame.size.height+MARGIN, width, height) bgColor:[UIColor whiteColor] tag:-1 alpha:1.0];
    [confirmPassView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
    [mainScroll addSubview:confirmPassView];
    
    txtConfirmPass = [SEGBIN_SINGLETONE_INSTANCE createTextFieldWithFrame:CGRectMake(0, 0, width, height) placeHolder:NSLocalizedString(@"txtPlaceHolderConfirmPass", nil) font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:14)] textColor:[UIColor lightGrayColor] tag:TAG_TXT_NEWPASS];
    [txtConfirmPass setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
    [txtConfirmPass setDelegate:self];
    [confirmPassView addSubview:txtConfirmPass];
    
    btnSubmit = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(xPos, confirmPassView.frame.origin.y+confirmPassView.frame.size.height+MARGIN, width, height) withTitle:NSLocalizedString(@"btnSubmit", nil) withImage:nil withTag:TAG_BTN_SUBMIT Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:TopBgColor];
    [btnSubmit addTarget:self action:@selector(btnSubmitClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btnSubmit setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
    [mainScroll addSubview:btnSubmit];
    
    mainScroll.contentSize = CGSizeMake(mainScroll.frame.size.width, btnSubmit.frame.origin.y+btnSubmit.frame.size.height+MARGIN);
}

#pragma mark - IMDEventImageView Delegate
-(void)eventImageView:(IMDEventImageView *)imageView didSelectWithURL:(NSString *)url
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Select from Library", nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [actionSheet showInView:self.view];
    }
    else
    {
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        if (iPad) {
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
            //[popover presentPopoverFromRect:CGRectMake(225, 145, 320, 100) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            NSLog(@"%@", NSStringFromCGPoint(imgVwProfile.center));
            [popover presentPopoverFromRect:imgVwProfile.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            self.popover = popover;
        } else {
            [self presentViewController:picker animated:YES completion:nil];
        }
    }
}

#pragma mark -
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int i = buttonIndex;
    switch(i)
    {
        case 0:
        {
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            if (iPad) {
                UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
                //[popover presentPopoverFromRect:CGRectMake(225, 145, 320, 100) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                [popover presentPopoverFromRect:imgVwProfile.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                self.popover = popover;
            } else {
                [self presentViewController:picker animated:YES completion:nil];
            }
        }
            break;
        case 1:
        {
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            if (iPad) {
                UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
                //[popover presentPopoverFromRect:CGRectMake(225, 145, 320, 100) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                [popover presentPopoverFromRect:imgVwProfile.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                self.popover = popover;
            } else {
                [self presentViewController:picker animated:YES completion:nil];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma - mark Selecting Image from Camera and Library
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if(iPad)
    {
        [self.popover dismissPopoverAnimated:NO];
    }
    else
    {
        [picker dismissViewControllerAnimated:YES completion:^{}];
    }
    
    UIImage *selectedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    if (!selectedImage)
    {
        return;
    }
    
    // Adjusting Image Orientation
    NSData *data = UIImagePNGRepresentation(selectedImage);
    UIImage *tmp = [UIImage imageWithData:data];
    UIImage *fixed = [UIImage imageWithCGImage:tmp.CGImage
                                         scale:selectedImage.scale
                                   orientation:selectedImage.imageOrientation];
    selectedImage = fixed;
    
    [imgVwProfile setImage:selectedImage];
}

#pragma mark - Submit Button Click
-(void)btnSubmitClicked:(CustomButton *)btn
{
    [activeField resignFirstResponder];
    
    if(APPDELEGATE.netOnLink == 0)
    {
        [self.view makeToast:WARNING];
        return;
    }
    
    if(txtOldPass.text.length == 0 && txtNewPass.text.length == 0 && txtConfirmPass.text.length == 0)
    {
    }
    else
    {
        if(txtOldPass.text.length == 0)
        {
            [self.view makeToast:NSLocalizedString(@"validateOldPassword", nil)];
            return;
        }
        if(txtNewPass.text.length == 0)
        {
            [self.view makeToast:NSLocalizedString(@"validateNewPassword", nil)];
            return;
        }
        if(txtConfirmPass.text.length == 0)
        {
            [self.view makeToast:NSLocalizedString(@"validateConfirmPassword", nil)];
            return;
        }
        if(![txtNewPass.text isEqualToString:txtConfirmPass.text])
        {
            [self.view makeToast:NSLocalizedString(@"validateNewAndConfirmPassword", nil)];
            return;
        }
    }
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *aUrl = [NSURL URLWithString:NSLocalizedString(@"appAPI", nil)];
    //NSLog(@"%@", aUrl);
    NSMutableURLRequest *request1 = [[NSMutableURLRequest alloc] initWithURL:aUrl];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request1 addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *body = [[NSMutableData alloc] init];
    
    [SEGBIN_SINGLETONE_INSTANCE setName:keyAccount withValue:[defaults objectForKey:keyAccount] onBody:body];
    [SEGBIN_SINGLETONE_INSTANCE setName:keyPage withValue:NSLocalizedString(@"apiUpdateUserDetail", nil) onBody:body];
    [SEGBIN_SINGLETONE_INSTANCE setName:keyOldPassword withValue:@"" onBody:body];
    [SEGBIN_SINGLETONE_INSTANCE setName:keyNewPassword withValue:@"" onBody:body];
    [SEGBIN_SINGLETONE_INSTANCE setName:keyProfilePhoto withFileName:keyProfileFileName withValue:UIImageJPEGRepresentation(imgVwProfile.image, 0.8) onBody:body];
    
    int m = [APPDELEGATE getDownLoadMode] + 1;
    int nv = [APPDELEGATE getNotificationType] + 1;
    int np = [APPDELEGATE getNotificationPeriod] + 1;
    
    [SEGBIN_SINGLETONE_INSTANCE setName:keyModeVal withValue:[NSString stringWithFormat:@"%d", m] onBody:body];
    [SEGBIN_SINGLETONE_INSTANCE setName:keyNotifyVal withValue:[NSString stringWithFormat:@"%d", nv] onBody:body];
    [SEGBIN_SINGLETONE_INSTANCE setName:keyNotifyPeriodVal withValue:[NSString stringWithFormat:@"%d", np] onBody:body];
    
    [request1 setHTTPBody:body];
    [request1 setHTTPMethod:@"POST"];
    
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [SEGBIN_SINGLETONE_INSTANCE addLoader];
    [self enableDisableUI:FALSE];
    [NSURLConnection sendAsynchronousRequest:request1 queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         [SEGBIN_SINGLETONE_INSTANCE removeLoader];
         [self enableDisableUI:TRUE];
         if(data != nil)
         {
             NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
             
             if ([[result objectForKey:keyCode] isEqualToString:keySuccess]){
                 
                 APPDELEGATE.latestProfImg = imgVwProfile.image;
                 [self.view makeToast:[result valueForKey:keyValue]];
                 
             }else{
                 [self.view makeToast:kServerError];
             }
         }
         else
         {
             [self.view makeToast:kServerError];
         }
     }];
}

-(void)enableDisableUI:(BOOL)status
{
    [imgVwProfile setUserInteractionEnabled:status];
    [txtOldPass setUserInteractionEnabled:status];
    [txtNewPass setUserInteractionEnabled:status];
    [txtConfirmPass setUserInteractionEnabled:status];
    [btnSubmit setUserInteractionEnabled:status];
}

#pragma mark - TextField Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    activeField = textField;
    [mainScroll setScrollEnabled:YES];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

#pragma mark - KeyBordMethod

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}
- (void)deregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        // code for Landscape orientation
        //Anand 15-Oct-2013
        if(iOS7)
        {
            CGFloat kbWidth = kbSize.width;// get the keyboard height following your usual method
            
            UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, kbWidth, 0);
            insets.bottom = kbWidth;
            mainScroll.contentInset = insets;
            
            UIEdgeInsets scrollInsets = UIEdgeInsetsMake(0, 0, kbWidth, 0);
            scrollInsets.bottom = kbWidth;
            mainScroll.scrollIndicatorInsets = scrollInsets;
            
            [mainScroll setNeedsDisplay];
        }
        else
        {
            
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(0+MIN(KStatusBarHeight, KStatusBarWidth), 0, kbSize.width, 0);
            mainScroll.contentInset = contentInsets;
            mainScroll.scrollIndicatorInsets = contentInsets;
            [mainScroll setNeedsDisplay];
            
        }
        if (activeField)
        {
            [mainScroll setContentOffset:CGPointMake(mainScroll.contentOffset.x, activeField.superview.frame.origin.y) animated:YES];
        }
    }
    else
    {
        if(iPad)
        {
            return;
        }
        // code for Portrait orientation
        
        //22-oct
        if(iOS7)
        {
            CGFloat kbHeight = kbSize.height;// get the keyboard height following your usual method
            
            UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, kbHeight, 0);
            insets.bottom = kbHeight;
            mainScroll.contentInset = insets;
            
            UIEdgeInsets scrollInsets = UIEdgeInsetsMake(0, 0, kbHeight, 0);
            scrollInsets.bottom = kbHeight;
            
            mainScroll.scrollIndicatorInsets = scrollInsets;
            [mainScroll setNeedsDisplay];
            
        }
        else
        {
            
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(0+MIN(KStatusBarHeight, KStatusBarWidth), 0, kbSize.height, 0);
            mainScroll.contentInset = contentInsets;
            mainScroll.scrollIndicatorInsets = contentInsets;
            [mainScroll setNeedsDisplay];
        }
        
        if (!IS_IPHONE_5 && activeField)
        {
            CGRect frame = activeField.superview.frame;
            [mainScroll setContentOffset:CGPointMake(mainScroll.contentOffset.x,frame.origin.y) animated:YES];
        }
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    mainScroll.contentInset = contentInsets;
    mainScroll.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Rotation Method

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(iPad)
    {
        [self.popover dismissPopoverAnimated:NO];
        
        /*
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
        //[popover presentPopoverFromRect:CGRectMake(225, 145, 320, 100) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        NSLog(@"%@", NSStringFromCGPoint(imgVwProfile.center));
        [popover presentPopoverFromRect:imgVwProfile.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        self.popover = popover;
         */
    }
    [self setSagebinLogoInCenterForOrientation:toInterfaceOrientation];
    
    
    [self performSelector:@selector(de) withObject:self afterDelay:0.1];
}
-(void)de
{
    mainScroll.contentSize = CGSizeMake(self.view.frame.size.width, btnSubmit.frame.origin.y+btnSubmit.frame.size.height+MARGIN);
}
-(void)dealloc
{
    [self deregisterForKeyboardNotifications];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    NSLog(@"EditProfileViewController dealloc called");
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
