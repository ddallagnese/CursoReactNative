//
//  NewsViewController.h
//  Sagebin
//
//  
//

#import <UIKit/UIKit.h>

typedef enum NewsViewTags {
    TAG_NEWS_TOP = 30001,
    TAG_NEWS_MAIN,
    TAG_NEWS_CELL,
    TAG_NEWS_ICON_VIEW,
    TAG_NEWS_OTHER_VIE,
    TAG_NEWS_LBL_TITLE,
    TAG_NEWS_DESCRIPTION,
    TAG_NEWS_VIEW_MORE,
    
}NEWS_TAG;

@interface NewsViewController : RootViewController <ChromecastControllerDelegate>

@end
