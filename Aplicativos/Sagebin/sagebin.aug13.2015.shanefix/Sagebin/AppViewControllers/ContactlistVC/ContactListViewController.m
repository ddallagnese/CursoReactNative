//
//  ContactListViewController.m
//  Sagebin
//
//  Created by hyperlink on 31/10/14.
//  Copyright (c) 2014  . All rights reserved.
//

#import "ContactListViewController.h"
#import "CastViewController.h"
#import "DeviceTableViewController.h"
#import <AddressBook/AddressBook.h>

#define kRowHeight (iPad?54:35)
#define SEARCHTBL_HEIGHT (iPad?600:300)
#define MARGIN (iPad?15:5)
#define BUTTON_HEIGHT (iPad?60:40)
#define TIME_LABLE (iPad?200:65)
#define kSectionTitles @"CONTACTS"
#define kPendingSectionTitles @"PENDING (TAP TO RESEND INVITE)"

@interface ContactListViewController ()
{
     __weak ChromecastDeviceController *_chromecastController;
}

@end

@implementation ContactListViewController
@synthesize inviteType;
@synthesize strMovieId,strMovieTitle;
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
    
    arrData=[[NSMutableArray alloc]init];
}
-(void)viewWillAppear:(BOOL)animated
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:keyIsAlertAvailable])
    {
        [self.alertButton setHidden:YES];
    }
    
    if(arrData.count==0)
    {
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
        
        
        switch (inviteType) {
            case TYPE_INVITE:
            {
                [self setupLayoutMethods];
                [self showContentByContact];
                [searchTable reloadData];
                [self registerForKeyboardNotifications];
                
               
                
            }
                break;
                
            case TYPE_PENDING_INVITE:
            {
                [self setupPendingLayout];
                [self getPendingRequestAPI];
                [searchTable reloadData];
            }
            default:
                break;
        }
        
    }
    else
    {
       //we put that because when we go with landscap new view and come with portrait at that time button width are different
        
        CGFloat btnWidth=self.view.frame.size.width/3-MARGIN*(iPad?1.8:2.3);
        
        CustomButton *btnfac = (CustomButton *)[_mainScrollView viewWithTag:TAG_FacebookContact];
        btnfac.frame=CGRectMake((iPad?26:12), searchView.frame.origin.y+kRowHeight+MARGIN, btnWidth, BUTTON_HEIGHT);
        
        CustomButton *btngoogle = (CustomButton *)[_mainScrollView viewWithTag:TAG_GmailContact];
        btngoogle.frame=CGRectMake(btnfac.frame.origin.x+btnfac.frame.size.width+MARGIN, searchView.frame.origin.y+kRowHeight+MARGIN, btnWidth, BUTTON_HEIGHT);
        
        CustomButton *btnCon = (CustomButton *)[_mainScrollView viewWithTag:TAG_Contact];
        btnCon.frame=CGRectMake(btngoogle.frame.origin.x+btngoogle.frame.size.width+MARGIN, searchView.frame.origin.y+kRowHeight+MARGIN, btnWidth, BUTTON_HEIGHT);
        
        [searchTable reloadData];
        
        if(objView)
        {
            [objView adjustForOrientation:[UIApplication sharedApplication].statusBarOrientation];
        }
        [self setSagebinLogoInCenterForOrientation:[UIApplication sharedApplication].statusBarOrientation];
        
    }
   
    
    
    
}
-(void)dealloc
{
    [self deregisterForKeyboardNotifications];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    NSLog(@"ContactListViewController dealloc called");
}
-(void)setupLayoutMethods
{
    UIFont *btnFont = [APPDELEGATE Fonts_OpenSans_Regular:(iPad?18:12)];
    UIColor *btnGreenColor = [UIColor colorWithRed:143.0/255.0 green:194.0/255.0 blue:0.0/255.0 alpha:1.0];
    
    [self setViewImage:[UIImage imageNamed:@"search"] withTitle:@"Email, Facebook, or Google"];
    [self setSagebinLogoInCenterForOrientation:[UIApplication sharedApplication].statusBarOrientation];
    
    UIView *lbl = [self.view viewWithTag:TOP_ViewLbl_Tag];
    [lbl setFrame:CGRectMake(lbl.frame.origin.x, lbl.frame.origin.y, (iPad?400:250), (iPad?lbl.frame.size.height+5:lbl.frame.size.height))];
    
    UILabel *titlelbl = (UILabel *)[self.view viewWithTag:TOP_ViewLbl_Tag];
    [titlelbl setFont:[APPDELEGATE Fonts_OpenSans_Bold:(iPad?28:13)]];
    
    NSInteger yPos = lbl.frame.origin.y+lbl.frame.size.height;
    
    _mainScrollView = [SEGBIN_SINGLETONE_INSTANCE createScrollViewWithFrame:CGRectMake(0, (iPad?yPos+10:yPos), self.view.frame.size.width, self.view.frame.size.height) bgColor:[UIColor clearColor] tag:TAG_Main_ScrollView delegate:self];
    [_mainScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:_mainScrollView];
    
    // Search Bar
    searchView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake((iPad?26:12),10, self.view.frame.size.width-(iPad?52:24), kRowHeight) bgColor:[UIColor whiteColor] tag:-1 alpha:1.0];
    [searchView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    txtSearch = [SEGBIN_SINGLETONE_INSTANCE createTextFieldWithFrame:CGRectMake(MARGIN, kRowHeight/2-kRowHeight/4, searchView.frame.size.width-(iPad?54:30)-MARGIN,kRowHeight/2) placeHolder:@"name" font:[APPDELEGATE Fonts_OpenSans_LightItalic:(iPad?18:10)] textColor:[UIColor blackColor] tag:TAG_ContactSearchText];
    [txtSearch setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth];
    [txtSearch setDelegate:self];
    [txtSearch setClearButtonMode:UITextFieldViewModeWhileEditing];
    [txtSearch setReturnKeyType:UIReturnKeySearch];
    [searchView addSubview:txtSearch];
    
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSearch setTag:TAG_ContactSearchButton];
    [btnSearch setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [btnSearch setImage:[UIImage imageNamed:@"friend_search"] forState:UIControlStateNormal];
    [btnSearch addTarget:self action:@selector(searchMovie:) forControlEvents:UIControlEventTouchUpInside];
    [btnSearch setFrame:CGRectMake(txtSearch.frame.origin.x + txtSearch.frame.size.width, 0,(iPad?54:30), searchView.frame.size.height)];
    [searchView addSubview:btnSearch];
    [_mainScrollView addSubview:searchView];
    
    CGFloat btnWidth=searchView.frame.size.width/3-MARGIN+(iPad?5:2);
    
    //Facebook btn
    CustomButton *btnFacebook = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake((iPad?26:12), searchView.frame.origin.y+kRowHeight+MARGIN, btnWidth, BUTTON_HEIGHT) withTitle:@"Facebook" withImage:nil withTag:TAG_FacebookContact Font:btnFont BGColor:btnGreenColor];
    [btnFacebook addTarget:self action:@selector(SocialMediaBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_mainScrollView addSubview:btnFacebook];
    NSDictionary *temp = [[NSUserDefaults standardUserDefaults]valueForKey:keyFacebookFriends];
    if([temp count]<=0)
    {
        btnFacebook.alpha=0.50;
        btnFacebook.userInteractionEnabled=FALSE;
    }
    
    //Gmail btn
    CustomButton *btnGmail = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(btnFacebook.frame.origin.x+btnFacebook.frame.size.width+MARGIN, searchView.frame.origin.y+kRowHeight+MARGIN, btnWidth, BUTTON_HEIGHT) withTitle:@"Google" withImage:nil withTag:TAG_GmailContact Font:btnFont BGColor:btnGreenColor];
    [btnGmail addTarget:self action:@selector(SocialMediaBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_mainScrollView addSubview:btnGmail];
    NSDictionary *temp1 = [[NSUserDefaults standardUserDefaults]valueForKey:keyGoogleFriends];
    if([temp1 count]<=0)
    {
        btnGmail.alpha=0.50;
        btnGmail.userInteractionEnabled=FALSE;
    }
    
    //Contact btn
    CustomButton *btnContact = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(btnGmail.frame.origin.x+btnGmail.frame.size.width+MARGIN, searchView.frame.origin.y+kRowHeight+MARGIN, btnWidth, BUTTON_HEIGHT) withTitle:@"Contacts" withImage:nil withTag:TAG_Contact Font:btnFont BGColor:btnGreenColor];
    [btnContact addTarget:self action:@selector(SocialMediaBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_mainScrollView addSubview:btnContact];
    
    arraySectionTitles = [[NSMutableArray alloc]init];
    [arraySectionTitles addObjectsFromArray:[kSectionTitles componentsSeparatedByString:@","]];
    
    yPos = btnContact.frame.size.height+btnContact.frame.origin.y+MARGIN;
    searchTable = [[UITableView alloc]initWithFrame:CGRectMake((iPad?26:12), yPos, self.view.frame.size.width-(iPad?26:12)*2, SEARCHTBL_HEIGHT) style:UITableViewStylePlain];
    searchTable.tag = TAG_ContactTable;
    searchTable.delegate = self;
    searchTable.dataSource = self;
    searchTable.backgroundView = nil;
    searchTable.backgroundColor = [UIColor clearColor];
    [searchTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [searchTable setShowsVerticalScrollIndicator:NO];
    [searchTable setAutoresizingMask:UIViewAutoresizingFlexibleWidth ];// | UIViewAutoresizingFlexibleHeight
    if ([searchTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [searchTable setSeparatorInset:UIEdgeInsetsZero];
    }
    [_mainScrollView addSubview:searchTable];

    //Email View
    emailView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake((iPad?26:12), searchTable.frame.size.height+searchTable.frame.origin.y+MARGIN*2, self.view.frame.size.width-(iPad?52:24), kRowHeight) bgColor:[UIColor whiteColor] tag:-1 alpha:1.0];
    [emailView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    txtEmail = [SEGBIN_SINGLETONE_INSTANCE createTextFieldWithFrame:CGRectMake(MARGIN, kRowHeight/2-kRowHeight/4, searchView.frame.size.width-(iPad?54:30)-MARGIN,kRowHeight/2) placeHolder:@"email" font:[APPDELEGATE Fonts_OpenSans_LightItalic:(iPad?18:10)] textColor:[UIColor blackColor] tag:TAG_EmailText];
    [txtEmail setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth];
    [txtEmail setDelegate:self];
    [txtEmail setClearButtonMode:UITextFieldViewModeWhileEditing];
    [txtEmail setReturnKeyType:UIReturnKeySend];
    [emailView addSubview:txtEmail];
    
    UIButton *btnEmail = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnEmail setTag:TAG_Emailbtn];
    [btnEmail setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [btnEmail setImage:[UIImage imageNamed:@"sendemail"] forState:UIControlStateNormal];
    [btnEmail addTarget:self action:@selector(searchMovie:) forControlEvents:UIControlEventTouchUpInside];
    [btnEmail setFrame:CGRectMake(txtSearch.frame.origin.x + txtSearch.frame.size.width, 0,(iPad?54:30), searchView.frame.size.height)];
    [emailView addSubview:btnEmail];
    [_mainScrollView addSubview:emailView];
    
    _mainScrollView.contentSize = CGSizeMake(_mainScrollView.contentSize.width, emailView.frame.origin.y+emailView.frame.size.height+(iPad?160:110));
    
}
-(void)setupPendingLayout
{
    UIView *topView = [self.view viewWithTag:TopView_Tag];
    [self setSagebinLogoInCenterForOrientation:[UIApplication sharedApplication].statusBarOrientation];
    
    arraySectionTitles = [[NSMutableArray alloc]init];
    [arraySectionTitles addObjectsFromArray:[kPendingSectionTitles componentsSeparatedByString:@","]];

    
    searchTable = [[UITableView alloc]initWithFrame:CGRectMake((iPad?26:12), topView.frame.size.height+topView.frame.origin.y+10, self.view.frame.size.width-(iPad?26:12)*2, self.view.frame.size.height-kRowHeight*2.2) style:UITableViewStylePlain];
    searchTable.tag = TAG_ContactTable;
    searchTable.delegate = self;
    searchTable.dataSource = self;
    searchTable.backgroundView = nil;
    searchTable.backgroundColor = [UIColor clearColor];
    [searchTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [searchTable setShowsVerticalScrollIndicator:NO];
    [searchTable setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];//
    if ([searchTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [searchTable setSeparatorInset:UIEdgeInsetsZero];
    }
    [self.view addSubview:searchTable];
}
#pragma mark - Search Button Action
-(void)searchMovie:(UIButton *)btnserch
{
    [txtSearch resignFirstResponder];
    [txtEmail resignFirstResponder];
    switch (btnserch.tag)
    {
        case TAG_Emailbtn:
        {
            if(txtEmail.text.length == 0 || ![self validateEmail:txtEmail.text])
            {
                [self.view makeToast:NSLocalizedString(@"validateEmail", nil)];
                return;
            }
            [self sendMovieInvitation:txtEmail.text];
        }
            break;
        case TAG_ContactSearchButton:
        {
            NSString *nameformatString = [NSString stringWithFormat:@"%@ BEGINSWITH[cd] '%@'", keyDisplayName,txtSearch.text];
                NSPredicate *namePredicate = [NSPredicate predicateWithFormat:nameformatString];
                 NSArray *newArray = (NSMutableArray *)[arrData filteredArrayUsingPredicate:namePredicate];
                NSLog(@"%@", newArray);
            
            if([newArray count]<=0)
            {
                [self.view makeToast:@"No contact found"];
                return;
            }
            else
            {
                arrData=(NSMutableArray *)[newArray mutableCopy];
                [searchTable reloadData];
            }
            
        }
            break;
            
        default:
            break;
    }
}
-(void)SocialMediaBtnClick:(CustomButton *)sender
{
    [txtSearch resignFirstResponder];
    [txtEmail resignFirstResponder];
    
    switch (sender.tag)
    {
        case TAG_Contact:
        {
            [arrData removeAllObjects];
            [self showContentByContact];
            [searchTable reloadData];
        }
            break;
            
        
            
        case TAG_FacebookContact:
        {
            
            NSLog(@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:keyFacebookFriends]);
            
            NSDictionary *temp = [[NSUserDefaults standardUserDefaults]valueForKey:keyFacebookFriends];
            
            if([temp count]<=0)
            {
                [self.view makeToast:@"No contact found"];
                return;
            }
            else
            {
                [arrData removeAllObjects];
                for (int i=0; i<[temp count]; i++)
                {
                    NSDictionary *contact = [[NSDictionary alloc] initWithObjectsAndKeys:[[temp valueForKey:@"first_name"] objectAtIndex:i], keyDisplayName, [[temp valueForKey:@""] objectAtIndex:i], keyPhones, [[NSMutableArray alloc] init], keyEmails, nil];
                    [arrData addObject:contact];
                }
                
                [searchTable reloadData];
            }
           
        }
            break;
            
        case TAG_GmailContact:
        {
            
            NSLog(@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:keyGoogleFriends]);
            
            NSDictionary *temp = [[NSUserDefaults standardUserDefaults]valueForKey:keyGoogleFriends];
            
            if([temp count]<=0)
            {
                [self.view makeToast:@"No contact found"];
                return;
            }
            else
            {
                [arrData removeAllObjects];
                for (int i=0; i<[temp count]; i++)
                {
                    NSDictionary *contact = [[NSDictionary alloc] initWithObjectsAndKeys:[[temp valueForKey:@"displayName"] objectAtIndex:i], keyDisplayName, [[temp valueForKey:@""] objectAtIndex:i], keyPhones, [[NSMutableArray alloc] init], keyEmails, nil];
                    [arrData addObject:contact];
                }
                
                [searchTable reloadData];
            }
            
            
        }
            break;
            
        default:
            break;
    }
}
- (void)showContentByContact{
    //[self resetSView];
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        //dispatch_release(sema);
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(
                                                               kCFAllocatorDefault,
                                                               CFArrayGetCount(allPeople),
                                                               allPeople
                                                               );
    
    CFArraySortValues(
                      peopleMutable,
                      CFRangeMake(0, CFArrayGetCount(peopleMutable)),
                      (CFComparatorFunction) ABPersonComparePeopleByName,
                      (void*) ABPersonGetSortOrdering()
                      );
    
    if(nPeople <= 0)
    {
        [self.view makeToast:@"There is no contact"];
        return;
    }
    
    for (int i = 0; i < nPeople; i++)
    {
        NSString* name = @"";
        
        ABRecordRef aPerson = CFArrayGetValueAtIndex(peopleMutable, i);
        ABMultiValueRef fnameProperty = ABRecordCopyValue(aPerson, kABPersonFirstNameProperty);
        ABMultiValueRef lnameProperty = ABRecordCopyValue(aPerson, kABPersonLastNameProperty);
        
        ABMultiValueRef phoneProperty = ABRecordCopyValue(aPerson, kABPersonPhoneProperty);
        ABMultiValueRef emailProperty = ABRecordCopyValue(aPerson, kABPersonEmailProperty);
        
        NSArray *emailArray=[[NSArray alloc] initWithArray:(__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailProperty)];
        NSArray *phoneArray=[[NSArray alloc] initWithArray:(__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneProperty)];
        
        if (fnameProperty != nil) {
            name = [NSString stringWithFormat:@"%@", fnameProperty];
        }
        if (lnameProperty != nil) {
            name = [name stringByAppendingString:[NSString stringWithFormat:@" %@", lnameProperty]];
        }
        NSDictionary *contact = [[NSDictionary alloc] initWithObjectsAndKeys:name, keyDisplayName, phoneArray, keyPhones, emailArray, keyEmails, nil];
        
        
        [arrData addObject:contact];
        //=================================================================================
    }
    if([arrData count] == 0)
    {
        [self.view makeToast:@"There is no contact"];
    }
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:keyDisplayName ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:descriptor, nil];
    
    NSArray *temp = [arrData mutableCopy];
    
    temp= (NSMutableArray *)[temp sortedArrayUsingDescriptors:sortDescriptors];
    
    arrData=[temp mutableCopy];
}
#pragma mark - TextField Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if(textField.text.length > 0)
    {
        if(APPDELEGATE.netOnLink == 0)
        {
            [self.view makeToast:WARNING];
        }
        else
        {
            if(textField.tag==TAG_EmailText)
            {
                if(textField.text.length == 0 || ![self validateEmail:textField.text])
                {
                    [self.view makeToast:NSLocalizedString(@"validateEmail", nil)];
                    return NO;
                }
                [self sendMovieInvitation:txtEmail.text];
            }
            else if (textField.tag==TAG_ContactSearchText)
            {
                if(textField.text.length == 0)
                {
                    [self.view makeToast:@"Please enter contact name"];
                    return NO;
                }
                NSString *nameformatString = [NSString stringWithFormat:@"%@ BEGINSWITH[cd] '%@'", keyDisplayName,txtSearch.text];
                NSPredicate *namePredicate = [NSPredicate predicateWithFormat:nameformatString];
                NSArray *newArray = (NSMutableArray *)[arrData filteredArrayUsingPredicate:namePredicate];
                NSLog(@"%@", newArray);
                
                if([newArray count]<=0)
                {
                    [self.view makeToast:@"No contact found"];
                    return NO;
                }
                else
                {
                    arrData=(NSMutableArray *)[newArray mutableCopy];
                    [searchTable reloadData];
                }

            }
        }
    }
    else
    {
        [self.view makeToast:NSLocalizedString(@"txtSearchEmpty", nil)];
    }
    
    return [textField resignFirstResponder];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    activeField = textField;
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    textField.autocorrectionType=UITextAutocorrectionTypeNo;
    
    if (range.location == 0 && [string isEqualToString:@""])
    {
        [arrData removeAllObjects];
        [self showContentByContact];
        [searchTable reloadData];
        return YES;
    }
    
    return YES;
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
    
    if(inviteType == TYPE_INVITE)
    {
        UILabel *lbl=(UILabel *)[cell viewWithTag:Tag_Invite_Time_Pending];
        [lbl setHidden:TRUE];
    }
    
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(inviteType==TYPE_INVITE)
    {
        [txtSearch resignFirstResponder];
        [txtEmail resignFirstResponder];
        NSLog(@"%@",[arrData objectAtIndex:indexPath.row]);
        if([[[arrData objectAtIndex:indexPath.row] valueForKey:keyEmails] count]>0)
        {
            NSLog(@"%@",[[[arrData objectAtIndex:indexPath.row] valueForKey:keyEmails] objectAtIndex:0]);
            [self sendMovieInvitation:[[[arrData objectAtIndex:indexPath.row] valueForKey:keyEmails] objectAtIndex:0]];
        }
        else
        {
            objView = [[CustomPopupView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            [objView setTag:TAG_Contact_Popup_View];
            [objView setDelegate:self];
            [self.view addSubview:objView];
            
            [objView setStrViewTitle:@"Invite Friend"]; //[btn titleForState:UIControlStateNormal]
            [objView setStrViewMessage:[NSString stringWithFormat:@"Send movie %@ to %@. Please enter %@'s Email id.",strMovieTitle,[[arrData valueForKey:keyDisplayName] objectAtIndex:indexPath.row],[[arrData valueForKey:keyDisplayName] objectAtIndex:indexPath.row]]]  ;
            [objView customizeViewForType:VideoActionInviteToFriend];
            [objView adjustForOrientation:[UIApplication sharedApplication].statusBarOrientation];
        }
    }
    else if(inviteType==TYPE_PENDING_INVITE)
    {
        
        strMovieId=[[arrData valueForKey:keyVideoId] objectAtIndex:indexPath.row];
        [self sendMovieInvitation:[[arrData valueForKey:keyDisplayName] objectAtIndex:indexPath.row]];
    }
    
    
    
}
- (void)setupCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    NSDictionary *movieDictionary = [arrData objectAtIndex:indexPath.row];
    
    UIView *whiteBGView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(0, 0, searchTable.frame.size.width, kRowHeight) bgColor:[UIColor whiteColor] tag:TAG_ContactReuseView alpha:1.0];
    [cell addSubview:whiteBGView];
    
    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(MARGIN, kRowHeight/2-kRowHeight/4, (searchTable.frame.size.width-MARGIN*2)/1.3, kRowHeight/2.0)];
    [lblTitle setFont:[UIFont fontWithName:kFontHelvetica size:(iPad?18:14)]];
    [lblTitle setTag:TAG_Contact_LblTitle];
    [lblTitle setTextColor:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:[movieDictionary valueForKey:keyDisplayName]];
    [cell addSubview:lblTitle];
    
    UILabel *lblPendingtime = [[UILabel alloc]initWithFrame:CGRectMake(lblTitle.frame.size.width+lblTitle.frame.origin.x+MARGIN-3, kRowHeight/2-kRowHeight/4, TIME_LABLE, kRowHeight/2.0)];
    [lblPendingtime setFont:[UIFont fontWithName:kFontHelvetica size:(iPad?18:14)]];
    [lblPendingtime setTag:Tag_Invite_Time_Pending];
    [lblPendingtime setTextAlignment:NSTextAlignmentRight];
    [lblPendingtime setTextColor:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]];
    [lblPendingtime setBackgroundColor:[UIColor clearColor]];
    //[lblPendingtime setText:[movieDictionary valueForKey:keyDisplayName]];
    [lblPendingtime setText:[NSString stringWithFormat:@"%@ hrs left",[movieDictionary valueForKey:@"remaining_hours"]]];
    [cell addSubview:lblPendingtime];
    
    
    NSLog(@"%@",lblTitle.text);
    
    
    CGFloat lineHeight = 1.0/[UIScreen mainScreen].scale;
    UIView *line = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(0, kRowHeight - lineHeight, self.view.frame.size.width-10*2, lineHeight) bgColor:[UIColor blackColor] tag:Tag_Contact_ViewLine alpha:0.3];
    [cell addSubview:line];
}

- (void)updateCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    NSDictionary *movieDictionary = [arrData objectAtIndex:indexPath.row];
    
    UIView *whiteBGView = (UIView *)[cell viewWithTag:TAG_ContactReuseView];
    [whiteBGView setFrame:CGRectMake(0, 0, searchTable.frame.size.width, kRowHeight)];
    
    CGRect frame = CGRectMake(MARGIN, kRowHeight/2-kRowHeight/4, (searchTable.frame.size.width-MARGIN*2)/1.3, kRowHeight/2.0);
    UILabel *label = (UILabel *)[cell viewWithTag:TAG_Contact_LblTitle];
    [label setText:[movieDictionary valueForKey:keyDisplayName]];
    label.frame = frame;
    
    UILabel *pendinglabel = (UILabel *)[cell viewWithTag:Tag_Invite_Time_Pending];
   // [pendinglabel setText:[movieDictionary valueForKey:keyDisplayName]];
    [pendinglabel setText:[NSString stringWithFormat:@"%@ hrs left",[movieDictionary valueForKey:@"remaining_hours"]]];
    pendinglabel.frame = CGRectMake(label.frame.size.width+label.frame.origin.x+MARGIN-3,kRowHeight/2-kRowHeight/4, TIME_LABLE, kRowHeight/2.0);
    
    CGFloat lineHeight = 1.0/[UIScreen mainScreen].scale;
    UIView *line = (UIView *)[cell viewWithTag:Tag_Contact_ViewLine];
    [line setFrame:CGRectMake(0, kRowHeight - lineHeight, self.view.frame.size.width-10*2, lineHeight)];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrData count];
}

#pragma mark - CustomPopupView Delegate
- (void)confirmButtonClicked:(CustomPopupView *)customView forType:(VideoAction)requestType withValues:(NSDictionary *)result
{
    [customView removeFromSuperview];
    switch (requestType)
    {
        case VideoActionInviteToFriend:
        {
            NSLog(@"%@",strMovieId);
            NSLog(@"%@",result);
            
            [self sendMovieInvitation:[result valueForKey:keyComment]];
            
        }
            break;
            
        default:
            break;
    }
}

- (void)cancelButtonClicked:(CustomPopupView *)customView {
    [customView removeFromSuperview];
    
}
#pragma mark API call
-(void)sendMovieInvitation:(NSString *)Email
{
    IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
    NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strParameter = [NSString stringWithFormat:NSLocalizedString(@"apiSendMovieInvitation", nil), strMovieId, Email];
    strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], strParameter];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl]];
    NSData *postData = [NSData dataWithBytes:[strParameter UTF8String] length:[strParameter length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:kTAG_SENDMOVIE_INVITAION];
    [requestConnection startAsynchronousRequest];
    
    [SEGBIN_SINGLETONE_INSTANCE addLoader];
}
-(void)getPendingRequestAPI
{
    IMDHTTPRequest *requestConnection = [[IMDHTTPRequest alloc]initWithDelegate:self];
    NSString *apiUrl = NSLocalizedString(@"appAPI", nil);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strParameter = [NSString stringWithFormat:NSLocalizedString(@"apiPendingRequest", nil)];
    strParameter = [NSString stringWithFormat:@"account=%@&%@", [defaults objectForKey:keyAccount], strParameter];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl]];
    NSData *postData = [NSData dataWithBytes:[strParameter UTF8String] length:[strParameter length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [requestConnection requestWithURL:apiUrl withParaMeter:strParameter withMethod:@"POST" withTag:kTAG_PENDING_INVITATION_REQUEST];
    [requestConnection startAsynchronousRequest];
    
    [SEGBIN_SINGLETONE_INSTANCE addLoader];
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
            _mainScrollView.contentInset = insets;
            
            UIEdgeInsets scrollInsets = UIEdgeInsetsMake(0, 0, kbWidth, 0);
            scrollInsets.bottom = kbWidth;
            _mainScrollView.scrollIndicatorInsets = scrollInsets;
            
            [_mainScrollView setNeedsDisplay];
        }
        else
        {
            
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(0+MIN(KStatusBarHeight, KStatusBarWidth), 0, kbSize.width, 0);
            _mainScrollView.contentInset = contentInsets;
            _mainScrollView.scrollIndicatorInsets = contentInsets;
            [_mainScrollView setNeedsDisplay];
            
        }
        if (activeField)
        {
            [_mainScrollView setContentOffset:CGPointMake(_mainScrollView.contentOffset.x, activeField.superview.frame.origin.y) animated:YES];
        }
    }
    else
    {
        
        // code for Portrait orientation
        
        //22-oct
        if(iOS7)
        {
            CGFloat kbHeight = kbSize.height;// get the keyboard height following your usual method
            
            UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, kbHeight, 0);
            insets.bottom = kbHeight;
            _mainScrollView.contentInset = insets;
            
            UIEdgeInsets scrollInsets = UIEdgeInsetsMake(0, 0, kbHeight, 0);
            scrollInsets.bottom = kbHeight;
            
            _mainScrollView.scrollIndicatorInsets = scrollInsets;
            [_mainScrollView setNeedsDisplay];
            
        }
        else
        {
            
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(0+MIN(KStatusBarHeight, KStatusBarWidth), 0, kbSize.height, 0);
            _mainScrollView.contentInset = contentInsets;
            _mainScrollView.scrollIndicatorInsets = contentInsets;
            [_mainScrollView setNeedsDisplay];
        }
        
        if (activeField==txtEmail)
        {
            CGRect frame = activeField.superview.frame;
            [_mainScrollView setContentOffset:CGPointMake(_mainScrollView.contentOffset.x,frame.origin.y) animated:YES];
        }
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _mainScrollView.contentInset = contentInsets;
    _mainScrollView.scrollIndicatorInsets = contentInsets;
}
#pragma mark - IMDHTTPRequest Delegates
-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didFailWithError:(NSError*)error withTag:(int)tag
{
    [self.view makeToast:@"Sending Faild"];
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    
}

-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didSuccessWithItems:(NSObject*)items withData:(NSData*)data withTag:(int)tag
{
    [SEGBIN_SINGLETONE_INSTANCE removeLoader];
    
    if (tag==kTAG_SENDMOVIE_INVITAION)
    {
        NSDictionary *result = (NSDictionary *)items;
        if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
        {
            [self checkUserAlert:[result objectForKey:keyAlerts]];
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
            [self.view makeToast:kServerError];
        }
    
    }
    else if (tag==kTAG_PENDING_INVITATION_REQUEST)
    {
        NSDictionary *result = (NSDictionary *)items;
        if ([[result objectForKey:keyCode] isEqualToString:keySuccess])
        {
            
            NSArray *temp = [result valueForKey:keyValue];
            
            [arrData removeAllObjects];
            for (int i=0; i<[temp count]; i++)
            {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                
                [dict setObject:[[temp valueForKey:@"remaining_hours"] objectAtIndex:i] forKey:@"remaining_hours"];
                [dict setObject:[[temp valueForKey:@"friend_email"] objectAtIndex:i] forKey:keyDisplayName];
                [dict setObject:[[temp valueForKey:@"owner_video"] objectAtIndex:i] forKey:keyVideoId];
                [arrData addObject:dict];
            }
            [searchTable reloadData];
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
            [self.view makeToast:kServerError];
        }

    }

    
}

#pragma mark - Rotation Method

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(inviteType == TYPE_INVITE)
    {
        [self resetupLayoutMethods:toInterfaceOrientation];
    }
    else
    {
        searchTable.frame = CGRectMake(searchTable.frame.origin.x, searchTable.frame.origin.y, searchTable.frame.size.width, self.view.frame.size.height-kRowHeight*2.2);
    }
    
    if(objView)
    {
        [objView adjustForOrientation:toInterfaceOrientation];
    }
  [self setSagebinLogoInCenterForOrientation:toInterfaceOrientation];
    [searchTable reloadData];
}
-(void)resetupLayoutMethods:(UIInterfaceOrientation)toInterfaceOrientation
{
    
    [self setViewImage:[UIImage imageNamed:@"search"] withTitle:@"Email, Facebook, or Google"];

    CGFloat btnWidth=self.view.frame.size.height/3-MARGIN*(iPad?1.8:2.3);
    
    CustomButton *btnfac = (CustomButton *)[_mainScrollView viewWithTag:TAG_FacebookContact];
    btnfac.frame=CGRectMake((iPad?26:12), searchView.frame.origin.y+kRowHeight+MARGIN, btnWidth, BUTTON_HEIGHT);
    
    CustomButton *btngoogle = (CustomButton *)[_mainScrollView viewWithTag:TAG_GmailContact];
    btngoogle.frame=CGRectMake(btnfac.frame.origin.x+btnfac.frame.size.width+MARGIN, searchView.frame.origin.y+kRowHeight+MARGIN, btnWidth, BUTTON_HEIGHT);
    
    CustomButton *btnCon = (CustomButton *)[_mainScrollView viewWithTag:TAG_Contact];
    btnCon.frame=CGRectMake(btngoogle.frame.origin.x+btngoogle.frame.size.width+MARGIN, searchView.frame.origin.y+kRowHeight+MARGIN, btnWidth, BUTTON_HEIGHT);
    
}
#pragma mark - Field Validation
-(BOOL) validateEmail: (NSString *) email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [emailTest evaluateWithObject:email];
    return isValid;
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
