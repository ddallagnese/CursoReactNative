//
//  UIImageAdditions.h
//  Basic
//
//  Created by hyperlink Singh on 01/11/12.
//  Copyright (c) 2012 hyperlink Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage(Resize)


//For resize image
-(UIImage*)resizedImageToSize:(CGSize)dstSize;
-(UIImage*)resizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale;
-(UIImage *) scaleAndRotateImage: (UIImage *) image;

@end
