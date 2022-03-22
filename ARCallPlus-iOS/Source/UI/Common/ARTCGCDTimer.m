//
//  ARTCGCDTimer.m
//  ARUICalling
//
//  Created by 余生丶 on 2022/2/15.
//

#import "ARTCGCDTimer.h"

@implementation ARTCGCDTimer

static NSMutableDictionary *rtcTimers;
dispatch_semaphore_t rtcSemaphore;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rtcTimers = [NSMutableDictionary dictionary];
        rtcSemaphore = dispatch_semaphore_create(1);
    });
}

+ (NSString *)timerTask:(void(^)(void))task
                  start:(NSTimeInterval)start
               interval:(NSTimeInterval)interval
                repeats:(BOOL)repeats
                  async:(BOOL)async {
    if (!task || start < 0 || (interval <= 0 && repeats)) {
        return nil;
    }
    
    dispatch_queue_t queue = async ? dispatch_get_global_queue(0, 0) : dispatch_get_main_queue();
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_semaphore_wait(rtcSemaphore, DISPATCH_TIME_FOREVER);
    NSString *timerName = [NSString stringWithFormat:@"%zd", rtcTimers.count];
    rtcTimers[timerName] = timer;
    dispatch_semaphore_signal(rtcSemaphore);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        task();
        if (!repeats) {
            [self canelTimer:timerName];
        }
    });
    dispatch_resume(timer);
    return timerName;
}

+ (void)canelTimer:(NSString *)timerName {
    if (timerName.length == 0) {
        return;
    }
    
    dispatch_semaphore_wait(rtcSemaphore, DISPATCH_TIME_FOREVER);
    dispatch_source_t timer = rtcTimers[timerName];
    
    if (timer) {
        dispatch_source_cancel(timer);
        [rtcTimers removeObjectForKey:timerName];
    }
    
    dispatch_semaphore_signal(rtcSemaphore);
}

@end
