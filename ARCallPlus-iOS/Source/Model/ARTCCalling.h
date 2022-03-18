//
//  ARTCCalling.h
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/15.
//

#import <Foundation/Foundation.h>
#import "ARTCCallingModel.h"
#import "ARTCCallingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ARTCCalling : NSObject

/// 单例对象
+ (ARTCCalling *)shareInstance;

/// 设置ARTCCallingDelegate回调
/// @param delegate 回调实例
- (void)addDelegate:(id<ARTCCallingDelegate>)delegate;

/// 发起通话
/// @param userIDs 被邀请方ID列表
/// @param type 通话类型:视频/语音
- (void)call:(NSArray *)userIDs type:(CallType)type;

/// 接受当前通话
/// @param isVideo 视频/语音接听
- (void)accept:(BOOL)isVideo;

/// 拒绝当前通话
- (void)reject;

/// 主动挂断通话
- (void)hangup;

/// 主动操作 - 忙线通话（发送忙线信令到主叫者）
- (void)lineBusy;

/// 切换到语音通话
- (void)switchToAudio;

/// 开启远程用户视频渲染
- (void)startRemoteView:(NSString *)userId view:(UIView *)view
NS_SWIFT_NAME(startRemoteView(userId:view:));

/// 关闭远程用户视频渲染
- (void)stopRemoteView:(NSString *)userId
NS_SWIFT_NAME(stopRemoteView(userId:));

/// 打开摄像头
- (void)openCamera:(BOOL)frontCamera view:(UIView *)view
NS_SWIFT_NAME(openCamera(frontCamera:view:));

/// 关闭摄像头
- (void)closeCamara;

/// 切换摄像头
- (void)switchCamera:(BOOL)frontCamera;

/// 静音操作
- (void)setMicMute:(BOOL)isMute;

/// 免提操作
- (void)setHandsFree:(BOOL)isHandsFree;

@end

NS_ASSUME_NONNULL_END
