//
//  MatrixDataViewController.m
//  MatrixFilter
//
//  Created by Michael on 22/08/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

#import "MatrixDataViewController.h"

#import "CollectionViewCell.h"

#import "FileManager.h"

static NSString *const kCollectionViewCell = @"kCollectionViewCell";

@interface MatrixDataViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation MatrixDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"已保存的滤镜";
    [self setupCollectionView];
    [self.view addSubview:self.collectionView];
}

#pragma mark - UICollectionViewDelegate & etc
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [FileManager sharedInstance].file.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCell forIndexPath:indexPath];
    
    NSDictionary *file = [FileManager sharedInstance].file;
    cell.title = file.allKeys[indexPath.row];
    cell.matrix = file.allValues[indexPath.row];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat screenWidth = CGRectGetWidth(self.view.frame);
    return CGSizeMake(screenWidth/2-10, 140);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0f;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(MatrixDataViewController:didSelectCellAtIndexPath:)]) {
        [self.navigationController popViewControllerAnimated:YES];
        [self.delegate MatrixDataViewController:self didSelectCellAtIndexPath:indexPath];
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView * _Nonnull)collectionView layout:(UICollectionViewLayout * _Nonnull)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 0, 5);
}

#pragma mark - 
- (void)setupCollectionView {
    NSString *nibName = NSStringFromClass([CollectionViewCell class]);
    [self.collectionView registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellWithReuseIdentifier:kCollectionViewCell];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumLineSpacing = 2.0f;
        layout.minimumInteritemSpacing = 2.0f;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

@end
