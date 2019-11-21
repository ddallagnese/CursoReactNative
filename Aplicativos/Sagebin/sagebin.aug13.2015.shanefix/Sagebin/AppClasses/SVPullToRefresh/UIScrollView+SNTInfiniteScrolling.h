//
// UIScrollView+SNTInfiniteScrolling.h
//
//

#import <UIKit/UIKit.h>
#import "UIScrollView+SNTPullToRefresh.h"

#define SNTInfiniteScrollingViewHeight 55.0//75.0

@class SNTInfiniteScrollingView;

@interface UIScrollView (SNTInfiniteScrolling)

- (void)addInfiniteScrollingWithActionHandler:(void (^)(void))actionHandler;
- (void)triggerInfiniteScrolling;
- (void)addInfiniteScrollingWithBottomImageName:(NSString *)bottomImage WithActionHandler:(void (^)(void))actionHandler;

@property (nonatomic, strong, readonly) SNTInfiniteScrollingView *infiniteScrollingView;
@property (nonatomic, assign) BOOL showsInfiniteScrolling;

@end

enum {
	SNTInfiniteScrollingStateStopped = 0,
    SNTInfiniteScrollingStateTriggered,
    SNTInfiniteScrollingStateLoading,
    SNTInfiniteScrollingStateEndOfPage,
    SNTInfiniteScrollingStateAll = 10
};

typedef NSUInteger SNTInfiniteScrollingState;

@interface SNTInfiniteScrollingView : UIView

{
    NSTimer *timerDotAnimation;
    NSInteger DOT_INDEX;
    BOOL _zeroUpdate;
    BOOL _prevNetState;
}

@property (nonatomic, readonly) SNTInfiniteScrollingState state;
@property (nonatomic, readwrite) BOOL enabled;

- (void)setCustomView:(UIView *)view forState:(SNTInfiniteScrollingState)state;

- (void)startAnimating;
- (void)stopAnimating;
- (void)stopAnimatingWithNoUpdate;
//- (void)setShowsInfiniteScrolling:(BOOL)showsInfiniteScrolling;

@end


