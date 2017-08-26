//
//  CollectionViewCell.h
//  MatrixFilter
//
//  Created by Michael on 22/08/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CollectionViewCell;
@protocol CellDelegate <NSObject>

-(void)deleteCell:(CollectionViewCell *)cell;

@end

@interface CollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id <CellDelegate>delegate;
@property (nonatomic, strong) NSMutableArray *matrix;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL hideDeleteButton;

@end
