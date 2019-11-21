//
//  IMDCellButton.h
//  ShowandTell
//
//  Created by Jignesh Brahmkhatri on 26/01/13.
//  Copyright (c) 2013 Jignesh Brahmkhatri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMDGlobal.h"

#define RESIZE_FORMAT   @"%@_resized"
#define DATA_FORMAT     @"%@_data"
#define CONNECTIONKEY   @"%@_connection"
#define CONNECTION_FORMAT   @"%p"
#define PROCESSING_FORMAT   @"%@_processing"
#define DATA_COUNT_FORMAT   @"%@_data_count"

#define UPDATE_PROGRESS_TIME 5
#define TIME_OUT_INTERVAL 60.0f
@protocol IMDCellButtonDelegate;

@interface IMDCellButton : UIButton{
    UIActivityIndicatorView *_indicator;
    BOOL _allowCaching;
    BOOL _progressiveLoading;
    int _qualityPercent;
    BOOL _IsBackgroundImage;
    UIControlState _controlState;
    NSString *_strCurrentURL;
    __unsafe_unretained UIColor *_loadingColor;
    UIView *_loadingView;
    __unsafe_unretained id<IMDCellButtonDelegate>_delegate;
    
    UIImage *_originalBgImage;
    UIImage *_originalImage;
    int _tag1;
    BOOL _isAllState;
    NSObject *_refrenceObject;
    UIImage *_placeholderImage;
    UIViewAnimationOptions _animationType;
    BOOL _isDrawImage;
}
@property (nonatomic,assign)BOOL isDrawImage;
@property (nonatomic, readwrite)UIViewAnimationOptions animationType;
@property (nonatomic,strong) UIImage *placeholderImage;
@property (nonatomic,retain)NSObject *refrenceObject;
@property (nonatomic,assign) int tag1;
@property(nonatomic,assign)BOOL allowCaching;
@property(nonatomic, assign)BOOL progressiveLoading;
@property(nonatomic, readwrite) int qualityPercent;
@property (nonatomic,assign) UIColor *loadingColor;
@property (nonatomic,assign)id<IMDCellButtonDelegate>delegate;
@property(nonatomic, readonly) UIImage *originalBgImage;
@property(nonatomic, readonly) UIImage *originalImage;

-(void)setBackgroundImageFromURL:(NSString*)URLString LoadingIndicatorType:(IMDIndicatorViewStyle)indicatorViewStyle forState:(UIControlState)state withBorder:(BOOL)isBorder;
-(void)setBackgroundImageFromURLForAllState:(NSString*)URLString LoadingIndicatorType:(IMDIndicatorViewStyle)indicatorViewStyle withBorder:(BOOL)isBorder;
-(void)setImageFromURL:(NSString*)URLString LoadingIndicatorType:(IMDIndicatorViewStyle)indicatorViewStyle forState:(UIControlState)state withBorder:(BOOL)isBorder;
-(void)setImageFromURLForAllState:(NSString*)URLString LoadingIndicatorType:(IMDIndicatorViewStyle)indicatorViewStyle withBorder:(BOOL)isBorder;
+(void)setCatchImageForURL:(NSString*)strURL withImage:(UIImage*)image;
+(void)removeImageCaching;
+(void)removeCachedImageForURL:(NSString *)strURL;
-(void)stopLoading;
@end

@protocol IMDCellButtonDelegate<NSObject>
@optional

//When fail loading iamge with error then get error for url
-(void)IMDCellButton:(IMDCellButton*)button didFailWithError:(NSError*)error withURL:(NSString*)strURL;
-(void)IMDCellButton:(IMDCellButton*)button didReceiveImage:(UIImage*)image withURL:(NSString*)strURL;

@end
