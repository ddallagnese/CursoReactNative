//
//  SearchMovieListViewController.h
//  Sagebin
//
//  
//

#import <UIKit/UIKit.h>

//typedef enum SearchMovieViewTags {
//    TAG_SearchMovieView = 300,
//    TAG_SEARCHTEXT,
//    TAG_SEARCHBUTTON,
//}SEARCH_MOVIE_VIEW_TAG;

typedef enum SearchMovieTags : NSUInteger {
    TAG_SearchMovieView = 300,
    TAG_SearchText,
    TAG_SearchButton,
    
    TAG_SearchTable,
    TAG_SearchReuseView,
    TAG_Search_LblTitle,
    Tag_Search_ViewLine
} SearchMovieTags;

@interface SearchMovieListViewController : RootViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, ChromecastControllerDelegate>
{
    UIView *searchView;
    UITextField *txtSearch;
    NSMutableArray *arrData, *arraySectionTitles;
    UITableView *searchTable;
    
    
    int moviePageNo, movieCount;
    int totalCount;
    BOOL isRefresh;
}
@property(nonatomic,retain)NSString *movieName;
@end
