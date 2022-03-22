//
//  ARUIGroupCallingView.h
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/17.
//

#import "ARUICallingBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ARUIGroupCallingView : ARUICallingBaseView

/// 初始化页面
- (instancetype)initWithUser:(CallUserModel *)user isVideo:(BOOL)isVideo isCallee:(BOOL)isCallee;

@end

NS_ASSUME_NONNULL_END
