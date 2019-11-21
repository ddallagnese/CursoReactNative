//
//  SettingsViewController.h
//  Sagebin
//
//  
//

#import <UIKit/UIKit.h>
#import "NewsViewController.h"

#define kTagSaveButton 98
#define kTagTableSettings 99

#define kRowHeight 44.0

enum{
    SectionDownloadMode = 0,
    SectionNotificationType,
    SectionNotificationPeriod,
    SectionAccountCredits
}SectionTitle;

enum{
    DownloadModeTitleWIFI = 0,
    DownloadModeTitleCelluler,
    DownloadModeTitleBoth
}DownloadModeTitle;

enum{
    NotificationTypeTitleEmail = 0,
    NotificationTypeTitlePush,
    NotificationTypeTitleBoth
}NotificationTypeTitle;

enum{
    NotificationPeriodTitleDaily = 0,
    NotificationPeriodTitleWeekly,
    NotificationPeriodTitleMonthly
}NotificationPeriodTitle;

typedef enum SettingsViewTags {
    TAG_TableView = 300,
    TAG_SaveButton,
    
    // From below tag use for collection view cell
    TAG_REUSEVIEW,
    TAG_Cell_LblTitle,
    Tag_Cell_ViewLine
}SEETINGS_TAG;

@interface SettingsViewController : RootViewController <UITableViewDataSource, UITableViewDelegate, ChromecastControllerDelegate>
{
    NSInteger CHECKED_INDEX_DOWNLOAD_MODE, CHECKED_INDEX_NOTIFICATION_TYPE,CHECKED_INDEX_NOTIFICATION_PERIOD;
    NSMutableArray *arraySectionTitles;
    NSMutableArray *arrayDownloadModes, *arrayNotificationTypes,*arrayNotificationPeriods;
    
    NSMutableArray *arrData;
    NSDictionary *userDictionary;
    UITableView *settingsTable;
    
}
@end
