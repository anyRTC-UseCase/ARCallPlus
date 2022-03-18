//
//  ARUICalling.m
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/15.
//

#import "ARUICalling.h"
#import "ARTCCallingDelegate.h"
#import "ARUIInvitedActionProtocal.h"
#import "ARUICallingBaseView.h"
#import "ARTCCalling.h"
#import "ARTCCalling+Signal.h"
#import "ARUICallingAudioPlayer.h"
#import "ARTCGCDTimer.h"
#import "ARUICommonUtil.h"
#import "UIView+ARUIToast.h"
#import "ARUILogin.h"
#import "ARUICallingView.h"
#import "ARUIGroupCallingView.h"

// onCallEvent常用类型定义
NSString *const EVENT_CALL_HANG_UP = @"Hangup";
NSString *const EVENT_CALL_LINE_BUSY = @"LineBusy";
NSString *const EVENT_CALL_CNACEL = @"Cancel";
NSString *const EVENT_CALL_TIMEOUT = @"Timeout";
NSString *const EVENT_CALL_NO_RESP = @"NoResp";
NSString *const EVENT_CALL_SUCCEED = @"Succeed";
NSString *const EVENT_CALL_START = @"Start";
NSString *const EVENT_CALL_DECLINE = @"Decline";
NSString *const EVENT_CALL_REMOTE_LOGIN = @"RemoteLogin";

typedef NS_ENUM(NSUInteger, ARUICallingUserRemoveReason) {
    ARUICallingUserRemoveReasonLeave,
    ARUICallingUserRemoveReasonReject,
    ARUICallingUserRemoveReasonNoresp,
    ARUICallingUserRemoveReasonBusy
};

@interface ARUICalling () <ARTCCallingDelegate, ARUIInvitedActionProtocal>

/// 存储监听者对象
@property (nonatomic, weak) id<ARUICallingListerner> listener;
///Calling 主视图
@property (nonatomic, strong) ARUICallingBaseView *callingView;
/// 记录当前的呼叫类型  语音、视频
@property (nonatomic, assign) ARUICallingType currentCallingType;
/// 记录当前的呼叫用户类型  主动、被动
@property (nonatomic, assign) ARUICallingRole currentCallingRole;
/// 铃声的资源地址
@property (nonatomic, copy) NSString *bellFilePath;
/// 记录是否开启静音模式     需考虑恢复默认页面
@property (nonatomic, assign) BOOL enableMuteMode;
/// 记录是否开启悬浮窗
@property (nonatomic, assign) BOOL enableFloatWindow;
/// 记录是否自定义视图
@property (nonatomic, assign) BOOL enableCustomViewRoute;
/// 记录原始userIDs数据（不包括自己）
@property (nonatomic, strong) NSArray<NSString *> *userIDs;
/// 记录计时器名称
@property (nonatomic, copy) NSString *timerName;
/// 记录通话时间 单位：秒
@property (nonatomic, assign) NSInteger totalTime;

/// 记录是否需要继续播放来电铃声
@property (nonatomic, assign) BOOL needContinuePlaying;

@end

@implementation ARUICalling

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static ARUICalling * t_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        t_sharedInstance = [[ARUICalling alloc] init];
    });
    return t_sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _enableMuteMode = NO;
        _enableFloatWindow = NO;
        _currentCallingRole = NO;
        _enableCustomViewRoute = NO;
        [[ARTCCalling shareInstance] addDelegate:self];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// MARK: - Public method

- (void)call:(NSArray<ARCallUser *> *)users type:(ARUICallingType)type {
    NSMutableArray *userIDs = [NSMutableArray array];
    for (NSInteger i = 0; i < users.count; i++) {
        ARCallUser *callUser = users[i];
        NSString *userId = callUser.userId;
        if (userId.length != 0) {
            if (![userId isEqualToString:[ARUILogin getUserID]]) {
                [userIDs addObject:userId];
                [ARUILogin setCallUserInfo:callUser];
            } else {
                ARLog(@"log: Can't call yourself");
            }
        }
    }
    
    if (![ARUICommonUtil checkArrayValid:userIDs] || userIDs.count == 0) return;
    
    self.userIDs = [NSArray arrayWithArray:userIDs];
    self.currentCallingType = type;
    self.currentCallingRole = ARUICallingRoleCall;
    
    if ([self checkAuthorizationStatusIsDenied]) return;
    if (!self.currentUserId) return;
    
    __weak typeof(self)weakSelf = self;
    [[ARUILogin kit] queryPeersOnlineStatus:userIDs completion:^(NSArray<ARtmPeerOnlineStatus *> * _Nullable peerOnlineStatus, ARtmQueryPeersOnlineErrorCode errorCode) {
        if (errorCode == ARtmQueryPeersOnlineErrorOk) {
            __strong typeof(weakSelf)self = weakSelf;
            NSMutableArray *arr = [NSMutableArray array];
            for (NSInteger i = 0; i < peerOnlineStatus.count; i++) {
                ARtmPeerOnlineStatus *onlineStatus = peerOnlineStatus[i];
                if (onlineStatus.state != ARtmPeerOnlineStateOnline) {
                    [arr addObject:onlineStatus.peerId];
                }
            }
            
            if (self.listener && arr.count != 0) {
                if ([self.listener respondsToSelector:@selector(onPushToOfflineUser:type:)]) {
                    [self.listener onPushToOfflineUser:arr type:type];
                }
            }
        }
    }];
    
    [[ARTCCalling shareInstance] call:userIDs type:[self transformCallingType:type]];
    CallUserModel *model = [self covertUser:[ARUILogin getCallUserInfo:self.currentUserId]];
    
    if (userIDs.count >= 2) {
        [self initCallingViewWithUser:model isGroup:YES];
        NSMutableArray *ids = [NSMutableArray arrayWithArray:userIDs];
        [ids insertObject:self.currentUserId atIndex:0];
        [self configCallViewWithUserIDs:[ids copy] sponsor:nil];
    } else {
        [self initCallingViewWithUser:nil isGroup:NO];
        [self configCallViewWithUserIDs:userIDs sponsor:nil];
    }
    
    [self callStartWithUserIDs:userIDs type:type role:ARUICallingRoleCall];
}

- (void)setCallingListener:(id<ARUICallingListerner>)listener {
    if (listener) {
        self.listener = listener;
    }
}

- (void)setCallingBell:(NSString *)filePath {
    if (filePath && ![filePath hasPrefix:@"http"]) {
        self.bellFilePath = filePath;
    }
}

- (void)enableMuteMode:(BOOL)enable {
    self.enableMuteMode = enable;
    [[ARTCCalling shareInstance] setMicMute:enable];
}

- (void)enableFloatWindow:(BOOL)enable {
    self.enableFloatWindow = enable;
}

- (void)enableCustomViewRoute:(BOOL)enable {
    self.enableCustomViewRoute = enable;
}

// MARK: - Private method

- (void)callStartWithUserIDs:(NSArray *)userIDs type:(ARUICallingType)type role:(ARUICallingRole)role {
    if (self.enableCustomViewRoute && self.listener && [self.listener respondsToSelector:@selector(callStart:type:role:viewController:)]) {
        UIViewController *callVC = [[UIViewController alloc] init];
        callVC.view.backgroundColor = [UIColor clearColor];
        [callVC.view addSubview:self.callingView];
        [self.listener callStart:userIDs type:type role:role viewController:callVC];
    } else {
        [self.callingView show];
    }
    
    if (self.enableMuteMode) {
        return;
    }
    
    if (role == ARUICallingRoleCall) {
        playAudio(CallingAudioTypeDial);
        return;
    }
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        self.needContinuePlaying = YES;
        return;
    }
    
    [self playAudioToCalled];
}

- (void)playAudioToCalled {
    if (self.bellFilePath) {
        playAudioWithFilePath(self.bellFilePath);
    } else {
        playAudio(CallingAudioTypeCalled);
    }
}

- (void)handleStopAudio {
    stopAudio();
    self.needContinuePlaying = NO;
}

- (void)handleCallEnd {
    if (self.enableCustomViewRoute && self.listener && [self.listener respondsToSelector:@selector(callEnd:type:role:totalTime:)]) {
        [self.listener callEnd:self.userIDs type:self.currentCallingType role:self.currentCallingRole totalTime:(CGFloat)self.totalTime];
    }
    
    [ARUILogin removeAllCallUserInfo];
    [self.callingView disMiss];
    self.callingView = nil;
    [self handleStopAudio];
    [ARTCGCDTimer canelTimer:self.timerName];
    [self enableAutoLockScreen:YES];
    self.timerName = nil;
}

- (void)handleCallEvent:(ARUICallingEvent)event message:(NSString *)message {
    if (self.enableCustomViewRoute && self.listener && [self.listener respondsToSelector:@selector(onCallEvent:type:role:message:)]) {
        [self.listener onCallEvent:event type:self.currentCallingType role:self.currentCallingRole message:message];
    }
}

- (void)enableAutoLockScreen:(BOOL)isEnable {
    [UIApplication sharedApplication].idleTimerDisabled = !isEnable;
}

// MARK: - ARUIInvitedActionProtocal

- (void)acceptCalling:(BOOL)isVideo {
    [self handleStopAudio];
    [[ARTCCalling shareInstance] accept:isVideo];
    [self.callingView acceptCalling];
    [self startTimer];
    [self enableAutoLockScreen:NO];
}

- (void)refuseCalling {
    [[ARTCCalling shareInstance] reject];
    [self.callingView refuseCalling];
    [self handleCallEvent:ARUICallingEventCallFailed message:EVENT_CALL_DECLINE];
    [self handleCallEnd];
}

- (void)hangupCalling {
    [[ARTCCalling shareInstance] hangup];
    [self handleCallEvent:ARUICallingEventCallEnd message:EVENT_CALL_HANG_UP];
    [self handleCallEnd];
}

#pragma mark - ARTCCallingDelegate

-(void)onError:(int)code msg:(NSString * _Nullable)msg {
    ARLog(@"onError: code %d, msg %@", code, msg);
    NSString *toast = [NSString stringWithFormat:@"Error code: %d, Message: %@", code, msg];
    if (code != 0) {
        [self makeToast:toast];
    }
    [self handleCallEvent:code message:msg];
}

- (void)onSwitchToAudio:(BOOL)success message:(NSString *)message {
    if (success) {
        [self.callingView switchToAudio];
    }
    if (message && message.length > 0) {
        [self.callingView makeToast:message];
    }
}

- (void)onInvited:(NSString *)sponsor
          userIds:(NSArray<NSString *> *)userIDs
      isFromGroup:(BOOL)isFromGroup
         callType:(CallType)callType {
    ARLog(@"log: onInvited sponsor:%@ userIds:%@", sponsor, userIDs);
    
    if (![ARUICommonUtil checkArrayValid:userIDs]) return;
    
    if (self.listener && [self.listener respondsToSelector:@selector(shouldShowOnCallView)]) {
        if (![self.listener shouldShowOnCallView]) {
            [[ARTCCalling shareInstance] reject];
            [self onLineBusy:@""]; // 仅仅提示用户忙线，不做calling处理
            return;
        }
    }
    
    self.userIDs = [NSArray arrayWithArray:userIDs];
    self.currentCallingRole = ARUICallingRoleCalled;
    self.currentCallingType = [self transformCallType:callType];
    
    if ([self checkAuthorizationStatusIsDenied]) return;
    
    if (userIDs.count > 2) {
        CallUserModel *model = [self covertUser:[ARUILogin getCallUserInfo:self.currentUserId]];
        [self initCallingViewWithUser:model isGroup:YES];
        [self callStartWithUserIDs:userIDs type:[self transformCallType:callType] role:ARUICallingRoleCalled];
        [self refreshCallingViewWithUserIDs:userIDs sponsor:sponsor];
    } else {
        [self initCallingViewWithUser:nil isGroup:NO];
        [self callStartWithUserIDs:userIDs type:[self transformCallType:callType] role:ARUICallingRoleCalled];
        [self refreshCallingViewWithUserIDs:userIDs sponsor:sponsor];
    }
}

- (void)initCallingViewWithUser:(CallUserModel *)userModel isGroup:(BOOL)isGroup {
    ARUICallingBaseView *callingView = nil;
    BOOL isCallee = (self.currentCallingRole == ARUICallingRoleCalled);
    BOOL isVideo = (self.currentCallingType == ARUICallingTypeVideo);
    
    if (isGroup) {
        callingView = (ARUICallingBaseView *)[[ARUIGroupCallingView alloc] initWithUser:userModel isVideo:isVideo isCallee:isCallee];
    } else {
        callingView = (ARUICallingBaseView *)[[ARUICallingView alloc] initWithIsVideo:isVideo isCallee:isCallee];
    }
    
    callingView.actionDelegate = self;
    self.callingView =  callingView;
}

- (void)refreshCallingViewWithUserIDs:(NSArray<NSString *> *)userIDs sponsor:(NSString *)sponsor {
    // 查询用户信息
    ARCallUser *curUserInfo = [ARUILogin getCallUserInfo:sponsor];
    [self configCallViewWithUserIDs:userIDs sponsor:[self covertUser:curUserInfo isEnter:true]];
}

- (void)onGroupCallInviteeListUpdate:(NSArray *)userIds {
    ARLog(@"log: onGroupCallInviteeListUpdate userIds:%@", userIds);
}

- (void)onUserEnter:(NSString *)uid {
    ARLog(@"log: onUserEnter: %@", uid);
    [self handleStopAudio];
    
    ARCallUser *userInfo = [ARUILogin getCallUserInfo:uid];
    [self startTimer];
    [self enableAutoLockScreen:NO];
    CallUserModel *userModel = [self covertUser:userInfo];
    [self.callingView enterUser:userModel];
}

- (void)onUserLeave:(NSString *)uid {
    ARLog(@"log: onUserLeave: %@", uid);
    [self removeUserFromCallVC:uid removeReason:ARUICallingUserRemoveReasonLeave];
}

- (void)onReject:(NSString *)uid {
    ARLog(@"log: onReject: %@", uid);
    [self removeUserFromCallVC:uid removeReason:ARUICallingUserRemoveReasonReject];
}

- (void)onNoResp:(NSString *)uid {
    ARLog(@"log: onNoResp: %@", uid);
    [self removeUserFromCallVC:uid removeReason:ARUICallingUserRemoveReasonNoresp];
}

- (void)onLineBusy:(NSString *)uid {
    ARLog(@"log: onLineBusy: %@", uid);
    [self removeUserFromCallVC:uid removeReason:ARUICallingUserRemoveReasonBusy];
}

- (void)onCallingCancel:(NSString *)uid {
    ARLog(@"log: onCallingCancel: %@", uid);
    [self makeToast:@"取消了通话" uid:uid];
    [self handleCallEnd];
    [self handleCallEvent:ARUICallingEventCallFailed message:EVENT_CALL_CNACEL];
}

- (void)onCallingTimeOut {
    ARLog(@"log: onCallingTimeOut");
    [self makeToast:@"通话超时"];
    [self handleCallEnd];
    [self handleCallEvent:ARUICallingEventCallFailed message:EVENT_CALL_TIMEOUT];
}

- (void)onCallEnd {
    ARLog(@"onCallEnd \n %s", __FUNCTION__);
    [self handleCallEnd];
    [self handleCallEvent:ARUICallingEventCallEnd message:EVENT_CALL_HANG_UP];
}

- (void)onUserAudioAvailable:(NSString *)uid available:(BOOL)available {
    ARLog(@"log: onUserAudioAvailable: %@, available: %d",uid, available);
    if (self.callingView) {
        CallUserModel *userModel = [self.callingView getUserById:uid];
        if (userModel) {
            userModel.isEnter = YES;
            userModel.isAudioAvaliable = available;
            [self.callingView updateUser:userModel animated:NO];
        }
    }
}

- (void)onUserVoiceVolume:(NSString *)uid volume:(UInt32)volume {
    if (!self.callingView) return;
    CallUserModel *user = [self.callingView getUserById:uid];
    
    if (user) {
        CallUserModel *newUser = user;
        newUser.isEnter = YES;
        newUser.volume = (CGFloat)volume / 100;
        [self.callingView updateUserVolume:newUser];
    }
}

- (void)onUserVideoAvailable:(NSString *)uid available:(BOOL)available {
    ARLog(@"log: onUserVideoAvailable: %@ available: %d", uid, available);
    if (self.callingView) {
        CallUserModel *userModel = [self.callingView getUserById:uid];
        
        if (userModel) {
            userModel.isEnter = YES;
            userModel.isVideoAvaliable = available;
            [self.callingView updateUser:userModel animated:NO];
        } else {
            ARCallUser *userInfo =  [ARUILogin getCallUserInfo:uid];
            CallUserModel *newUser = [self covertUser:userInfo];
            newUser.isVideoAvaliable = available;
            [self.callingView enterUser:newUser];
        }
    }
}

- (void)removeUserFromCallVC:(NSString *)uid removeReason:(ARUICallingUserRemoveReason)removeReason {
    if (!self.callingView) return;
    
    ARCallUser *userInfo = [ARUILogin getCallUserInfo:uid];
    if (!userInfo) return;

    CallUserModel *callUserModel = [self covertUser:userInfo];
    [self.callingView leaveUser:callUserModel];

    NSString *toast = @"";
    switch (removeReason) {
        case ARUICallingUserRemoveReasonReject:
            if (![ARTCCalling shareInstance].isBeingCalled) {
                toast = @"拒绝了通话";
            }
            [self handleCallEvent:ARUICallingEventCallFailed message:EVENT_CALL_HANG_UP];
            break;
        case ARUICallingUserRemoveReasonNoresp:
            toast = @"未响应";
            [self handleCallEvent:ARUICallingEventCallFailed message:EVENT_CALL_NO_RESP];
            break;
        case ARUICallingUserRemoveReasonBusy:
            toast = @"忙线";
            [self handleCallEvent:ARUICallingEventCallFailed message:EVENT_CALL_LINE_BUSY];
            break;
        case ARUICallingUserRemoveReasonLeave:
            toast = @"已挂断";
            [self handleCallEvent:ARUICallingEventCallEnd message:EVENT_CALL_HANG_UP];
            break;
        default:
            break;
    }

    if (toast && toast.length > 0) {
        NSString *userStr = callUserModel.name ?: callUserModel.userId;
        toast = [NSString stringWithFormat:@"%@ %@", userStr, toast];
        [self makeToast:toast];
    }
}

- (void)configCallViewWithUserIDs:(NSArray<NSString *> *)userIDs sponsor:(CallUserModel *)sponsor {
    NSMutableArray <CallUserModel *> *modleList = [NSMutableArray array];
    for (NSInteger i = 0 ; i < userIDs.count; i++) {
        NSString *uid = userIDs[i];
        ARCallUser *userInfo = [ARUILogin getCallUserInfo:uid];
        [modleList addObject:[self covertUser:userInfo]];
        if (modleList.count == userIDs.count) {
            if (sponsor && ![userIDs containsObject:sponsor.userId]) {
                [modleList addObject:sponsor];
            }
            [self.callingView configViewWithUserList:[modleList copy] sponsor:sponsor];
        }
    }
}

//MARK: - Private method

- (void)makeToast:(NSString *)toast uid:(NSString *)uid {
    if (uid && uid.length > 0) {
        ARCallUser *userFullInfo = [ARUILogin getCallUserInfo:uid];
        NSString *toastStr = [NSString stringWithFormat:@"%@ %@", userFullInfo.userName ?: userFullInfo.userId, toast];
        [self makeToast:toastStr duration:3 position:nil];
        return;
    }
    [self makeToast:toast duration:3 position:nil];
}

- (void)makeToast:(NSString *)toast {
    [self makeToast:toast duration:3 position:nil];
}

- (void)makeToast:(NSString *)toast duration:(NSTimeInterval)duration position:(id)position {
    if (!toast || toast.length <= 0)  return;
    
    [[ARUICommonUtil getRootWindow] makeToast:toast duration:duration position:position];
}

- (NSString *)currentUserId {
    return [ARUILogin getUserID];
}

- (CallType)transformCallingType:(ARUICallingType)type {
    CallType callType = CallType_Unknown;
    switch (type) {
        case ARUICallingTypeVideo:
            callType = CallType_Video;
            break;
        case ARUICallingTypeAudio:
        default:
            callType = CallType_Audio;
            break;
    }
    return callType;
}

- (ARUICallingType)transformCallType:(CallType)type {
    ARUICallingType callingType = ARUICallingTypeAudio;
    if (type == CallType_Video) {
        callingType = ARUICallingTypeVideo;
    }
    return callingType;
}

- (CallUserModel *)covertUser:(ARCallUser *)user {
    return [self covertUser:user volume:0 isEnter:NO];
}

- (CallUserModel *)covertUser:(ARCallUser *)user isEnter:(BOOL)isEnter {
    return [self covertUser:user volume:0 isEnter:isEnter];
}

- (CallUserModel *)covertUser:(ARCallUser *)user volume:(NSUInteger)volume isEnter:(BOOL)isEnter {
    CallUserModel *dstUser = [[CallUserModel alloc] init];
    dstUser.name = user.userName;
    dstUser.avatar = user.headerUrl;
    dstUser.userId = user.userId;
    dstUser.isEnter = isEnter ? YES : NO;
    dstUser.volume = (CGFloat)volume / 100.0f;
    CallUserModel *oldUser = [self.callingView getUserById:user.userId];

    if (oldUser) {
        dstUser.isVideoAvaliable = oldUser.isVideoAvaliable;
    }
    return dstUser;
}

- (BOOL)checkAuthorizationStatusIsDenied {
    AVAuthorizationStatus statusAudio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    AVAuthorizationStatus statusVideo = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (statusAudio == AVAuthorizationStatusDenied) {
        [[ARUICommonUtil getRootWindow] makeToast:@"获取麦克风权限失败，请前往隐私-麦克风设置里面打开应用权限"];
        return YES;
    }
    if ((self.currentCallingType == ARUICallingTypeVideo) && (statusVideo == AVAuthorizationStatusDenied)) {
        [[ARUICommonUtil getRootWindow] makeToast:@"获取摄像头权限失败，请前往隐私-相机设置里面打开应用权限"];
        return YES;
    }
    return NO;
}

- (void)startTimer {
    if (self.timerName.length) return;
    
    [self handleCallEvent:ARUICallingEventCallSucceed message:EVENT_CALL_SUCCEED];
    [self handleCallEvent:ARUICallingEventCallStart message:EVENT_CALL_START];
    self.totalTime = 0;
    NSTimeInterval interval = 1.0;
    __weak typeof(self) weakSelf = self;
    self.timerName = [ARTCGCDTimer timerTask:^{
        self.totalTime += (NSInteger)interval;
        NSString *minutes = [NSString stringWithFormat:@"%@%ld", (weakSelf.totalTime / 60 < 10) ? @"0" : @"" , (NSInteger)(self.totalTime / 60)];
        NSString *seconds = [NSString stringWithFormat:@"%@%ld", (weakSelf.totalTime % 60 < 10) ? @"0" : @"" , weakSelf.totalTime % 60];
        [weakSelf.callingView setCallingTimeStr:[NSString stringWithFormat:@"%@ : %@", minutes, seconds]];
    } start:0 interval:interval repeats:YES async:NO];
}


@end
