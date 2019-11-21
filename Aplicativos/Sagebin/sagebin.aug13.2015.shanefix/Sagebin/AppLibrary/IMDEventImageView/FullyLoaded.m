
#import "FullyLoaded.h"
#import "SynthesizeSingleton.h"

#define MAXIMUM_CACHED_ITEMS 1000

@interface FullyLoadedOne()


@end
static FullyLoadedOne  *sharedInstance;
static __strong NSMutableDictionary *imageCache;
@implementation FullyLoadedOne

//SYNTHESIZE_SINGLETON_FOR_CLASS(FullyLoaded);

- (void)dealloc {
}

+ (FullyLoadedOne *)sharedFullyLoaded
{
    @synchronized(self)
    {
        if (sharedInstance == NULL)
        {
            sharedInstance = [[FullyLoadedOne alloc] init];
        }
        return sharedInstance;
    }
}

- (id)init {
    self = [super init];
	if (self) {
        imageCache = [[NSMutableDictionary alloc] init];
	}
	return self;
}
-(void)removeCachedImageForURL :(NSString*)imageURL
{
    [imageCache removeObjectForKey:imageURL];
    NSString *strImagePath = [self pathForImageURL:imageURL];
    [[NSFileManager defaultManager] removeItemAtPath:strImagePath error:nil];
}
- (void)emptyCache {
	NSLog(@"Emptying Cache");
    
    @synchronized(imageCache)
    {
        if ([imageCache count] > 0) {
            [imageCache removeAllObjects];
        }
    }
}
- (void) removeAllCacheDownloads {
    NSLog(@"deleting all cache downloads");
    NSString * cacheFolderPath = [[self pathForImageURL:@"http://a.cn/b.jpg"] stringByDeletingLastPathComponent];
    [[NSFileManager defaultManager] removeItemAtPath:cacheFolderPath error:nil];
}
-(void)setImage:(UIImage*)image withKey:(NSString*)strKey{
    [imageCache setValue:image forKey:strKey];
}
- (UIImage*) imageForURL:(NSString*)imageURL
{
    @try {
        if (imageURL.length == 0){
            return nil;
        }
        UIImage *image = nil;
        if ((image = [imageCache objectForKey:imageURL])) {
            return image;
        }
        else if ((image = [UIImage imageWithContentsOfFile:[self pathForImageURL:imageURL]]))
        {
            if ([imageCache count] > MAXIMUM_CACHED_ITEMS)
            {
                [self emptyCache];
            }
            if (image)
            {
                [imageCache setValue:image forKey:imageURL];
            }
            return image;
        }
        return nil;
    }
    @catch (NSException *exception) {
        NSLog(@"%s Exception:%@",__PRETTY_FUNCTION__,exception);
        
    }
    @finally {
    }
}
- (NSString*) pathForImageURL:(NSString*)imageURL
{
    if ([imageURL hasPrefix:@"http://"] || [imageURL hasPrefix:@"https://"] || [imageURL hasPrefix:@"ftp://"]) {
        
        [[NSUserDefaults standardUserDefaults] setValue:[[self class] tmpFilePathForResourceAtURL:imageURL] forKey:imageURL];
        return [[self class] tmpFilePathForResourceAtURL:imageURL];
    }
    return imageURL;
}
/////////////////////////////////////////////////
// storage related

+ (BOOL) fileExistsForResourceAtURL:(NSString*)url
{
    NSString * localFile = [self filePathForResourceAtURL:url];
    return [[NSFileManager defaultManager] fileExistsAtPath:localFile];
}

+ (BOOL) tmpFileExistsForResourceAtURL:(NSString*)url
{
    NSString * localFile = [self tmpFilePathForResourceAtURL:url];
    return [[NSFileManager defaultManager] fileExistsAtPath:localFile];
}
+ (NSString*) filePathForStorage
{
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/data"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return  path;
}

+ (NSString*) filePathForTemporaryStorage {
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/data"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return  path;
}

+ (NSString*) fileNameForResourceAtURL:(NSString*)url
{
    NSString * fileName = url;
    if ([url hasPrefix:@"http://"])
    {
        fileName = [url substringFromIndex:[@"http://" length]];
    }
    else if ([url hasPrefix:@"https://"])
    {
        fileName = [url substringFromIndex:[@"https://" length]];
    }
    fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"__"];
    return fileName;
}

+ (NSString*) filePathForResourceAtURL:(NSString*)url
{
    NSString * fileName = [self fileNameForResourceAtURL:url];
    NSString * path = [self filePathForStorage];
    return [path stringByAppendingPathComponent:fileName];
}

+ (NSString*) tmpFilePathForResourceAtURL:(NSString*)url
{
    NSString * fileName = [self fileNameForResourceAtURL:url];
    NSString * path = [self filePathForTemporaryStorage];
    return [path stringByAppendingPathComponent:fileName];
}

@end
