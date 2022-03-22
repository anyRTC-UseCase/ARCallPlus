//
//  ARUIAudioUserContainerView.h
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CallUserModel;

@interface ARUIAudioUserContainerView : UIView

/// 配置用户信息视图
/// @param userModel 数据Modle
/// @param text 等待文本
- (void)configUserInfoViewWith:(CallUserModel *)userModel showWaitingText:(NSString *)text;

///配置用户名的字体颜色/文本内容
/// @param textColor 字体颜色
- (void)setUserNameTextColor:(UIColor *)textColor;

@end

NS_ASSUME_NONNULL_END
