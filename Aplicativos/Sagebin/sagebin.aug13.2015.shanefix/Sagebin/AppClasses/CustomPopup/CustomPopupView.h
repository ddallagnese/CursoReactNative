//
//  CustomPopupView.h
//  Sagebin
//
//  
//

#import <UIKit/UIKit.h>

#define kTagSevenDays 7
#define kTagOneDay 1
#define kTagTwoDays 2

typedef enum PopupTag
{
    Popup_Main_ScrollView=601,
    PopupView_Tag,
    ViewTitle_Tag,
    LblTitle_Tag,
    ViewMsg_Tag,
    LblMsg_Tag,
    ViewTextField_Tag,
    TextField_Tag,
    ViewTextView_Tag,
    TextView_Tag,
    ViewTableView_Tag,
    Table_Tag,
    ViewButton_Tag,
    BtnOne_Tag,
    BtnTwo_Tag,
    BtnThree_Tag,
    ViewOption_Tag,
    BtnCancel_Tag,
    BtnConfirm_Tag,
    ViewPickerView_Tag,
    PickerView_Tag
}PopupViewTags;

@protocol CustomPopupViewDelegate;

@interface CustomPopupView : UIView <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
{
    UIScrollView *_mainScrollView;
    UIView *popupView;
    
    //custom alert - title
    UIView *viewTitle;
    UILabel *lblTitle;
    
    //custom alert - message
    UIView *viewMessage;
    UILabel *lblMessage;
    
    //textfield
    UIView *viewTextField;
    UITextField *textFieldAlert;
    
    //textview
    UIView *viewTextView;
    UITextView *textViewAlert;
    
    //tableview
    UIView *viewTableView;
    UITableView *tableViewAlert;
    
    //custom alert - option buttons
    UIView *viewButtons;
    CustomButton *buttonOne, *buttonTwo, *buttonThree;
    
    //custom alert - cancel confirm
    UIView *viewAlertOptions;
    CustomButton *btnCancelAlert, *btnConfirmAlert;
    
    //custom alert - price picker
    UIView *viewPickerView;
    UIPickerView *pickerViewAlert;
    
    NSMutableArray *selectionArray;
    
    VideoAction requestType;
    
    UIButton *currentRadioButton;
    
    AppDelegate *appDelegate;
    
    CGRect initialVisibleFrame;
    
    NSIndexPath *selectedIndexPath;
    
    //current textfield:
    UITextField *currentTextField;
    
   
    
    NSMutableArray *priceArray;
    int firstComponentValue, secondComponentValue, thirdComponentValue;
    float fourthComponentValue, fifthComponentValue, totalPrice;
    UITextView *currentTextView;
}

@property (nonatomic, retain) NSString *strViewTitle;
@property (nonatomic, retain) NSString *strViewMessage;
@property (nonatomic, retain) NSArray *arrayOptions;

@property (nonatomic, retain) NSString *strTextFieldPlaceHodlder;

@property (nonatomic, retain) NSString *strConfirmTitle;

@property (nonatomic, retain) NSString *strCancelTitle;

@property (assign, nonatomic) id <CustomPopupViewDelegate>delegate;

- (void) customizeViewForType:(VideoAction)viewType;
- (void) defaultButtonSelectionDuration:(int)duration;
- (void) adjustForOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
@end

@protocol CustomPopupViewDelegate<NSObject>
@optional
- (void)confirmButtonClicked:(CustomPopupView *)customView forType:(VideoAction)viewType withValues:(NSDictionary *)result;
- (void)cancelButtonClicked:(CustomPopupView *)customView;

@end
