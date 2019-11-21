/*
 
 IMDEventImageView Documentation
 ===============================
 
 1)By Default content mode is Center , you can change from outside the class.
 2)By Default background color is grayColor.
 3)By Default userInteractionEnabled is YES.
 
 */

#import <UIKit/UIKit.h>
//#import "ImageLoading.h"

enum code {
    kTimeout = 2111
};

@protocol IMDEventImageDelegate;

@interface IMDEventImageView : UIImageView <NSURLConnectionDataDelegate,NSURLConnectionDelegate>//,ImageLoadingDelegate> {
{
    //Store current url
    
    NSString *strCurrUrl;
    //=================
    
    //Self Delegate
    
    id <IMDEventImageDelegate> _eventImageDelegate;
    //=================
    UIImage *_placeholderImage;
    int _tag1;
    UIViewContentMode _contentModeType;
    NSTimer *timerAnim;
    
}
@property (nonatomic,strong)UIImage *placeholderImage;
@property (nonatomic,readwrite)int tag1;

//Animation type given from outside
@property (nonatomic,readwrite)UIViewAnimationOptions animationType;

//Imageview delegate protocol
@property (nonatomic , strong)id <IMDEventImageDelegate> eventImageDelegate;

//Method for setimagefrom url
-(void)setImageWithURL:(NSString*)strURL placeholderImage:(UIImage*)placeholdImage;

//Method for setImagefrom url from crop view
-(void)setImageWithURLforCrop:(NSString*)strURL placeholderImage:(UIImage*)placeholdImage;

//Method for set array of images of url
-(void)setImagesArrayFromURL:(NSMutableArray*)arrStrURL withPlaceholderImage:(UIImage*)placeholdImage;

//Method for set image in Album cover page
-(void)setImageInAlbum:(NSTimer *)timer;

//Method for , if image not in cache
-(void)requestForImage:(NSString*)strURL;

//Received image on main thread
-(void)receivedImage:(UIImage *)image;

//This is for stop album image animation
-(void)stopAnimation;
@end

//Delegate protocol
@protocol IMDEventImageDelegate <NSObject>
@optional
//Imageview didselect delegate method
-(void)eventImageView:(IMDEventImageView *)imageView didSelectWithURL:(NSString *)url;
-(void)eventImageView:(IMDEventImageView *)imageView didSelectEndWithURL:(NSString *)url withTapCount:(int)tapCount;
//Did received image method
-(void)eventImageView:(IMDEventImageView *)imageView didReceiveImage:(UIImage*)image withURL:(NSString*)strURL;
-(void)setContentMode:(UIViewContentMode)contentModeType;
@end
