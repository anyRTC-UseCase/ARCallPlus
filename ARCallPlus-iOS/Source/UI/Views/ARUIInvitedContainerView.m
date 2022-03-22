//
//  ARUIInvitedContainerView.m
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/17.
//

#import "ARUIInvitedContainerView.h"
#import <Masonry/Masonry.h>
#import "ARUICommonUtil.h"
#import "ARUICallingControlButton.h"
#import "UIColor+ARUIHex.h"

@interface ARUIInvitedContainerView ()

/// 拒接通话按钮
@property (nonatomic, strong) ARUICallingControlButton *refuseBtn;

/// 接收通话按钮
@property (nonatomic, strong) ARUICallingControlButton *acceptBtn;

@end

@implementation ARUIInvitedContainerView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.acceptBtn];
        [self addSubview:self.refuseBtn];
        [self makeConstraints];
    }
    return self;
}

- (void)makeConstraints {
    [self.refuseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).offset(-80);
        make.bottom.equalTo(self);
        make.width.equalTo(@(100));
        make.height.equalTo(@(94));
    }];
    [self.acceptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).offset(80);
        make.bottom.equalTo(self);
        make.width.equalTo(@(100));
        make.height.equalTo(@(94));
    }];
}

- (void)configTitleColor:(UIColor *)titleColor {
    [_acceptBtn configTitleColor:titleColor];
    [_refuseBtn configTitleColor:titleColor];
}

#pragma mark - Event Action

- (void)acceptTouchEvent:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(acceptCalling:)]) {
        [self.delegate acceptCalling: YES];
    }
}

- (void)refuseTouchEvent:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(refuseCalling)]) {
        [self.delegate refuseCalling];
    }
}

#pragma mark - Lazy

- (ARUICallingControlButton *)acceptBtn {
    if (!_acceptBtn) {
        _acceptBtn = [ARUICallingControlButton createViewWithFrame:CGRectZero titleText:@"接听" buttonAction:^(UIButton * _Nonnull sender) {
            [self acceptTouchEvent:sender];
        } imageSize:CGSizeMake(64, 64)];
        [_acceptBtn configTitleColor:[UIColor t_colorWithHexString:@"#666666"]];
        [_acceptBtn configBackgroundImage:[ARUICommonUtil getBundleImageWithName:@"icon_call"]];
    }
    return _acceptBtn;
}

- (ARUICallingControlButton *)refuseBtn {
    if (!_refuseBtn) {
        _refuseBtn = [ARUICallingControlButton createViewWithFrame:CGRectZero titleText:@"拒绝" buttonAction:^(UIButton * _Nonnull sender) {
            [self refuseTouchEvent:sender];
        } imageSize:CGSizeMake(64, 64)];
        [_refuseBtn configTitleColor:[UIColor t_colorWithHexString:@"#666666"]];
        [_refuseBtn configBackgroundImage:[ARUICommonUtil getBundleImageWithName:@"icon_hangup"]];
    }
    
    return _refuseBtn;
}


@end
