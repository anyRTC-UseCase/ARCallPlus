//
//  ARUIInvitedContainerView.h
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/17.
//

#import <UIKit/UIKit.h>
#import "ARUIInvitedActionProtocal.h"

NS_ASSUME_NONNULL_BEGIN

@interface ARUIInvitedContainerView : UIView

@property (nonatomic, weak) id<ARUIInvitedActionProtocal> delegate;

- (void)configTitleColor:(UIColor *)titleColor;

@end

NS_ASSUME_NONNULL_END
