//
// UIScrollView+SNTInfiniteScrolling.m
//
//

#import <QuartzCore/QuartzCore.h>
#import "UIScrollView+SNTInfiniteScrolling.h"


//static CGFloat const SNTInfiniteScrollingViewHeight = 75.0;
static CGFloat const SNTRefreshDotAnimDuration = 0.2;
static NSInteger const SNTRefreshDotCount = 7;
static CGFloat const SNTRefreshDotGap = 10.0;

NSString *SNTLoadingCircleImage = @"loader_refresh.png";
NSString *SNTBottomPageImage = @"down1.png";

#define DotColor [UIColor colorWithRed:193.0/255.0 green:193.0/255.0 blue:193.0/255.0 alpha:1.0]
#define DotColorFill [UIColor colorWithRed:118.0/255.0 green:118.0/255.0 blue:118.0/255.0 alpha:1.0]

@interface SNTPullToRefreshArrow2 : UIView

@property (nonatomic, strong) UIColor *arrowColor;

@end

@interface SNTInfiniteScrollingDotView : UIView

@property (nonatomic, strong) UIColor *arrowColor;

@end



@interface SNTInfiniteScrollingView ()

@property (nonatomic, retain) NSMutableArray *arrayRefreshDots;
@property (nonatomic, strong) SNTPullToRefreshArrow2 *arrow;
@property (nonatomic, copy) void (^infiniteScrollingHandler)(void);
@property (nonatomic, readwrite) SNTInfiniteScrollingState state;
@property (nonatomic, strong) NSMutableArray *viewForState;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, readwrite) CGFloat originalBottomInset;
@property (nonatomic, assign) BOOL wasTriggeredByUser;
@property (nonatomic, assign) BOOL isObserving;

- (void)resetScrollViewContentInset;
- (void)setScrollViewContentInsetForInfiniteScrolling;
- (void)setScrollViewContentInset:(UIEdgeInsets)insets;

@end

#pragma mark - UIScrollView (SNTInfiniteScrollingView)
#import <objc/runtime.h>

static char UIScrollViewInfiniteScrollingView;
UIEdgeInsets scrollViewOriginalContentInsets;

@implementation UIScrollView (SNTInfiniteScrolling)

@dynamic infiniteScrollingView;

- (void)addInfiniteScrollingWithBottomImageName:(NSString *)bottomImage WithActionHandler:(void (^)(void))actionHandler {
    
    if(!self.infiniteScrollingView) {
        SNTBottomPageImage = bottomImage;
        UIImage *image = [UIImage imageNamed:SNTBottomPageImage];
        SNTInfiniteScrollingView *view = [[SNTInfiniteScrollingView alloc] initWithFrame:CGRectMake(0, self.contentSize.height, self.bounds.size.width, image.size.height)];
        view.infiniteScrollingHandler = actionHandler;
        view.scrollView = self;
        [self addSubview:view];
        
        view.originalBottomInset = self.contentInset.bottom;
        self.infiniteScrollingView = view;
        self.showsInfiniteScrolling = YES;
        
    }
}

- (void)addInfiniteScrollingWithActionHandler:(void (^)(void))actionHandler {
    
    if(!self.infiniteScrollingView) {
        UIImage *image = [UIImage imageNamed:SNTBottomPageImage];
        SNTInfiniteScrollingView *view = [[SNTInfiniteScrollingView alloc] initWithFrame:CGRectMake(0, self.contentSize.height, self.bounds.size.width, image.size.height)];
        view.infiniteScrollingHandler = actionHandler;
        view.scrollView = self;
        [self addSubview:view];
        
        view.originalBottomInset = self.contentInset.bottom;
        self.infiniteScrollingView = view;
        self.showsInfiniteScrolling = YES;
    }
}

- (void)triggerInfiniteScrolling {
    self.infiniteScrollingView.state = SNTInfiniteScrollingStateTriggered;
    [self.infiniteScrollingView startAnimating];
}

- (void)setInfiniteScrollingView:(SNTInfiniteScrollingView *)infiniteScrollingView {
    [self willChangeValueForKey:@"UIScrollViewInfiniteScrollingView"];
    objc_setAssociatedObject(self, &UIScrollViewInfiniteScrollingView,
                             infiniteScrollingView,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"UIScrollViewInfiniteScrollingView"];
}

- (SNTInfiniteScrollingView *)infiniteScrollingView{
    return objc_getAssociatedObject(self, &UIScrollViewInfiniteScrollingView);
}

- (void)setShowsInfiniteScrolling:(BOOL)showsInfiniteScrolling
{
    
    self.infiniteScrollingView.hidden = !showsInfiniteScrolling;
    
    if(!showsInfiniteScrolling) {
        if (self.infiniteScrollingView.isObserving) {
            [self removeObserver:self.infiniteScrollingView forKeyPath:@"contentOffset"];
            [self removeObserver:self.infiniteScrollingView forKeyPath:@"contentSize"];
            
            //[self.infiniteScrollingView resetScrollViewContentInset];
            self.infiniteScrollingView.isObserving = NO;
        }
    }
    else {
        if (!self.infiniteScrollingView.isObserving) {
            [self addObserver:self.infiniteScrollingView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self.infiniteScrollingView forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
            
            [self.infiniteScrollingView setScrollViewContentInsetForInfiniteScrolling];
            self.infiniteScrollingView.isObserving = YES;
            
            [self.infiniteScrollingView setNeedsLayout];
            
            self.infiniteScrollingView.frame = CGRectMake(0, self.contentSize.height, self.infiniteScrollingView.bounds.size.width, SNTInfiniteScrollingViewHeight);
        }
    }
    
   
}



- (BOOL)showsInfiniteScrolling {
    return !self.infiniteScrollingView.hidden;
}

@end


#pragma mark - SNTInfiniteScrollingView
@implementation SNTInfiniteScrollingView

// public properties
@synthesize infiniteScrollingHandler;

@synthesize state = _state;
@synthesize scrollView = _scrollView;
@synthesize arrow = _arrow;
@synthesize arrayRefreshDots = _arrayRefreshDots;

-(UIImageView *)pageImage
{
    UIImage *image = [UIImage imageNamed:SNTBottomPageImage];
    UIImageView *view = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - image.size.height , image.size.width, image.size.height)];
    view.image = image;
    /*
     float color = 230.0;
     view.backgroundColor = [UIColor colorWithRed:color/255.0 green:color/255.0 blue:color/255.0 alpha:1.0];
     */
    view.backgroundColor = [UIColor clearColor];
    [self createRefreshingDotsOnView:view];
    [self setClipsToBounds:NO];
    
    return view;
}

- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        
        [self addSubview:[self pageImage]];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.state = SNTInfiniteScrollingStateStopped;
        self.enabled = YES;
        self.viewForState = [NSMutableArray arrayWithObjects:@"", @"", @"", @"", nil];
        self.backgroundColor = [UIColor clearColor];
        float color = 230.0;
        self.backgroundColor = [UIColor colorWithRed:color/255.0 green:color/255.0 blue:color/255.0 alpha:1.0];
        
        //        self.layer.borderColor = [UIColor redColor].CGColor;
        //        self.layer.borderWidth = 1.0;
        self.backgroundColor = [UIColor clearColor];
        [self setClipsToBounds:NO];
        
        [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)  name:UIDeviceOrientationDidChangeNotification  object:nil];
        
//        [[NSNotificationCenter defaultCenter]removeObserver:self name:InternetNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(internetConnectionAvailableNotification:)  name:InternetNotification  object:nil];
    }
    
    return self;
}
//- (void)internetConnectionAvailableNotification:(NSNotification *)notification
//{
//    if (_prevNetState == [notification.object boolValue]) {
//        return;
//    }
//    _prevNetState = [notification.object boolValue];
//    if([notification.object boolValue]) {
//        [self.scrollView setShowsInfiniteScrolling:YES];
//    } else {
//        [self.scrollView setShowsInfiniteScrolling:NO];
//    }
//}
- (void)orientationChanged:(NSNotification *)notification{
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}
- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation {
    
   
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
//    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
//    {
        //load the portrait view
        self.arrow.center = CGPointMake(screenSize.width/2.0, self.arrow.center.y);
//    }
//    else if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
//    {
//        //load the landscape view
//        self.arrow.center = CGPointMake(screenSize.height/2.0, self.arrow.center.y);
//    }
    [self upDateDotPositionsWithXPos:self.arrow.center.x];
   
        
   
}

-(void)upDateDotPositionsWithXPos:(CGFloat )xPos
{
    float xCenter = xPos - floor(self.arrayRefreshDots.count/2.0)*SNTRefreshDotGap;
    float yCenter = SNTInfiniteScrollingViewHeight - SNTInfiniteScrollingViewHeight * 0.15;
    
    //    float width = self.frame.size.width;
    for (UIView *dot in self.arrayRefreshDots) {
        //        for (int i = 0; i < self.arrayRefreshDots.count; i++) {
        dot.center = CGPointMake(xCenter, yCenter);
        //            UIView *view = [self dotWithCenter:CGPointMake(xCenter, yCenter)];
        //            [self.arrayRefreshDots addObject:view];
        xCenter = xCenter + SNTRefreshDotGap;
        //            [v addSubview:view];
        //        }
    }
}


- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.superview && newSuperview == nil) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        if (scrollView.showsInfiniteScrolling) {
            if (self.isObserving) {
                [scrollView removeObserver:self forKeyPath:@"contentOffset"];
                [scrollView removeObserver:self forKeyPath:@"contentSize"];
                self.isObserving = NO;
            }
        }
    }
}

#pragma mark - Scroll View

- (void)resetScrollViewContentInset {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.bottom = self.originalBottomInset;
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInsetForInfiniteScrolling {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.bottom = self.originalBottomInset + SNTInfiniteScrollingViewHeight;
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset {
    /*[UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scrollView.contentInset = contentInset;
                     }
                     completion:NULL];
     */
    self.scrollView.contentInset = contentInset;
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if(APPDELEGATE.netOnLink == 0) {
        [self stopAnimatingWithNoUpdate];
        return;
    }
    
    if([keyPath isEqualToString:@"contentOffset"])
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    else if([keyPath isEqualToString:@"contentSize"]) {
        
        [self layoutSubviews];
        CGFloat yPos = self.scrollView.contentSize.height < self.scrollView.frame.size.height ? self.scrollView.frame.size.height : self.scrollView.contentSize.height;
        self.frame = CGRectMake(0,yPos, self.bounds.size.width, SNTInfiniteScrollingViewHeight);
    }
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    
    if(self.state != SNTInfiniteScrollingStateLoading && self.enabled) {
        CGFloat scrollViewContentHeight = self.scrollView.contentSize.height;
        CGFloat scrollOffsetThreshold = scrollViewContentHeight-self.scrollView.bounds.size.height;
        
        if(!self.scrollView.isDragging && self.state == SNTInfiniteScrollingStateTriggered)
            self.state = SNTInfiniteScrollingStateLoading;
        else if(contentOffset.y > scrollOffsetThreshold && self.state == SNTInfiniteScrollingStateStopped && self.scrollView.isDragging)
            self.state = SNTInfiniteScrollingStateTriggered;
        else if(contentOffset.y < scrollOffsetThreshold  && self.state != SNTInfiniteScrollingStateStopped)
            self.state = SNTInfiniteScrollingStateStopped;
    }
}

#pragma mark - Getters

- (SNTPullToRefreshArrow2 *)arrow {
    if(!_arrow) {
        UIImage *image = [UIImage imageNamed:SNTLoadingCircleImage];
		_arrow = [[SNTPullToRefreshArrow2 alloc]initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        _arrow.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0 - 5.0);
        _arrow.backgroundColor = [UIColor clearColor];
        _arrow.clipsToBounds = NO;
		[self addSubview:_arrow];
    }
    return _arrow;
}

//Mehtod for set frame at bottom
-(void)createRefreshingDotsOnView:(UIView *)v
{
    if(!self.arrayRefreshDots){
        self.arrayRefreshDots = [[NSMutableArray alloc]init];
    }else{
        [self.arrayRefreshDots removeAllObjects];
    }
    
    float width = self.frame.size.width;
    float xCenter = width/2.0 - floor(SNTRefreshDotCount/2.0)*SNTRefreshDotGap;
    float yCenter = SNTInfiniteScrollingViewHeight - SNTInfiniteScrollingViewHeight * 0.15;
    for (int i = 0; i < SNTRefreshDotCount; i++) {
        
        UIView *view = [self dotWithCenter:CGPointMake(xCenter, yCenter)];
        [self.arrayRefreshDots addObject:view];
        xCenter = xCenter + SNTRefreshDotGap;
        [v addSubview:view];
    }
}
-(UIView *)dotWithCenter:(CGPoint)center
{
    float width = 6.0;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, width)];
    view.layer.cornerRadius = width/2.0;
    view.layer.borderColor = [[[UIColor blackColor]colorWithAlphaComponent:0.5]CGColor];
    view.layer.borderWidth = 0.1;
    view.backgroundColor = DotColor;
    view.center = center;
    return view;
}

#pragma mark - Setters

- (void)setCustomView:(UIView *)view forState:(SNTInfiniteScrollingState)state {
    id viewPlaceholder = view;
    
    if(!viewPlaceholder)
        viewPlaceholder = @"";
    
    if(state == SNTInfiniteScrollingStateAll)
        [self.viewForState replaceObjectsInRange:NSMakeRange(0, 3) withObjectsFromArray:@[viewPlaceholder, viewPlaceholder, viewPlaceholder]];
    else
        [self.viewForState replaceObjectAtIndex:state withObject:viewPlaceholder];
    
    self.state = self.state;
}

#pragma mark -
- (void)triggerRefresh {
    self.state = SNTInfiniteScrollingStateTriggered;
    self.state = SNTInfiniteScrollingStateLoading;
}

- (void)startAnimating{
    self.state = SNTInfiniteScrollingStateLoading;
}

- (void)stopAnimating {
    if (self.scrollView.contentSize.height < self.scrollView.frame.size.height) {
        if (self.scrollView.pullToRefreshView.state == SNTPullToRefreshStateTriggered ||
            self.scrollView.pullToRefreshView.state == SNTPullToRefreshStateLoading) {
            return;
        }
    }
    _zeroUpdate = NO;
    self.state = SNTInfiniteScrollingStateStopped;
}
- (void)stopAnimatingWithNoUpdate {
    if (self.scrollView.contentSize.height < self.scrollView.frame.size.height) {
        if (self.scrollView.pullToRefreshView.state == SNTPullToRefreshStateTriggered ||
            self.scrollView.pullToRefreshView.state == SNTPullToRefreshStateLoading) {
            return;
        }
    }
    _zeroUpdate = YES;
//    self.state = SNTInfiniteScrollingStateStopped;
    self.state = SNTInfiniteScrollingStateEndOfPage;
}

- (void)setState:(SNTInfiniteScrollingState)newState {
    if (newState != SNTInfiniteScrollingStateEndOfPage) {
        if(_state == newState)
            return;
    }
    
    SNTInfiniteScrollingState previousState = _state;
    _state = newState;
    
    for(id otherView in self.viewForState) {
        if([otherView isKindOfClass:[UIView class]])
            [otherView removeFromSuperview];
    }
    
    id customView = [self.viewForState objectAtIndex:newState];
    BOOL hasCustomView = [customView isKindOfClass:[UIView class]];
    
    if(hasCustomView) {
        [self addSubview:customView];
        CGRect viewBounds = [customView bounds];
        CGPoint origin = CGPointMake(roundf((self.bounds.size.width-viewBounds.size.width)/2), roundf((self.bounds.size.height-viewBounds.size.height)/2));
        [customView setFrame:CGRectMake(origin.x, origin.y, viewBounds.size.width, viewBounds.size.height)];
    }
    else {
        
        switch (newState) {
            case SNTInfiniteScrollingStateStopped:
                [self setAnimating:NO];
                break;
                
            case SNTInfiniteScrollingStateTriggered:
                break;
                
            case SNTInfiniteScrollingStateLoading:
                if (self.scrollView.pullToRefreshView.state == SNTPullToRefreshStateTriggered ||
                    self.scrollView.pullToRefreshView.state == SNTPullToRefreshStateLoading) {
                    if (self.scrollView.pullToRefreshView.state == self.scrollView.infiniteScrollingView.state) {
                        return;
                    }
                }
                [self setAnimating:YES];
                break;
                
            case SNTInfiniteScrollingStateEndOfPage:
                [self setAnimating:NO];
                [self setStateWithEndofPage];
                break;
        }
    }
    
    if(previousState == SNTInfiniteScrollingStateTriggered && newState == SNTInfiniteScrollingStateLoading && self.infiniteScrollingHandler && self.enabled)
    {
        self.infiniteScrollingHandler();
    }
}

- (void)setStateWithEndofPage
{
    CGFloat yOffset = (self.scrollView.contentSize.height + SNTInfiniteScrollingViewHeight) > self.scrollView.frame.size.height ? (self.scrollView.contentOffset.y + SNTInfiniteScrollingViewHeight) : 0.0;
    [self.scrollView setContentOffset:CGPointMake(0, yOffset) animated:NO];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, (self.scrollView.contentSize.height - SNTInfiniteScrollingViewHeight));
}

-(void)setAnimating:(BOOL)flag
{
    if (flag) {
        [self setDotAnimation:NO];
        CABasicAnimation *rotation;
        rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotation.fromValue = [NSNumber numberWithFloat:0];
        rotation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
        rotation.duration = 1.0; // Speed
        rotation.repeatCount = HUGE_VALF; // Repeat forever. Can be a finite number.
        
        [self.arrow.layer addAnimation:rotation forKey:@"Spin"];
        [self setDotAnimation:YES];
    }
    else{
        
        //        if (self.scrollView.infiniteScrollingView.state != SNTInfiniteScrollingStateLoading) {
        //            return;
        //        }
        //        if (self.state != SNTInfiniteScrollingStateLoading) {
        //            return;
        //        }
        [self.arrow.layer removeAnimationForKey:@"Spin"];
        [self setDotAnimation:NO];
        if (_zeroUpdate) {
            NSLog(@"if");
            self.scrollView.showsInfiniteScrolling = NO;
            [UIView animateWithDuration:0.2f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y ) animated:NO];
                             }
                             completion:^(BOOL finished) {
                                 [self.scrollView.infiniteScrollingView setHidden:YES];
                                 [self.scrollView setShowsInfiniteScrolling:NO];
                             }];
        }else{
            NSLog(@"else");
            self.scrollView.showsInfiniteScrolling = YES;
            [UIView animateWithDuration:0.2f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y) animated:NO];
                             }
                             completion:^(BOOL finished) {
                                 [self.scrollView.infiniteScrollingView setHidden:NO];
                                 [self.scrollView setShowsInfiniteScrolling:YES];
                             }];
        }
        
        
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    
}

-(void)setDotAnimation:(BOOL)flag
{
    if (flag) {
        [self startDotAnimation];
    }else{
        if (timerDotAnimation) {
            [timerDotAnimation invalidate];
            timerDotAnimation = nil;
        }
    }
}

-(void)updateDot:(NSTimer *)timer
{
    if (DOT_INDEX < self.arrayRefreshDots.count) {
        UIView *view = (UIView *)[self.arrayRefreshDots objectAtIndex:DOT_INDEX];
        view.backgroundColor = DotColorFill;
        DOT_INDEX++;
    }else{
        [timer invalidate];
        timer = nil;
        [self startDotAnimation];
    }
}
-(void)startDotAnimation
{
    for (UIView *view in self.arrayRefreshDots) {
        view.backgroundColor = DotColor;
    }
    DOT_INDEX = 0;
    timerDotAnimation = [NSTimer scheduledTimerWithTimeInterval:SNTRefreshDotAnimDuration target:self selector:@selector(updateDot:) userInfo:timerDotAnimation repeats:YES];
    
}

@end


#pragma mark - SNTPullToRefreshArrow2

@implementation SNTPullToRefreshArrow2
@synthesize arrowColor;

-(UIImageView *)loadingCircle{
    
    UIImage *image = [UIImage imageNamed:SNTLoadingCircleImage];
    UIImageView *view = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    view.image = image;
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)drawRect:(CGRect)rect {
    
    UIView *view = [self loadingCircle];
    view.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    [self addSubview:view];
}

@end

