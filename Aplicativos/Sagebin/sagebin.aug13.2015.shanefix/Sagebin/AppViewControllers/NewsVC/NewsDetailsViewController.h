//
//  NewsDetailsViewController.h
//  Sagebin
//
//  
//

#import <UIKit/UIKit.h>

typedef enum NewsDetails
{
    TAG_ND_PICTURE_VIEW = 0,
    TAG_ND_TITLE_VIEW,
    TAG_ND_LBL_TITLE,
    TAG_ND_DETAILS_VIEW,
    TAG_ND_LBL_DETAILS,
}NewsDetails;

@interface NewsDetailsViewController : RootViewController <ChromecastControllerDelegate>
{
    IMDEventImageView *pictureView;
    UIView *titleView, *detailsView;
}

@property (nonatomic,retain) NSString *strId;

@end
