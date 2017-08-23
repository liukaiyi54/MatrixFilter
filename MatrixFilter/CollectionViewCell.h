//
//  CollectionViewCell.h
//  MatrixFilter
//
//  Created by Michael on 22/08/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) NSMutableArray *matrix;
@property (nonatomic, copy) NSString *title;

@end
