//
// UIScrollView+SNTPullToRefresh.h
//
//
//

#import <UIKit/UIKit.h>
#import <AvailabilityMacros.h>
#import "UIScrollView+SNTInfiniteScrolling.h"

#define SNTPullToRefreshViewHeight  55.0 //85.0
@class SNTPullToRefreshView;

@interface UIScrollView (SNTPullToRefresh)

enum {
    SNTPullToRefreshPositionTop = 0,
    SNTPullToRefreshPositionBottom,
};

typedef NSUInteger SNTPullToRefreshPosition;

- (void)addPullToRefreshWithActionHandler:(void (^)(void))actionHandler;
- (void)addPullToRefreshWithActionHandler:(void (^)(void))actionHandler position:(SNTPullToRefreshPosition)position;
- (void)addPullToRefreshWithTopImageName:(NSString *)topImageName andActionHandler:(void (^)(void))actionHandler;
- (void)triggerPullToRefresh;

@property (nonatomic, strong, readonly) SNTPullToRefreshView *pullToRefreshView;
@property (nonatomic, assign) BOOL showsPullToRefresh;

@end


enum {
    SNTPullToRefreshStateStopped = 0,
    SNTPullToRefreshStateTriggered,
    SNTPullToRefreshStateLoading,
    SNTPullToRefreshStateAll = 10
};

typedef NSUInteger SNTPullToRefreshState;

@interface SNTPullToRefreshView : UIView

@property (nonatomic, strong) UIColor *arrowColor;
@property (nonatomic, strong) UIColor *textColor, *textShadowColor;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *subtitleLabel;

@property (nonatomic, readonly) SNTPullToRefreshState state;
@property (nonatomic, readonly) SNTPullToRefreshPosition position;

- (void)setTitle:(NSString *)title forState:(SNTPullToRefreshState)state;
- (void)setSubtitle:(NSString *)subtitle forState:(SNTPullToRefreshState)state;
- (void)setCustomView:(UIView *)view forState:(SNTPullToRefreshState)state;

- (void)startAnimating;
- (void)stopAnimating;
- (void)setAnimating:(BOOL)flag;
- (void)setState:(SNTPullToRefreshState)newState;

// deprecated; use setSubtitle:forState: instead
@property (nonatomic, strong, readonly) UILabel *dateLabel DEPRECATED_ATTRIBUTE;
@property (nonatomic, strong) NSDate *lastUpdatedDate DEPRECATED_ATTRIBUTE;
@property (nonatomic, strong) NSDateFormatter *dateFormatter DEPRECATED_ATTRIBUTE;

// deprecated; use [self.scrollView triggerPullToRefresh] instead
- (void)triggerRefresh DEPRECATED_ATTRIBUTE;

@end
