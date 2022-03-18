//
//  ARUILogin.h
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/16.
//

#import <Foundation/Foundation.h>
#import <ARtmKit/ARtmKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 用户基本资料
@interface ARCallUser : NSObject
/// 用户 ID
@property(nonatomic, copy) NSString *userId;

/// 用户昵称
@property(nonatomic, copy) NSString *userName;

/// 用户头像
@property(nonatomic, copy) NSString *headerUrl;

/// 自定义数据
@property(nonatomic, copy) NSString *customData;

- (instancetype)initWithUid:(NSString *)uid;
@end

typedef void (^ARFail)(ARtmLoginErrorCode code);
typedef void (^ARSucc)(void);

@interface ARUILogin : NSObject

/// 初始化
/// @param sdkAppID appid
+ (void)initWithSdkAppID:(NSString * _Nonnull)sdkAppID;

/// 登录
/// @param callUser 用户信息
/// @param succ 成功回调
/// @param fail 失败回调
+ (void)login:(ARCallUser *_Nonnull)callUser succ:(ARSucc)succ fail:(ARFail)fail;

/// 登出
+ (void)logout;

/// 获取rtm
+ (ARtmKit * _Nullable)kit;

/// 获取 sdkappid
+ (NSString *)getSdkAppID;

/// 获取 userID
+ (NSString *)getUserID;

/// 获取昵称
+ (NSString *)getNickName;

/// 获取头像
+ (NSString *)getFaceUrl;

/// 记录当前通话用户信息
/// @param user 用户信息
+ (void)setCallUserInfo:(ARCallUser *)user;

/// 清除当前通话用户信息
+ (void)removeAllCallUserInfo;

/// 获取当前通话用户信息
/// @param uid 用户id
+ (ARCallUser *)getCallUserInfo:(NSString *)uid;

@end

NS_ASSUME_NONNULL_END
