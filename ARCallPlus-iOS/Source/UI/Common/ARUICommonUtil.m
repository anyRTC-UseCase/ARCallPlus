//
//  ARUICommonUtil.m
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/17.
//

#import "ARUICommonUtil.h"

@implementation ARUICommonUtil

+ (NSBundle *)callingBundle {
    NSURL *callingKitBundleURL = [[NSBundle mainBundle] URLForResource:@"ARUICallingKitBundle" withExtension:@"bundle"];
    return [NSBundle bundleWithURL:callingKitBundleURL];
}

+ (UIImage *)getBundleImageWithName:(NSString *)name {
    return [UIImage imageNamed:name inBundle:[self callingBundle] compatibleWithTraitCollection:nil];
}

+ (UIWindow *)getRootWindow {
    NSArray *windows = [[UIApplication sharedApplication] windows];
    
    for (UIWindow *window in [windows reverseObjectEnumerator]) {
        if ([window isKindOfClass:[UIWindow class]] &&
            window.windowLevel == UIWindowLevelNormal &&
            CGRectEqualToRect(window.bounds, [UIScreen mainScreen].bounds))
            return window;
    }
    
    return [UIApplication sharedApplication].keyWindow;
}

+ (UIViewController *)getTopViewController {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topViewController = [self getCurrentTopVCFrom:rootViewController];
    return topViewController;
}

+ (UIViewController *)getCurrentTopVCFrom:(UIViewController *)rootVC {
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController]) {
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        currentVC = [self getCurrentTopVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        currentVC = [self getCurrentTopVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        currentVC = rootVC;
    }
    
    return currentVC;
}

+ (BOOL)checkDictionaryValid:(id)data {
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    return YES;
}

+ (BOOL)checkArrayValid:(id)data {
    if (!data || ![data isKindOfClass:[NSArray class]]) {
        return NO;
    }
    return YES;
}

+ (id)fetchModelWithIndex:(NSInteger)index dataArray:(NSArray *)dataArray {
    if (dataArray && [dataArray isKindOfClass:[NSArray class]] && dataArray.count > index) {
        return dataArray[index];
    }
    return nil;
}

+ (NSInteger)fetchIndexWithModel:(id)model dataArray:(NSArray *)dataArray {
    if ([self checkArrayValid:dataArray] && [dataArray containsObject:model]) {
        return [dataArray indexOfObject:model];
    }
    return 0;
}

+ (BOOL)checkIndexInRangeWith:(NSInteger)index dataArray:(NSArray *)dataArray {
    if (dataArray.count > 0 && (dataArray.count > index)) {
        return YES;
    }
    return NO;
}

+ (CGFloat)calculateTextWidth:(NSString *)text font:(UIFont *)font {
    return [self calculateTextSize:text font:font targetWidth:MAXFLOAT].width;
}

+ (CGSize)calculateTextSize:(NSString *)text font:(UIFont *)font targetWidth:(CGFloat)targetWidth {
    return [text boundingRectWithSize:CGSizeMake(targetWidth,MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
}

@end
