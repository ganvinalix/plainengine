#import <Foundation/Foundation.h>
#import <stdio.h>
#import <stdlib.h>

#import <MPLog.h>
#import <MPFileLogChannel.h>
#import <MPConfigDictionary.h>
#import <MPNotifications.h>

#define MP_SLEEP(x) [NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: (float)(x)/1000]]

#if __LP64__ || NS_BUILD_32_LIKE_64
typedef long NSInteger;
typedef unsigned long NSUInteger;
#else
typedef int NSInteger;
typedef unsigned int NSUInteger;
#endif

