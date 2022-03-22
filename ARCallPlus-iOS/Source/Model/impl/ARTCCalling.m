//
//  ARTCCalling.m
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/15.
//

#import "ARTCCalling.h"
#import <ARtcKit/ARtcKit.h>
#import "ARTCCalling+Signal.h"
#import "ARUILogin.h"
#import "ARTCCallingUtils.h"
#import "ARUIDefine.h"

@interface ARTCCalling()<ARtcEngineDelegate>

@property (nonatomic, strong) ARtcEngineKit *rtcEngine;
@property (nonatomic, assign) BOOL isMicMute;
@property (nonatomic, assign) BOOL isHandsFreeOn;

@end

@implementation ARTCCalling {
    BOOL _isOnCalling;
    NSString *_curCallID;
}

+ (ARTCCalling *)shareInstance {
    static dispatch_once_t onceToken;
    static ARTCCalling * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[ARTCCalling alloc] init];
    });
    return g_sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.curLastModel = [[CallModel alloc] init];
        self.curLastModel.invitedList = [NSMutableArray array];
        self.curRoomList = [NSMutableArray array];
        self.callingDic = [[NSMutableDictionary alloc] init];
        self.calledDic = [[NSMutableDictionary alloc] init];
        self.timerDic = [[NSMutableDictionary alloc] init];
        self.isHandsFreeOn = YES;
        self.isBeingCalled = YES;
    }
    return self;
}

- (ARtcEngineKit *)rtcEngine {
    if (!_rtcEngine) {
        /// 实例化音视频引擎对象
        _rtcEngine = [ARtcEngineKit sharedEngineWithAppId:[ARUILogin getSdkAppID] delegate:self];
        /// 直播模式
        [_rtcEngine setChannelProfile: ARChannelProfileLiveBroadcasting];
        [_rtcEngine setClientRole: ARClientRoleBroadcaster];
        /// 编码配置
        ARVideoEncoderConfiguration *configuration = [[ARVideoEncoderConfiguration alloc] init];
        configuration.dimensions = CGSizeMake(960, 540);
        configuration.frameRate = 15;
        configuration.bitrate = 500;
        [_rtcEngine setVideoEncoderConfiguration:configuration];
        /// 启用说话者音量提示
        [_rtcEngine enableAudioVolumeIndication:2000 smooth:3 report_vad: YES];
        /// 开启美颜
        [_rtcEngine setBeautyEffectOptions:YES options:[[ARBeautyOptions alloc]init]];
    }
    return _rtcEngine;
}

- (void)dealloc {
    [self removeSignalListener];
}

//MARK: - Publish Method

- (void)addDelegate:(id<ARTCCallingDelegate>)delegate {
    self.delegate = delegate;
}

- (void)call:(NSArray *)userIDs type:(CallType)type {
    /// 发起通话
    if (!self.isOnCalling) {
        self.curLastModel.inviter = [ARUILogin getUserID];
        self.curLastModel.action = CallAction_Call;
        self.curLastModel.calltype = type;
        self.curRoomID = [NSString stringWithFormat:@"%d", [ARTCCallingUtils generateRoomID]];
        self.isMembers = userIDs.count >= 2 ? YES : NO;
        self.calleeUserIDs = [@[] mutableCopy];
        
        self.curType = type;
        self.isOnCalling = YES;
        self.isBeingCalled = NO;
        [self joinRoom];
        [self createMemberChannel];
    }
    
    // 如果不在当前邀请列表，则新增
    NSMutableArray *newInviteList = [NSMutableArray array];
    for (NSString *userID in userIDs) {
        if (![self.curInvitingList containsObject:userID]) {
            [newInviteList addObject:userID];
        }
    }
    
    [self.curInvitingList addObjectsFromArray:newInviteList];
    [self.calleeUserIDs addObjectsFromArray:newInviteList];
    
    if (!(self.curInvitingList && self.curInvitingList.count > 0)) return;
    self.currentCallingUserID = newInviteList.firstObject;
    for (NSString *userID in self.curInvitingList) {
        [self invite:userID action:CallAction_Call];
    }
}

- (void)accept:(BOOL)isVideo {
    /// 接受当前通话
    ARLog(@"Calling - accept Call");
    if (!isVideo) {
        [self.rtcEngine disableVideo];
        self.curType = CallType_Audio;
        if ([self canDelegateRespondMethod:@selector(onSwitchToAudio:message:)]) {
            [self.delegate onSwitchToAudio:YES message:@""];
        }
    }
    
    [self joinRoom];
    self.currentCallingUserID = self.curSponsorForMe;
    [self invite:self.curSponsorForMe action:CallAction_Accept];
    self.isCallSucess = YES;
    [self dealWithException:10];
}

- (void)reject {
    /// 拒绝当前通话
    ARLog(@"Calling - reject Call");
    [self invite:self.curSponsorForMe action:CallAction_Reject];
    self.isOnCalling = NO;
    [self.rtcEngine disableVideo];
}

- (void)hangup {
    /// 主动挂断通话
    __block BOOL hasCallUser = NO;
    [self.curRoomList enumerateObjectsUsingBlock:^(NSString *user, NSUInteger idx, BOOL * _Nonnull stop) {
        if ((user && user.length > 0) && ![self.curInvitingList containsObject:user]) {
            // 还有正在通话的用户
            hasCallUser = YES;
            [self invite:user action:CallAction_End];
            *stop = YES;
        }
    }];
    
    /// 主叫需要取消未接通的通话
    if (hasCallUser == NO) {
        ARLog(@"Calling - GroupHangup Send CallAction_Cancel");
        [self.curInvitingList enumerateObjectsUsingBlock:^(NSString *invitedId, NSUInteger idx, BOOL * _Nonnull stop) {
            [self invite:invitedId action:CallAction_Cancel];
        }];
    }

    [self leaveRoom];
    self.isOnCalling = NO;
}

- (void)lineBusy {
    /// 主动操作 - 忙线通话（发送忙线信令到主叫者）
    [self invite:self.curSponsorForMe action:CallAction_Linebusy];
    self.isOnCalling = NO;
}

- (void)switchToAudio {
    /// 切换到语音通话（通话中）
    self.curType = CallType_Audio;
    [self.rtcEngine disableVideo];
    [self invite:self.currentCallingUserID action:CallAction_SwitchToAudio];
    
    if ([self canDelegateRespondMethod:@selector(onSwitchToAudio:message:)]) {
        [self.delegate onSwitchToAudio:YES message:@""];
    }
}

- (void)startRemoteView:(NSString *)userID view:(UIView *)view {
    /// 开启远程用户视频渲染
    ARLog(@"Calling - startRemoteView userID = %@", userID);
    if (userID.length != 0) {
        ARtcVideoCanvas *canvas = [[ARtcVideoCanvas alloc] init];
        canvas.uid = userID;
        canvas.view = view;
        [self.rtcEngine setupRemoteVideo:canvas];
    }
}

- (void)stopRemoteView:(NSString *)userID {
    /// 关闭远程用户视频渲染
    ARLog(@"Calling - stopRemoteView userID = %@", userID);
    ARtcVideoCanvas *canvas = [[ARtcVideoCanvas alloc] init];
    canvas.uid = userID;
    canvas.view = nil;
    [self.rtcEngine setupRemoteVideo:canvas];
}

- (void)openCamera:(BOOL)frontCamera view:(UIView *)view {
    /// 打开摄像头
    ARLog(@"Calling - openCamera");
    if (self.curType == CallType_Video) {
        [self.rtcEngine enableVideo];
    }
    ARtcVideoCanvas *canvas = [[ARtcVideoCanvas alloc] init];
    canvas.uid = [ARUILogin getUserID];
    canvas.view = view;
    [self.rtcEngine setupLocalVideo:canvas];
    [self.rtcEngine startPreview];
    self.isFrontCamera = frontCamera;
}

- (void)closeCamara {
    /// 关闭摄像头
    ARLog(@"Calling - closeCamara");
    [self.rtcEngine disableVideo];
}

- (void)switchCamera:(BOOL)frontCamera {
    /// 切换摄像头
    if (self.isFrontCamera != frontCamera) {
        [self.rtcEngine switchCamera];
        self.isFrontCamera = frontCamera;
    }
}

- (void)setMicMute:(BOOL)isMute {
    /// 静音操作
    if (self.isMicMute != isMute) {
        [self.rtcEngine muteLocalAudioStream:isMute];
        self.isMicMute = isMute;
    }
}

- (void)setHandsFree:(BOOL)isHandsFree {
    /// 免提操作
    [self.rtcEngine setEnableSpeakerphone:isHandsFree];
    self.isHandsFreeOn = isHandsFree;
}

//MARK: - Signal Extension

- (void)joinRoom {
    ARLog(@"Calling - rtc JoinChannel");
    if (self.curType == CallType_Video) {
        [self.rtcEngine enableVideo];
    }
    
    [self.rtcEngine joinChannelByToken:nil channelId:self.curRoomID uid:[ARUILogin getUserID] joinSuccess:^(NSString * _Nonnull channel, NSString * _Nonnull uid, NSInteger elapsed) {
        ARLog(@"Calling - joinChannel Sucess");
    }];
}

- (void)leaveRoom {
    ARLog(@"Calling - rtc LeaveChannel");
    [self.rtcEngine disableVideo];
    [self.rtcEngine leaveChannel:nil];
    [ARtcEngineKit destroy];
    self.rtcEngine = nil;
    self.isMicMute = NO;
    self.isHandsFreeOn = YES;
}

//MARK: - ARtcEngineDelegate

- (void)rtcEngine:(ARtcEngineKit *)engine didOccurError:(ARErrorCode)errorCode {
    /// 发生错误回调
    ARLog(@"Calling - didOccurError = %ld", (long)errorCode);
}

- (void)rtcEngine:(ARtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSString *)uid size:(CGSize)size elapsed:(NSInteger)elapsed {
    ARLog(@"Calling - firstRemoteVideoDecodedOfUid = %@", uid);
}

- (void)rtcEngine:(ARtcEngineKit *)engine didJoinedOfUid:(NSString *)uid elapsed:(NSInteger)elapsed {
    /// 远端用户/主播加入回调
    ARLog(@"Calling - didJoinedOfUid = %@", uid);
    // C2C curInvitingList 不要移除 userID，如果是自己邀请的对方，这里移除后，最后发结束信令的时候找不到人
    [self dealWithException:0];
    [self removeTimer:uid];
    if ([self.curInvitingList containsObject:uid]) {
        [self.curInvitingList removeObject:uid];
    }
    if (![self.curRoomList containsObject:uid]) {
        [self.curRoomList addObject:uid];
    }
    // C2C 通话要计算通话时长
    if ([self canDelegateRespondMethod:@selector(onUserEnter:)]) {
        [self.delegate onUserEnter:uid];
    }
}

- (void)rtcEngine:(ARtcEngineKit *)engine didOfflineOfUid:(NSString *)uid reason:(ARUserOfflineReason)reason {
    /// 远端用户（通信场景）/主播（直播场景）离开当前频道回调
    ARLog(@"Calling - didOfflineOfUid = %@", uid);
    // C2C curInvitingList 不要移除 userID，如果是自己邀请的对方，这里移除后，最后发结束信令的时候找不到人
    if (self.isMembers || (!self.isMembers && reason == ARUserOfflineReasonQuit)) {
        if ([self.curInvitingList containsObject:uid]) {
            [self.curInvitingList removeObject:uid];
        }
        if ([self.curRoomList containsObject:uid]) {
            [self.curRoomList removeObject:uid];
        }
        if ([self canDelegateRespondMethod:@selector(onUserLeave:)]) {
            [self.delegate onUserLeave:uid];
        }
        [self preExitRoom];
    } else if (reason == ARUserOfflineReasonDropped) {
        [self dealWithException:10];
    }
}

- (void)rtcEngine:(ARtcEngineKit *)engine remoteVideoStateChangedOfUid:(NSString *)uid state:(ARVideoRemoteState)state reason:(ARVideoRemoteStateReason)reason elapsed:(NSInteger)elapsed {
    /// 远端视频状态发生改变回调
    if (reason == ARVideoRemoteStateReasonRemoteMuted || reason == ARVideoRemoteStateReasonRemoteUnmuted) {
        if ([self canDelegateRespondMethod:@selector(onUserVideoAvailable:available:)]) {
            [self.delegate onUserVideoAvailable:uid available:(reason == ARVideoRemoteStateReasonRemoteMuted) ? NO : YES];
        }
    }
}

- (void)rtcEngine:(ARtcEngineKit *)engine remoteAudioStateChangedOfUid:(NSString *)uid state:(ARAudioRemoteState)state reason:(ARAudioRemoteStateReason)reason elapsed:(NSInteger)elapsed {
    /// 远端音频状态发生改变回调
    if (reason == ARAudioRemoteReasonRemoteMuted || reason == ARAudioRemoteReasonRemoteUnmuted) {
        if ([self canDelegateRespondMethod:@selector(onUserAudioAvailable:available:)]) {
            [self.delegate onUserAudioAvailable:uid available:(reason == ARAudioRemoteReasonRemoteMuted) ? NO : YES];
        }
    }
}

- (void)rtcEngine:(ARtcEngineKit *)engine reportAudioVolumeIndicationOfSpeakers:(NSArray<ARtcAudioVolumeInfo *> *)speakers totalVolume:(NSInteger)totalVolume {
    /// 提示频道内谁正在说话、说话者音量及本地用户是否在说话的回调
    if ([self canDelegateRespondMethod:@selector(onUserVoiceVolume:volume:)]) {
        for (ARtcAudioVolumeInfo *info in speakers) {
            if ([info.uid isEqualToString:@"0"]) {
                [self.delegate onUserVoiceVolume:[ARUILogin getUserID] volume:(UInt32)info.volume];
            } else {
                [self.delegate onUserVoiceVolume:info.uid volume:(UInt32)info.volume];
            }
        }
    }
}

- (void)rtcEngine:(ARtcEngineKit *)engine connectionChangedToState:(ARConnectionStateType)state reason:(ARConnectionChangedReason)reason {
    //ARLog(@"Calling - rtc connectionStateChanged state = %ld reason = %ld", (long)state, (long)reason);
}

- (void)rtcEngine:(ARtcEngineKit *)engine didVideoSubscribeStateChange:(NSString *)channel withUid:(NSString *)uid oldState:(ARStreamSubscribeState)oldState newState:(ARStreamSubscribeState)newState elapseSinceLastState:(NSInteger)elapseSinceLastState {
    ARLog(@"Calling - didVideoSubscribeStateChange = %@ %@ %lu %lu", channel, uid, (unsigned long)oldState, (unsigned long)newState);
}

//MARK: - other

- (void)setIsOnCalling:(BOOL)isOnCalling {
    if (isOnCalling && _isOnCalling != isOnCalling) {
        // 开始通话
    } else if (!isOnCalling && _isOnCalling != isOnCalling) { // 退出通话
        [self leaveMemberChannel];
        self.isBeingCalled = YES;
        self.isCallSucess = NO;
        self.curRoomID = @"0";
        self.curType = CallType_Unknown;
        self.curSponsorForMe = @"";
        self.startCallTS = 0;
        self.curLastModel = [[CallModel alloc] init];
        self.curInvitingList = [NSMutableArray array];
        self.curRoomList = [NSMutableArray array];
        self.calleeUserIDs = [@[] mutableCopy];
        self.currentCallingUserID = nil;
    }
    _isOnCalling = isOnCalling;
}

- (BOOL)isOnCalling {
    return _isOnCalling;
}

- (void)setCurInvitingList:(NSMutableArray *)curInvitingList {
    self.curLastModel.invitedList = curInvitingList;
}

- (NSMutableArray *)curInvitingList {
    return self.curLastModel.invitedList;
}

- (void)setCurRoomID:(NSString *)curRoomID {
    self.curLastModel.roomid = curRoomID;
}

- (NSString *)curRoomID {
    return self.curLastModel.roomid;
}

- (void)setCurType:(CallType)curType {
    self.curLastModel.calltype = curType;
}

- (CallType)curType {
    return self.curLastModel.calltype;
}

- (BOOL)micMute {
    return self.isMicMute;
}

- (BOOL)handsFreeOn {
    return self.isHandsFreeOn;
}

- (BOOL)canDelegateRespondMethod:(SEL)selector {
    return self.delegate && [self.delegate respondsToSelector:selector];
}

@end
