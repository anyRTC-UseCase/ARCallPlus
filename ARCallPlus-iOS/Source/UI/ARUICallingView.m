//
//  ARUICallingView.m
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/17.
//

#import "ARUICallingView.h"
#import "ARUIAudioUserContainerView.h"
#import "ARUIVideoUserContainerView.h"
#import "ARUILogin.h"

static CGFloat const kSmallVideoViewWidth = 100.0f;

@interface ARUICallingView()

/// 记录Calling当前的状态
@property (nonatomic, assign) ARUICallingState curCallingState;

/// 记录远程通话人信息
@property (nonatomic, strong) CallUserModel *remoteSponsor;

/// 通话时间按钮
@property (nonatomic, strong) UILabel *callingTime;

/// 关闭麦克风按钮
@property (nonatomic, strong) ARUICallingControlButton *muteBtn;

/// 挂断按钮
@property (nonatomic, strong) ARUICallingControlButton *hangupBtn;

/// 免提按钮
@property (nonatomic, strong) ARUICallingControlButton *handsfreeBtn;

/// 接听控制视图
@property (nonatomic, strong) ARUIInvitedContainerView *invitedContainerView;

/// 远程音频用户信息视图
@property (nonatomic, strong) ARUIAudioUserContainerView *audioUserContainerView;

/** 视频相关处理 */

/// 远程视频用户信息视图
@property (nonatomic, strong) ARUIVideoUserContainerView *videoUserContainerView;

/// 视频通话 - 视频的渲染视图 - 本地视图
@property (nonatomic, strong) ARUICallingVideoRenderView *localPreView;

/// 视频通话 - 视频的渲染视图 - 远程视图
@property (nonatomic, strong) ARUICallingVideoRenderView *remotePreView;

/// 关闭摄像头
@property (nonatomic, strong) ARUICallingControlButton *closeCameraBtn;

/// 视频通话 - 用于切换摄像头的按钮
@property (nonatomic, strong) UIButton *switchCameraBtn;

/// 视频通话 - 用于切换到语音按钮
@property (nonatomic, strong) ARUICallingControlButton *switchToAudioBtn;

/// 记录是本地预览大图
@property (nonatomic, assign) BOOL isLocalPreViewLarge;

/// 记录是否为前置相机
@property (nonatomic, assign) BOOL isFrontCamera;

/// 标记是否需要清除页面
@property (nonatomic, assign) BOOL isClearFlag;

/// 麦克风 / 切换音频和听筒状态记录
@property (nonatomic, assign) BOOL isMicMute;
@property (nonatomic, assign) BOOL isHandsFreeOn;
@property (nonatomic, assign) BOOL isSwitchedToAudio;
@property (nonatomic, assign) BOOL isCloseCamera;

@end

@implementation ARUICallingView

- (instancetype)initWithIsVideo:(BOOL)isVideo isCallee:(BOOL)isCallee {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.isVideo = isVideo;
        self.isCallee = isCallee;
        self.isClearFlag = NO;
        
        if (isVideo) {
            self.isLocalPreViewLarge = YES;
            self.isFrontCamera = YES;
            self.isHandsFreeOn = YES;
        } else {
            self.isHandsFreeOn = NO;
        }
        
        [self setupUI];
        [[ARTCCalling shareInstance] setHandsFree:self.isHandsFreeOn];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor t_colorWithHexString:@"#F4F5F9"];
    if (self.isVideo) {
        self.backgroundColor = [UIColor t_colorWithHexString:@"#242424"];
        // 设置背景视频试图
        [[ARTCCalling shareInstance] openCamera:self.isFrontCamera view:self.localPreView];
    }
    _curCallingState = self.isCallee ? ARUICallingStateOnInvitee : ARUICallingStateDailing;
    self.switchToAudioBtn.hidden = !self.isCallee;
}

/// 音频通话，主叫方UI初始化
- (void)iniARUIForAudioCaller {
    [self addSubview:self.audioUserContainerView];
    [self addSubview:self.callingTime];
    [self addSubview:self.muteBtn];
    [self addSubview:self.hangupBtn];
    [self addSubview:self.handsfreeBtn];
    // 视图约束
    [self.audioUserContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(StatusBar_Height + 74);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
    }];
    [self.callingTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.bottom.equalTo(self.hangupBtn.mas_top).offset(-10);
        make.height.equalTo(@(30));
    }];
    [self.muteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.hangupBtn.mas_left);
        make.bottom.equalTo(self.hangupBtn);
        make.size.equalTo(@(kControlBtnSize));
    }];
    [self.hangupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_top).offset(self.frame.size.height - Bottom_SafeHeight - 20);
        make.size.equalTo(@(kControlBtnSize));
    }];
    [self.handsfreeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.hangupBtn.mas_right);
        make.bottom.equalTo(self.hangupBtn);
        make.size.equalTo(@(kControlBtnSize));
    }];
    self.callingTime.textColor = [UIColor t_colorWithHexString:@"#333333"];
    [self.muteBtn configTitleColor:[UIColor t_colorWithHexString:@"#666666"]];
    [self.hangupBtn configTitleColor:[UIColor t_colorWithHexString:@"#666666"]];
    [self.handsfreeBtn configTitleColor:[UIColor t_colorWithHexString:@"#666666"]];
}

/// 音频通话，被呼叫方UI初始化
- (void)iniARUIForAudioCallee {
    [self addSubview:self.audioUserContainerView];
    [self addSubview:self.invitedContainerView];
    // 视图约束
    [self.audioUserContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(StatusBar_Height + 74);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
    }];
    [self.invitedContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerX.equalTo(self).offset(60);
        make.right.centerX.equalTo(self).offset(-60);
        make.height.equalTo(@(94));
        make.bottom.equalTo(self).offset(-Bottom_SafeHeight - 20);
    }];
    [self.invitedContainerView configTitleColor:[UIColor t_colorWithHexString:@"#666666"]];
}

/// 视频通话，主叫方UI初始化
- (void)iniARUIForVideoCaller {
    [self addSubview:self.remotePreView];
    [self addSubview:self.localPreView];
    [self addSubview:self.videoUserContainerView];
    [self addSubview:self.switchCameraBtn];
    [self addSubview:self.switchToAudioBtn];
    [self addSubview:self.hangupBtn];
    // 视图约束
    [self.switchCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(StatusBar_Height + 20);
        make.left.equalTo(self).offset(20);
        make.width.height.equalTo(@(32));
    }];
    [self.videoUserContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(StatusBar_Height + 20);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
    }];
    [self.switchToAudioBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.hangupBtn.mas_top).offset(-10);
        make.size.equalTo(@(CGSizeMake(200, 46)));
    }];
    [self.hangupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_top).offset(self.frame.size.height - Bottom_SafeHeight - 20);
        make.size.equalTo(@(kControlBtnSize));
    }];
    self.localPreView.hidden = NO;
    [self.hangupBtn configTitleColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
}

/// 视频通话， 功能控制试图（时间，摄像头，麦克风，免提）
- (void)iniARUIForVideoControl {
    self.switchToAudioBtn.hidden = NO;
    [self addSubview:self.callingTime];
    [self addSubview:self.muteBtn];
    [self addSubview:self.handsfreeBtn];
    [self addSubview:self.closeCameraBtn];
    // 视图约束
    [self.callingTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.switchToAudioBtn.mas_top).offset(-10);
        make.height.equalTo(@(30));
    }];
    [self.switchToAudioBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.handsfreeBtn.mas_top).offset(-10);
        make.size.equalTo(@(CGSizeMake(200, 46)));
    }];
    [self.muteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.handsfreeBtn.mas_left);
        make.centerY.equalTo(self.handsfreeBtn);
        make.size.equalTo(@(kControlBtnSize));
    }];
    [self.handsfreeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.hangupBtn.mas_top).offset(-10);
        make.size.equalTo(@(kControlBtnSize));
    }];
    [self.closeCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.handsfreeBtn.mas_right);
        make.centerY.equalTo(self.handsfreeBtn);
        make.size.equalTo(@(kControlBtnSize));
    }];
    
    [self.handsfreeBtn configBackgroundImage:[ARUICommonUtil getBundleImageWithName:@"icon_handsfree_on"]];
    self.callingTime.textColor = [UIColor t_colorWithHexString:@"#FFFFFF"];
    [self.muteBtn configTitleColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
    [self.handsfreeBtn configTitleColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
    [self.hangupBtn configTitleColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
}

/// 视频通话，被呼叫方UI初始化
- (void)iniARUIForVideoCallee {
    [self addSubview:self.localPreView];
    [self addSubview:self.videoUserContainerView];
    [self addSubview:self.invitedContainerView];
    [self addSubview:self.switchToAudioBtn];
    // 视图约束
    [self.videoUserContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(StatusBar_Height + 32);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
    }];
    [self.invitedContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerX.equalTo(self).offset(60);
        make.right.centerX.equalTo(self).offset(-60);
        make.height.equalTo(@(94));
        make.bottom.equalTo(self).offset(-Bottom_SafeHeight - 20);
    }];
    [self.switchToAudioBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.invitedContainerView.mas_top).offset(-10);
        make.size.equalTo(@(CGSizeMake(200, 46)));
    }];
    self.localPreView.hidden = NO;
    [self.invitedContainerView configTitleColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
}

#pragma mark - Puilic

- (void)switchToAudio {
    self.isVideo = NO;
    self.isClearFlag = YES;
    self.backgroundColor = [UIColor t_colorWithHexString:@"#F4F5F9"];
    
    [[ARTCCalling shareInstance] closeCamara];
    if (self.isHandsFreeOn) {
        [self hangsfreeTouchEvent:nil];
    }
    [self setCurCallingState:self.curCallingState];
}

- (void)setCurCallingState:(ARUICallingState)curCallingState {
    _curCallingState = curCallingState;
    
    if (self.isClearFlag) {
        self.isClearFlag = NO;
        [self clearAllSubViews];
    }
    
    switch (curCallingState) {
        case ARUICallingStateOnInvitee: {
            self.callingTime.hidden = YES;
            
            if (self.isVideo) {
                [self iniARUIForVideoCallee];
                [self.videoUserContainerView configUserInfoViewWith:self.remoteSponsor showWaitingText:@"邀请你视频通话"];
            } else {
                [self iniARUIForAudioCallee];
                [self.audioUserContainerView configUserInfoViewWith:self.remoteSponsor showWaitingText:@"邀请你音频通话"];
            }
        } break;
        case ARUICallingStateDailing: {
            self.callingTime.hidden = YES;
            
            if (self.isVideo) {
                [self iniARUIForVideoCaller];
                [self.videoUserContainerView configUserInfoViewWith:self.remoteSponsor showWaitingText:@"等待对方接受"];
            } else {
                [self iniARUIForAudioCaller];
                [self.audioUserContainerView configUserInfoViewWith:self.remoteSponsor showWaitingText:@"等待对方接受"];
            }
        } break;
        case ARUICallingStateCalling: {
            self.callingTime.hidden = NO;
            if (self.isVideo) {
                [self iniARUIForVideoCaller];
                [self iniARUIForVideoControl];
                self.videoUserContainerView.hidden = YES;
                // 主叫接通，互换本地/远程视频页面位置
                [self setRemotePreViewWith:self.remoteSponsor];
                [self switchTo2UserPreView];
                if (self.isCloseCamera) {
                    self.localPreView.hidden = YES;
                }
                [self.videoUserContainerView configUserInfoViewWith:self.remoteSponsor showWaitingText:@""];
            } else {
                [self iniARUIForAudioCaller];
                [self.audioUserContainerView configUserInfoViewWith:self.remoteSponsor showWaitingText:@""];
            }
        } break;
        default:
            break;
    }
}

- (void)clearAllSubViews {
    if (_localPreView != nil && self.localPreView.superview != nil) {
        self.localPreView.hidden = YES;
        [self.localPreView removeFromSuperview];
    }
    if (_remotePreView != nil && self.remotePreView.superview != nil) {
        self.remotePreView.hidden = YES;
        [self.remotePreView removeFromSuperview];
    }
    if (_videoUserContainerView != nil && self.videoUserContainerView.superview != nil) {
        [self.videoUserContainerView removeFromSuperview];
    }
    if (_invitedContainerView != nil && self.invitedContainerView.superview != nil) {
        [self.invitedContainerView removeFromSuperview];
    }
    if (_callingTime != nil && self.callingTime.superview != nil) {
        [self.callingTime removeFromSuperview];
    }
    if (_switchToAudioBtn != nil && self.switchToAudioBtn.superview != nil) {
        [self.switchToAudioBtn removeFromSuperview];
    }
    if (_muteBtn != nil && self.muteBtn.superview != nil) {
        [self.muteBtn removeFromSuperview];
    }
    if (_hangupBtn != nil && self.hangupBtn.superview != nil) {
        [self.hangupBtn removeFromSuperview];
    }
    if (_handsfreeBtn != nil && self.handsfreeBtn.superview != nil) {
        [self.handsfreeBtn removeFromSuperview];
    }
    if (_closeCameraBtn != nil && self.closeCameraBtn.superview != nil) {
        [self.closeCameraBtn removeFromSuperview];
    }
    if (_switchCameraBtn != nil && self.switchCameraBtn.superview != nil) {
        [self.switchCameraBtn removeFromSuperview];
    }
    if (_audioUserContainerView != nil && self.audioUserContainerView.superview != nil) {
        [self.audioUserContainerView removeFromSuperview];
    }
}

- (void)configViewWithUserList:(NSArray<CallUserModel *> *)userList sponsor:(CallUserModel *)sponsor {
    if (sponsor) {
        self.isClearFlag = YES;
        self.remoteSponsor = sponsor;
        self.curCallingState = ARUICallingStateOnInvitee;
    } else {
        self.remoteSponsor = [userList firstObject];
        self.curCallingState = ARUICallingStateDailing;
    }
}

- (void)configAudioCallView {
    NSString *showText = @"";
    
    if (!self.isCallee && self.curCallingState != ARUICallingStateCalling) {
        // 等待对方接听
        showText = @"等待对方接受";
    }
    
    if (self.curCallingState == ARUICallingStateCalling) {
        self.callingTime.hidden = NO;
    } else {
        self.callingTime.hidden = YES;
    }
    
    // 刷新远程用户信息视图
    [self.audioUserContainerView configUserInfoViewWith:self.remoteSponsor showWaitingText:showText];
}

- (void)setRemotePreViewWith:(CallUserModel *)user{
    if (user.userId != [ARUILogin getUserID]) {
        self.remotePreView.hidden = NO;
        [self.remotePreView configViewWithUserModel:user];
        [[ARTCCalling shareInstance] startRemoteView:user.userId view:self.remotePreView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [self.remotePreView addGestureRecognizer:tap];
        [pan requireGestureRecognizerToFail:tap];
        [self.remotePreView addGestureRecognizer:pan];
    }
}

- (void)enterUser:(CallUserModel *)user {
    self.curCallingState = ARUICallingStateCalling;
    [self updateUser:user animated:YES];
}

- (void)updateUser:(CallUserModel *)user animated:(BOOL)animated {
    self.remotePreView.hidden = !user.isVideoAvaliable;
    
    if (self.remoteSponsor.userId == user.userId) {
        self.remoteSponsor = user;
    }
}

- (void)updateUserVolume:(CallUserModel *)user {
    if (self.remoteSponsor.userId == user.userId) {
        [self.remotePreView configViewWithUserModel:user];
    }
}

- (CallUserModel *)getUserById:(NSString *)userId {
    if (self.remoteSponsor.userId == userId) {
        return self.remoteSponsor;
    }
    return Nil;
}

- (void)acceptCalling {
    self.isClearFlag = YES;
    self.curCallingState = ARUICallingStateCalling;
}

- (void)refuseCalling {
    self.localPreView = nil;
    self.remotePreView = nil;
}

- (void)setCallingTimeStr:(NSString *)timeStr {
    if (timeStr && timeStr.length > 0) {
        self.callingTime.text = timeStr;
    }
}

#pragma mark - Event Action

- (void)muteTouchEvent:(UIButton *)sender {
    self.isMicMute = !self.isMicMute;
    [[ARTCCalling shareInstance] setMicMute:self.isMicMute];
    [self.muteBtn configBackgroundImage:[ARUICommonUtil getBundleImageWithName:self.isMicMute ? @"icon_mute_on" : @"icon_mute"]];
}

- (void)hangupTouchEvent:(UIButton *)sender {
    if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(hangupCalling)]) {
        [self.actionDelegate hangupCalling];
    }
}

- (void)hangsfreeTouchEvent:(UIButton *)sender {
    self.isHandsFreeOn = !self.isHandsFreeOn;
    [[ARTCCalling shareInstance] setHandsFree:self.isHandsFreeOn];
    [self.handsfreeBtn configBackgroundImage:[ARUICommonUtil getBundleImageWithName:self.isHandsFreeOn ? @"icon_handsfree_on" : @"icon_handsfree"]];
}

- (void)switchCameraTouchEvent:(UIButton *)sender {
    self.isFrontCamera = !self.isFrontCamera;
    [[ARTCCalling shareInstance] switchCamera:self.isFrontCamera];
}

- (void)closeCameraTouchEvent:(UIButton *)sender {
    self.isCloseCamera = !self.isCloseCamera;
    [self.closeCameraBtn setUserInteractionEnabled:NO];
    
    [self.closeCameraBtn configBackgroundImage:[ARUICommonUtil getBundleImageWithName:self.isCloseCamera ? @"icon_camera_off" : @"icon_camera_on"]];
    
    if (self.isCloseCamera) {
        [[ARTCCalling shareInstance] closeCamara];
        self.localPreView.hidden = YES;
    } else {
        [[ARTCCalling shareInstance] openCamera:self.isFrontCamera view:self.localPreView];
        self.localPreView.hidden = NO;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.closeCameraBtn setUserInteractionEnabled:YES];
    });
    
    self.localPreView.hidden = self.isCloseCamera;
}

- (void)switchToAudioTouchEvent:(UIButton *)sender {
    if (self.curCallingState == ARUICallingStateOnInvitee) {
        if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(acceptCalling:)]) {
            [self.actionDelegate acceptCalling:NO];
        }
    } else if (self.curCallingState == ARUICallingStateCalling) {
        [[ARTCCalling shareInstance] switchToAudio];
    }
}

#pragma mark - Private

- (void)switchTo2UserPreView {
    if (!self.remotePreView || self.isLocalPreViewLarge == NO) return;
    
    [self.localPreView setUserInteractionEnabled:YES];
    [[self.localPreView.subviews firstObject] setUserInteractionEnabled: NO];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.localPreView.frame = CGRectMake(self.frame.size.width - kSmallVideoViewWidth - 18, StatusBar_Height + 20, kSmallVideoViewWidth, kSmallVideoViewWidth / 9.0 * 16.0);
        
        self.remotePreView.frame = self.frame;
    } completion:^(BOOL finished) {
        [self.remotePreView removeFromSuperview];
        [self insertSubview:self.remotePreView belowSubview:self.localPreView];
        self.isLocalPreViewLarge = NO;
    }];
}

- (void)switchPreView {
    if (!self.remotePreView) {
        return;
    }
    
    ARUICallingVideoRenderView *remoteView = self.remotePreView;
    
    if (_isLocalPreViewLarge) {
        remoteView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            remoteView.frame = self.frame;
            self.localPreView.frame = CGRectMake(self.frame.size.width - kSmallVideoViewWidth - 18, StatusBar_Height + 20, kSmallVideoViewWidth, kSmallVideoViewWidth / 9.0 * 16.0);
        } completion:^(BOOL finished) {
            [remoteView removeFromSuperview];
            [self insertSubview:remoteView belowSubview:self.localPreView];
            
            if (self.localPreView.isHidden || remoteView.isHidden) {
                [self.localPreView setUserInteractionEnabled:NO];
                [remoteView setUserInteractionEnabled:NO];
            } else {
                [self.localPreView setUserInteractionEnabled:YES];
            }
        }];
    } else {
        self.localPreView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.localPreView.frame = self.frame;
            remoteView.frame = CGRectMake(self.frame.size.width - kSmallVideoViewWidth - 18, StatusBar_Height + 20, kSmallVideoViewWidth, kSmallVideoViewWidth / 9.0 * 16.0);
        } completion:^(BOOL finished) {
            [self.localPreView removeFromSuperview];
            [self insertSubview:self.localPreView belowSubview:remoteView];
            self.remotePreView = remoteView;
            
            if (self.localPreView.isHidden || remoteView.isHidden) {
                [self.localPreView setUserInteractionEnabled:NO];
                [remoteView setUserInteractionEnabled:NO];
            } else {
                [remoteView setUserInteractionEnabled:YES];
            }
        }];
    }
    
    self.isLocalPreViewLarge = !_isLocalPreViewLarge;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    if ([tapGesture view].frame.size.width == kSmallVideoViewWidth) {
        [self switchPreView];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (!panGesture || !panGesture.view) {
        return;
    }
    
    UIView *smallView = panGesture.view;
    
    if (smallView.frame.size.width == kSmallVideoViewWidth) {
        if (panGesture.state == UIGestureRecognizerStateChanged) {
            CGPoint translation = [panGesture translationInView:self];
            CGFloat newCenterX = translation.x + (smallView.center.x);
            CGFloat newCenterY = translation.y + (smallView.center.y);
            
            if ((newCenterX < (smallView.bounds.size.width / 2.0)) || (newCenterX > self.bounds.size.width - (smallView.bounds.size.width) / 2)) {
                return;
            }
            
            if ((newCenterY < (smallView.bounds.size.height) / 2) ||
                (newCenterY > self.bounds.size.height - (smallView.bounds.size.height) / 2))  {
                return;
            }
            
            [UIView animateWithDuration:0.1 animations:^{
                smallView.center = CGPointMake(newCenterX, newCenterY);
            }];
            
            [panGesture setTranslation:CGPointZero inView:self];
        }
    }
}

#pragma mark - Lazy

- (ARUIAudioUserContainerView *)audioUserContainerView {
    if (!_audioUserContainerView) {
        _audioUserContainerView = [[ARUIAudioUserContainerView alloc] initWithFrame:CGRectZero];
    }
    return _audioUserContainerView;
}

- (UILabel *)callingTime {
    if (!_callingTime) {
        _callingTime = [[UILabel alloc] initWithFrame:CGRectZero];
        _callingTime.font = [UIFont boldSystemFontOfSize:14.0f];
        [_callingTime setTextColor:[UIColor t_colorWithHexString:@"#333333"]];
        [_callingTime setBackgroundColor:[UIColor clearColor]];
        [_callingTime setText:@"00:00"];
        [_callingTime setTextAlignment:NSTextAlignmentCenter];
    }
    return _callingTime;
}

- (ARUICallingControlButton *)muteBtn {
    if (!_muteBtn) {
        __weak typeof(self) weakSelf = self;
        _muteBtn = [ARUICallingControlButton createViewWithFrame:CGRectZero titleText:@"麦克风" buttonAction:^(UIButton * _Nonnull sender) {
            [weakSelf muteTouchEvent:sender];
        } imageSize:kBtnSmallSize];
        [_muteBtn configBackgroundImage:[ARUICommonUtil getBundleImageWithName:@"icon_mute"]];
    }
    return _muteBtn;
}

- (ARUICallingControlButton *)hangupBtn {
    if (!_hangupBtn) {
        __weak typeof(self) weakSelf = self;
        _hangupBtn = [ARUICallingControlButton createViewWithFrame:CGRectZero titleText:@"挂断" buttonAction:^(UIButton * _Nonnull sender) {
            [weakSelf hangupTouchEvent:sender];
        } imageSize:kBtnLargeSize];
        [_hangupBtn configBackgroundImage:[ARUICommonUtil getBundleImageWithName:@"icon_hangup"]];
    }
    return _hangupBtn;
}

- (ARUICallingControlButton *)handsfreeBtn {
    if (!_handsfreeBtn) {
        __weak typeof(self) weakSelf = self;
        _handsfreeBtn = [ARUICallingControlButton createViewWithFrame:CGRectZero titleText:@"扬声器" buttonAction:^(UIButton * _Nonnull sender) {
            [weakSelf hangsfreeTouchEvent:sender];
        } imageSize:kBtnSmallSize];
        [_handsfreeBtn configBackgroundImage:[ARUICommonUtil getBundleImageWithName:@"icon_handsfree"]];
    }
    return _handsfreeBtn;
}

- (ARUIInvitedContainerView *)invitedContainerView {
    if (!_invitedContainerView) {
        _invitedContainerView = [[ARUIInvitedContainerView alloc] initWithFrame:CGRectZero];
        _invitedContainerView.delegate = self.actionDelegate;
    }
    return _invitedContainerView;
}

#pragma mark - Lazy -- 视频通话相关

- (ARUICallingVideoRenderView *)localPreView {
    if (!_localPreView) {
        _localPreView = [[ARUICallingVideoRenderView alloc] initWithFrame:self.bounds];
        _localPreView.backgroundColor = [UIColor t_colorWithHexString:@"#242424"];
        _localPreView.frame = self.bounds;
        [_localPreView setUserInteractionEnabled:NO];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [_localPreView addGestureRecognizer:tap];
        [pan requireGestureRecognizerToFail:tap];
        [_localPreView addGestureRecognizer:pan];
    }
    return _localPreView;
}

- (ARUICallingVideoRenderView *)remotePreView {
    if (!_remotePreView) {
        _remotePreView = [[ARUICallingVideoRenderView alloc] initWithFrame:CGRectMake(self.bounds.size.width - 120, 74 + 20, 100, 216)];
        _remotePreView.backgroundColor = [UIColor t_colorWithHexString:@"#242424"];
        _remotePreView.hidden = YES;
    }
    return _remotePreView;
}

- (UIButton *)switchCameraBtn {
    if (!_switchCameraBtn) {
        _switchCameraBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_switchCameraBtn setBackgroundImage:[ARUICommonUtil getBundleImageWithName:@"icon_switch_camera"] forState:UIControlStateNormal];
        [_switchCameraBtn addTarget:self action:@selector(switchCameraTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraBtn;
}

- (ARUICallingControlButton *)switchToAudioBtn {
    if (!_switchToAudioBtn) {
        __weak typeof(self) weakSelf = self;
        _switchToAudioBtn = [ARUICallingControlButton createViewWithFrame:CGRectZero titleText:@"切换到语音通话" buttonAction:^(UIButton * _Nonnull sender) {
            [weakSelf switchToAudioTouchEvent:sender];
        } imageSize:CGSizeMake(28, 18)];
        [_switchToAudioBtn configTitleColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
        [_switchToAudioBtn configBackgroundImage:[ARUICommonUtil getBundleImageWithName:@"icon_switch_audio"]];
    }
    return _switchToAudioBtn;
}

- (ARUIVideoUserContainerView *)videoUserContainerView {
    if (!_videoUserContainerView) {
        _videoUserContainerView = [[ARUIVideoUserContainerView alloc] initWithFrame:CGRectZero];
    }
    return _videoUserContainerView;
}

- (ARUICallingControlButton *)closeCameraBtn {
    if (!_closeCameraBtn) {
        __weak typeof(self) weakSelf = self;
        _closeCameraBtn = [ARUICallingControlButton createViewWithFrame:CGRectZero titleText:@"摄像头" buttonAction:^(UIButton * _Nonnull sender) {
            [weakSelf closeCameraTouchEvent:sender];
        } imageSize:kBtnSmallSize];
        [_closeCameraBtn configTitleColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
        [_closeCameraBtn configBackgroundImage:[ARUICommonUtil getBundleImageWithName:@"icon_camera_on"]];
    }
    return _closeCameraBtn;
}

@end
