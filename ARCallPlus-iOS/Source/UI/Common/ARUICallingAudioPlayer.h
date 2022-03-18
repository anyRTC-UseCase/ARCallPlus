//
//  ARUICallingAudioPlayer.h
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/15.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    CallingAudioTypeHangup,     // 挂断
    CallingAudioTypeCalled,     // 被动呼叫
    CallingAudioTypeDial,       // 主动呼叫
} CallingAudioType;

extern BOOL playAudioWithFilePath(NSString *filePath);

extern BOOL playAudio(CallingAudioType type);

extern void stopAudio(void);

NS_ASSUME_NONNULL_END
