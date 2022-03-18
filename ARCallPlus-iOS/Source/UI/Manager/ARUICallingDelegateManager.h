//
//  ARUICallingDelegateManager.h
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/17.
//

#import <Foundation/Foundation.h>
#import "ARTCCallingModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ARUICallingDelegateManager : NSObject <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) UICollectionView *collectionView;

- (__kindof UIView * _Nullable)getRenderViewFromUser:(NSString *)userId;

- (void)reloadCallingGroupWithModel:(NSArray <CallUserModel *>*)models;

- (void)reloadGroupCellWithIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
