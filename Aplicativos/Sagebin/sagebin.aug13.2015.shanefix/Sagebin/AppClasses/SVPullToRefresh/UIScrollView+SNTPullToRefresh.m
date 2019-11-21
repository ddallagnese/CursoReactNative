//
// UIScrollView+SNTPullToRefresh.m
//
//
//

#import "UIScrollView+SNTPullToRefresh.h"

#define fequal(a,b) (fabs((a) - (b)) < FLT_EPSILON)
#define fequalzero(a) (fabs(a) < FLT_EPSILON)

//static CGFloat const SNTPullToRefreshViewHeight = 85;
NSString *SNTPullToRefreshPageImage = @"up2.png";
static NSString *SNTPullToRefreshLoadingCircleImage = @"loader_refresh.png";
static NSString *SNTPullToRefreshTextFont = @"HelveticaNeue";
static CGFloat const SNTPullToRefreshTextSize = 13.0;

@interface SNTPullToRefreshArrow : UIView

@property (nonatomic, strong) UIColor *arrowColor;

@end


@interface SNTPullToRefreshView ()

@property (nonatomic, copy) void (^pullToRefreshActionHandler)(void);

@property (nonatomic, strong) SNTPullToRefreshArrow *arrow;
@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@property (nonatomic, strong, readwrite) UILabel *subtitleLabel;
@property (nonatomic, readwrite) SNTPullToRefreshState state;
@property (nonatomic, readwrite) SNTPullToRefreshPosition position;

@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) NSMutableArray *subtitles;
@property (nonatomic, strong) NSMutableArray *viewForState;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, readwrite) CGFloat originalTopInset;
@property (nonatomic, readwrite) CGFloat originalBottomInset;

@property (nonatomic, assign) BOOL wasTriggeredByUser;
@property (nonatomic, assign) BOOL showsPullToRefresh;
@property (nonatomic, assign) BOOL showsDateLabel;
@property(nonatomic, assign) BOOL isObserving;

- (void)resetScrollViewContentInset;
- (void)setScrollViewContentInsetForLoading;
- (void)setScrollViewContentInset:(UIEdgeInsets)insets;
- (void)rotateArrow:(float)degrees hide:(BOOL)hide;

@end



#pragma mark - UIScrollView (SNTPullToRefresh)
#import <objc/runtime.h>

static char UIScrollViewPullToRefreshView;

@implementation UIScrollView (SNTPullToRefresh)

@dynamic pullToRefreshView, showsPullToRefresh;


- (void)addPullToRefreshWithActionHandler:(void (^)(void))actionHandler position:(SNTPullToRefreshPosition)position {
    
    if(!self.pullToRefreshView) {
        CGFloat yOrigin;
        switch (position) {
            case SNTPullToRefreshPositionTop:
                yOrigin = - SNTPullToRefreshViewHeight;
                
            case SNTPullToRefreshPositionBottom:
                yOrigin = self.contentSize.height;
                break;
            default:
                return;
        }
        SNTPullToRefreshView *view = [[SNTPullToRefreshView alloc] initWithFrame:CGRectMake(0, yOrigin, self.bounds.size.width, SNTPullToRefreshViewHeight)];
        view.pullToRefreshActionHandler = actionHandler;
        view.scrollView = self;
        [self addSubview:view];
        
        view.originalTopInset = self.contentInset.top;
        view.originalBottomInset = self.contentInset.bottom;
        view.position = position;
        self.pullToRefreshView = view;
        self.showsPullToRefresh = YES;
        
//        view.layer.borderColor = [UIColor redColor].CGColor;
//        view.layer.borderWidth = 1.0;
    }
    
}

- (void)addPullToRefreshWithActionHandler:(void (^)(void))actionHandler {
    [self addPullToRefreshWithActionHandler:actionHandler position:SNTPullToRefreshPositionTop];
}

/**/
- (void)addPullToRefreshWithTopImageName:(NSString *)topImageName andActionHandler:(void (^)(void))actionHandler {
    SNTPullToRefreshPageImage = topImageName;
    [self addPullToRefreshWithActionHandler:actionHandler position:SNTPullToRefreshPositionTop];
}

/**/

- (void)triggerPullToRefresh {
    self.pullToRefreshView.state = SNTPullToRefreshStateTriggered;
    [self.pullToRefreshView startAnimating];
    
}
- (void)setPullToRefreshView:(SNTPullToRefreshView *)pullToRefreshView {
    [self willChangeValueForKey:@"SNTPullToRefreshView"];
    objc_setAssociatedObject(self, &UIScrollViewPullToRefreshView,
                             pullToRefreshView,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"SNTPullToRefreshView"];
}

- (SNTPullToRefreshView *)pullToRefreshView {
    return objc_getAssociatedObject(self, &UIScrollViewPullToRefreshView);
}

- (void)setShowsPullToRefresh:(BOOL)showsPullToRefresh {
    self.pullToRefreshView.hidden = !showsPullToRefresh;
    
    if(!showsPullToRefresh) {
        if (self.pullToRefreshView.isObserving) {
            [self removeObserver:self.pullToRefreshView forKeyPath:@"contentOffset"];
            [self removeObserver:self.pullToRefreshView forKeyPath:@"frame"];
            [self.pullToRefreshView resetScrollViewContentInset];
            self.pullToRefreshView.isObserving = NO;
        }
    }
    else {
        if (!self.pullToRefreshView.isObserving) {
            [self addObserver:self.pullToRefreshView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self.pullToRefreshView forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self.pullToRefreshView forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
            self.pullToRefreshView.isObserving = YES;
            
            CGFloat yOrigin = 0.0;
            switch (self.pullToRefreshView.position) {
                case SNTPullToRefreshPositionTop:
                    yOrigin = -SNTPullToRefreshViewHeight;
                    break;
                case SNTPullToRefreshPositionBottom:
                    yOrigin = self.contentSize.height;
                    break;
            }
            
            self.pullToRefreshView.frame = CGRectMake(0, yOrigin, self.bounds.size.width, SNTPullToRefreshViewHeight);
        }
    }
}

- (BOOL)showsPullToRefresh {
    return !self.pullToRefreshView.hidden;
}

@end

#pragma mark - SNTPullToRefresh
@implementation SNTPullToRefreshView

// public properties
@synthesize pullToRefreshActionHandler, textColor, lastUpdatedDate, dateFormatter, textShadowColor;

@synthesize state = _state;
@synthesize scrollView = _scrollView;
@synthesize showsPullToRefresh = _showsPullToRefresh;
@synthesize arrow = _arrow;
@synthesize titleLabel = _titleLabel;
@synthesize dateLabel = _dateLabel;


#pragma mark - Base Components

-(UIImageView *)pageImage
{
    UIImage *image = [UIImage imageNamed:SNTPullToRefreshPageImage];
    UIImageView *view = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - image.size.height, image.size.width, image.size.height)];
    view.image = image;
   // float color = 255.0;
    view.backgroundColor = [UIColor clearColor]/*[UIColor colorWithRed:color/255.0 green:color/255.0 blue:color/255.0 alpha:1.0]*/;
    //    return [view autorelease];
    return view;
}

- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        
        [self addSubview:[self pageImage]];
        
        // default styling values
       // float colorVal = 150.0;
        self.textColor = [UIColor whiteColor]/*[UIColor colorWithRed:colorVal/255.0 green:colorVal/255.0 blue:colorVal/255.0 alpha:1.0]*/;
      //  self.textShadowColor = [[UIColor blackColor]colorWithAlphaComponent:0.7];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.state = SNTPullToRefreshStateStopped;
        self.showsDateLabel = NO;
        
        self.titles = [NSMutableArray arrayWithObjects:NSLocalizedString(@"Pull to refresh...",),
                       NSLocalizedString(@"Release to refresh...",),
                       NSLocalizedString(@"Loading...",),
                       nil];
        
        self.subtitles = [NSMutableArray arrayWithObjects:@"", @"", @"", @"", nil];
        self.viewForState = [NSMutableArray arrayWithObjects:@"", @"", @"", @"", nil];
        self.wasTriggeredByUser = YES;
        
        //float color = 235.0;
        self.backgroundColor = [UIColor clearColor]/*[UIColor colorWithRed:color/255.0 green:color/255.0 blue:color/255.0 alpha:1.0]*/;
        
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.superview && newSuperview == nil) {
        //use self.superview, not self.scrollView. Why self.scrollView == nil here?
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        if (scrollView.showsPullToRefresh) {
            if (self.isObserving) {
                //If enter this branch, it is the moment just before "SNTPullToRefreshView's dealloc", so remove observer here
                [scrollView removeObserver:self forKeyPath:@"contentOffset"];
                [scrollView removeObserver:self forKeyPath:@"contentSize"];
                [scrollView removeObserver:self forKeyPath:@"frame"];
                self.isObserving = NO;
            }
        }
    }
}

- (void)layoutSubviews {
    
    for(id otherView in self.viewForState) {
        if([otherView isKindOfClass:[UIView class]])
            [otherView removeFromSuperview];
    }
    
    id customView = [self.viewForState objectAtIndex:self.state];
    BOOL hasCustomView = [customView isKindOfClass:[UIView class]];
    
    self.titleLabel.hidden = hasCustomView;
    self.subtitleLabel.hidden = hasCustomView;
    self.arrow.hidden = hasCustomView;
    
    if(hasCustomView) {
        [self addSubview:customView];
        CGRect viewBounds = [customView bounds];
        CGPoint origin = CGPointMake(roundf((self.bounds.size.width-viewBounds.size.width)/2), roundf((self.bounds.size.height-viewBounds.size.height)/2));
        [customView setFrame:CGRectMake(origin.x, origin.y, viewBounds.size.width, viewBounds.size.height)];
    }
    else {
        switch (self.state) {
            case SNTPullToRefreshStateStopped:
                self.arrow.alpha = 1;
                [self setAnimating:NO];
                switch (self.position) {
                    case SNTPullToRefreshPositionTop:
                        [self rotateArrow:0 hide:NO];
                        break;
                    case SNTPullToRefreshPositionBottom:
                        [self rotateArrow:(float)M_PI hide:NO];
                        break;
                }
                break;
                
            case SNTPullToRefreshStateTriggered:
                switch (self.position) {
                    case SNTPullToRefreshPositionTop:
                        [self rotateArrow:(float)M_PI hide:NO];
                        break;
                    case SNTPullToRefreshPositionBottom:
                        [self rotateArrow:0 hide:NO];
                        break;
                }
                break;
                
            case SNTPullToRefreshStateLoading:
                [self setAnimating:YES];
                switch (self.position) {
                    case SNTPullToRefreshPositionTop:
                        [self rotateArrow:0 hide:YES];
                        break;
                    case SNTPullToRefreshPositionBottom:
                        [self rotateArrow:(float)M_PI hide:YES];
                        break;
                }
                break;
        }
        self.titleLabel.text = [self.titles objectAtIndex:self.state];
    }
}

#pragma mark - Scroll View

- (void)resetScrollViewContentInset {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    switch (self.position) {
        case SNTPullToRefreshPositionTop:
            currentInsets.top = self.originalTopInset;
            break;
        case SNTPullToRefreshPositionBottom:
            currentInsets.bottom = self.originalBottomInset;
            currentInsets.top = self.originalTopInset;
            break;
    }
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInsetForLoading {
    CGFloat offset = MAX(self.scrollView.contentOffset.y * -1, 0);
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    switch (self.position) {
        case SNTPullToRefreshPositionTop:
            currentInsets.top = MIN(offset, self.originalTopInset + self.bounds.size.height);
            break;
        case SNTPullToRefreshPositionBottom:
            currentInsets.bottom = MIN(offset, self.originalBottomInset + self.bounds.size.height);
            break;
    }
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
    if([keyPath isEqualToString:@"contentOffset"])
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    else if([keyPath isEqualToString:@"contentSize"]) {
        [self layoutSubviews];
        
        CGFloat yOrigin = 0.0;
        switch (self.position) {
            case SNTPullToRefreshPositionTop:
                yOrigin = -SNTPullToRefreshViewHeight;
                break;
            case SNTPullToRefreshPositionBottom:
                yOrigin = MAX(self.scrollView.contentSize.height, self.scrollView.bounds.size.height);
                break;
        }
        self.frame = CGRectMake(0, yOrigin, self.bounds.size.width, SNTPullToRefreshViewHeight);
    }
    else if([keyPath isEqualToString:@"frame"])
        [self layoutSubviews];
    
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    
    if(APPDELEGATE.netOnLink == 0)
        return;
    
    if(self.state != SNTPullToRefreshStateLoading) {
        CGFloat scrollOffsetThreshold = 0.0;
        switch (self.position) {
            case SNTPullToRefreshPositionTop:
                scrollOffsetThreshold = self.frame.origin.y-self.originalTopInset;
                break;
            case SNTPullToRefreshPositionBottom:
                scrollOffsetThreshold = MAX(self.scrollView.contentSize.height - self.scrollView.bounds.size.height, 0.0f) + self.bounds.size.height + self.originalBottomInset;
                break;
        }
        
        if(!self.scrollView.isDragging && self.state == SNTPullToRefreshStateTriggered)
            self.state = SNTPullToRefreshStateLoading;
        else if(contentOffset.y < scrollOffsetThreshold && self.scrollView.isDragging && self.state == SNTPullToRefreshStateStopped && self.position == SNTPullToRefreshPositionTop)
            self.state = SNTPullToRefreshStateTriggered;
        else if(contentOffset.y >= scrollOffsetThreshold && self.state != SNTPullToRefreshStateStopped && self.position == SNTPullToRefreshPositionTop)
            self.state = SNTPullToRefreshStateStopped;
        else if(contentOffset.y > scrollOffsetThreshold && self.scrollView.isDragging && self.state == SNTPullToRefreshStateStopped && self.position == SNTPullToRefreshPositionBottom)
            self.state = SNTPullToRefreshStateTriggered;
        else if(contentOffset.y <= scrollOffsetThreshold && self.state != SNTPullToRefreshStateStopped && self.position == SNTPullToRefreshPositionBottom)
            self.state = SNTPullToRefreshStateStopped;
    } else {
        CGFloat offset;
        UIEdgeInsets contentInset;
        switch (self.position) {
            case SNTPullToRefreshPositionTop:
                offset = MAX(self.scrollView.contentOffset.y * -1, 0.0f);
                offset = MIN(offset, self.originalTopInset + self.bounds.size.height);
                contentInset = self.scrollView.contentInset;
                self.scrollView.contentInset = UIEdgeInsetsMake(offset, contentInset.left, contentInset.bottom, contentInset.right);
                break;
            case SNTPullToRefreshPositionBottom:
                if (self.scrollView.contentSize.height >= self.scrollView.bounds.size.height) {
                    offset = MAX(self.scrollView.contentSize.height - self.scrollView.bounds.size.height + self.bounds.size.height, 0.0f);
                    offset = MIN(offset, self.originalBottomInset + self.bounds.size.height);
                    contentInset = self.scrollView.contentInset;
                    self.scrollView.contentInset = UIEdgeInsetsMake(contentInset.top, contentInset.left, offset, contentInset.right);
                } else if (self.wasTriggeredByUser) {
                    offset = MIN(self.bounds.size.height, self.originalBottomInset + self.bounds.size.height);
                    contentInset = self.scrollView.contentInset;
                    self.scrollView.contentInset = UIEdgeInsetsMake(-offset, contentInset.left, contentInset.bottom, contentInset.right);
                }
                break;
        }
    }
}

#pragma mark - Getters

- (SNTPullToRefreshArrow *)arrow {
    if(!_arrow) {
        UIImage *image = [UIImage imageNamed:SNTPullToRefreshLoadingCircleImage];
		_arrow = [[SNTPullToRefreshArrow alloc]initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        _arrow.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0 - 10.0);
        _arrow.backgroundColor = [UIColor clearColor];
        _arrow.clipsToBounds = NO;
        [_arrow setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
		[self addSubview:_arrow];
    }
    return _arrow;
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 22)];
        _titleLabel.text = NSLocalizedString(@"Pull to refresh...",);
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = textColor;
        _titleLabel.shadowColor = textShadowColor;
        _titleLabel.shadowOffset = CGSizeMake(1, 1);
        _titleLabel.font = [UIFont fontWithName:SNTPullToRefreshTextFont size:SNTPullToRefreshTextSize];
        _titleLabel.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height - 10.0);
        [_titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if(!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 210, 20)];
        _subtitleLabel.font = [UIFont systemFontOfSize:12];
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.textColor = textColor;
        [self addSubview:_subtitleLabel];
    }
    return _subtitleLabel;
}

- (UILabel *)dateLabel {
    return self.showsDateLabel ? self.subtitleLabel : nil;
}

- (NSDateFormatter *)dateFormatter {
    if(!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		dateFormatter.locale = [NSLocale currentLocale];
    }
    return dateFormatter;
}

- (UIColor *)arrowColor {
	return self.arrow.arrowColor; // pass through
}

- (UIColor *)textColor {
    return self.titleLabel.textColor;
}
- (UIColor *)textShadowColor{
    return self.titleLabel.shadowColor;
}

#pragma mark - Setters

- (void)setArrowColor:(UIColor *)newArrowColor {
	self.arrow.arrowColor = newArrowColor; // pass through
	[self.arrow setNeedsDisplay];
}

- (void)setTitle:(NSString *)title forState:(SNTPullToRefreshState)state {
    if(!title)
        title = @"";
    
    if(state == SNTPullToRefreshStateAll)
        [self.titles replaceObjectsInRange:NSMakeRange(0, 3) withObjectsFromArray:@[title, title, title]];
    else
        [self.titles replaceObjectAtIndex:state withObject:title];
    
    [self setNeedsLayout];
}

- (void)setSubtitle:(NSString *)subtitle forState:(SNTPullToRefreshState)state {
    if(!subtitle)
        subtitle = @"";
    
    if(state == SNTPullToRefreshStateAll)
        [self.subtitles replaceObjectsInRange:NSMakeRange(0, 3) withObjectsFromArray:@[subtitle, subtitle, subtitle]];
    else
        [self.subtitles replaceObjectAtIndex:state withObject:subtitle];
    
    [self setNeedsLayout];
}

- (void)setCustomView:(UIView *)view forState:(SNTPullToRefreshState)state {
    id viewPlaceholder = view;
    
    if(!viewPlaceholder)
        viewPlaceholder = @"";
    
    if(state == SNTPullToRefreshStateAll)
        [self.viewForState replaceObjectsInRange:NSMakeRange(0, 3) withObjectsFromArray:@[viewPlaceholder, viewPlaceholder, viewPlaceholder]];
    else
        [self.viewForState replaceObjectAtIndex:state withObject:viewPlaceholder];
    
    [self setNeedsLayout];
}

- (void)setTextColor:(UIColor *)newTextColor {
    textColor = newTextColor;
    self.titleLabel.textColor = newTextColor;
	self.subtitleLabel.textColor = newTextColor;
}
- (void)setTextShadowColor:(UIColor *)newtextShadowColor{
    textShadowColor = newtextShadowColor;
    self.titleLabel.shadowColor = newtextShadowColor;
    self.subtitleLabel.shadowColor = newtextShadowColor;
}

- (void)setLastUpdatedDate:(NSDate *)newLastUpdatedDate {
    self.showsDateLabel = YES;
    self.dateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Last Updated: %@",), newLastUpdatedDate?[self.dateFormatter stringFromDate:newLastUpdatedDate]:NSLocalizedString(@"Never",)];
}

- (void)setDateFormatter:(NSDateFormatter *)newDateFormatter {
	dateFormatter = newDateFormatter;
    self.dateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Last Updated: %@",), self.lastUpdatedDate?[newDateFormatter stringFromDate:self.lastUpdatedDate]:NSLocalizedString(@"Never",)];
}

#pragma mark -

- (void)triggerRefresh {
    [self.scrollView triggerPullToRefresh];
}

- (void)startAnimating{
    switch (self.position) {
        case SNTPullToRefreshPositionTop:
            
            if(fequalzero(self.scrollView.contentOffset.y)) {
                [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -self.frame.size.height) animated:YES];
                self.wasTriggeredByUser = NO;
            }
            else
                self.wasTriggeredByUser = YES;
            
            break;
        case SNTPullToRefreshPositionBottom:
            
            if((fequalzero(self.scrollView.contentOffset.y) && self.scrollView.contentSize.height < self.scrollView.bounds.size.height)
               || fequal(self.scrollView.contentOffset.y, self.scrollView.contentSize.height - self.scrollView.bounds.size.height)) {
                [self.scrollView setContentOffset:(CGPoint){.y = MAX(self.scrollView.contentSize.height - self.scrollView.bounds.size.height, 0.0f) + self.frame.size.height} animated:YES];
                self.wasTriggeredByUser = NO;
            }
            else
                self.wasTriggeredByUser = YES;
            
            break;
            
    }
    
    self.state = SNTPullToRefreshStateLoading;
}

- (void)stopAnimating {
    self.state = SNTPullToRefreshStateStopped;
    
    if (self.scrollView.contentSize.height < self.scrollView.frame.size.height) {
        if (self.scrollView.infiniteScrollingView.state == SNTInfiniteScrollingStateLoading ||
            self.scrollView.infiniteScrollingView.state == SNTInfiniteScrollingStateTriggered) {
            return;
        }
    }
    switch (self.position) {
        case SNTPullToRefreshPositionTop:
            if(!self.wasTriggeredByUser && self.scrollView.contentOffset.y < -self.originalTopInset)
                [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -self.originalTopInset) animated:NO]; // YES
            break;
        case SNTPullToRefreshPositionBottom:
            if(!self.wasTriggeredByUser && self.scrollView.contentOffset.y < -self.originalTopInset)
                [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, self.scrollView.contentSize.height - self.scrollView.bounds.size.height + self.originalBottomInset) animated:YES];
            break;
    }
}

- (void)setState:(SNTPullToRefreshState)newState {
    
    if(_state == newState)
        return;
    
    SNTPullToRefreshState previousState = _state;
    _state = newState;
    
    [self setNeedsLayout];
    //    if (self.scrollView.infiniteScrollingView.state == SNTInfiniteScrollingStateTriggered ||
    //        self.scrollView.infiniteScrollingView.state == SNTInfiniteScrollingStateLoading)
    //    {
    //        if (self.scrollView.pullToRefreshView.state != self.scrollView.infiniteScrollingView.state) {
    //            return;
    //        }
    //    }
    switch (newState) {
        case SNTPullToRefreshStateStopped:
            [self resetScrollViewContentInset];
            self.wasTriggeredByUser = YES;
            break;
            
        case SNTPullToRefreshStateTriggered:
            
            break;
            
        case SNTPullToRefreshStateLoading:
            if (self.scrollView.infiniteScrollingView.state == SNTInfiniteScrollingStateTriggered ||
                self.scrollView.infiniteScrollingView.state == SNTInfiniteScrollingStateLoading)
            {
                if (self.scrollView.contentSize.height > self.scrollView.frame.size.height) {
                    if (self.scrollView.pullToRefreshView.state != self.scrollView.infiniteScrollingView.state) {
                        return;
                    }
                }
            }
            [self setScrollViewContentInsetForLoading];
            
            if(previousState == SNTPullToRefreshStateTriggered && pullToRefreshActionHandler)
                pullToRefreshActionHandler();
            
            break;
    }
}

- (void)rotateArrow:(float)degrees hide:(BOOL)hide {
    
    /*
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.arrow.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.arrow.layer.transform = CATransform3DMakeRotation(degrees, 0, 0, 1);
    } completion:NULL];
     */
    self.arrow.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.arrow.layer.transform = CATransform3DMakeRotation(degrees, 0, 0, 1);
}

-(void)setAnimating:(BOOL)flag
{
    if (flag) {
        CABasicAnimation *rotation;
        rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotation.fromValue = [NSNumber numberWithFloat:0];
        rotation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
        rotation.duration = 1.0; // Speed
        rotation.repeatCount = HUGE_VALF; // Repeat forever. Can be a finite number.
        
        [self.arrow.layer addAnimation:rotation forKey:@"Spin"];
        
    } else {
        [self.arrow.layer removeAnimationForKey:@"Spin"];
    }
}

@end


#pragma mark - SNTPullToRefreshArrow

@implementation SNTPullToRefreshArrow
@synthesize arrowColor;

-(UIImageView *)loadingCircle
{
    UIImage *image = [UIImage imageNamed:SNTPullToRefreshLoadingCircleImage];
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
