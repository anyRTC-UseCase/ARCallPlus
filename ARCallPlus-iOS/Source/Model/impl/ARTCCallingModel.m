//
//  ARTCCallingModel.m
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/15.
//

#import "ARTCCallingModel.h"

int SIGNALING_EXTRA_KEY_TIME_OUT = 30;
// 如果头像为空的默认头像
NSString *const DEFAULT_AVATETR = @"";

@implementation CallModel

- (id)copyWithZone:(NSZone *)zone {
    CallModel * model = [[CallModel alloc] init];
    model.version = self.version;
    model.calltype = self.calltype;
    model.roomid = self.roomid;
    model.action = self.action;
    model.code = self.code;
    model.invitedList = self.invitedList;
    model.inviter = self.inviter;
    return model;
}

@end

@implementation ARTCCallingUserModel

- (id)copyWithZone:(NSZone *)zone {
    ARTCCallingUserModel * model = [[ARTCCallingUserModel alloc] init];
    model.userId = self.userId;
    model.name = self.name;
    model.avatar = self.avatar;
    return model;
}

- (NSString *)avatar {
    return _avatar ?: DEFAULT_AVATETR;
}

@end

@implementation CallUserModel

- (id)copyWithZone:(NSZone *)zone {
    CallUserModel * model = [[CallUserModel alloc] init];
    model.userId = self.userId;
    model.name = self.name;
    model.avatar = self.avatar;
    model.isEnter = self.isEnter;
    model.isVideoAvaliable = self.isVideoAvaliable;
    model.isAudioAvaliable = self.isAudioAvaliable;
    model.volume = self.volume;
    return model;
}

@end

