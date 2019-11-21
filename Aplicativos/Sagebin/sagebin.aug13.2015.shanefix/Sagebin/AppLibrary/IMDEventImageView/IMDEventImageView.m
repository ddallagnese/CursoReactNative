
#import "IMDEventImageView.h"
#import "FullyLoaded.h"

@implementation IMDEventImageView
@synthesize animationType;
@synthesize eventImageDelegate = _eventImageDelegate;
@synthesize tag1 = _tag1;
@synthesize placeholderImage = _placeholderImage;
static const float kDuration = 1.0;
static const float kAnimationChangeDuration = 2.0;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        
    }
    return self;
}

#pragma mark
#pragma mark - Set content mode type
-(void)setContentMode:(UIViewContentMode)contentMode
{
    [super setContentMode:contentMode];
    _contentModeType = contentMode;
}

-(void)setModeForImage:(UIViewContentMode)contentMode{
    [super setContentMode:contentMode];
}

#pragma mark
#pragma mark  - SET URL FOR IMAGE WITH PLACEHOLDER IMAGE
-(void)setImageWithURL:(NSString*)strURL placeholderImage:(UIImage*)placeholdImage {
    
    strCurrUrl =  strURL;       //Store current Url
//    NSLog(@"%s Strurl:%@",__PRETTY_FUNCTION__,strURL);

//    NSLog(@"Imageview Tag :%d",self.tag1);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
    
        UIImage *image = [[FullyLoadedOne sharedFullyLoaded] imageForURL:strURL];
        //    UIImage *image = [UIImage imageNamed:@"place-holder.png"];
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            @autoreleasepool {
                
                if (image)
                {
                    self.image = image;

                    [self receivedImage:image];
                    [self setModeForImage:_contentModeType];
                    
                    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
                    [NSURLCache setSharedURLCache:sharedCache];
//                    NSLog(@"%s got imgae",__PRETTY_FUNCTION__);
                    
                }
                else
                {
//                    NSLog(@"%s got url",__PRETTY_FUNCTION__);
                    if (placeholdImage) {
                        self.image = placeholdImage;//Set placeholder image to self(UIImageView)
                        
                        if (placeholdImage.size.width > self.frame.size.width || placeholdImage.size.height > self.frame.size.height) {
                            
                            [self setModeForImage:UIViewContentModeScaleAspectFill];
                        }
                        else
                        {
                            [self setModeForImage:UIViewContentModeCenter];
                        }
                    }
                    

//                    NSLog(@"Imageview Tag :%d",self.tag1);
                    [self requestForImage:strURL];
                }
            }
        });
    });
}

#pragma mark
#pragma mark - Pass array of Url in Album
-(void)setImagesArrayFromURL:(NSMutableArray*)arrStrURL withPlaceholderImage:(UIImage*)placeholdImage {
    
    if ([arrStrURL count] > 0) {
        
        if (!self.image) {
            if (placeholdImage) {
                self.image = placeholdImage;
            }
        }
        [timerAnim invalidate];
        timerAnim = nil;
        timerAnim = [NSTimer scheduledTimerWithTimeInterval:kAnimationChangeDuration target:self selector:@selector(setImageInAlbum:) userInfo:arrStrURL repeats:YES];
    }else{
        if (placeholdImage) {
            self.image = placeholdImage;
        }
    }
}
#pragma mark
#pragma mark -  Set image Url in Album Cover
-(void)setImageInAlbum:(NSTimer *)timer {
    
    @try {
        NSUInteger randomIndex = arc4random() % [timer.userInfo count];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            UIImage *image = [[FullyLoadedOne sharedFullyLoaded] imageForURL:[timer.userInfo objectAtIndex:randomIndex]];
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                if (image)
                {
                    [UIView transitionWithView:self
                                      duration:kDuration
                                       options: animationType|UIViewAnimationOptionAllowUserInteraction
                                    animations:^{
                                        
                                        [self setModeForImage:_contentModeType];
                                        self.image = image;
                                        [self performSelectorOnMainThread:@selector(receivedImage:) withObject:image waitUntilDone:NO];
                                    }
                                    completion:nil];
                }
                else
                {
                    [self requestForImage:[timer.userInfo objectAtIndex:randomIndex]];
                }
            });
        });
    }
    @catch (NSException *exception) {
        NSLog(@"%s Exception:%@",__PRETTY_FUNCTION__,exception);
    }
    @finally {
    }
}
#pragma mark - Stop Album Image Animation -
-(void)stopAnimation
{
    [[NSRunLoop currentRunLoop] cancelPerformSelectorsWithTarget:self];
    [[NSRunLoop mainRunLoop]cancelPerformSelectorsWithTarget:self];
    if ([timerAnim isValid]) {
        [timerAnim invalidate];
        timerAnim = nil;
    }
}
#pragma mark
#pragma mark - REQUEST FOR IMAGE URL
-(void)requestForImage:(NSString*)strURL{
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSURLRequest *request;
//    NSLog(@"Str Url :%@",strURL);
    NSString * newImageURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:newImageURL]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         UIImage *image = [UIImage imageWithData:data];
         
         if ([data length] > 0 && error == nil && image)  //If  success
         {
             [[FullyLoadedOne sharedFullyLoaded] setImage:image withKey:strURL];
             if ([strURL isEqualToString:strCurrUrl]) {
                 
                 //recive data
                 
                 dispatch_queue_t queue_ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                 dispatch_async(queue_, ^{
                     
                     UIImage *image = [[FullyLoadedOne sharedFullyLoaded] imageForURL:strURL];
                     
                     [self performSelectorOnMainThread:@selector(receivedImage:) withObject:image waitUntilDone:NO];
                     
                     [data writeToFile:[[NSUserDefaults standardUserDefaults] valueForKey:strURL] atomically:YES];
                     
                     NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
                     [NSURLCache setSharedURLCache:sharedCache];
                     
                     dispatch_sync(dispatch_get_main_queue(), ^{
                         [UIView transitionWithView:self
                                           duration:kDuration
                                            options: animationType|UIViewAnimationOptionAllowUserInteraction
                                         animations:^{
                                             self.image = image;
//                                             NSLog(@"Image set : %@",strURL);
                                         }
                                         completion:NULL];
                         [self setModeForImage:_contentModeType];
//                         NSLog(@"Imageview Tag :%d",self.tag1);
                     });
                 });
             }
             else if (([data length] == 0 || !image) && error == nil ){
                 //empty reply
                              NSLog(@"empty data");
             }
             else if (error != nil && error.code == kTimeout){//ERROR_CODE_TIMEOUT
                 //time out
                              NSLog(@"request time out");
             }
             else if (error != nil){
                 //error
                              NSLog(@"error occured");
             }
         }
     }];
}

#pragma mark
#pragma mark - REQUEST FOR IMAGE URL
-(void)requestForCropImage:(NSString*)strURL{
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSURLRequest *request;
    NSString * newImageURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:newImageURL]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         UIImage *image = [UIImage imageWithData:data];
         
         if ([data length] > 0 && error == nil && image)  //If  success
         {
             [[FullyLoadedOne sharedFullyLoaded] setImage:image withKey:strURL];
             if ([strURL isEqualToString:strCurrUrl])
             {
                 //recive data
                 dispatch_queue_t queue_ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                 dispatch_async(queue_, ^{
                     
                     UIImage *image = [[FullyLoadedOne sharedFullyLoaded] imageForURL:strURL];
                     
                     [self performSelectorOnMainThread:@selector(receivedImage:) withObject:image waitUntilDone:NO];
                     
                     [data writeToFile:[[NSUserDefaults standardUserDefaults] valueForKey:strURL] atomically:YES];
                 });
             }
             else if (([data length] == 0 || !image) && error == nil ){
                 //empty reply
                 //             NSLog(@"empty data");
             }
             else if (error != nil && error.code == kTimeout){//ERROR_CODE_TIMEOUT
                 //time out
                 //             NSLog(@"request time out");
             }
             else if (error != nil){
                 //error
                 //             NSLog(@"error occured");
             }
         }
     }];
}
#pragma mark
#pragma mark - Method will call from CropImage
-(void)setImageWithURLforCrop:(NSString*)strURL placeholderImage:(UIImage*)placeholdImage
{
    strCurrUrl =  strURL;       //Store current Url
    
    //    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    //    dispatch_async(queue, ^{
    
    UIImage *image = [[FullyLoadedOne sharedFullyLoaded] imageForURL:strURL];
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @autoreleasepool {
            if (image)
            {
                self.image = image;
                [self performSelectorOnMainThread:@selector(receivedImage:) withObject:image waitUntilDone:NO];
                [self setModeForImage:_contentModeType];
            }
            else
            {
                if (placeholdImage) {
                    self.image = placeholdImage;//Set placeholder image to self(UIImageView)
                    
                    if (placeholdImage.size.width > self.frame.size.width || placeholdImage.size.height > self.frame.size.height) {
                        
                        [self setModeForImage:UIViewContentModeScaleAspectFill];
                    }
                    else
                    {
                        [self setModeForImage:UIViewContentModeCenter];
                    }
                }
                
                [self requestForCropImage:strURL];
            }
            
        }
        
    });
    
}
#pragma mark
#pragma mark - TOUCH DELEGATE METHOD
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 2) {
        //This will cancel the singleTap action
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
    
    if ([touch view] == self)
    {
        if ([_eventImageDelegate respondsToSelector:@selector(eventImageView:didSelectWithURL:)]) {
            
            [_eventImageDelegate eventImageView:self didSelectWithURL:strCurrUrl];
        }
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    NSUInteger numTaps = [[touches anyObject] tapCount];
//    float delay = 0.2;
//    
//    
//    
//    if ([touch view] == self && numTaps == 1)
//    {
//        if (numTaps < 2)
//        {
//            [self performSelector:@selector(handleSingleTap) withObject:nil afterDelay:delay ];
//            [self.nextResponder touchesEnded:touches withEvent:event];
//        }
//        else if(numTaps == 2)
//        {
//            [NSObject cancelPreviousPerformRequestsWithTarget:self];
//            [self performSelector:@selector(handleDoubleTap) withObject:nil afterDelay:delay ];
//        }
//    }
//}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSUInteger numTaps = [[touches anyObject] tapCount];
    float delay = 0.2;

        if (numTaps < 2)
        {
            [self performSelector:@selector(handleSingleTap) withObject:nil afterDelay:delay];
            [self.nextResponder touchesEnded:touches withEvent:event];
        }
        else if(numTaps == 2)
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [self performSelector:@selector(handleDoubleTap) withObject:nil afterDelay:delay];
        }
    
}
-(void)handleSingleTap{
    if ([_eventImageDelegate respondsToSelector:@selector(eventImageView:didSelectEndWithURL:withTapCount:)]) {
        
        [_eventImageDelegate eventImageView:self didSelectEndWithURL:strCurrUrl withTapCount:1];
    }
}

-(void)handleDoubleTap{
    if ([_eventImageDelegate respondsToSelector:@selector(eventImageView:didSelectEndWithURL:withTapCount:)]) {
        
        [_eventImageDelegate eventImageView:self didSelectEndWithURL:strCurrUrl withTapCount:2];
    }
}

-(void)receivedImage:(UIImage *)image {
    
    if ([_eventImageDelegate respondsToSelector:@selector(eventImageView:didReceiveImage:withURL:)]) {
        
        [_eventImageDelegate eventImageView:self didReceiveImage:image withURL:strCurrUrl];
    }
}
-(void)dealloc
{
    if ([timerAnim isValid])
    {
        [timerAnim invalidate];
        timerAnim = nil;
    }
    id __weak localdelegate = self.eventImageDelegate;
    self.eventImageDelegate = nil;
    localdelegate  = nil;
}
@end
