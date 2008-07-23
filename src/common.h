#import <Foundation/Foundation.h>
#import <stdio.h>
#import <stdlib.h>

#import <MPLog.h>
#import <MPFileLogChannel.h>
#import <MPConfigDictionary.h>
#import <MPNotifications.h>

#define MP_SLEEP(x) [NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: (float)(x)/1000]];

