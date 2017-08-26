//
//  CollectionViewCell.m
//  MatrixFilter
//
//  Created by Michael on 22/08/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

#import "CollectionViewCell.h"

#import <ChameleonFramework/Chameleon.h>

@interface CollectionViewCell()
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *matrixLabels;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation CollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.cornerRadius = 4.0f;
    self.layer.borderColor = [UIColor flatMintColor].CGColor;
    self.layer.borderWidth = 1.0f;
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

- (IBAction)didTapDeleteButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(deleteCell:)]) {
        [self.delegate deleteCell:self];
    }
}

- (void)setHideDeleteButton:(BOOL)hideDeleteButton {
    _hideDeleteButton = hideDeleteButton;
    if (_hideDeleteButton) {
        self.deleteButton.hidden = YES;
    } else {
        self.deleteButton.hidden = NO;
    }
}

@end
