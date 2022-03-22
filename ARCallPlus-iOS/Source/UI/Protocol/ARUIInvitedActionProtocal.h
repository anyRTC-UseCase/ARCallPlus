//
//  ARUIInvitedActionProtocal.h
//  Pods
//
//  Created by 余生丶 on 2022/2/15.
//

#ifndef ARUIInvitedActionProtocal_h
#define ARUIInvitedActionProtocal_h

@protocol ARUIInvitedActionProtocal <NSObject>

/// 接听Calling电话
- (void)acceptCalling:(BOOL)isVideo;

/// 拒接Calling电话
- (void)refuseCalling;

/// 主动挂断电话
- (void)hangupCalling;

@end


#endif /* ARUIInvitedActionProtocal_h */
