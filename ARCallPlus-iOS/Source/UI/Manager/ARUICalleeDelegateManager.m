//
//  ARUICalleeDelegateManager.m
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/17.
//

#import "ARUICalleeDelegateManager.h"
#import "ARUICalleeGroupCell.h"

static CGFloat const kItemWidth = 32.0f;
static CGFloat const kSpacing = 5.0f;

@interface ARUICalleeDelegateManager ()

@property (nonatomic, copy) NSArray <CallUserModel *> *listDate;

@end

@implementation ARUICalleeDelegateManager

- (void)reloadCallingGroupWithModel:(NSArray <CallUserModel *>*)models {
    self.listDate = models;
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.listDate.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ARUICalleeGroupCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ARUICalleeGroupCell class]) forIndexPath:indexPath];
    CallUserModel *model = self.listDate[indexPath.item];
    cell.model = model;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kItemWidth, kItemWidth);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.frame.size.width, 0.1);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(collectionView.frame.size.width, 0.1);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kSpacing;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat totalCellWidth = kItemWidth * self.listDate.count;
    CGFloat totalSpacingWidth = kSpacing * (((float)self.listDate.count - 1) < 0 ? 0 :self.listDate.count - 1);
    CGFloat leftInset = (collectionView.bounds.size.width - (totalCellWidth + totalSpacingWidth)) / 2;
    CGFloat rightInset = leftInset;
    UIEdgeInsets sectionInset = UIEdgeInsetsMake(0, leftInset, 0, rightInset);
    return sectionInset;
}


@end
