//
//  ReleaseVC.h
//  Sagebin
//
//  
//  
//

#import "RootViewController.h"


typedef enum ReleaseViewTags {
    TAG_REL_TOP = 20001,
    TAG_REL_MAIN,
    TAG_REL_CELL,
    TAG_REL_ICON_VIEW,
    TAG_REL_OTHER_VIE,
    TAG_REL_LBL_TITLE,
    TAG_REL_MOV_TITLE,
    TAG_REL_LBL_RETTING,
    TAG_REL_LBL_DESCRIPTION,
    TAG_STAR_MOVIE,
    TAG_PURCHASE,
    TAG_DOWNLOAD
    
    
}RELEASE_TAG;


@interface ReleaseVC : RootViewController <ChromecastControllerDelegate>
{
    int moviePageNo, movieCount,favIndex;
    int totalCount;
    BOOL isRefresh;
}
@end
