


//IMDRequest vCF1.0

//Updated IMDCrashReport for human readable crash log

#import <Foundation/Foundation.h>


#define SafeRelease(var_name) if (var_name != nil) var_name = nil;[var_name release];

//constant for GET method
#define GET @"GET"
//constant for POST method
#define POST @"POST"
//for image caching
#define kIMDCacheFolder @"IMDImageCaching"
#define kIMDPlistFileName @"IMDCaching.plist"
#define kIMDPrevPlist @"IMDPrevPlist"

//tag for indicator
#define indicatorTag 100

enum{
    IMDProgressViewStyleDefault,     // normal progress bar
    IMDProgressViewStyleBar,         // for use in a toolbar
    IMDProgressViewStyleNone,
};
typedef NSUInteger IMDProgressViewStyle;

enum {
    IMDIndicatorViewStyleWhiteLarge,
    IMDIndicatorViewStyleWhite,
    IMDIndicatorViewStyleGray,
    IMDIndicatorViewStyleNone,
};
typedef NSUInteger IMDIndicatorViewStyle;

@interface IMDGlobal : NSObject{
    int _maximumCachingCount; //set maximum count of caching image (default count is 300)
}
@property (nonatomic,assign)int maximumCachingCount;

+(IMDGlobal *)sharedGlobal;
-(NSString*)getDocumentFolderPath:(NSString*)strFolderName;
-(NSString*)getDocumentPath;
-(BOOL)writeDataOnPath:(NSString*)strPath withData:(NSData*)data;
-(BOOL)removeFileFromPath:(NSString*)strPath;
-(void)writeDataInPlist:(NSString*)strValue withKey:(NSString*)strKey toPath:(NSString*)strPath;
-(NSArray*)getAllFileNameFromPath:(NSString*)strPath;
-(NSString*)getUniqueFileName;
-(void)WriteImageInDocument:(NSDictionary*)dicData;
-(NSString*)getFilePath:(NSString*)strExtension andAddress:(NSString*)strAddress;

//remove imagecaching
-(BOOL)removeCachedImage;
-(void)removeLiveCachedImage;


@end



@interface UIImage(Extended)
+ (UIImage*)imageWithFilePath:(NSString *)path;
+(void)clearImageCache;

//For resize image
-(UIImage*)resizedImageToSize:(CGSize)dstSize;
-(UIImage*)resizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale;
@end

