//
//  FilterManager.h
//  MatrixFilter
//
//  Created by Michael on 31/07/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^imageBlock)(UIImage *image);

@interface FilterManager : NSObject

@property (nonatomic, copy) imageBlock imageBlock;

- (UIImage *)createImageWithImage:(UIImage *)image colorMatrix:(const float *)f;

@end
