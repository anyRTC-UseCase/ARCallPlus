//
//  ARUICallingDelegateManager.m
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/17.
//

#import "ARUICallingDelegateManager.h"
#import "ARUICallingGroupCell.h"

@interface ARUICallingDelegateManager()

@property (nonatomic, copy) NSArray <CallUserModel *> *listDate;

@end

@implementation ARUICallingDelegateManager

- (void)reloadCallingGroupWithModel:(NSArray<CallUserModel *> *)models {
    self.listDate = models;
}

- (__kindof UIView *)getRenderViewFromUser:(NSString *)userId {
    __block NSInteger index = -1;
    [self.listDate enumerateObjectsUsingBlock:^(CallUserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:userId]) {
            index = idx;
            *stop = YES;
        }
    }];
    if (index >= 0) {
        ARUICallingGroupCell *cell = (ARUICallingGroupCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        return cell.renderView;
    }
    return nil;
}

- (void)reloadGroupCellWithIndex:(NSInteger)index {
    if (index >= 0 && (self.listDate.count > index)) {
        ARUICallingGroupCell *cell = (ARUICallingGroupCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        cell.model = self.listDate[index];
    }
}


#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.listDate.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ARUICallingGroupCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[NSString stringWithFormat:@"ARUICallingGroupCell_%d", (int)indexPath.item] forIndexPath:indexPath];
    CallUserModel *model = self.listDate[indexPath.item];
    cell.model = model;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat side = collectionView.bounds.size.width / 2.0 - 0.5;
    if (self.listDate.count >= 5) {
        side = collectionView.bounds.size.width / 3.0 - 0.5;
    }
    return CGSizeMake(side, side);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.frame.size.width, 0.1);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(collectionView.frame.size.width, 0.1);
}

@end
