//
//  Segbin_Singletone.h
//  Sagebin
//
//  //  
//

#import <Foundation/Foundation.h>
#import "CustomButton.h"

typedef enum STATUS{
    USER_STATUS_ONLINE=1,
    USER_STATUS_OFFLINE
}USER_STATUS;

@interface Segbin_Singletone : NSObject

+(Segbin_Singletone*)sharedInstance;
-(UILabel *)createLabelWithFrame:(CGRect)frm withFont:(UIFont *)font withTextColor:(UIColor *)colorText withTextAlignment:(NSTextAlignment)textAlign withTag:(int)tag;

-(UIImage * )imageForStatus:(NSInteger )status;
-(CGSize)sizeForString:(NSString *)string fontType:(UIFont *)fonts;
-(UIButton *)createBtnWithFrame:(CGRect)frm withTitle:(NSString *)title withImage:(UIImage *)imgBtn withTag:(int)tag;
-(UITextField *)createTextFieldWithFrame:(CGRect)frame placeHolder:(NSString *)strPlaceholder font:(UIFont *)font textColor:(UIColor *)txtColor tag:(int)tag;
-(UIView *)createViewWithFrame:(CGRect)frame bgColor:(UIColor *)bgColor tag:(int)tag alpha:(CGFloat)alpha;

-(UIButton *)createBtnWithFrame:(CGRect)frm withTitle:(NSString *)title withImage:(UIImage *)imgBtn withTag:(int)tag Font:(UIFont *)font BGColor:(UIColor *)bgColor;

-(void)reuseStart:(UIView *)view withYpostion:(CGFloat)yPOS withPoint:(CGFloat)point;
-(void)addStart:(UIView *)view withYpostion:(CGFloat)yPOS withPoint:(CGFloat)point;

-(CustomButton *)createCustomBtnWithFrame:(CGRect)frm withTitle:(NSString *)title withImage:(UIImage *)imgBtn withTag:(int)tag;
-(CustomButton *)createCustomBtnWithFrame:(CGRect)frm withTitle:(NSString *)title withImage:(UIImage *)imgBtn withTag:(int)tag Font:(UIFont *)font BGColor:(UIColor *)bgColor;

UIColor* colorWithHexString(NSString* hex);

-(void)setName:(NSString *)name withValue:(NSString *)value onBody:(NSMutableData *)body;
-(void)setName:(NSString *)name withFileName:(NSString *)fileName withValue:(NSData *)data onBody:(NSMutableData *)body;

-(void)addLoader;
-(void)removeLoader;
-(NSMutableArray *)getOfflineVideos;

-(UIScrollView *)createScrollViewWithFrame:(CGRect)frame bgColor:(UIColor *)bgColor tag:(int)tag delegate:(id)delegate;

@end
