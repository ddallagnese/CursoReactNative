//
//  OfflineMovieListViewController.h
//  Sagebin
//
//  
//

#import <UIKit/UIKit.h>

typedef enum OfflineViewTags {
    TAG_OFF_TOP = 50001,
    TAG_OFF_MAIN,
    TAG_OFF_CELL,
    TAG_OFF_ICON_VIEW,
    TAG_OFF_OTHER_VIE,
    TAG_OFF_LBL_TITLE,
    TAG_OFF_LBL_DESCRIPTION,
    TAG_OFF_LBL_RATING,
    TAG_OFF_IMGVW_SELL
    
}OFFLINE_TAG;

@interface OfflineMovieListViewController : RootViewController <ChromecastControllerDelegate>
{
    NSMutableArray *temporaryDownloadedVideos;
}

@end
