//
//  ARUIVideoUserContainerView.h
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/17.
//

#import <UIKit/UIKit.h>
@class CallUserModel;

NS_ASSUME_NONNULL_BEGIN

@interface ARUIVideoUserContainerView : UIView

/// 配置用户信息视图
/// @param userModel 数据Modle
/// @param text 等待文本
- (void)configUserInfoViewWith:(CallUserModel *)userModel showWaitingText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
