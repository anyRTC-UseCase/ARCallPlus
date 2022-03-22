//
//  UIColor+ARUIHex.h
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (ARUIHex)

/// UIColor转换成UIImage
/// @param color UIColor颜色
/// @param size image的大小
/// @return UIImage类型
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;

/// 色值字符串转换成UIColor
/// @param color 16进制字符串
/// @return UIColor类型
+ (UIColor *)t_colorWithHexString:(NSString *)color;

+ (UIColor *)t_colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

/// 16进制当中带有透明度的色值字符串转成UIColor
/// @param color 16进制带透明度的字符串
/// @return UIColor类型
+ (UIColor *)t_colorWithAlphaHexString:(NSString *)color;

@end

NS_ASSUME_NONNULL_END
