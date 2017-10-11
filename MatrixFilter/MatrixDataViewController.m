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
#import <ChameleonFramework/Chameleon.h>

static NSString *const kCollectionViewCell = @"kCollectionViewCell";

@interface MatrixDataViewController () <UICollectionViewDelegate, UICollectionViewDataSource, CellDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL showDeleteButton;

@end

@implementation MatrixDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"已保存的滤镜";
    [self setupCollectionView];
    [self.view addSubview:self.collectionView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(didTapBack)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.showDeleteButton = NO;
    if ([FileManager sharedInstance].file.count == 0) {
        self.navigationItem.rightBarButtonItem = nil;
        [self.view addSubview:[self defaultLabel]];
    } else {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit"] style:UIBarButtonItemStylePlain target:self action:@selector(didTapEdit:)];
        [item setImageInsets:UIEdgeInsetsMake(10, 0, 0, 0)];
        self.navigationItem.rightBarButtonItem = item;
    }
    
    [self.collectionView reloadData];
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
    cell.delegate = self;
    
    NSDictionary *file = [FileManager sharedInstance].file;
    cell.title = file.allKeys[indexPath.row];
    cell.matrix = file.allValues[indexPath.row];
    cell.hideDeleteButton = !self.showDeleteButton;
    
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

- (void)deleteCell:(CollectionViewCell *)cell {
    [self.collectionView performBatchUpdates:^{
        NSIndexPath *indexpath = [self.collectionView indexPathForCell:cell];
        NSString *key = [FileManager sharedInstance].file.allKeys[indexpath.row];
        [[FileManager sharedInstance].file removeObjectForKey:key];
        [[FileManager sharedInstance] saveFile];
        
        [self.collectionView deleteItemsAtIndexPaths:@[indexpath]];
    } completion:^(BOOL finished) {
        [self.collectionView reloadData];
        if ([FileManager sharedInstance].file.count == 0) {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }];
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

- (void)didTapEdit:(UIBarButtonItem *)sender {
    self.showDeleteButton = !self.showDeleteButton;
    [sender setImage:[UIImage imageNamed:self.showDeleteButton ? @"checked" : @"edit"]];
    
    [self.collectionView reloadData];
}

- (void)didTapBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UILabel *)defaultLabel {
    UILabel *label = [[UILabel alloc] init];
    label.text = @"暂无滤镜，快去创建吧！";
    label.font = [UIFont systemFontOfSize:22];
    [label sizeToFit];
    label.textColor = [UIColor flatGrayColor];
    label.center = self.view.center;
    return label;
}

@end
