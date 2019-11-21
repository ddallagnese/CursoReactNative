#define kTagViewDatasource 35000;

#import <Foundation/Foundation.h>



//constant string for attribute, get attribute data from Xml parsing with kAttributes key
extern NSString * const kAttributes;

//if use notification then get tag from userinfo dictionray with key kTag
extern NSString * const kTag;
//if use notification then get ResponseTime from userinfo dictionray with key kResponseTime
extern NSString * const kResponseTime;

//Get Notification when parsing start
extern  NSString * const NSStartParsingResponseNotification;
//Get Notification when parsing end
extern	NSString * const NSEndParsingResponseNotification;

@class IMDHTTPRequest;
@protocol IMDHTTPRequestDelegate<NSObject>
@optional

//When fail parssing with error then get error for url tag
-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didFailWithError:(NSError*)error withRefrenceObject:(NSObject*)object withTag:(int)tag;
//when success parssing then get nsdata and NSObject (NSArray,NSMutableDictionary,NSString) with url tag
-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didSuccessWithItems:(NSObject*)items withData:(NSData*)data withRefrenceObject:(NSObject*)object withTag:(int)tag;

//When fail parssing with error then get error for url tag
-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didFailWithError:(NSError*)error withTag:(int)tag;
//when success parssing then get nsdata and NSObject (NSArray,NSMutableDictionary,NSString) with url tag
-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didSuccessWithItems:(NSObject*)items withData:(NSData*)data withTag:(int)tag;
//when get response form url for particular tag
-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didGetResponse:(NSHTTPURLResponse*)response withTag:(int)tag;
//when get response of data length
-(void)IMDHTTPRequest:(IMDHTTPRequest*)request didReceiveDataLength:(CGFloat)dataLenght withExpectedLength:(CGFloat)expLength withTag:(int)tag;
@end


@protocol IMDHTTPRequestDataSource<NSObject>

@optional
//Called when the send any request with url then return loading screen and u can get text for set text with particular object
-(UIView *)IMDHTTPRequest:(IMDHTTPRequest*)request viewForLoading:(UIView *)reusingView withLoadingText:(NSString*)loadingText;
@end

@interface IMDHTTPRequest : NSObject {
    id <IMDHTTPRequestDelegate> _webDelegate;
	__unsafe_unretained id <IMDHTTPRequestDataSource> _webDataSource;
	NSArray *_arrIgnoreTags;
	BOOL _needsProgressBar;
	
	NSString *_startResponseTime;
	BOOL _bExistsDatasource;
	NSMutableDictionary *_dicData;
	UIView *_loadingObj;
	UIImageView *_progressStrip;
	int _checkLoading;
	BOOL _flagLoading;
	UIProgressView *_objProgress;
	UILabel *_lblLoading;
	NSMutableDictionary *_dicAllConection;
	double _expectedSize;
	double _currentDownloadSize;
	CGFloat _expectedTime;
	NSString *_strTimeUnit;
	BOOL _isAuthentication;
	NSString *_userName;
	NSString *_password;
	NSString *_loadingText;
    NSObject *_refrenceObject;
    
    NSMutableDictionary *_dicRequest;
    NSStringEncoding _encoding;
    
    BOOL _isSetDataSource;
    BOOL _isAllowRefresh;
	
}
@property (nonatomic,assign) BOOL isAllowRefresh;
@property (nonatomic,strong) NSObject *refrenceObject;
@property (nonatomic,strong) id <IMDHTTPRequestDelegate> webDelegate;
@property (nonatomic,assign) id <IMDHTTPRequestDataSource> webDataSource;
@property (nonatomic,readwrite) BOOL needsProgressBar;
@property (nonatomic,strong) NSArray *arrIgnoreTags;

//use this function u have confuison related object array or dictionary then get data in array
-(NSMutableArray *)getMutableArrayFromObject:(NSObject *)object;

//get current running request
+(IMDHTTPRequest *)currentRequest;
//check request is running or not
-(BOOL)isRunningRequest;
//stop all request
-(void)stopRequest;
//for get data with asynchronous Reqest (in background thread)
-(void)startAsynchronousRequest;
//for get data with synchronous Reqest (in main thread)
-(void)startSynchronousRequest;
//+(id)sendSynchronousRequest:(NSData**)responseData withUrlResponse:(NSURLResponse**)urlResponse withError:(NSError**)error;
//set loading text and get text in datasource method for display in loading view
-(void)setLoadingText:(NSString*)loadingText;

//send request with AuthenticationURL
-(void)requestWithAuthenticationURL:(NSString*)URLString withParaMeter:(NSString*)URLParameter withMethod:(NSString*)methodName withUserName:(NSString*)userName withPassword:(NSString*)password withTag:(int)tag;
//send request with soap message url with POST method
-(void)requestWithURL:(NSString*)URLString withSoapMsg:(NSString*)soapMsg withSoapAction:(NSString*)soapAction withTag:(int)tag;
//send request with parameterized url with any method
-(void)requestWithURL:(NSString*)URLString withParaMeter:(NSString*)URLParameter withMethod:(NSString*)methodName withTag:(int)tag;
//send request with custom NSURLRequest
-(void)requestWithURLRequest:(NSURLRequest*)request withTag:(int)tag;

//send request with url with any GET get method
-(void)requestWithURL:(NSString*)URLString withTag:(int)tag;
//send request with url with any GET get method with object
-(void)requestWithURL:(NSString*)URLString withObject:(NSObject*)object withTag:(int)tag;
//send request with local file parsing
-(void)requestWithLocalPath:(NSString*)filePath withTag:(int)tag;
//set encoding
//please refer this url for learn about encoading type http://samplecodebank.blogspot.in/2011/05/nsstringencoding-table.html
-(void)setEncoding:(NSStringEncoding)encoading;

//undocument
+(void)cancelRequest:(id)object;
+(void)cancelRequest:(id)object withTag:(int)tag;
+(NSMutableDictionary*)getAllRunningRequest;


//for init object
-(id)init;
//for init with delegate
-(id)initWithDelegate:(id)delegate;
//for init with datasource
-(id)initWithDatasource:(id)datasource;
//for init with delegate and datasource
-(id)initWithDelegate:(id)delegate andDatasource:(id)datasource;

//private method
-(NSObject*)startParsingWithSynchronious:(NSMutableData *)objData withReturningError:(NSError**)error;
@end

//get notication when receive any error with loading image and get error in userInfo for key "error"
extern NSString * const NSErrorNotification;

@interface UIImageView(LoadImageFromUrl)
//load any image with AsynchronousRequest with image url, also include border with image only loading time
-(id)initWithFrame:(CGRect)frame withUrl:(NSString *)URLString withBorder:(BOOL)isBorder;
//load any image with AsynchronousRequest with Authentication image url, also include border with image only loading time
-(id)initWithFrame:(CGRect)frame withAuthenticationUrl:(NSString *)URLString withUserName:(NSString*)userName withPassword:(NSString*)password withBorder:(BOOL)isBorder;

@end

@interface NSString (URLEncode)
//encode string for special charecter 
-(NSString *)urlEncode;
@end

@interface NSObject(Synchronous)
//get response with Synchronousrequest for soap message url data comes with POST method
+(id)requestWithURL:(NSString*)URLString withSoapMsg:(NSString*)soapMsg withSoapAction:(NSString*)soapAction withReturnningError:(NSError**)error;
//get response with Synchronousrequest for parameterized url 
+(id)requestWithURL:(NSString*)URLString withParaMeter:(NSString*)URLParameter withMethod:(NSString*)methodName withReturnningError:(NSError**)error;
//get response with Synchronousrequest for url data comes with GET method
+(id)requestWithURL:(NSString*)URLString withReturnningError:(NSError**)error;
//get response with Synchronousrequest with local file parsing
+(id)requestWithLocalPath:(NSString*)filePath withReturnningError:(NSError**)error;
@end




