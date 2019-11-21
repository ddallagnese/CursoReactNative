

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <QuartzCore/QuartzCore.h>
#define DEG2RAD(degrees) (degrees * 0.01745327) // degrees * pi over 180
@class IMDDBRequest;
@protocol DBActionDelegate<NSObject>
@optional

//Called when the database send any error
-(void)IMDDBRequest:(IMDDBRequest*)request didFailWithError:(NSError*)error withTag:(int)tag;
//Called when the select statement execute then success then return array from database  with tag
-(void)IMDDBRequestWithSelectStatement:(IMDDBRequest*)request didSuccessWithItems:(NSArray*)databaseItems withTag:(int)tag;
//Called when the execute query then success then return query is succes or not and if make insert query then return lastid with tag
-(void)IMDDBRequestWithExecuteQuery:(IMDDBRequest*)request didSuccess:(BOOL)isSucces getLastInsertId:(int)lastId withTag:(int)tag;
//Called when the version is changed
-(void)IMDDBRequest:(IMDDBRequest*)request didUpdateToVersion:(NSString*)newVersion;
@end

@protocol DBActionDataSource<NSObject>
@optional
//Called when the send any request with query then return loading screen and u can get text for set text with particular object
-(UIView *)IMDDBRequest:(IMDDBRequest*)request viewForLoadingDatabase:(UIView *)reusingView withLoadingText:(NSString*)loadingText;
@end

@interface IMDDBRequest : NSObject {
	id<DBActionDelegate> _delegateDB;
	id<DBActionDataSource> _dataSourceDB;
	NSMutableDictionary *_dicRequest;
	NSString *_loadingText;
    BOOL _isStop;
	
	//int intTag;
}
@property (nonatomic,strong)id<DBActionDelegate> delegateDB;
@property (nonatomic,strong)id<DBActionDataSource> dataSourceDB;
//when create database and need distance function, its generally call when application is launch
-(void)check_Create_DB:(NSString*)databaseName needDistanceFunction:(BOOL)isNedded ;
//for send query in database for select statement with tag
-(void)requestWithSelectQuery:(NSString*)query withTag:(int)tag;
//for send query in database for execute any query (delete, update, insert) with tag
-(void)requestWithExecuteQuery:(NSString *)exeuteSql withTag:(int)tag;
//for insert data in table when pass table name and all data in dictionary keys as a column name and keys value as column value
- (void)requestWithInsertIntoTable:(NSString *)table withValues:(NSDictionary *)dicValues withTag:(int)tag;
//for update data in table when pass table name and all data in dictionary keys as a column name and keys value as column value and pass in condition in where
- (void)requestWithUpadateTable:(NSString *)table withValues:(NSDictionary *)dicValues where:(NSString *)where withTag:(int)tag;
//for stop loading data from database
-(void)stopRequest;
//for get data with asynchronous Reqest (in background thread)
-(void)startAsynchronousRequest;
//for get data with synchronous Reqest (in main thread)
-(void)startSynchronousRequest;
//set loading text and get text in datasource method for display in loading view
-(void)setLoadingText:(NSString*)loadingText;

//get current running request
+(IMDDBRequest *)currentRequest;

+(void)begin;
+(void)commit;
+(void)rollback;
//for check any request running or not, if return YES then request is running and return NO then no any request in running process
-(BOOL)isRunningRequest;
//for init object
-(id)init;
//for init with delegate
-(id)initWithDelegate:(id)delegate;
//for init with datasource
-(id)initWithDatasource:(id)datasource;
//for init with delegate and datasource
-(id)initWithDelegate:(id)delegate andDatasource:(id)datasource;

//------------------------------Private method-------------------------------
-(NSMutableArray*)query:(NSString*)str withError:(NSError**)error;
-(int)executeQuery:(NSString*)str withError:(NSError**)error;
//----------------------------------END--------------------------------------

@end

@interface NSMutableArray(Synchronous)
//get array from database and get any error if comes in database, its only for select query 
+(id)requestWithSynchronousQuery:(NSString*)strQuery withReturnningError:(NSError**)error;
@end

@interface NSNumber(Synchronous)
//get last insert id and get any error if comes in database, its only for execute query 
+(id)requestWithSynchronousExecuteQuery:(NSString*)strQuery withReturnningError:(NSError**)error;
@end

