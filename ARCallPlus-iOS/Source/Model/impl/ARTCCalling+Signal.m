//
//  ARTCCalling+Signal.m
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/15.
//

#import "ARTCCalling+Signal.h"
#import "ARTCCallingUtils.h"
#import "ARTCCallingHeader.h"
#import "NSObject+ARExtension.h"
#import "ARUIDefine.h"
#import "ARTCGCDTimer.h"

@interface ARTCCalling ()<ARtmDelegate, ARtmCallDelegate, ARtmChannelDelegate>

@end

@implementation ARTCCalling (Signal)

- (void)addSignalListener {
    ARUILogin.kit.aRtmDelegate = self;
    self.callEngine.callDelegate = self;
    /// 用户进入后台推送问题
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(enterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(becomeActive:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)removeSignalListener {
    self.callEngine.callDelegate = nil;
    self.callEngine = nil;
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)invite:(NSString *)receiver action:(CallAction)action {
    if (action == CallAction_Call) {
        /// 发起呼叫邀请
        NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:[ARUILogin getUserID], nil];
        [arr addObjectsFromArray:self.calleeUserIDs];
        
        NSMutableArray *infoArr = [NSMutableArray array];
        for (NSInteger i = 0; i < arr.count; i++) {
            ARCallUser *user = [ARUILogin getCallUserInfo:arr[i]];
            [infoArr addObject:[NSObject ar_dictionaryWithObject: user]];
        }
        
        NSDictionary *dic = @{@"Mode": @(self.curType == CallType_Video ? 0 : 1),
                             @"Conference": [NSNumber numberWithBool:self.isMembers],
                             @"ChanId": self.curRoomID,
                             @"UserData": arr,
                             @"UserInfo": infoArr
        };
        ARtmLocalInvitation *localInvitation = [[ARtmLocalInvitation alloc] initWithCalleeId:receiver];
        localInvitation.content = [ARTCCallingUtils dictionary2JsonStr:dic];
        [self.callEngine sendLocalInvitation:localInvitation completion:^(ARtmInvitationApiCallErrorCode errorCode) {
            ARLog(@"sendLocalInvitation code = %ld", (long)errorCode);
        }];
        [self.callingDic setObject:localInvitation forKey:receiver];
    } else if (action == CallAction_Cancel) {
        /// 取消呼叫邀请
        id invitation = [self.callingDic objectForKey:receiver];
        if (invitation) {
            ARtmLocalInvitation *localInvitation = (ARtmLocalInvitation *)invitation;
            [self.callEngine cancelLocalInvitation:localInvitation completion:^(ARtmInvitationApiCallErrorCode errorCode) {
                ARLog(@"cancelLocalInvitation code = %ld", (long)errorCode);
            }];
        }
    } else if (action == CallAction_Accept) {
        /// 接受呼叫邀请
        id invitation = [self.calledDic objectForKey:receiver];
        if (invitation) {
            ARtmRemoteInvitation *remoteInvitation = (ARtmRemoteInvitation *)invitation;
            NSDictionary *dic = @{@"Mode": @(self.curType == CallType_Video ? 0: 1), @"Conference": [NSNumber numberWithBool:self.isMembers]};
            remoteInvitation.response = [ARTCCallingUtils dictionary2JsonStr:dic];
            [self.callEngine acceptRemoteInvitation:remoteInvitation completion:^(ARtmInvitationApiCallErrorCode errorCode) {
                ARLog(@"acceptRemoteInvitation code = %ld", (long)errorCode);
            }];
        }
    } else if (action == CallAction_Reject) {
        /// 拒绝呼叫邀请
        id invitation = [self.calledDic objectForKey:receiver];
        if (invitation) {
            ARtmRemoteInvitation *remoteInvitation = (ARtmRemoteInvitation *)invitation;
            [self.callEngine refuseRemoteInvitation:remoteInvitation completion:^(ARtmInvitationApiCallErrorCode errorCode) {
                ARLog(@"refuseRemoteInvitation code = %ld", (long)errorCode);
            }];
        }
    } else if (action == CallAction_SwitchToAudio) {
        /// 切换成语音通话
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"SwitchAudio", @"Cmd",nil];
        ARtmMessage *message = [[ARtmMessage alloc] initWithText:[ARTCCallingUtils dictionary2JsonStr:dic]];
        [self sendPeerMessage:message user:receiver];
    } else if (action == CallAction_End) {
        /// 通话中断
        if (!self.isMembers) {
            NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"EndCall", @"Cmd",nil];
            ARtmMessage *message = [[ARtmMessage alloc] initWithText:[ARTCCallingUtils dictionary2JsonStr:dic]];
            [self sendPeerMessage:message user:receiver];
        }
    }
}

- (void)preExitRoom {
    /// 当前房间中存在成员，不能自动退房
    if (self.curRoomList.count > 0) return;
    
    /// 存在正在呼叫的通话
    if (self.curInvitingList.count >= 1) {
        return;
    }
    
    [self exitRoom];
}

- (void)exitRoom {
    ARLog(@"Calling - exitRoom");
    if ([self canDelegateRespondMethod:@selector(onCallEnd)]) {
        [self.delegate onCallEnd];
    }
    
    for (NSString *uid in self.timerDic.allKeys) {
        [self removeTimer:uid];
    }
    
    [self dealWithException:0];
    [self leaveRoom];
    self.isOnCalling = NO;
    
    if(UIApplication.sharedApplication.applicationState == UIApplicationStateBackground) {
        [self logout];
    }
}

// MARK: - privite

- (ARtmCallKit *)callEngine {
    return [ARUILogin.kit getRtmCallKit];
}

- (void)dealWithException:(NSInteger)countdown {
    if (!self.isMembers) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(exitRoom) object:nil];
        if (countdown > 0) {
            [self performSelector:@selector(exitRoom) withObject:nil afterDelay:countdown];
        }
    }
}

- (void)sendPeerMessage:(ARtmMessage *)message user:(NSString *)uid {
    ARLog(@"Calling - sendPeerMessage = %@", message.text);
    ARtmSendMessageOptions *options = [[ARtmSendMessageOptions alloc] init];
    [[ARUILogin kit] sendMessage:message toPeer:uid sendMessageOptions:options completion:^(ARtmSendPeerMessageErrorCode errorCode) {
        ARLog(@"Calling - SendPeerMessage code = %ld", (long)errorCode);
    }];
}

- (void)createMemberChannel {
    if (self.isMembers) {
        self.rtmChannel = [[ARUILogin kit] createChannelWithId:self.curRoomID delegate:self];
        [self.rtmChannel joinWithCompletion:^(ARtmJoinChannelErrorCode errorCode) {
            ARLog(@"Calling - Join RTM Channel code = %ld", (long)errorCode);
        }];
    }
}

- (void)leaveMemberChannel {
    if (self.isMembers) {
        [self.rtmChannel leaveWithCompletion:nil];
        [ARUILogin.kit destroyChannelWithId:self.curRoomID];
    }
}

- (void)removeTimer:(NSString *)uid {
    /// 移除定时器 -- 兼容异常
    if (self.isBeingCalled) {
        if ([self.timerDic.allKeys containsObject:uid]) {
            NSString *timerName = [self.timerDic objectForKey:uid];
            [ARTCGCDTimer canelTimer:timerName];
            [self.timerDic removeObjectForKey:uid];
        }
    }
}

- (void)logout {
    if (!self.isOnCalling && ARUILogin.kit != nil) {
        [ARUILogin.kit logoutWithCompletion:nil];
        self.interrupt = YES;
    }
}

- (void)enterBackground:(NSNotification *)notification {
    [self logout];
}

- (void)becomeActive:(NSNotification *)notification {
    if (!self.isOnCalling && self.interrupt) {
        [ARUILogin.kit loginByToken:nil user:ARUILogin.getUserID completion:nil];
        self.interrupt = NO;
    }
}

//MARK: - ARtmDelegate

- (void)rtmKit:(ARtmKit *)kit connectionStateChanged:(ARtmConnectionState)state reason:(ARtmConnectionChangeReason)reason {
    ARLog(@"Calling - rtm connectionStateChanged state = %ld reason = %ld", (long)state, (long)reason);
    if (reason == ARtmConnectionChangeReasonRemoteLogin) {
        [self.delegate onError:401 msg:@"RemoteLogin"];
        [self exitRoom];
        return;
    }
    
    if (!self.isMembers) {
        if (state == ARtmConnectionStateDisconnected || state == ARtmConnectionStateReconnecting) {
            self.isReconnection = YES;
            [self dealWithException: 30];
            
        } else if (state == ARtmConnectionStateConnected) {
            [self dealWithException:0];
            
            if (self.isReconnection && self.isOnCalling && self.currentCallingUserID) {
                /// 兼容异常
                [self dealWithException:10];
                self.isReconnection = NO;
                NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"CallState", @"Cmd",nil];
                ARtmMessage *message = [[ARtmMessage alloc] initWithText:[ARTCCallingUtils dictionary2JsonStr:dic]];
                [self sendPeerMessage:message user:self.currentCallingUserID];
            }
        }
    }
}

- (void)rtmKit:(ARtmKit *)kit messageReceived:(ARtmMessage *)message fromPeer:(NSString *)peerId {
    /// 收到点对点消息回调
    ARLog(@"Calling - messageReceived text = %@ ", message.text);
    if (message.text.length != 0) {
        NSDictionary *dic = [ARTCCallingUtils jsonSring2Dictionary:message.text];
        NSString *value = [dic objectForKey:@"Cmd"];
        if ([value isEqualToString:@"SwitchAudio"]) {
            /// 切换成语音通话
            if ([self canDelegateRespondMethod:@selector(onSwitchToAudio:message:)]) {
                [self.delegate onSwitchToAudio:YES message:@""];
            }
            self.curType = CallType_Audio;
            
        } else if ([value isEqualToString:@"EndCall"]) {
            /// 结束通话
            if (!self.isMembers) {
                if ([self canDelegateRespondMethod:@selector(onUserLeave:)]) {
                    [self.delegate onUserLeave:peerId];
                }
                [self exitRoom];
            }
        } else if ([value isEqualToString:@"CallState"]) {
            /// 确认通话状态
            NSDictionary *dic;
            if (self.isCallSucess) {
                dic = @{@"Cmd": @"CallStateResult", @"state": @(2), @"Mode": (self.curType == CallType_Video ? @(0) : @(1))};
            } else {
                dic= @{@"Cmd": @"CallStateResult", @"state": @(1)};
            }
            ARtmMessage *message = [[ARtmMessage alloc] initWithText:[ARTCCallingUtils dictionary2JsonStr:dic]];
            [self sendPeerMessage:message user:peerId];
            
        } else if ([value isEqualToString:@"CallStateResult"]) {
            /// 对方通话状态回复结果
            [self dealWithException:0];
            
            int state = [[dic objectForKey:@"state"] intValue];
            if (state == 0) {
                /// 已挂断
                [self exitRoom];
            } else if (state == 1) {
                /// 呼叫等待
            } else {
                /// 已同意
                int mode = [[dic objectForKey:@"Mode"] intValue];
                if (self.curType == CallType_Video && mode == 1) {
                    self.curType = CallType_Audio;
                    [self switchToAudio];
                }
            }
        }
    }
}

//MARK: - ARtmChannelDelegate

- (void)channel:(ARtmChannel * _Nonnull)channel memberJoined:(ARtmMember * _Nonnull)member {
    /// 远端用户加入频道回调
    ARLog(@"Calling - memberJoined = %@", member.uid);
}

- (void)channel:(ARtmChannel * _Nonnull)channel memberLeft:(ARtmMember * _Nonnull)member {
    /// 频道成员离开频道回调
    ARLog(@"Calling - memberLeft = %@", member.uid);
    NSString *uid = member.uid;
    [self removeTimer:uid];
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
}

// MARK: - ARtmCallDelegate

- (void)rtmCallKit:(ARtmCallKit * _Nonnull)callKit localInvitationReceivedByPeer:(ARtmLocalInvitation * _Nonnull)localInvitation {
    /// 被叫已收到呼叫邀请
    ARLog(@"Calling - localInvitationReceivedByPeer");
}

- (void)rtmCallKit:(ARtmCallKit * _Nonnull)callKit localInvitationAccepted:(ARtmLocalInvitation * _Nonnull)localInvitation withResponse:(NSString * _Nullable) response {
    /// 被叫已接受呼叫邀请
    ARLog(@"Calling - localInvitationAccepted response = %@", response);
    [self.callingDic removeObjectForKey:localInvitation.calleeId];
    if (response != nil) {
        NSDictionary * dic = [ARTCCallingUtils jsonSring2Dictionary:response];
        if (self.curType == CallType_Video && [[dic objectForKey:@"Mode"] intValue] == 1) {
            if ([self canDelegateRespondMethod:@selector(onSwitchToAudio:message:)]) {
                [self.delegate onSwitchToAudio:YES message:@""];
            }
            self.curType = CallType_Audio;
        }
    }
    
    self.isCallSucess = YES;
}

- (void)rtmCallKit:(ARtmCallKit * _Nonnull)callKit localInvitationRefused:(ARtmLocalInvitation * _Nonnull)localInvitation withResponse:(NSString * _Nullable) response {
    /// 被叫已拒绝呼叫邀请
    ARLog(@"Calling - localInvitationRefused");
    [self.callingDic removeObjectForKey:localInvitation.calleeId];
    
    BOOL isBusy = NO;
    if (localInvitation.response.length != 0) {
        NSDictionary * dic = [ARTCCallingUtils jsonSring2Dictionary:localInvitation.response];
        if ([dic.allValues containsObject:@"Calling"]) {
            isBusy = YES;
        }
    }
    
    if (self.delegate) {
        NSString *uid = localInvitation.calleeId;
        if ([self.curInvitingList containsObject:uid]) {
            [self.curInvitingList removeObject:uid];
        }
        if (isBusy) {
            if ([self canDelegateRespondMethod:@selector(onLineBusy:)]) {
                [self.delegate onLineBusy:localInvitation.calleeId];
            }
        } else {
            if ([self canDelegateRespondMethod:@selector(onReject:)]) {
                [self.delegate onReject:uid];
            }
        }
        [self preExitRoom];
    }
}

- (void)rtmCallKit:(ARtmCallKit * _Nonnull)callKit localInvitationCanceled:(ARtmLocalInvitation * _Nonnull)localInvitation {
    /// 呼叫邀请已被取消
    ARLog(@"Calling - localInvitationCanceled");
    [self.callingDic removeObjectForKey:localInvitation.calleeId];
}

- (void)rtmCallKit:(ARtmCallKit * _Nonnull)callKit localInvitationFailure:(ARtmLocalInvitation * _Nonnull)localInvitation errorCode:(ARtmLocalInvitationErrorCode)errorCode {
    /// 呼叫邀请发送失败
    ARLog(@"Calling - localInvitationFailure");
    NSString *calleeId = localInvitation.calleeId;
    [self.callingDic removeObjectForKey:calleeId];
    
    if ([self canDelegateRespondMethod:@selector(onNoResp:)]) {
        [self.delegate onNoResp:calleeId];
    }
    if ([self.curInvitingList containsObject:calleeId]) {
        [self.curInvitingList removeObject:calleeId];
    }
    [self preExitRoom];
}

- (void)rtmCallKit:(ARtmCallKit * _Nonnull)callKit remoteInvitationReceived:(ARtmRemoteInvitation * _Nonnull)remoteInvitation {
    /// 收到一个呼叫邀请
    ARLog(@"Calling - remoteInvitationReceived");
    [self.calledDic setObject:remoteInvitation forKey:remoteInvitation.callerId];
    if (!self.isOnCalling) {
        self.isOnCalling = YES;
        self.curSponsorForMe = remoteInvitation.callerId;
        self.currentCallingUserID = remoteInvitation.callerId;
        
        NSDictionary *dic = [ARTCCallingUtils jsonSring2Dictionary:remoteInvitation.content];
        self.isMembers = [[dic objectForKey:@"Conference"] boolValue];
        self.curRoomID = [dic objectForKey:@"ChanId"];
        CallType type = ([[dic objectForKey:@"Mode"] intValue] == 0) ? CallType_Video : CallType_Audio;
        self.curType = type;
        if ([dic.allKeys containsObject:@"UserInfo"]) {
            NSArray *infoArr = [dic objectForKey:@"UserInfo"];
            for (NSInteger i = 0; i < infoArr.count; i++) {
                ARCallUser *user = [ARCallUser ar_objectWithDictionary: infoArr[i]];
                [ARUILogin setCallUserInfo:user];
            }
        }
        
        if (self.isMembers) {
            /// 多人通话
            NSArray *arr = [dic objectForKey:@"UserData"];
            [self.delegate onInvited:remoteInvitation.callerId userIds:arr isFromGroup:NO callType:type];
            [self createMemberChannel];
            
            /// 30s
            for (NSInteger i = 0; i < arr.count; i++) {
                NSString *uid = arr[i];
                /// 被叫对其他受邀者倒计时 -- 异常处理
                if (![uid isEqualToString:[ARUILogin getUserID]] && ![uid isEqualToString:self.curSponsorForMe]) {
                    __block NSInteger totalTime = 0;
                    NSTimeInterval interval = 1.0;
                    __weak typeof(self) weakSelf = self;
                    NSString *timerName = [ARTCGCDTimer timerTask:^{
                        totalTime += (NSInteger)interval;
                        if (totalTime == 30) {
                            if ([weakSelf canDelegateRespondMethod:@selector(onNoResp:)]) {
                                [weakSelf.delegate onNoResp:uid];
                                [weakSelf removeTimer: uid];
                            }
                        }
                        ARLog(@"%@ ==> %ld \n", uid, (long)totalTime);
                    } start:0 interval:interval repeats:YES async:NO];
                    [self.timerDic setObject:timerName forKey:uid];
                }
            }
        } else {
            /// 单人通话
            [self.delegate onInvited:remoteInvitation.callerId userIds:@[[ARUILogin getUserID]] isFromGroup:NO callType:type];
        }
    } else {
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"Calling", @"Cmd",nil];
        remoteInvitation.response = [ARTCCallingUtils dictionary2JsonStr:dic];
        [self invite:remoteInvitation.callerId action:CallAction_Reject];
    }
}

- (void)rtmCallKit:(ARtmCallKit * _Nonnull)callKit remoteInvitationRefused:(ARtmRemoteInvitation * _Nonnull)remoteInvitation {
    /// 拒绝呼叫邀请成功
    ARLog(@"Calling - remoteInvitationRefused");
    [self.calledDic removeObjectForKey:remoteInvitation.callerId];
}

- (void)rtmCallKit:(ARtmCallKit * _Nonnull)callKit remoteInvitationAccepted:(ARtmRemoteInvitation * _Nonnull)remoteInvitation {
    /// 接受呼叫邀请成功
    ARLog(@"Calling - remoteInvitationAccepted");
    [self.calledDic removeObjectForKey:remoteInvitation.callerId];
}

- (void)rtmCallKit:(ARtmCallKit * _Nonnull)callKit remoteInvitationCanceled:(ARtmRemoteInvitation * _Nonnull)remoteInvitation {
    /// 主叫已取消呼叫邀请
    ARLog(@"Calling - remoteInvitationCanceled");
    [self.calledDic removeObjectForKey:remoteInvitation.callerId];
    
    if ([self.curSponsorForMe isEqualToString:remoteInvitation.callerId]) {
        [self exitRoom];
        if ([self canDelegateRespondMethod:@selector(onCallingCancel:)]) {
            [self.delegate onCallingCancel:remoteInvitation.callerId];
        }
    }
}

- (void)rtmCallKit:(ARtmCallKit * _Nonnull)callKit remoteInvitationFailure:(ARtmRemoteInvitation * _Nonnull)remoteInvitation errorCode:(ARtmRemoteInvitationErrorCode) errorCode {
    /// 来自对端的邀请失败
    ARLog(@"Calling - remoteInvitationFailure");
    [self.calledDic removeObjectForKey:remoteInvitation.callerId];
    if (self.delegate) {
        [self preExitRoom];
        self.isOnCalling = NO;
        [self.delegate onCallingTimeOut];
    }
}

@end
