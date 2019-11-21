//
//  CustomButton.m
//  Sagebin
//
//  
//

#import "CustomButton.h"

@implementation CustomButton

@synthesize dictData;
@synthesize buttonTag;
@synthesize indexPath;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dictData = [[NSMutableDictionary alloc]init];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

+ (id)buttonWithType:(UIButtonType)buttonType{
    return [super buttonWithType:buttonType];
    
}

@end
