//
//  IMDImageView.h
//  Basic
//
//  Created by hyperlink Singh on 20/02/12.
//  Copyright (c) 2012 hyperlink Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMDGlobal.h"
#define kIMDDefaultCacheTimeValue 604800.0f // 7 days
#define kIMDDefaultTimeoutValue 10.0f

@class IMDImageView;
@protocol IMDImageViewDelegate<NSObject>
@optional

//When fail loading iamge with error then get error for url 
-(void)IMDImageView:(IMDImageView*)imageView didFailWithError:(NSError*)error withURL:(NSString*)strURL;

-(void)IMDImageView:(IMDImageView*)imageView didReceiveImage:(UIImage*)image withURL:(NSString*)strURL;


@end

@interface IMDImageView : UIImageView{
    @package
        id <IMDImageViewDelegate> _delegate;
        IMDIndicatorViewStyle _indicatorViewStyle;
        IMDProgressViewStyle _progressViewStyle;
        NSString *_userName;
        NSString *_password;
        BOOL _isAuthentication;
        BOOL _isProgressBar;
        double _expectedSize;
        double _currentDownloadSize;
        UIProgressView *_objProgress;
        UILabel *_lblProgress;
        NSString *_strUrl;
        int _count;
        NSURLConnection *_connection;
        BOOL _allowCaching;
        BOOL _progressiveLoading;
        int _tag1;
        UIColor *_loadingColor;
        NSMutableDictionary *_dicFileInfo;
        NSOperationQueue *_queue;
        NSInteger _qualityPercent; //it should be in percentage
        NSOperation *_prevOperation;
        NSFileHandle *_file;
        UIImage *__unsafe_unretained _originalImage;
}
@property (unsafe_unretained, nonatomic,readonly)UIImage *originalImage;
@property (nonatomic,assign)NSInteger qualityPercent;
@property (nonatomic,strong)UIColor *loadingColor; 
@property (nonatomic,readwrite)int tag1; //for another tag
@property (nonatomic,assign)BOOL progressiveLoading; //allow progressing loading
@property (nonatomic,assign)BOOL allowCaching; // for allow image caching
@property (nonatomic,strong)id <IMDImageViewDelegate> delegate;
-(void)setImageFromURL:(NSString*)URLString LoadingIndicatorType:(IMDIndicatorViewStyle)indicatorViewStyle withBorder:(BOOL)isBorder;
-(void)setImageFromURL:(NSString*)URLString Progressbarstyle:(IMDProgressViewStyle)progressViewStyle withBorder:(BOOL)isBorder;

-(void)setImageWithAuthenticationUrl:(NSString *)URLString withUserName:(NSString*)userName withPassword:(NSString*)password LoadingIndicatorType:(IMDIndicatorViewStyle)indicatorViewStyle withBorder:(BOOL)isBorder;

-(void)setImageWithAuthenticationUrl:(NSString *)URLString withUserName:(NSString*)userName withPassword:(NSString*)password Progressbarstyle:(IMDProgressViewStyle)progressViewStyle withBorder:(BOOL)isBorder;

-(void)addIndicator:(IMDIndicatorViewStyle)indicatorViewStyle withBorder:(BOOL)isBorder;
-(void)stopLoading;
-(void)cancelPreviousRequest;
-(UIImage*)getImage;

@end
