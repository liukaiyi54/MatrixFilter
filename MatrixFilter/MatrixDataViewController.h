//
//  MatrixDataViewController.h
//  MatrixFilter
//
//  Created by Michael on 22/08/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionViewCell.h"

@class MatrixDataViewController;

@protocol MatrixDataViewControllerDelegate <NSObject>

- (void)MatrixDataViewController:(MatrixDataViewController *)vc didSelectCellAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface MatrixDataViewController : UIViewController

@property (nonatomic, weak) id <MatrixDataViewControllerDelegate> delegate;

@end
