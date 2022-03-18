//
//  ARTCCalling+Signal.h
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/15.
//

#import "ARTCCalling.h"
#import "ARUILogin.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ARTCCallingDelegate;

@interface ARTCCalling (Signal)

/// 添加信令监听
- (void)addSignalListener;

/// 移除信令监听
- (void)removeSignalListener;

/// 通过信令发起通话邀请
- (void)invite:(NSString *)receiver action:(CallAction)action;

/// 检查是否满足自动挂断逻辑
- (void)preExitRoom;

/// 兼容异常问题（单人通话）
- (void)dealWithException:(NSInteger)countdown;

/// 发送点对点消息
- (void)sendPeerMessage:(ARtmMessage *)message user:(NSString *)uid;

/// 创建  rtm 频道（多人）
- (void)createMemberChannel;

/// 离开 rtm 频道（多人）
- (void)leaveMemberChannel;

/// 移除定时器（多人被叫端）-- 兼容异常
- (void)removeTimer:(NSString *)uid;

@end

/// ARTCCalling扩展参数
@interface ARTCCalling ()

/// 被邀请的所有用户 ID
@property (nonatomic, strong) NSMutableArray<NSString *> *calleeUserIDs;
/// 记录当前正在邀请成员的列表(被叫：会拼接上主动呼叫者。。。    主叫：不包含主叫者)
@property (nonatomic, strong) NSMutableArray *curInvitingList;
/// 记录当前已经进入房间成功的成员列表
@property (nonatomic, strong) NSMutableArray *curRoomList;
/// 对自己发起通话邀请的人
@property (nonatomic, copy) NSString *curSponsorForMe;
/// 音视频邀请都需要展示消息，这个参数最好做成可配置，如果设置为 false 信令邀请就会产生 IM 消息
@property (nonatomic, assign) BOOL onlineUserOnly;
/// 用于区分主叫、被叫  默认是被叫   「被叫」：YES   「主叫」：NO
@property (nonatomic, assign) BOOL isBeingCalled;
/// 记录类型  Unknown、Audio、Video  （ 未知类型  、语音邀请  、视频邀请）
@property (nonatomic, assign) CallType curType;
/// 记录当前的房间ID
@property (nonatomic, copy) NSString *curRoomID;
/// 记录通话是否已接通（单人通话）
@property (nonatomic, assign) BOOL isCallSucess;
/// 记录「自己」是否正在通话中…
@property (nonatomic, assign) BOOL isOnCalling;
/// 是否为前置摄像头
@property (nonatomic, assign) BOOL isFrontCamera;
/// 通话要计算通话时长,  记录一下
@property (nonatomic, assign) UInt64 startCallTS;

@property (nonatomic, strong) CallModel *curLastModel;
@property (nonatomic, copy) NSString *_Nullable currentCallingUserID;

@property (nonatomic, strong, nullable) ARtmCallKit *callEngine;
@property (nonatomic, weak) id<ARTCCallingDelegate> delegate;
/// 主叫 ARtmLocalInvitation
@property (nonatomic, strong) NSMutableDictionary *callingDic;
/// 被叫 remoteInvitation
@property (nonatomic, strong) NSMutableDictionary *calledDic;
/// 多人YES、单人NO
@property (nonatomic, assign) BOOL isMembers;
@property (nonatomic, strong) ARtmChannel *rtmChannel;
/// 断线重连机制 - 单人通话
@property (nonatomic, assign) BOOL isReconnection;
@property (nonatomic, strong) NSMutableDictionary *timerDic;
@property (nonatomic, assign) BOOL interrupt;
 
- (void)leaveRoom;
- (BOOL)canDelegateRespondMethod:(SEL)selector;

@end


NS_ASSUME_NONNULL_END
