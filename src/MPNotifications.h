#import <Foundation/Foundation.h>

#import <MPNotificationQueue.h>
#import <MPResultCradle.h>
#import <common.h>

//typedef NSNotificationCenter MPNotificationCenter;
typedef NSNotificationQueue  MPAsynchronousNotificationCenter;

/** Notification posting function */
void MPPostNotification(NSString *notificationName, MPCDictionaryRepresentable *params);
void MPPostRequest(NSString *requestName, MPCDictionaryRepresentable *params, id<MPResultCradle> aResult);

@interface MPNotificationCenter : NSNotificationCenter

+ (NSNotificationCenter*) defaultCenter;

@end
