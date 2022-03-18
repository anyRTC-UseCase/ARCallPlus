//
//  ARTCCallingUtils.h
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/18.
//

#import <Foundation/Foundation.h>
#import "ARTCCallingModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ARTCCallingUtils : NSObject

///生成随机 RoomID
+ (UInt32)generateRoomID;

+ (NSString *)dictionary2JsonStr:(NSDictionary *)dict;

+ (NSData *)dictionary2JsonData:(NSDictionary *)dict;

+ (NSDictionary *)jsonSring2Dictionary:(NSString *)jsonString;

+ (NSDictionary *)jsonData2Dictionary:(NSData *)jsonData;

@end

NS_ASSUME_NONNULL_END
