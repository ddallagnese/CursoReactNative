//
//  CustomButton.h
//  Sagebin
//
//  
//

#import <UIKit/UIKit.h>

@interface CustomButton : UIButton

@property (nonatomic, retain) NSMutableDictionary *dictData;
@property (nonatomic, assign) NSInteger buttonTag;
@property (nonatomic, retain) NSIndexPath *indexPath;
@end
