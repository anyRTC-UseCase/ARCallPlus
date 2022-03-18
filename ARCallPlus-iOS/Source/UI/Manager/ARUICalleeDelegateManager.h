//
//  ARUICalleeDelegateManager.h
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/17.
//

#import <Foundation/Foundation.h>
#import "ARTCCallingModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ARUICalleeDelegateManager : NSObject<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

- (void)reloadCallingGroupWithModel:(NSArray <CallUserModel *>*)models;

@end

NS_ASSUME_NONNULL_END
