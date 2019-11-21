//
//  CustomPopupView.m
//  Sagebin
//
//  
//

#import "CustomPopupView.h"

#define BACKGROUND_COLOR [UIColor colorWithRed:2/255.f green:40/255.f blue:82/255.f alpha:1.0]
#define kBtnFont [APPDELEGATE Fonts_OpenSans_Regular:(iPad?14:12)]
#define kLblFont [APPDELEGATE Fonts_OpenSans_Regular:(iPad?14:12)]
#define kBtnGreenColor [UIColor colorWithRed:143.0/255.0 green:194.0/255.0 blue:0.0/255.0 alpha:1.0]
#define kBtnRedColor NewReleaseViewBgColor

#define MARGIN 10

@implementation CustomPopupView

@synthesize strViewMessage, strViewTitle, arrayOptions, strTextFieldPlaceHodlder;
@synthesize strConfirmTitle, strCancelTitle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self createLayout];
        
        [self registerForKeyboardNotifications];
    }
    return self;
}

-(void)createLayout
{
    _mainScrollView = [SEGBIN_SINGLETONE_INSTANCE createScrollViewWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) bgColor:nil tag:Popup_Main_ScrollView delegate:nil];
    [_mainScrollView setBackgroundColor:[[UIColor blackColor]colorWithAlphaComponent:0.4]];
    [self addSubview:_mainScrollView];
    
    popupView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(20, 20, 280, 264) bgColor:nil tag:PopupView_Tag alpha:1.0];
    popupView.center = CGPointMake(_mainScrollView.frame.size.width/2, _mainScrollView.frame.size.height/2);
    [_mainScrollView addSubview:popupView];
    
    [self createTextView];
    [self createTableView];
    [self createMessageView];
    [self createButtonView];
    [self createTextFieldView];
    [self createTitleView];
    [self createOptionView];
    [self createPickerView];
    
    [self hideAllSubViews];
}

-(void)hideAllSubViews
{
    [viewTextView setHidden:YES];
    [viewTableView setHidden:YES];
    [viewMessage setHidden:YES];
    [viewButtons setHidden:YES];
    [viewTextField setHidden:YES];
    [viewTitle setHidden:YES];
    [viewAlertOptions setHidden:YES];
    [viewPickerView setHidden:YES];
}

-(void)createTextView
{
    viewTextView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(0, 0, 280, 60) bgColor:nil tag:ViewTextView_Tag alpha:1.0];
    [popupView addSubview:viewTextView];
    
    textViewAlert = [[UITextView alloc]initWithFrame:CGRectMake(20, 8, 240, 44)];
    [textViewAlert setDelegate:self];
    [textViewAlert setFont:kLblFont];
    [viewTextView addSubview:textViewAlert];
}

-(void)createTableView
{
    viewTableView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(35, 0, 210, 100) bgColor:nil tag:ViewTableView_Tag alpha:1.0];
    [popupView addSubview:viewTableView];
    
    tableViewAlert = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 210, 100)];
    [tableViewAlert setDelegate:self];
    [tableViewAlert setDataSource:self];
    if ([tableViewAlert respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableViewAlert setSeparatorInset:UIEdgeInsetsZero];
    }
    [viewTableView addSubview:tableViewAlert];
}

-(void)createMessageView
{
    viewMessage = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(0, 0, 280, 70) bgColor:nil tag:ViewMsg_Tag alpha:1.0];
    [popupView addSubview:viewMessage];
    
    lblMessage = [[UILabel alloc]initWithFrame:CGRectMake(10, 4, 260, 62)];
    [lblMessage setBackgroundColor:[UIColor clearColor]];
    [lblMessage setTag:LblMsg_Tag];
    [lblMessage setNumberOfLines:0];
    [lblMessage setFont:kLblFont];
    [lblMessage setTextAlignment:NSTextAlignmentCenter];
    [viewMessage addSubview:lblMessage];
}

-(void)createButtonView
{
    viewButtons = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(0, 0, 280, 47) bgColor:nil tag:ViewButton_Tag alpha:1.0];
    [popupView addSubview:viewButtons];
    
    buttonOne = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(21, 5, 73, 36) withTitle:@"7 Days" withImage:nil withTag:kTagSevenDays Font:kBtnFont BGColor:[UIColor grayColor]];
    [buttonOne addTarget:self action:@selector(optionSelection:) forControlEvents:UIControlEventTouchUpInside];
    [viewButtons addSubview:buttonOne];
    
    buttonTwo = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(104, 5, 73, 36) withTitle:@"24 Hours" withImage:nil withTag:kTagOneDay Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:[UIColor grayColor]];
    [buttonTwo addTarget:self action:@selector(optionSelection:) forControlEvents:UIControlEventTouchUpInside];
    [viewButtons addSubview:buttonTwo];
    
    buttonThree = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(187, 5, 73, 36) withTitle:@"48 Hours" withImage:nil withTag:kTagTwoDays Font:[APPDELEGATE Fonts_OpenSans_Light:(iPad?18:11)] BGColor:[UIColor grayColor]];
    [buttonThree addTarget:self action:@selector(optionSelection:) forControlEvents:UIControlEventTouchUpInside];
    [viewButtons addSubview:buttonThree];
}

-(void)createTextFieldView
{
    viewTextField = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(0, 0, 280, 40) bgColor:nil tag:ViewTextField_Tag alpha:1.0];
    [popupView addSubview:viewTextField];
    
    textFieldAlert = [[UITextField alloc]initWithFrame:CGRectMake(10, 5, 260, 30)];
    [textFieldAlert setTag:TextField_Tag];
    [textFieldAlert setFont:kLblFont];
    [viewTextField addSubview:textFieldAlert];
}

-(void)createTitleView
{
    viewTitle = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(0, 0, 280, 27) bgColor:nil tag:ViewTitle_Tag alpha:1.0];
    [popupView addSubview:viewTitle];
    
    lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 3, 280, 21)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setTag:LblTitle_Tag];
    [lblTitle setFont:kLblFont];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [viewTitle addSubview:lblTitle];
}

-(void)createOptionView
{
    viewAlertOptions = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(0, 0, 280, 60) bgColor:nil tag:ViewOption_Tag alpha:1.0];
    [popupView addSubview:viewAlertOptions];
    
    btnConfirmAlert = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(33, 10, 100, 40) withTitle:@"Confirm" withImage:nil withTag:BtnConfirm_Tag Font:kBtnFont BGColor:kBtnGreenColor];
    [btnConfirmAlert addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    [viewAlertOptions addSubview:btnConfirmAlert];
    
    btnCancelAlert = [SEGBIN_SINGLETONE_INSTANCE createCustomBtnWithFrame:CGRectMake(148, 10, 100, 40) withTitle:@"Cancel" withImage:nil withTag:BtnCancel_Tag Font:kBtnFont BGColor:kBtnRedColor];
    [btnCancelAlert addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [viewAlertOptions addSubview:btnCancelAlert];
}

-(void)createPickerView
{
    viewPickerView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(0, 0, 280, 150) bgColor:nil tag:ViewPickerView_Tag alpha:1.0];
    [viewPickerView.layer setCornerRadius:10.0];
    [viewPickerView.layer setMasksToBounds:YES];
    [popupView addSubview:viewPickerView];
    
    pickerViewAlert = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 280, 150)];
    [pickerViewAlert setDelegate:self];
    [pickerViewAlert setDataSource:self];
    [pickerViewAlert setTag:PickerView_Tag];
    [pickerViewAlert setBackgroundColor:kButtonBGColorUnSel];
    
    [viewPickerView addSubview:pickerViewAlert];
}

#pragma mark - Customize View
- (void) setViewBorder {
    //[popupView.layer setBorderWidth:2.0];
    //[popupView.layer setBorderColor:[UIColor whiteColor].CGColor];
    //[popupView.layer setCornerRadius:10.0];
    //[popupView.layer setMasksToBounds:YES];
}

- (void) setTextViewBoarder {
    [textViewAlert.layer setCornerRadius:10.0];
    [textViewAlert.layer setMasksToBounds:YES];
}

- (void) setTextFieldBoarder {
    [textFieldAlert.layer setCornerRadius:10.0];
    [textFieldAlert.layer setMasksToBounds:YES];
}

- (void) setTableViewBoarder {
    [tableViewAlert.layer setCornerRadius:10.0];
    [tableViewAlert.layer setMasksToBounds:YES];
}

- (void) setTitleMessageColor {
    lblTitle.textColor = [UIColor whiteColor];
    lblMessage.textColor = [UIColor whiteColor];
}

- (void) setPickerViewBoarder {
    [pickerViewAlert.layer setCornerRadius:10.0];
    [pickerViewAlert.layer setMasksToBounds:YES];
}

-(void) setDefaultValuesForPrice
{
    priceArray = [[NSMutableArray alloc]initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9", nil];
    firstComponentValue = 0;
    secondComponentValue = 0;
    thirdComponentValue = 0;
    fourthComponentValue = 0.0;
    fifthComponentValue = 0.0;
    totalPrice = 0.00;
}

- (void) setViewBackgroundColors {
    viewTitle.backgroundColor = [UIColor clearColor];
    viewMessage.backgroundColor = [UIColor clearColor];
    viewButtons.backgroundColor = [UIColor clearColor];;
    viewAlertOptions.backgroundColor = [UIColor clearColor];
    viewTextField.backgroundColor = [UIColor clearColor];
    viewTextView.backgroundColor = [UIColor clearColor];
    viewTableView.backgroundColor = [UIColor clearColor];
    viewPickerView.backgroundColor = [UIColor clearColor];
    //    self.view.backgroundColor = BACKGROUND_COLOR;
    popupView.backgroundColor = TopBgColor;
}

#pragma mark - Set Delegates
- (void) setTextFieldDelegate {
    textFieldAlert.delegate = self;
}

- (void) setTextViewDelegate {
    textViewAlert.delegate = self;
}

#pragma mark - Reload Table
- (void) reloadTable {
    [tableViewAlert reloadData];
}

#pragma mark - Reload PickerVeiw
- (void) reloadPicker {
    [pickerViewAlert reloadAllComponents];
}

#pragma mark - UITextField Delegates
/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Check for 0-9 only
    static NSCharacterSet *charSet = nil;
    if(!charSet) {
        charSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    }
    NSRange location = [string rangeOfCharacterFromSet:charSet];
    
    // Check for Lenght (5 characters max)
    if (location.location == NSNotFound) {
        NSUInteger newLength = [textFieldAlert.text length] + [string length] - range.length;
        if(requestType == VideoActionSellToFriend) {
            if(newLength > 0) {
                if([selectionArray count]>0) {
                    [btnConfirmAlert setEnabled:YES];
                }
            }
        }else{
            [btnConfirmAlert setEnabled:(newLength > 0 ? YES : NO )];
        }
        
        if (textField==textFieldAlert)
        {
            return (newLength > 9) ? NO : YES;
        }
    }
    
    return NO;
}
*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField1{
    [textField1 resignFirstResponder];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    currentTextField = textField;
}

#pragma mark - UITextView Delegates
- (void)textViewDidBeginEditing:(UITextView *)textView1
{
    currentTextView = textView1;
}

- (void)textViewDidEndEditing:(UITextView *)textView1
{
}

/*
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string
{
    NSUInteger newLength = [textView.text length] + [string length] - range.length;
    
    if(requestType == VideoActionGiftToFriend || requestType == VideoActionSend) {
        if(newLength > 0) {
            if([selectionArray count]>0) {
                [btnConfirmAlert setEnabled:YES];
            }
        }else{
            [btnConfirmAlert setEnabled:NO];
        }
    }else{
        [btnConfirmAlert setEnabled:(newLength > 0 ? YES : NO )];
    }
    return YES;
}
*/

#pragma mark - UITableView Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayOptions.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIden = [NSString stringWithFormat:@"Cell %d",indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIden];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIden];
        cell.textLabel.font = kLblFont;
        cell.textLabel.textColor = [UIColor grayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if(requestType != VideoDownloadOfflineFrom)
    {
        if([selectionArray containsObject:[[arrayOptions objectAtIndex:indexPath.row] valueForKey:keyID]]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.textLabel.text = [[arrayOptions objectAtIndex:indexPath.row] valueForKey:keyDisplayName];
    }
    else
    {
        //download from person off-line mode
        if([selectionArray containsObject:[[arrayOptions objectAtIndex:indexPath.row] valueForKey:keyUID]]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.textLabel.text = [[arrayOptions objectAtIndex:indexPath.row] valueForKey:keyName];
    }
    cell.textLabel.font = kLblFont;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    
    if(requestType != VideoDownloadOfflineFrom)
    {
        if(!selectionArray){
            selectionArray = [[NSMutableArray alloc] init];
        }
        
        if(cell.accessoryType == UITableViewCellAccessoryNone)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            if(requestType == VideoActionGiftToFriend || requestType == VideoActionSend)
            {
                if(selectedIndexPath)
                {
                    UITableViewCell *cell = [tableView cellForRowAtIndexPath:selectedIndexPath];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    
                    [selectionArray removeObject:[[arrayOptions objectAtIndex:selectedIndexPath.row] valueForKey:keyID]];
                }
                selectedIndexPath = indexPath;
            }
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            selectedIndexPath = nil;
        }
        
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
        {
            [selectionArray addObject:[[arrayOptions objectAtIndex:indexPath.row] valueForKey:keyID]];
        }
        else
        {
            [selectionArray removeObject:[[arrayOptions objectAtIndex:indexPath.row] valueForKey:keyID]];
        }
    }
    else
    {
        //off-line mode download from selection
        if(selectionArray){
            if([selectionArray count]>0){
                [selectionArray removeAllObjects];
            }
        }
        else{
            selectionArray = [[NSMutableArray alloc] init];
        }
        [selectionArray addObject:[[arrayOptions objectAtIndex:indexPath.row] valueForKey:keyUID]];
        [tableViewAlert reloadData];
    }
}

#pragma mark - UIPickerView Delegates
- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    
    if(component == 0)
    {
        firstComponentValue = [[priceArray objectAtIndex:row] intValue] * 100;
    }
    else if(component == 1)
    {
        secondComponentValue = [[priceArray objectAtIndex:row] intValue] * 10;
    }
    else if(component == 2)
    {
        thirdComponentValue = [[priceArray objectAtIndex:row] intValue];
    }
    else if(component == 4)
    {
        fourthComponentValue = [[priceArray objectAtIndex:row] intValue] * 0.1;
    }
    else if(component == 5)
    {
        fifthComponentValue = [[priceArray objectAtIndex:row] intValue] * 0.01;
    }
    
    totalPrice = firstComponentValue + secondComponentValue + thirdComponentValue + fourthComponentValue + fifthComponentValue;
}
// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if(component == 3)
    {
        return 1;
    }
    return [priceArray count];
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 6;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString *title = [priceArray objectAtIndex:row];
    if(component == 3)
    {
        title = [NSString stringWithFormat:@"."];
    }
    return title;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [priceArray objectAtIndex:row];
    if(component == 3)
    {
        title = [NSString stringWithFormat:@"."];
    }
    NSAttributedString *attString;
    if(iOS7)
    {
        attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    }
    else
    {
        attString = [[NSAttributedString alloc]initWithString:title];
    }
    return attString;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return 30.0;
}

#pragma mark - Customization Controls
- (void) customizeTextViewProperties {
    textViewAlert.inputAccessoryView = [self accessoryView];
}

#pragma mark - Customize Alert View

- (void) defaultSelectionFirst {
    currentRadioButton = buttonOne;
    [self setSelected:YES forButton:buttonOne];
}

- (void) deselectAllButton {
    [self setSelected:NO forButton:buttonOne];
    [self setSelected:NO forButton:buttonTwo];
    [self setSelected:NO forButton:buttonThree];
}

- (void)setSelected:(BOOL)boolValue forButton:(UIButton *)button
{
    button.backgroundColor = boolValue ? kButtonBGColorSel : kButtonBGColorUnSel;
    [button setTitleColor:(boolValue ? kButtonTitleColorSel : kButtonTitleColorUnSel) forState:UIControlStateNormal];
}

- (void) customizeOptionButtonsDefault
{
    [self customizeButton:buttonOne];
    [self customizeButton:buttonTwo];
    [self customizeButton:buttonThree];
    
    //[self customizeButton:btnConfirmAlert];
    //[self customizeButton:btnCancelAlert];
    
    [self deselectAllButton];
    
    [self defaultSelectionFirst];
}

- (void) customizeButton:(UIButton *)button
{
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor whiteColor]];
    //button.layer.borderColor = [UIColor blackColor].CGColor;
    //button.layer.cornerRadius = 10.0;
    //button.layer.borderWidth = 1.0;
    [button.titleLabel setFont:kBtnFont];
}

- (void) customizeAlertOptionButtons {
    if(iOS7) {
        [btnConfirmAlert setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnCancelAlert setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [btnConfirmAlert setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [btnCancelAlert setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    }
}

- (void) defaultButtonSelectionDuration:(int)duration {
    if(duration>0) {
        [self deselectAllButton];
        if(duration == 7) {
            currentRadioButton = buttonOne;
            [self setSelected:YES forButton:buttonOne];
        }else if(duration == 1) {
            currentRadioButton = buttonTwo;
            [self setSelected:YES forButton:buttonTwo];
        }else if(duration == 2) {
            currentRadioButton = buttonThree;
            [self setSelected:YES forButton:buttonThree];
        }
    }else{
        //if no duration set then set first button as default
        currentRadioButton = buttonOne;
        [self setSelected:YES forButton:buttonOne];
    }
}

#pragma mark - Customize View
- (void) customizeViewForType:(VideoAction)viewType {
    
    //[self customizeAlertOptionButtons];
    
    requestType = viewType;
    
    [self setViewBorder];
    [self setTitleMessageColor];
    [self setViewBackgroundColors];
    
    switch (viewType)
    {
        case VideoActionBorrow:
            //[self setTextViewBoarder];
            [self setTextViewDelegate];
            [self customizeTextViewProperties];
            [self customizeOptionButtonsDefault];
            [self createBorrowFrom];
            break;
            
        case VideoActionSend:
            //[self setTextViewBoarder];
            [self setTextViewDelegate];
            [self customizeTextViewProperties];
            //[self setTableViewBoarder];
            [self createSendMovieToFriend];
            break;
            
        case VideoActionSell:
            [self setDefaultValuesForPrice];
            //[self setPickerViewBoarder];
            [self createSellThisMovie];
            [self reloadPicker];
            break;
            
        case VideoActionSellToFriend:
            [self setDefaultValuesForPrice];
            //[self setPickerViewBoarder];
            [self customizeOptionButtonsDefault];
            //[self setTableViewBoarder];
            [self createSellMovieToFriend];
            [self reloadTable];
            [self reloadPicker];
            break;
            
        case VideoActionGiftToFriend:
            //[self setTextViewBoarder];
            [self setTextViewDelegate];
            [self customizeTextViewProperties];
            [self customizeOptionButtonsDefault];
            //[self setTableViewBoarder];
            [self createGiftMovieToFriend];
            [self reloadTable];
            break;
            
        case VideoDownloadOffline:
            [self createDownload];
            [self customizeOptionButtonsDefault];
            break;
            
        case VideoDownloadOfflineFrom:
            [self createDownloadFrom];
            //[self setTableViewBoarder];
            [self reloadTable];
            break;
            
        case VideoDownloadOfflineRenew:
            [self createDownload];
            [self customizeOptionButtonsDefault];
            break;
            
        case VideoActionInviteToFriend:
        {
            [self setTextViewDelegate];
            [self customizeTextViewProperties];
            [self createInviteFriend];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Setter
- (void) setStrViewTitle:(NSString *)str {
    [lblTitle setText:str];
}

- (void) setStrViewMessage:(NSString *)str {
    [lblMessage setText:str];
}

- (void) setStrTextFieldPlaceHodlder:(NSString *)str {
    [textFieldAlert setPlaceholder:str];
}

- (void) setStrConfirmTitle:(NSString *)str {
    [btnConfirmAlert setTitle:str forState:UIControlStateNormal];
}

- (void) setStrCancelTitle:(NSString *)str {
    [btnConfirmAlert setTitle:str forState:UIControlStateNormal];
}

#pragma mark - Create View
- (void) createSellThisMovie {
    
    [viewTitle setHidden:NO];
    [viewPickerView setHidden:NO];
    [viewAlertOptions setHidden:NO];
    
    viewTitle.frame = CGRectMake(0, 0, viewTitle.frame.size.width, viewTitle.frame.size.height + 27);
    lblTitle.frame = CGRectMake(lblTitle.frame.origin.x, lblTitle.frame.origin.y, lblTitle.frame.size.width, viewTitle.frame.size.height + 27);
    viewPickerView.frame = CGRectMake(viewPickerView.frame.origin.x, viewTitle.frame.origin.y+viewTitle.frame.size.height+MARGIN, viewPickerView.frame.size.width, viewPickerView.frame.size.height);
    pickerViewAlert.frame = CGRectMake(0, 0, 280, pickerViewAlert.frame.size.height);
    viewAlertOptions.frame = CGRectMake(0, viewPickerView.frame.origin.y+viewPickerView.frame.size.height+MARGIN, viewAlertOptions.frame.size.width, viewAlertOptions.frame.size.height);
    
    popupView.frame = CGRectMake(popupView.frame.origin.x, popupView.frame.origin.y, popupView.frame.size.width, viewAlertOptions.frame.origin.y+viewAlertOptions.frame.size.height);
}

- (void) resizeMessageLabel {
    CGSize maxLabelSize = CGSizeMake(280,9999);
    
    CGSize expectedLabelSize = [lblMessage.text sizeWithFont:lblMessage.font
                                           constrainedToSize:maxLabelSize
                                               lineBreakMode:lblMessage.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = lblMessage.frame;
    newFrame.size.height = expectedLabelSize.height;
    lblMessage.frame = newFrame;
    viewMessage.frame = CGRectMake(viewMessage.frame.origin.x, viewMessage.frame.origin.y, viewMessage.frame.size.width, lblMessage.frame.size.height);
}

- (void) createSellMovieToFriend {
    
    [viewTitle setHidden:NO];
    [viewMessage setHidden:NO];
    [viewButtons setHidden:NO];
    [viewPickerView setHidden:NO];
    [viewTableView setHidden:NO];
    [viewAlertOptions setHidden:NO];
    
    viewTitle.frame = CGRectMake(0, 0, viewTitle.frame.size.width, viewTitle.frame.size.height);
    viewMessage.frame = CGRectMake(0, viewTitle.frame.origin.y+viewTitle.frame.size.height, viewMessage.frame.size.width, viewMessage.frame.size.height);
    
    [self resizeMessageLabel];
    
    viewButtons.frame = CGRectMake(0, viewMessage.frame.origin.y+viewMessage.frame.size.height+10.0, viewButtons.frame.size.width, viewButtons.frame.size.height);
    
    viewPickerView.frame = CGRectMake(viewPickerView.frame.origin.x, viewButtons.frame.origin.y+viewButtons.frame.size.height, viewPickerView.frame.size.width, viewPickerView.frame.size.height);
    pickerViewAlert.frame = CGRectMake(0, 0, pickerViewAlert.frame.size.width, pickerViewAlert.frame.size.height);
    
    viewTableView.frame = CGRectMake(viewTableView.frame.origin.x, viewPickerView.frame.origin.y + viewPickerView.frame.size.height+MARGIN*2, viewTableView.frame.size.width, viewTableView.frame.size.height);
    tableViewAlert.frame = CGRectMake(0, 0, viewTableView.frame.size.width, viewTableView.frame.size.height);
    
    viewAlertOptions.frame = CGRectMake(0, viewTableView.frame.origin.y+viewTableView.frame.size.height, viewAlertOptions.frame.size.width, viewAlertOptions.frame.size.height);
    
    popupView.frame = CGRectMake(popupView.frame.origin.x, popupView.frame.origin.y, popupView.frame.size.width, viewAlertOptions.frame.origin.y+viewAlertOptions.frame.size.height);
    
    _mainScrollView.contentSize = CGSizeMake(_mainScrollView.frame.size.width, popupView.frame.origin.y+popupView.frame.size.height);
}

- (void) createGiftMovieToFriend {
    
    [viewTitle setHidden:NO];
    [viewMessage setHidden:NO];
    [viewButtons setHidden:NO];
    [viewTextView setHidden:NO];
    [viewTableView setHidden:NO];
    [viewAlertOptions setHidden:NO];
    
    viewTitle.frame = CGRectMake(0, 0, viewTitle.frame.size.width, viewTitle.frame.size.height);
    viewMessage.frame = CGRectMake(0, viewTitle.frame.origin.y+viewTitle.frame.size.height, viewMessage.frame.size.width, viewMessage.frame.size.height);
    viewButtons.frame = CGRectMake(0, viewMessage.frame.origin.y+viewMessage.frame.size.height, viewButtons.frame.size.width, viewButtons.frame.size.height);
    viewTextView.frame = CGRectMake(0, viewButtons.frame.origin.y+viewButtons.frame.size.height, viewTextView.frame.size.width, viewTextView.frame.size.height);
    viewTableView.frame = CGRectMake(viewTableView.frame.origin.x, viewTextView.frame.origin.y+viewTextView.frame.size.height, viewTableView.frame.size.width, viewTableView.frame.size.height);
    viewAlertOptions.frame = CGRectMake(0, viewTableView.frame.origin.y+viewTableView.frame.size.height, viewAlertOptions.frame.size.width, viewAlertOptions.frame.size.height);
    
    popupView.frame = CGRectMake(popupView.frame.origin.x, popupView.frame.origin.y, popupView.frame.size.width, viewAlertOptions.frame.origin.y+viewAlertOptions.frame.size.height);
    _mainScrollView.contentSize = CGSizeMake(_mainScrollView.frame.size.width, popupView.frame.origin.y+popupView.frame.size.height);
}

- (void) createDownload {
    
    [viewTitle setHidden:NO];
    [viewMessage setHidden:NO];
    [viewButtons setHidden:NO];
    [viewAlertOptions setHidden:NO];
    
    viewTitle.frame = CGRectMake(0, 0, viewTitle.frame.size.width, viewTitle.frame.size.height);
    viewMessage.frame = CGRectMake(0, viewTitle.frame.origin.y+viewTitle.frame.size.height, viewMessage.frame.size.width, viewMessage.frame.size.height);
    viewButtons.frame = CGRectMake(0, viewMessage.frame.origin.y+viewMessage.frame.size.height, viewButtons.frame.size.width, viewButtons.frame.size.height);
    viewAlertOptions.frame = CGRectMake(0, viewButtons.frame.origin.y+viewButtons.frame.size.height, viewAlertOptions.frame.size.width, viewAlertOptions.frame.size.height);
    
    popupView.frame = CGRectMake(popupView.frame.origin.x, popupView.frame.origin.y, popupView.frame.size.width, viewAlertOptions.frame.origin.y+viewAlertOptions.frame.size.height);
}

- (void) createDownloadFrom {
    
    [viewTitle setHidden:NO];
    [viewMessage setHidden:NO];
    [viewTableView setHidden:NO];
    [viewAlertOptions setHidden:NO];
    
    viewTitle.frame = CGRectMake(0, 0, viewTitle.frame.size.width, viewTitle.frame.size.height);
    viewMessage.frame = CGRectMake(0, viewTitle.frame.origin.y+viewTitle.frame.size.height, viewMessage.frame.size.width, viewMessage.frame.size.height);
    viewTableView.frame = CGRectMake(viewTableView.frame.origin.x, viewMessage.frame.origin.y+viewMessage.frame.size.height, viewTableView.frame.size.width, viewTableView.frame.size.height);
    viewAlertOptions.frame = CGRectMake(0, viewTableView.frame.origin.y+viewTableView.frame.size.height, viewAlertOptions.frame.size.width, viewAlertOptions.frame.size.height);
    
    popupView.frame = CGRectMake(popupView.frame.origin.x, popupView.frame.origin.y, popupView.frame.size.width, viewAlertOptions.frame.origin.y+viewAlertOptions.frame.size.height);
}

- (void) createSendMovieToFriend {
    
    [viewTitle setHidden:NO];
    [viewTextView setHidden:NO];
    [viewTableView setHidden:NO];
    [viewAlertOptions setHidden:NO];
    
    viewTitle.frame = CGRectMake(0, 0, viewTitle.frame.size.width, viewTitle.frame.size.height);
    viewTextView.frame = CGRectMake(0, viewTitle.frame.origin.y+viewTitle.frame.size.height, viewTextView.frame.size.width, viewTextView.frame.size.height);
    viewTableView.frame = CGRectMake(viewTableView.frame.origin.x, viewTextView.frame.origin.y+viewTextView.frame.size.height, viewTableView.frame.size.width, viewTableView.frame.size.height);
    viewAlertOptions.frame = CGRectMake(0, viewTableView.frame.origin.y+viewTableView.frame.size.height, viewAlertOptions.frame.size.width, viewAlertOptions.frame.size.height);
    
    popupView.frame = CGRectMake(popupView.frame.origin.x, popupView.frame.origin.y, popupView.frame.size.width, viewAlertOptions.frame.origin.y+viewAlertOptions.frame.size.height);
    _mainScrollView.contentSize = CGSizeMake(_mainScrollView.frame.size.width, popupView.frame.origin.y+popupView.frame.size.height);
}

- (void) createBorrowFrom {

    [viewTitle setHidden:NO];
    [viewMessage setHidden:NO];
    [viewButtons setHidden:NO];
    [viewTextView setHidden:NO];
    [viewAlertOptions setHidden:NO];
    
    viewTitle.frame = CGRectMake(0, 0, viewTitle.frame.size.width, viewTitle.frame.size.height);
    viewMessage.frame = CGRectMake(0, viewTitle.frame.origin.y+viewTitle.frame.size.height, viewMessage.frame.size.width, viewMessage.frame.size.height);
    viewButtons.frame = CGRectMake(0, viewMessage.frame.origin.y+viewMessage.frame.size.height, viewButtons.frame.size.width, viewButtons.frame.size.height);
    viewTextView.frame = CGRectMake(0, viewButtons.frame.origin.y+viewButtons.frame.size.height, viewTextView.frame.size.width, viewTextView.frame.size.height);
    viewAlertOptions.frame = CGRectMake(0, viewTextView.frame.origin.y+viewTextView.frame.size.height, viewAlertOptions.frame.size.width, viewAlertOptions.frame.size.height);

    popupView.frame = CGRectMake(popupView.frame.origin.x, popupView.frame.origin.y, popupView.frame.size.width, viewAlertOptions.frame.origin.y+viewAlertOptions.frame.size.height);
}
- (void) createInviteFriend{
    
    [viewTitle setHidden:NO];
    [viewMessage setHidden:NO];
    [viewTextView setHidden:NO];
    [viewAlertOptions setHidden:NO];
    
    viewTitle.frame = CGRectMake(0, 0, viewTitle.frame.size.width, viewTitle.frame.size.height);
    viewMessage.frame = CGRectMake(0, viewTitle.frame.origin.y+viewTitle.frame.size.height, viewMessage.frame.size.width, viewMessage.frame.size.height);
    viewTextView.frame = CGRectMake(0, viewMessage.frame.origin.y+viewMessage.frame.size.height, viewTextView.frame.size.width, viewTextView.frame.size.height);
    viewAlertOptions.frame = CGRectMake(0, viewTextView.frame.origin.y+viewTextView.frame.size.height, viewAlertOptions.frame.size.width, viewAlertOptions.frame.size.height);
    
    popupView.frame = CGRectMake(popupView.frame.origin.x, popupView.frame.origin.y, popupView.frame.size.width, viewAlertOptions.frame.origin.y+viewAlertOptions.frame.size.height);
}

#pragma mark - Actions
- (IBAction)confirmAction:(id)sender
{
    [textViewAlert resignFirstResponder];
    [textFieldAlert resignFirstResponder];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    if(requestType == VideoActionBorrow) {
        
        if(textViewAlert.text.length == 0)
        {
            [self makeToast:NSLocalizedString(@"alertEnterMessage", nil)];
            return;
        }
        
        [result setObject:[NSNumber numberWithInt:currentRadioButton.tag] forKey:keyDuration];
        [result setObject:textViewAlert.text forKey:keyComment];
        
        [appDelegate.customAlertResult setObject:[NSNumber numberWithInt:currentRadioButton.tag] forKey:keyDuration];
        [appDelegate.customAlertResult setObject:textViewAlert.text forKey:keyComment];
    }
    else if(requestType == VideoDownloadOffline) {
        [result setObject:[NSNumber numberWithInt:currentRadioButton.tag] forKey:keyDuration];
        
        [appDelegate.customAlertResult setObject:[NSNumber numberWithInt:currentRadioButton.tag] forKey:keyDuration];
    }
    else if(requestType == VideoDownloadOfflineFrom){
        [result setObject:selectionArray forKey:keyFriendsSelected];
        
        [appDelegate.customAlertResult setObject:selectionArray forKey:keyFriendsSelected];
    }
    else if(requestType == VideoDownloadOfflineRenew){
        [result setObject:[NSNumber numberWithInt:currentRadioButton.tag] forKey:keyDuration];
        [result setObject:textViewAlert.text forKey:keyComment];
        
        [appDelegate.customAlertResult setObject:[NSNumber numberWithInt:currentRadioButton.tag] forKey:keyDuration];
        [appDelegate.customAlertResult setObject:textViewAlert.text forKey:keyComment];
    }
    else if(requestType == VideoActionGiftToFriend){
        
        if(textViewAlert.text.length == 0)
        {
            [self makeToast:NSLocalizedString(@"alertEnterMessage", nil)];
            return;
        }
        
        if([selectionArray count] == 0)
        {
            [self makeToast:NSLocalizedString(@"alertSelectFriend", nil)];
            return;
        }
        
        [result setObject:textViewAlert.text forKey:keyComment];
        [result setObject:selectionArray forKey:keyFriendsSelected];
        [result setObject:[NSNumber numberWithInt:currentRadioButton.tag] forKey:keyDuration];
        
        [appDelegate.customAlertResult setObject:textViewAlert.text forKey:keyComment];
        [appDelegate.customAlertResult setObject:selectionArray forKey:keyFriendsSelected];
        [appDelegate.customAlertResult setObject:[NSNumber numberWithInt:currentRadioButton.tag] forKey:keyDuration];
    }
    else if(requestType == VideoActionSellToFriend){
        
        if(totalPrice < 1.00)
        {
            [self makeToast:NSLocalizedString(@"alertSelectPrice", nil)];
            return;
        }
        
        if([selectionArray count] == 0)
        {
            [self makeToast:NSLocalizedString(@"alertSelectFriend", nil)];
            return;
        }
        
        [result setObject:[NSString stringWithFormat:@"%.2f", totalPrice] forKey:keyPrice];
        [result setObject:selectionArray forKey:keyFriendsSelected];
        [result setObject:[NSNumber numberWithInt:currentRadioButton.tag] forKey:keyDuration];
        
        [appDelegate.customAlertResult setObject:[NSString stringWithFormat:@"%.2f", totalPrice] forKey:keyPrice];
        [appDelegate.customAlertResult setObject:selectionArray forKey:keyFriendsSelected];
        [appDelegate.customAlertResult setObject:[NSNumber numberWithInt:currentRadioButton.tag] forKey:keyDuration];
    }
    else if(requestType == VideoActionSell){
        
        if(totalPrice < 1.00)
        {
            [self makeToast:NSLocalizedString(@"alertSelectPrice", nil)];
            return;
        }
        [result setObject:[NSString stringWithFormat:@"%.2f", totalPrice] forKey:keyPrice];
        [appDelegate.customAlertResult setObject:[NSString stringWithFormat:@"%.2f", totalPrice] forKey:keyPrice];
    }
    else if(requestType == VideoActionSend){
        
        if(textViewAlert.text.length == 0)
        {
            [self makeToast:NSLocalizedString(@"alertEnterMessage", nil)];
            return;
        }
        if([selectionArray count] == 0)
        {
            [self makeToast:NSLocalizedString(@"alertSelectFriend", nil)];
            return;
        }
        
        [result setObject:textViewAlert.text forKey:keyComment];
        [result setObject:selectionArray forKey:keyFriendsSelected];
        [result setObject:[NSNumber numberWithInt:currentRadioButton.tag] forKey:keyDuration];
        
        [appDelegate.customAlertResult setObject:textViewAlert.text forKey:keyComment];
        [appDelegate.customAlertResult setObject:selectionArray forKey:keyFriendsSelected];
        [appDelegate.customAlertResult setObject:[NSNumber numberWithInt:currentRadioButton.tag] forKey:keyDuration];
    }
    else if(requestType == VideoActionInviteToFriend)
    {
        
        if(textViewAlert.text.length == 0 || ![self validateEmail:textViewAlert.text])
        {
            [self makeToast:NSLocalizedString(@"validateEmail", nil)];
            return;
        }
        
         [result setObject:textViewAlert.text forKey:keyComment];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(confirmButtonClicked:forType:withValues:)])
    {
        [self.delegate confirmButtonClicked:self forType:requestType withValues:result];
    }
}

- (IBAction)cancelAction:(id)sender
{
    [textViewAlert resignFirstResponder];
    [textFieldAlert resignFirstResponder];
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelButtonClicked:)])
    {
        [self.delegate cancelButtonClicked:self];
        if(appDelegate.customAlertResult) {
            [appDelegate.customAlertResult removeAllObjects];
        }
    }
}

- (IBAction)optionSelection:(id)sender {
    CustomButton *btn = (CustomButton *)sender;
    currentRadioButton = btn;
    [self deselectAllButton];
    [self setSelected:YES forButton:btn];
}

#pragma mark - UIKeyBoard Notifications
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

- (CGRect)getScrollViewFrameForView:(UIView *)sView
{
    CGRect visibleRect = sView.frame;
    
    if([[sView superview] isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *superClass = (UIScrollView *)[sView superview];
        visibleRect.origin = superClass.contentOffset;
        visibleRect.size = superClass.contentSize;
        
        CGFloat navHeight = 44.f;
        if(iOS7) {
            navHeight = 64.f;
        }
        
        if(visibleRect.origin.y>0)
        {
            CGRect newframe = CGRectMake(superClass.frame.origin.x, navHeight, superClass.frame.size.width, superClass.frame.size.height + (superClass.contentOffset.y - navHeight));
            visibleRect = newframe;
        }else {
            CGRect newframe = CGRectMake(superClass.frame.origin.x, 0, superClass.frame.size.width, superClass.frame.size.height + superClass.contentOffset.y);
            visibleRect = newframe;
        }
    }
    
    return visibleRect;
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    //return;
    if(iPad)
    {
        if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
        {
            return;
        }
    }
    CGPoint point = [currentTextView.superview convertPoint:currentTextView.frame.origin fromView:popupView];
    CGFloat diff = point.y < 0 ? point.y*(-1) : point.y;
    [self setAlertContainerWithDiff:diff];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //return;
    if(iPad)
    {
        if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
        {
            return;
        }
    }
    [self setAlertContainerWithDiff:0.0];
}

- (void)setAlertContainerWithDiff:(CGFloat)diff
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    popupView.center = CGPointMake(_mainScrollView.frame.size.width/2.0, _mainScrollView.frame.size.height/2.0 - diff);
    [UIView commitAnimations];
}
#pragma mark - Field Validation
-(BOOL) validateEmail: (NSString *) email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [emailTest evaluateWithObject:email];
    return isValid;
}
#pragma mark - Accessory View
-(UIToolbar *)accessoryView
{
    UIToolbar *accessoryView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44.0)];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    accessoryView.items = [NSArray arrayWithObjects:flexibleSpace,btn, nil];
    [accessoryView setTintColor:[[UIColor blackColor]colorWithAlphaComponent:0.5]];
    return accessoryView;
}

#pragma mark - Events
- (void) doneButton {
    [textViewAlert resignFirstResponder];
    [textFieldAlert resignFirstResponder];
}

-(void)dealloc
{
    [self deregisterForKeyboardNotifications];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)adjustForOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    //alertContainer.center = CGPointMake(self.view.frame.size.width/2.0,self.view.frame.size.height/2.0);
    
    [self performSelector:@selector(de:) withObject:[NSString stringWithFormat:@"%d",toInterfaceOrientation] afterDelay:0.01];
   

    //================================
}

-(void)de:(NSString *)str
{
    UIInterfaceOrientation toInterfaceOrientation=(UIInterfaceOrientation)str;
    CGFloat heightToRemove = 20.0;
    if (iOS7) {
        heightToRemove = 0.0;
    }
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-heightToRemove);
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft
        || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width-heightToRemove);
    }
    
    //================================
    _mainScrollView.frame = frame;//self.superview.frame;
    CGFloat yCenter = frame.size.height > _mainScrollView.contentSize.height ? frame.size.height/2.0 : _mainScrollView.contentSize.height/2.0;
    popupView.center = CGPointMake(_mainScrollView.frame.size.width/2.0, yCenter);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
