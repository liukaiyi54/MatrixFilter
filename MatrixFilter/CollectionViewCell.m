//
//  CollectionViewCell.m
//  MatrixFilter
//
//  Created by Michael on 22/08/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

#import "CollectionViewCell.h"

@interface CollectionViewCell()
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *matrixLabels;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation CollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setMatrix:(NSMutableArray *)matrix {
    _matrix = matrix;
    for (NSInteger i = 0; i < 20; i++) {
        UILabel *label = [self.matrixLabels objectAtIndex:i];
        float f = [[_matrix objectAtIndex:i] floatValue];
        label.text = [NSString stringWithFormat:@"%.1f", f];
    }
}

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    self.titleLabel.text = _title;
}

@end
