//
//  AlertViewController.h
//  Sagebin
//
//  
//

#import <UIKit/UIKit.h>
#import "CustomPopupView.h"
#import "MovieListViewController.h"
#import "ContactListViewController.h"
typedef enum AlertTags
{
    TAG_AlertTable=0,
    TAG_AlertMessage,
    TAG_Alert,
    TAG_AlertBtnYes,
    TAG_AlertBtnNo,
    TAG_AlertLineView,
    TAG_NoAlertLabel
}AlertViewTags;

@interface AlertViewController : RootViewController <UITableViewDataSource, UITableViewDelegate, CustomPopupViewDelegate, ChromecastControllerDelegate>
{
    NSMutableArray *arrAlerts;
    UITableView *alertTable;
    
    NSString *strCurrentTitle;
    int currentReqDay;
    int currentIndex;
    NSIndexPath *currentIndexPath;
    NSString *videoId,*permissonId;
    int bId;
    BOOL flagRequstVideo;
    
    CustomPopupView *objPopupView;
    
//    id parentController;
}

@property (nonatomic, retain) id parentController;

@end
