//
//  FriendCell.m
//  Sagebin
//
//  
//  
//

#import "FriendCell.h"

@implementation FriendCell
@synthesize lblName = _lblName;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createLayout];
    }
    return self;
}
-(void)createLayout
{
    _lblName = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 50, 60)];
    [_lblName setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:_lblName];
}
-(void)layoutSubviews
{
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
