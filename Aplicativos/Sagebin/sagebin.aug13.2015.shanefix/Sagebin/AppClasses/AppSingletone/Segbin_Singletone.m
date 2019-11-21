//
//  Segbin_Singletone.m
//  Sagebin
//
//  
//  
//

#import "Segbin_Singletone.h"

#define K_STAR_TAG 756894

static Segbin_Singletone *_segbinSingletone = nil;

@implementation Segbin_Singletone


+(Segbin_Singletone*)sharedInstance
{
    @synchronized([Segbin_Singletone class])
    {
        if (!_segbinSingletone)
            _segbinSingletone = [[self alloc] init];
        return _segbinSingletone;
    }
    return nil;
}
+(id)alloc
{
    @synchronized([Segbin_Singletone class])
    {
        NSAssert(_segbinSingletone == nil, @"Attempted to allocate a second instance of a singleton.");
        _segbinSingletone = [super alloc];
        return _segbinSingletone;
    }
    return nil;
}
-(id)init
{
    if ((self=[super init]))
    {
        
    }
    return self;
}


#pragma MARK -
#pragma MARK - CREATE CONTROLLERS
-(UILabel *)createLabelWithFrame:(CGRect)frm withFont:(UIFont *)font withTextColor:(UIColor *)colorText withTextAlignment:(NSTextAlignment)textAlign withTag:(int)tag
{
    UILabel *lbl = [[UILabel alloc]initWithFrame:frm];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextColor:colorText];
    [lbl setFont:font];
    [lbl setTextAlignment:textAlign];
    [lbl setTag:tag];
    return lbl;
}

-(UIButton *)createBtnWithFrame:(CGRect)frm withTitle:(NSString *)title withImage:(UIImage *)imgBtn withTag:(int)tag
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:frm];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setImage:imgBtn forState:UIControlStateNormal];
    [btn setTag:tag];
    return btn;
}

-(UIButton *)createBtnWithFrame:(CGRect)frm withTitle:(NSString *)title withImage:(UIImage *)imgBtn withTag:(int)tag Font:(UIFont *)font BGColor:(UIColor *)bgColor
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:frm];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setImage:imgBtn forState:UIControlStateNormal];
    [btn setTag:tag];
    [btn.titleLabel setFont:font];
    [btn setBackgroundColor:bgColor];
    return btn;
}

-(CustomButton *)createCustomBtnWithFrame:(CGRect)frm withTitle:(NSString *)title withImage:(UIImage *)imgBtn withTag:(int)tag
{
    CustomButton *btn = [CustomButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:frm];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setImage:imgBtn forState:UIControlStateNormal];
    [btn setTag:tag];
    return btn;
}

-(CustomButton *)createCustomBtnWithFrame:(CGRect)frm withTitle:(NSString *)title withImage:(UIImage *)imgBtn withTag:(int)tag Font:(UIFont *)font BGColor:(UIColor *)bgColor
{
    CustomButton *btn = [CustomButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:frm];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setImage:imgBtn forState:UIControlStateNormal];
    [btn setTag:tag];
    [btn.titleLabel setFont:font];
    [btn setBackgroundColor:bgColor];
    return btn;
}

-(UITextField *)createTextFieldWithFrame:(CGRect)frame placeHolder:(NSString *)strPlaceholder font:(UIFont *)font textColor:(UIColor *)txtColor tag:(int)tag
{
    UITextField *txt = [[UITextField alloc]initWithFrame:frame];
    [txt setPlaceholder:strPlaceholder];
    [txt setFont:font];
    [txt setTextColor:txtColor];
    [txt setTag:tag];
    return txt;
}

-(UIView *)createViewWithFrame:(CGRect)frame bgColor:(UIColor *)bgColor tag:(int)tag alpha:(CGFloat)alpha
{
    UIView *view = [[UIView alloc]initWithFrame:frame];
    [view setBackgroundColor:bgColor];
    [view setTag:tag];
    [view setAlpha:alpha];
    return view;
}

-(UIScrollView *)createScrollViewWithFrame:(CGRect)frame bgColor:(UIColor *)bgColor tag:(int)tag delegate:(id)delegate
{
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:frame];
    [scrollView setBackgroundColor:bgColor];
    [scrollView setTag:tag];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setDelegate:delegate];
    return scrollView;
}

#pragma mark - Helper Methods
-(UIImage * )imageForStatus:(NSInteger )status
{
    if (status == USER_STATUS_OFFLINE)
    {
        return [UIImage imageNamed:@"friend_offline"];
    }
    else if (status == USER_STATUS_ONLINE)
    {
        return [UIImage imageNamed:@"friend_online"];
    }
    return nil;
}
-(CGSize)sizeForString:(NSString *)string fontType:(UIFont *)fonts
{
    // iOS7
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        CGRect rect = [string boundingRectWithSize:CGSizeMake(300, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:fonts
                                                                                                                                                                     forKey:NSFontAttributeName] context:nil];
        return rect.size;
    }
    
    // iOS6
    CGSize textSize = [string sizeWithFont:fonts
                         constrainedToSize:CGSizeMake(300, CGFLOAT_MAX)
                             lineBreakMode:NSLineBreakByWordWrapping];
    return textSize;
}

//===================================================================================

#pragma mark -
#pragma mark Add and Reuse star
-(void)reuseStart:(UIView *)view withYpostion:(CGFloat)yPOS withPoint:(CGFloat)point{
    
    int totalPoint = point *10;
    int div = 100 ;
    
    int TotalDisplayStar = totalPoint/div;
    int TotalYellowStar = TotalDisplayStar / 2;
    int WhileStar =TotalDisplayStar%2;
    if (WhileStar == 0) {
        int count = 0;
        for (int yStar =0 ; yStar <TotalYellowStar ; yStar++) {
            
            UIImageView *imageView = (UIImageView *)[view viewWithTag:K_STAR_TAG +count];
            [imageView setImage:[UIImage imageNamed:@"star_score"]];
            [imageView setFrame:CGRectMake(imageView.frame.origin.x, yPOS, imageView.frame.size.width, imageView.frame.size.height)];
            count ++;
        }
        for (int dStar= 0; dStar < (5-TotalYellowStar) ; dStar++) {
            UIImageView *imageView = (UIImageView *)[view viewWithTag:K_STAR_TAG +count];
            [imageView setImage:[UIImage imageNamed:@"star_score1"]];
            [imageView setFrame:CGRectMake(imageView.frame.origin.x, yPOS, imageView.frame.size.width, imageView.frame.size.height)];
            count ++;
            
            //count++;
        }
        
    }
    else
    {
        
        
        int count = 0;
        for (int yStar =0 ; yStar <TotalYellowStar ; yStar++)
        {
            UIImageView *imageView = (UIImageView *)[view viewWithTag:K_STAR_TAG +count];
            [imageView setImage:[UIImage imageNamed:@"star_score"]];
            [imageView setFrame:CGRectMake(imageView.frame.origin.x, yPOS, imageView.frame.size.width, imageView.frame.size.height)];
            count ++;
        }
        UIImageView *imageView = (UIImageView *)[view viewWithTag:K_STAR_TAG +count];
        [imageView setImage:[UIImage imageNamed:@"HelfStar"]];
        [imageView setFrame:CGRectMake(imageView.frame.origin.x, yPOS, imageView.frame.size.width, imageView.frame.size.height)];
        count ++;
        
        int reminStar = count;
        for (int dStar= 0; dStar < (5-reminStar) ; dStar++) {
            UIImageView *imageView =(UIImageView *)[view viewWithTag:K_STAR_TAG + count];
            [imageView setImage:[UIImage imageNamed:@"star_score1"]];
            [imageView setFrame:CGRectMake(imageView.frame.origin.x, yPOS, imageView.frame.size.width, imageView.frame.size.height)];
            count ++;
        }
        
    }
}

-(void)addStart:(UIView *)view withYpostion:(CGFloat)yPOS withPoint:(CGFloat)point{
    
    int totalPoint = point *10;
    int div = 100 ;
    
    int TotalDisplayStar = totalPoint/div;
    int TotalYellowStar = TotalDisplayStar / 2;
    int WhileStar =TotalDisplayStar%2;
    
    CGFloat Xpos = (iPad ?15 : 10);
    CGFloat GAP  = (iPad ? 5 : 3);
    CGFloat Height = (iPad ? 20 : 10);
    if (WhileStar == 0) {
        
        
        int count = 0;
        for (int yStar =0 ; yStar <TotalYellowStar ; yStar++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(Xpos, yPOS, Height, Height)];
            [imageView setImage:[UIImage imageNamed:@"star_score"]];
            [imageView setTag:K_STAR_TAG +count];
            [view addSubview:imageView];
            Xpos = Xpos +GAP + Height;
            count ++;
        }
        
        for (int dStar= 0; dStar < (5-TotalYellowStar) ; dStar++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(Xpos, yPOS, Height, Height)];
            [imageView setImage:[UIImage imageNamed:@"star_score1"]];
            [imageView setTag:K_STAR_TAG +count];
            [view addSubview:imageView];
            Xpos = Xpos+GAP + Height;
            count ++;
            
        }
        
        
    }
    else
    {
        int count = 0;
        for (int yStar =0 ; yStar <TotalYellowStar ; yStar++)
        {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(Xpos, yPOS, Height, Height)];
            [imageView setImage:[UIImage imageNamed:@"star_score"]];
            [imageView setTag:K_STAR_TAG +count];
            [view addSubview:imageView];
            Xpos = Xpos +GAP + Height;
            
            count ++;
        }
        
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(Xpos, yPOS, Height, Height)];
        [imageView setImage:[UIImage imageNamed:@"HelfStar"]];
        [imageView setTag:K_STAR_TAG +count];
        [view addSubview:imageView];
        Xpos = Xpos +GAP + Height;
        count ++;
        
        int reminStar = count;
        for (int dStar= 0; dStar < (5-reminStar) ; dStar++)
        {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(Xpos, yPOS, Height, Height)];
            [imageView setImage:[UIImage imageNamed:@"star_score1"]];
            [imageView setTag:K_STAR_TAG +count];
            [view addSubview:imageView];
            Xpos = Xpos +GAP + Height;
            count ++;
        }
    }
}

UIColor* colorWithHexString(NSString* hex)
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

-(void)setName:(NSString *)name withValue:(NSString *)value onBody:(NSMutableData *)body{
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",name] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)setName:(NSString *)name withFileName:(NSString *)fileName withValue:(NSData *)data onBody:(NSMutableData *)body{
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filetype=\"image/jpeg\"; filename=\"%@\"\r\n",name, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark - Loading View

-(void)addLoader
{
    
    UIImage *imageOuter = kLoaderImage;
    
    UIView *reusingView = [APPDELEGATE.window viewWithTag:kTagLoaderView];
    if(!reusingView)
    {
        reusingView = [SEGBIN_SINGLETONE_INSTANCE createViewWithFrame:CGRectMake(0, 0, imageOuter.size.width, imageOuter.size.width) bgColor:[UIColor clearColor] tag:kTagLoaderView alpha:1.0];
        reusingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        reusingView.center = CGPointMake(APPDELEGATE.window.frame.size.width/2.0, APPDELEGATE.window.frame.size.height/2.0);
        
    }    
    
    
    UIImageView *imageLoadingInner = [[UIImageView alloc] initWithFrame:CGRectMake((iPad?-40:-20), 0, (iPad?180:100), (iPad?92:51))];
    imageLoadingInner.backgroundColor = [UIColor clearColor];

    UIImage *frame1 = [UIImage imageNamed:@"1.png"];
    UIImage *frame2 = [UIImage imageNamed:@"2.png"];
    UIImage *frame3 = [UIImage imageNamed:@"3.png"];
    UIImage *frame4 = [UIImage imageNamed:@"4.png"];
    UIImage *frame5 = [UIImage imageNamed:@"5.png"];
    
   
    
    imageLoadingInner.animationImages = [NSArray arrayWithObjects:frame1, frame2, frame3, frame4, frame5,nil];
    
    imageLoadingInner.animationDuration = 1.5;
    imageLoadingInner.animationRepeatCount = 0;
    
     UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        reusingView.transform = CGAffineTransformMakeRotation(M_PI/0.5);
    }
    
    [reusingView addSubview:imageLoadingInner];
    [imageLoadingInner startAnimating];
    
    [APPDELEGATE.window addSubview:reusingView];
    
}

-(void)removeLoader
{
    UIView *view = [APPDELEGATE.window viewWithTag:kTagLoaderView];
    [view removeFromSuperview];
}

-(NSMutableArray *)getOfflineVideos
{
    NSMutableArray *arrOfflineVideos = [[NSMutableArray alloc]init];
    NSMutableArray *arrFinalRecords = [[NSMutableArray alloc]init];
    @try
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        if(userDefaults)
        {
            // --- add already downloaded videos
            
            //get all keys from defaults
            NSArray *keys = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys];
            
            //check all keys from defaults
            for(NSString *key in keys)
            {
                //if its offline object key
                if([key hasPrefix:@"ASIObjectIndex_"])
                {
                    //if there's an offline video
                    if ([userDefaults objectForKey:key]) {
                        NSDictionary *offlineMovie = [userDefaults objectForKey:key];
                        NSLog(@"offline-video: %@", offlineMovie);
                        if(offlineMovie) {
                            if([[offlineMovie valueForKey:keyOfflineMode] intValue] != 0) // Edited
                            {
                                [arrOfflineVideos addObject:offlineMovie];
                            }
                            else
                            {
                                [userDefaults removeObjectForKey:key];                                
                            }
                        }
                    }
                }
            }
            [userDefaults synchronize];
            
            NSMutableArray *temporaryDownloadedVideos = [NSMutableArray array];
            [temporaryDownloadedVideos addObjectsFromArray:[APPDELEGATE readFromListForKey:kVideosArray]];
            
            NSMutableArray *array = [NSMutableArray array];
            [array addObjectsFromArray:[APPDELEGATE readFromListForKey:kVideosArray]];
            
            // check for duplicate data
            if(arrOfflineVideos.count > 0)
            {
                for(int i=0;i<arrOfflineVideos.count;i++)
                {
                    id object = [arrOfflineVideos objectAtIndex:i];
                    if (![array containsObject:object]) {
                        [temporaryDownloadedVideos addObject:object];
                    }
                }                
            }
            [arrOfflineVideos removeAllObjects];
            [arrOfflineVideos addObjectsFromArray:temporaryDownloadedVideos];
            
            for(int i=0;i<arrOfflineVideos.count;i++)
            {
                NSDictionary *video = [arrOfflineVideos objectAtIndex:i];
                
                NSDateFormatter *df = [[NSDateFormatter alloc]init];
                [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *date1 = [df dateFromString:[video valueForKey:keyNewServerDate]];
                NSString *strCurrentDate = [df stringFromDate:[NSDate date]];
                NSDate *currentDate = [df dateFromString:strCurrentDate];
                NSTimeInterval dis = [currentDate timeIntervalSinceDate:date1];
                //double minutesInAnHour = 60;
                
                NSDate *date2 = [df dateFromString:[video valueForKey:keyNewExpiryDate]];
                NSTimeInterval distanceBetweenDates = [date2 timeIntervalSinceDate:date1];
                distanceBetweenDates = distanceBetweenDates - dis;
                //NSLog(@"distanceBetweenDates : %f", distanceBetweenDates);
                
                if(distanceBetweenDates < 0)
                {
                    [self removeOfflineMovieIfTimeOver:video];
                }
                else
                {
                    [arrFinalRecords addObject:video];
                }
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception while showing local/downloading offline movies! %@",[exception description]);
    }
    @finally {}
    
    return arrFinalRecords;
}

- (void) removeOfflineMovieIfTimeOver:(NSDictionary *)video
{
    @try
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if(userDefaults && video) {
            if([video valueForKey:keyId]) {
                NSString *objectKey = [APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]];
                if ([userDefaults objectForKey:objectKey]){
                    NSDictionary *offlineMovie = [userDefaults objectForKey:objectKey];
                    if(offlineMovie) {
                        
                        NSString *downloadPath = [APPDELEGATE getPathForDownloadedVideo:video];
                        if(downloadPath) {
                            NSFileManager *fileManager = [NSFileManager defaultManager];
                            if(fileManager) {
                                NSError *error = nil;
                                if([fileManager fileExistsAtPath:downloadPath]) {
                                    //removing local video file
                                    [fileManager removeItemAtPath:downloadPath error:&error];
                                    if(error) {
                                        NSLog(@"%@",[error localizedDescription]);
                                    }
                                    
                                    //removing video object from local // Edited On 31/01/2014
                                    [APPDELEGATE removeOldPrefrencesForKey:[APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]]];
                                }
                            }
                        }
                    }
                }
            }
        }
        [APPDELEGATE removeOldPrefrencesForKey:[APPDELEGATE getKeyForTag:[[video valueForKey:keyId] intValue]]];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception while deleting local video file! %@",[exception description]);
    }
    @finally {
    }
}

@end
