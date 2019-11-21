//
//  MovieListViewController.h
//  Sagebin
//
//  
//

#import <UIKit/UIKit.h>

typedef enum MoviListViewTags {
    TAG_ML_TOP = 40001,
    TAG_ML_MAIN,
    TAG_ML_CELL,
    TAG_ML_ICON_VIEW,
    TAG_ML_OTHER_VIE,
    TAG_ML_LBL_TITLE,
    TAG_ML_LBL_DESCRIPTION,
    TAG_ML_LBL_RATING,
    TAG_ML_IMGVW_SELL
}ML_TAG;

typedef enum MoviListType
{
    TYPE_FRIEND_MOVIE=0,
    TYPE_MY_MOVIE,
    TYPE_BIN_MOVIE,
    TYPE_FAV_MOVIE,
    TYPE_GIVE_MOVIE,
    TYPE_GIVE_MOVIE_FRIEND
}ML_TYPE;

@interface MovieListViewController : RootViewController <IMDEventImageDelegate, ChromecastControllerDelegate>
{
    int moviePageNo, movieCount,favIndex;
    int totalCount;
    BOOL isRefresh;
}

@property (nonatomic,assign) int movieList;

@end
