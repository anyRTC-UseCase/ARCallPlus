//
//  ARUICallingBaseView.h
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/15.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Masonry/Masonry.h>
#import <UIView+ARUIToast.h>
#import "ARTCCalling.h"
#import "ARUICommonUtil.h"
#import "UIColor+ARUIHex.h"
#import "ARUICallingVideoRenderView.h"
#import "ARUIInvitedContainerView.h"
#import "ARUICallingControlButton.h"
#import "ARUIDefine.h"

@class ARUIInvitedActionProtocal;

@class CallUserModel;

#define kControlBtnSize CGSizeMake(100, 94)
#define kBtnLargeSize CGSizeMake(64, 64)
#define kBtnSmallSize CGSizeMake(52, 52)

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ARUICallingState) {
    ARUICallingStateDailing = 0, // 正在拨打中（主动）
    ARUICallingStateOnInvitee,   // 等待接听状态（被动）
    ARUICallingStateCalling      // 正在通话中状态(已接听)
};

@interface ARUICallingBaseView : UIView

/// 是否是视频聊天
@property (nonatomic, assign) BOOL isVideo;

/// 是否是被呼叫方
@property (nonatomic, assign) BOOL isCallee;

@property (nonatomic, weak) id<ARUIInvitedActionProtocal> actionDelegate;

/// 页面相关处理
- (void)show;

- (void)disMiss;

- (void)configViewWithUserList:(NSArray<CallUserModel *> *)userList sponsor:(CallUserModel *)sponsor;

/// 数据相关处理
- (void)enterUser:(CallUserModel *)user;

- (void)leaveUser:(CallUserModel *)user;

- (void)updateUser:(CallUserModel *)user animated:(BOOL)animated;

- (void)updateUserVolume:(CallUserModel *)user;

- (CallUserModel *)getUserById:(NSString *)userId;

// 语音通话独有（视频切换语音）
- (void)switchToAudio;

// 被叫接听
- (void)acceptCalling;

// 被叫拒绝
- (void)refuseCalling;

// 刷新接通时间
- (void)setCallingTimeStr:(NSString *)timeStr;

@end

NS_ASSUME_NONNULL_END
