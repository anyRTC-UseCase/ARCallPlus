//
//  ARUICallingControlButton.h
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ARUICallingButtonActionBlcok) (UIButton *sender);

@interface ARUICallingControlButton : UIView

/// 创造自定义试图
/// @param frame 视图尺寸
/// @param titleText 文本文字
/// @param buttonAction 按钮行为
/// @param imageSize 图标尺寸
+ (instancetype)createViewWithFrame:(CGRect)frame titleText:(NSString *)titleText  buttonAction:(ARUICallingButtonActionBlcok)buttonAction imageSize:(CGSize)imageSize;

- (void)configBackgroundImage:(UIImage *)image;

- (void)configTitleColor:(UIColor *)titleColor;

@end

NS_ASSUME_NONNULL_END
