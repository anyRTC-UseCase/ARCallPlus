//
//  ARUILogin.m
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/16.
//

#import "ARUILogin.h"
#import "ARUICalling.h"
#import "ARTCCalling.h"
#import "ARTCCalling+Signal.h"

static NSString *g_sdkAppID = nil;
static NSString *g_userID = nil;
static NSString *g_nickName = nil;
static NSString *g_faceUrl = nil;
static ARCallUser *g_userInfo = nil;
static NSMutableDictionary *g_users = nil;

static ARtmKit *rtmEngine = nil;

@implementation ARCallUser

- (instancetype)initWithUid:(NSString *)uid {
    if (self = [super init]) {
        self.userId = uid;
    }
    return self;
}

@end

@implementation ARUILogin

+ (void)initWithSdkAppID:(NSString * _Nonnull)sdkAppID {
    // sdkappid 如果发生了变化要先 unInitSDK，否则 initSDK 会失败
    if (g_sdkAppID != nil) {
        [self logout];
        [rtmEngine destroy];
    }
    g_sdkAppID = sdkAppID;
    rtmEngine = [[ARtmKit alloc] initWithAppId:sdkAppID delegate:nil];
    g_users = [[NSMutableDictionary alloc] init];
}

+ (ARtmKit * _Nullable)kit {
    return rtmEngine;
}

+ (void)login:(ARCallUser * _Nonnull)callUser succ:(ARSucc)succ fail:(ARFail)fail {
    if (callUser.userId.length == 0) {
        if (fail) {
            fail(ARtmLoginErrorInvalidArgument);
        }
    }
    
    g_userInfo = callUser;
    g_userID = callUser.userId;
    
    [rtmEngine loginByToken:nil user:g_userID completion:^(ARtmLoginErrorCode errorCode) {
        if (errorCode == ARtmLoginErrorOk) {
            [ARTCCalling.shareInstance addSignalListener];
            if (succ) {
                succ();
            }
        } else {
            if (fail) {
                fail(errorCode);
            }
        }
    }];
}

+ (void)logout {
    g_userID = @"";
    [ARTCCalling.shareInstance removeSignalListener];
    [rtmEngine logoutWithCompletion:nil];
    [rtmEngine destroy];
    rtmEngine = nil;
}

+ (NSString *)getSdkAppID {
    return g_sdkAppID;
}

+ (NSString *)getUserID {
    return g_userID;
}

+ (NSString *)getNickName {
    return g_nickName;
}

+ (NSString *)getFaceUrl {
    return g_faceUrl;
}

+ (void)setCallUserInfo:(ARCallUser *)user {
    if (!g_users || user.userId.length == 0) {
        return;
    }

    [g_users setObject:user forKey:user.userId];
}

+ (void)removeAllCallUserInfo {
    [g_users removeAllObjects];
}

+ (ARCallUser *)getCallUserInfo:(NSString *)uid {
    if ([uid isEqualToString:g_userID]) {
        return g_userInfo;
    } else if ([g_users.allKeys containsObject:uid]) {
        return [g_users objectForKey:uid];
    } else {
        return [[ARCallUser alloc] initWithUid:uid];
    }
}

@end
