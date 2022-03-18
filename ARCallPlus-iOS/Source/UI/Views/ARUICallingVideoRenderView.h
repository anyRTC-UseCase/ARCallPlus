//
//  ARUICallingVideoRenderView.h
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/17.
//

#import <UIKit/UIKit.h>
@class CallUserModel;

NS_ASSUME_NONNULL_BEGIN

@interface ARUICallingVideoRenderView : UIView

/// 配置页面信息
/// @param userModel 用户数据模型
- (void)configViewWithUserModel:(CallUserModel *)userModel;

@end

NS_ASSUME_NONNULL_END
