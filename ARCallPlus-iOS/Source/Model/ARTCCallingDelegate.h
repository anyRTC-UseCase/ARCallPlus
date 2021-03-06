//
//  ARTCCallingDelegate.h
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/15.
//

#ifndef ARTCCallingDelegate_h
#define ARTCCallingDelegate_h
#import <Foundation/Foundation.h>
#import "ARTCCallingModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ARTCCallingDelegate <NSObject>
@optional
/// sdk内部发生了错误 | sdk error
/// - Parameters:
///   - code: 错误码
///   - msg: 错误消息
-(void)onError:(int)code msg:(NSString * _Nullable)msg
NS_SWIFT_NAME(onError(code:msg:));

/// 切换到语音通话结果回调
/// @param success 是否需要切换到语音
/// @param message 错误信息
- (void)onSwitchToAudio:(BOOL)success
                message:(NSString *)message
NS_SWIFT_NAME(onSwitchToAudio(success:message:));
   
/// 被邀请通话回调 | invitee callback
/// - Parameter userIds: 邀请列表 (invited list)
-(void)onInvited:(NSString *)sponsor
         userIds:(NSArray<NSString *> *)userIds
     isFromGroup:(BOOL)isFromGroup
        callType:(CallType)callType
NS_SWIFT_NAME(onInvited(sponsor:userIds:isFromGroup:callType:));
   
/// 群聊更新邀请列表回调 | update current inviteeList in group calling
/// - Parameter userIds: 邀请列表 | inviteeList
-(void)onGroupCallInviteeListUpdate:(NSArray *)userIds
NS_SWIFT_NAME(onGroupCallInviteeListUpdate(userIds:));
   
/// 进入通话回调 | user enter room callback
/// - Parameter uid: userid
-(void)onUserEnter:(NSString *)uid
NS_SWIFT_NAME(onUserEnter(uid:));
   
/// 离开通话回调 | user leave room callback
/// - Parameter uid: userid
-(void)onUserLeave:(NSString *)uid
NS_SWIFT_NAME(onUserLeave(uid:));
   
/// 用户是否开启音频上行回调 | is user audio available callback
/// - Parameters:
///   - uid: 用户ID | userID
///   - available: 是否有效 | available
-(void)onUserAudioAvailable:(NSString *)uid available:(BOOL)available
NS_SWIFT_NAME(onUserAudioAvailable(uid:available:));
   
/// 用户是否开启视频上行回调 | is user video available callback
/// - Parameters:
///   - uid: 用户ID | userID
///   - available: 是否有效 | available
-(void)onUserVideoAvailable:(NSString *)uid available:(BOOL)available
NS_SWIFT_NAME(onUserVideoAvailable(uid:available:));
   
/// 用户音量回调
/// - Parameter uid: 用户ID | userID
/// - Parameter volume: 说话者的音量, 取值范围0 - 100
-(void)onUserVoiceVolume:(NSString *)uid volume:(UInt32)volume
NS_SWIFT_NAME(onUserVoiceVolume(uid:volume:));
   
/// 拒绝通话回调-仅邀请者受到通知，其他用户应使用 onUserEnter |
/// reject callback only worked for Sponsor, others should use onUserEnter)
/// - Parameter uid: userid
-(void)onReject:(NSString *)uid
NS_SWIFT_NAME(onReject(uid:));
   
/// 无回应回调-仅邀请者受到通知，其他用户应使用 onUserEnter |
/// no response callback only worked for Sponsor, others should use onUserEnter)
/// - Parameter uid: userid
-(void)onNoResp:(NSString *)uid
NS_SWIFT_NAME(onNoResp(uid:));
   
/// 通话占线回调-仅邀请者受到通知，其他用户应使用 onUserEnter |
/// linebusy callback only worked for Sponsor, others should use onUserEnter
/// - Parameter uid: userid
-(void)onLineBusy:(NSString *)uid
NS_SWIFT_NAME(onLineBusy(uid:));
   
// invitee callback

/// 当前通话被取消回调 | current call had been canceled callback
-(void)onCallingCancel:(NSString *)uid
NS_SWIFT_NAME(onCallingCancel(uid:));
   
/// 通话超时的回调 | timeout callback
-(void)onCallingTimeOut;
   
/// 通话结束 | end callback
-(void)onCallEnd;

@end

NS_ASSUME_NONNULL_END
#endif /* ARTCCallingDelegate_h */
