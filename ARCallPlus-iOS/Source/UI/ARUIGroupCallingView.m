//
//  ARUIGroupCallingView.m
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/17.
//

#import "ARUIGroupCallingView.h"
#import "ARUIAudioUserContainerView.h"
#import "ARUICallingDelegateManager.h"
#import "ARUICalleeDelegateManager.h"

@interface ARUIGroupCallingView ()

/// 记录Calling当前的状态
@property (nonatomic, assign) ARUICallingState curCallingState;

/// 存储用户数据
@property (nonatomic, strong) NSMutableArray<CallUserModel *> *userList;

/// 组通话视图
@property (nonatomic, strong) UICollectionView *groupCollectionView;

/// 所有接收者提示文本
@property (nonatomic, strong) UILabel *calleeTipLabel;

/// 所有接收者视图
@property (nonatomic, strong) UICollectionView *calleeCollectionView;

/// UICollectionView 代理对象
@property (nonatomic, strong) ARUICallingDelegateManager *delegateManager;

/// 所有接收者视图代理对象
@property (nonatomic, strong) ARUICalleeDelegateManager *calleeDelegateManager;

/// 远程音频用户信息视图
@property (nonatomic, strong) ARUIAudioUserContainerView *userContainerView;

/// 接听控制视图
@property (nonatomic, strong) ARUIInvitedContainerView *invitedContainerView;

/// 通话时间按钮
@property (nonatomic, strong) UILabel *callingTime;

/// 关闭麦克风按钮
@property (nonatomic, strong) ARUICallingControlButton *muteBtn;

/// 挂断按钮
@property (nonatomic, strong) ARUICallingControlButton *hangupBtn;

/// 免提按钮
@property (nonatomic, strong) ARUICallingControlButton *handsfreeBtn;

/// 关闭摄像头
@property (nonatomic, strong) ARUICallingControlButton *closeCameraBtn;

/// 切换摄像头
@property (nonatomic, strong) UIButton *switchCameraBtn;

/// 记录本地用户
@property (nonatomic, strong) CallUserModel *currentUser;

/// 记录发起通话着
@property (nonatomic, strong) CallUserModel *curSponsor;

// 记录是否为前置相机,麦克风,听筒,摄像头开关
@property (nonatomic, assign) BOOL isFrontCamera;
@property (nonatomic, assign) BOOL isMicMute;
@property (nonatomic, assign) BOOL isHandsFreeOn;
@property (nonatomic, assign) BOOL isCloseCamera;

@end

@implementation ARUIGroupCallingView

- (instancetype)initWithUser:(CallUserModel *)user isVideo:(BOOL)isVideo isCallee:(BOOL)isCallee {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.currentUser = user;
        self.userList = [NSMutableArray arrayWithObject:user];
        self.isVideo = isVideo;
        self.isCallee = isCallee;
        self.isFrontCamera = YES;
        self.isHandsFreeOn = YES;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor t_colorWithHexString:@"#242424"];
    for (int i = 0; i < 9; i++) {
        [self.groupCollectionView registerClass:NSClassFromString(@"ARUICallingGroupCell") forCellWithReuseIdentifier:[NSString stringWithFormat:@"ARUICallingGroupCell_%d", i]];
    }
    [self.calleeCollectionView registerClass:NSClassFromString(@"ARUICalleeGroupCell") forCellWithReuseIdentifier:@"ARUICalleeGroupCell"];
    _curCallingState = self.isCallee ? ARUICallingStateOnInvitee : ARUICallingStateDailing;
}

- (void)iniARUIForCaller {
    if (self.isVideo) {
        [self iniARUIForVideoCaller];
    } else {
        [self iniARUIForAudioCaller];
    }
}

/// 多人通话，主叫方/接听后 UI初始化
- (void)iniARUIForAudioCaller {
    [self addSubview:self.groupCollectionView];
    [self addSubview:self.callingTime];
    [self addSubview:self.muteBtn];
    [self addSubview:self.hangupBtn];
    [self addSubview:self.handsfreeBtn];
    // 视图约束
    [self.groupCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(StatusBar_Height);
        make.centerX.equalTo(self);
        make.width.height.mas_equalTo(self.bounds.size.width);
    }];
    [self.callingTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.hangupBtn.mas_top).offset(-10);
        make.height.equalTo(@(30));
    }];
    [self.muteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.hangupBtn.mas_left).offset(-5);
        make.centerY.equalTo(self.hangupBtn);
        make.size.equalTo(@(kControlBtnSize));
    }];
    [self.hangupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_top).offset(self.frame.size.height - Bottom_SafeHeight - 20);
        make.size.equalTo(@(kControlBtnSize));
    }];
    [self.handsfreeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.hangupBtn.mas_right).offset(5);
        make.centerY.equalTo(self.hangupBtn);
        make.size.equalTo(@(kControlBtnSize));
    }];
}

/// 多人通话，主叫方/接听后 UI初始化
- (void)iniARUIForVideoCaller {
    [self addSubview:self.groupCollectionView];
    [self addSubview:self.callingTime];
    [self addSubview:self.muteBtn];
    [self addSubview:self.handsfreeBtn];
    [self addSubview:self.closeCameraBtn];
    [self addSubview:self.hangupBtn];
    [self addSubview:self.switchCameraBtn];
    // 视图约束
    [self.groupCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(StatusBar_Height);
        make.centerX.equalTo(self);
        make.width.height.mas_equalTo(self.bounds.size.width);
    }];
    [self.callingTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.handsfreeBtn.mas_top).offset(-10);
        make.height.equalTo(@(30));
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
    [self.hangupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_top).offset(self.frame.size.height - Bottom_SafeHeight - 20);
        make.size.equalTo(@(kControlBtnSize));
    }];
    [self.switchCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.hangupBtn);
        make.left.equalTo(self.hangupBtn.mas_right).offset(20);
        make.size.equalTo(@(CGSizeMake(36, 36)));
    }];
}

/// 多人通话，被呼叫方UI初始化
- (void)iniARUIForAudioCallee {
    [self addSubview:self.userContainerView];
    [self addSubview:self.calleeTipLabel];
    [self addSubview:self.calleeCollectionView];
    [self addSubview:self.invitedContainerView];
    // 视图约束
    [self.userContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(StatusBar_Height + 74);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
    }];
    [self.calleeTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.height.equalTo(@(20));
    }];
    [self.calleeCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.calleeTipLabel.mas_bottom).offset(15);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.height.equalTo(@(32));
    }];
    [self.invitedContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerX.equalTo(self).offset(60);
        make.right.centerX.equalTo(self).offset(-60);
        make.height.equalTo(@(94));
        make.bottom.equalTo(self).offset(-Bottom_SafeHeight - 20);
    }];
}

- (void)setCurCallingState:(ARUICallingState)curCallingState {
    _curCallingState = curCallingState;
    [self clearAllSubViews];
    
    switch (curCallingState) {
        case ARUICallingStateOnInvitee: {
            [self iniARUIForAudioCallee];
            NSString *waitingText = @"邀请你音频通话";
            if (self.isVideo) {
                waitingText = @"邀请你视频通话";
            }
            [self.userContainerView configUserInfoViewWith:self.curSponsor showWaitingText:waitingText];
        } break;
        case ARUICallingStateDailing: {
            [self iniARUIForCaller];
            self.callingTime.hidden = YES;
            [self.userContainerView configUserInfoViewWith:self.curSponsor showWaitingText:@"等待对方接受"];
        } break;
        case ARUICallingStateCalling: {
            [self iniARUIForCaller];
            self.callingTime.hidden = NO;
            self.userContainerView.hidden = YES;
            [self handleLocalRenderView];
        } break;
        default:
            break;
    }
}

#pragma mark - Public

- (void)configViewWithUserList:(NSArray<CallUserModel *> *)userList sponsor:(CallUserModel *)sponsor {
    if (userList) {
        [self.userList removeAllObjects];
        [self.userList addObjectsFromArray:userList];
    }
    
    if (sponsor) {
        self.curSponsor = sponsor;
        self.curCallingState = ARUICallingStateOnInvitee;
    } else {
        self.curCallingState = ARUICallingStateDailing;
    }
    
    if (self.isCallee && (self.curCallingState == ARUICallingStateOnInvitee)) {
        NSMutableArray *userArray = [NSMutableArray array];
        [self.userList enumerateObjectsUsingBlock:^(CallUserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.userId != self.currentUser.userId) {
                [userArray addObject:obj];
            }
        }];
        self.calleeTipLabel.hidden = !userArray.count;
        [self.calleeDelegateManager reloadCallingGroupWithModel:[userArray copy]];
        [self.calleeCollectionView reloadData];
    }
    
    [self.delegateManager reloadCallingGroupWithModel:self.userList];
    [self.groupCollectionView reloadData];
    [self.groupCollectionView layoutIfNeeded];
    self.switchCameraBtn.hidden = !self.isVideo;
    [self handleLocalRenderView];
}

- (void)enterUser:(CallUserModel *)user {
    if (!user) return;
    
    NSInteger index = [self getIndexForUser:user];
    if (index < 0) return;
    
    self.curCallingState = ARUICallingStateCalling;
    user.isEnter = YES;
    self.userList[index] = user;
    [self.delegateManager reloadCallingGroupWithModel:self.userList];
    [self.delegateManager reloadGroupCellWithIndex:index];
    
    if (self.isVideo) {
        UIView *renderView = [self.delegateManager getRenderViewFromUser:user.userId];
        [[ARTCCalling shareInstance] startRemoteView:user.userId view:renderView];
    }
}

- (void)leaveUser:(CallUserModel *)user {
    NSInteger index = [self getIndexForUser:user];
    if (index < 0) return;
    
    if (self.isVideo) {
        [[ARTCCalling shareInstance] stopRemoteView:user.userId];
    }
    
    [self.groupCollectionView performBatchUpdates:^{
        [self.groupCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
        [self.userList removeObjectAtIndex:index];
        [self.delegateManager reloadCallingGroupWithModel:self.userList];
    } completion:nil];
}

- (void)updateUserVolume:(CallUserModel *)user {
    [self updateUser:user animated:NO];
}

- (void)updateUser:(CallUserModel *)user animated:(BOOL)animated {
    NSInteger index = [self getIndexForUser:user];
    if (index < 0) return;
    self.userList[index] = user;
    [self.delegateManager reloadCallingGroupWithModel:self.userList];
    [self.delegateManager reloadGroupCellWithIndex:index];
}

/// 用户用户在用户数组中的位置。没有获取到返回 -1
/// @param user 目标用户
- (NSInteger)getIndexForUser:(CallUserModel *)user {
    if (!user) return -1;
    __block NSInteger index = -1;
    [self.userList enumerateObjectsUsingBlock:^(CallUserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.userId == user.userId) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

- (CallUserModel *)getUserById:(NSString *)userId {
    for (CallUserModel *userModel in self.userList) {
        if ([userModel.userId isEqualToString:userId]) {
            return userModel;
        }
    }
    return nil;
}

- (void)acceptCalling {
    self.curCallingState = ARUICallingStateCalling;
}

- (void)setCallingTimeStr:(NSString *)timeStr {
    if (timeStr && timeStr.length > 0) {
        self.callingTime.text = timeStr;
    }
}

#pragma mark - Private

- (void)handleLocalRenderView {
    if (!self.isVideo) return;
    
    UIView *localRenderView = [self.delegateManager getRenderViewFromUser:self.currentUser.userId];
    
    if (!self.isCloseCamera && localRenderView != nil) {
        [[ARTCCalling shareInstance] openCamera:self.isFrontCamera view:localRenderView];
    }
    
    self.currentUser.isVideoAvaliable = !self.isCloseCamera;
    self.currentUser.isEnter = YES;
    self.currentUser.isAudioAvaliable = YES;
    [self updateUser:self.currentUser animated:NO];
}

- (void)clearAllSubViews {
    if (_invitedContainerView != nil && self.invitedContainerView.superview != nil) {
        [self.invitedContainerView removeFromSuperview];
    }
    if (_calleeTipLabel != nil && self.calleeTipLabel.superview != nil) {
        [self.calleeTipLabel removeFromSuperview];
    }
    if (_calleeCollectionView != nil && self.calleeCollectionView.superview != nil) {
        [self.calleeCollectionView removeFromSuperview];
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
    if (_userContainerView != nil && self.userContainerView.superview != nil) {
        [self.userContainerView removeFromSuperview];
    }
}

#pragma mark - Event Action

- (void)muteTouchEvent:(UIButton *)sender {
    self.isMicMute = !self.isMicMute;
    [[ARTCCalling shareInstance] setMicMute:self.isMicMute];
    [self.muteBtn configBackgroundImage:[ARUICommonUtil getBundleImageWithName:self.isMicMute ? @"icon_mute_on" : @"icon_mute"]];
    self.currentUser.isAudioAvaliable = !self.isMicMute;
    [self updateUser:self.currentUser animated:NO];
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
        self.switchCameraBtn.hidden = YES;
    } else {
        self.switchCameraBtn.hidden = NO;
    }
    
    [self handleLocalRenderView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.closeCameraBtn setUserInteractionEnabled:YES];
    });
}

#pragma mark - Lazy

- (ARUIAudioUserContainerView *)userContainerView {
    if (!_userContainerView) {
        _userContainerView = [[ARUIAudioUserContainerView alloc] initWithFrame:CGRectZero];
        [_userContainerView setUserNameTextColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
    }
    return _userContainerView;
}

- (UILabel *)callingTime {
    if (!_callingTime) {
        _callingTime = [[UILabel alloc] initWithFrame:CGRectZero];
        _callingTime.font = [UIFont boldSystemFontOfSize:14.0f];
        [_callingTime setTextColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
        [_callingTime setBackgroundColor:[UIColor clearColor]];
        [_callingTime setText:@"00:00"];
        _callingTime.hidden = YES;
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
        [_muteBtn configTitleColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
    }
    return _muteBtn;
}

- (ARUICallingControlButton *)handsfreeBtn {
    if (!_handsfreeBtn) {
        __weak typeof(self) weakSelf = self;
        _handsfreeBtn = [ARUICallingControlButton createViewWithFrame:CGRectZero titleText:@"扬声器" buttonAction:^(UIButton * _Nonnull sender) {
            [weakSelf hangsfreeTouchEvent:sender];
        } imageSize:kBtnSmallSize];
        [_handsfreeBtn configBackgroundImage:[ARUICommonUtil getBundleImageWithName:@"icon_handsfree_on"]];
        [_handsfreeBtn configTitleColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
    }
    return _handsfreeBtn;
}

- (ARUICallingControlButton *)closeCameraBtn {
    if (!_closeCameraBtn) {
        __weak typeof(self) weakSelf = self;
        _closeCameraBtn = [ARUICallingControlButton createViewWithFrame:CGRectZero titleText:@"摄像头" buttonAction:^(UIButton * _Nonnull sender) {
            [weakSelf closeCameraTouchEvent:sender];
        } imageSize:kBtnSmallSize];
        [_closeCameraBtn configBackgroundImage:[ARUICommonUtil getBundleImageWithName:@"icon_camera_on"]];
        [_closeCameraBtn configTitleColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
    }
    return _closeCameraBtn;
}

- (ARUICallingControlButton *)hangupBtn {
    if (!_hangupBtn) {
        __weak typeof(self) weakSelf = self;
        
        _hangupBtn = [ARUICallingControlButton createViewWithFrame:CGRectZero titleText:@"挂断" buttonAction:^(UIButton * _Nonnull sender) {
            [weakSelf hangupTouchEvent:sender];
        } imageSize:kBtnLargeSize];
        [_hangupBtn configBackgroundImage:[ARUICommonUtil getBundleImageWithName:@"icon_hangup"]];
        [_hangupBtn configTitleColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
    }
    return _hangupBtn;
}

- (UIButton *)switchCameraBtn {
    if (!_switchCameraBtn) {
        _switchCameraBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_switchCameraBtn setBackgroundImage:[ARUICommonUtil getBundleImageWithName:@"icon_switch_camera"] forState:UIControlStateNormal];
        [_switchCameraBtn addTarget:self action:@selector(switchCameraTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraBtn;
}

- (ARUIInvitedContainerView *)invitedContainerView {
    if (!_invitedContainerView) {
        _invitedContainerView = [[ARUIInvitedContainerView alloc] initWithFrame:CGRectZero];
        _invitedContainerView.delegate = self.actionDelegate;
        [_invitedContainerView configTitleColor:[UIColor t_colorWithHexString:@"#FFFFFF"]];
    }
    return _invitedContainerView;
}

- (ARUICallingDelegateManager *)delegateManager {
    if (!_delegateManager) {
        _delegateManager = [[ARUICallingDelegateManager alloc] init];
    }
    return _delegateManager;
}

- (ARUICalleeDelegateManager *)calleeDelegateManager {
    if (!_calleeDelegateManager) {
        _calleeDelegateManager = [[ARUICalleeDelegateManager alloc] init];
    }
    return _calleeDelegateManager;
}

- (UICollectionView *)groupCollectionView {
    if (!_groupCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        _groupCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _groupCollectionView.delegate = self.delegateManager;
        _groupCollectionView.dataSource = self.delegateManager;
        self.delegateManager.collectionView = _groupCollectionView;
        _groupCollectionView.showsVerticalScrollIndicator = NO;
        _groupCollectionView.showsHorizontalScrollIndicator = NO;
        _groupCollectionView.backgroundColor = [UIColor clearColor];
    }
    return _groupCollectionView;
}

- (UILabel *)calleeTipLabel {
    if (!_calleeTipLabel) {
        _calleeTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _calleeTipLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        [_calleeTipLabel setTextColor:[UIColor t_colorWithHexString:@"#999999"]];
        [_calleeTipLabel setText:@"他们也在"];
        [_calleeTipLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _calleeTipLabel;
}

- (UICollectionView *)calleeCollectionView {
    if (!_calleeCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _calleeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _calleeCollectionView.delegate = self.calleeDelegateManager;
        _calleeCollectionView.dataSource = self.calleeDelegateManager;
        _calleeCollectionView.showsVerticalScrollIndicator = NO;
        _calleeCollectionView.showsHorizontalScrollIndicator = NO;
        _calleeCollectionView.backgroundColor = [UIColor clearColor];
    }
    return _calleeCollectionView;
}


@end
