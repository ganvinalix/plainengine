#import <MPNotifications.h>
#import <core_constants.h>

void MPPostNotification(NSString *notificationName, MPCDictionaryRepresentable *params)
{
	[[MPNotificationCenter defaultCenter] postNotificationName: notificationName
							    object: nil
							  userInfo: params];
}

void MPPostRequest(NSString *notificationName, MPCDictionaryRepresentable *params, id<MPResultCradle> aResult)
{
	[[MPNotificationCenter defaultCenter] postNotificationName: notificationName
							    object: aResult
							  userInfo: params];
}

@implementation MPNotificationCenter
MPNotificationCenter *gNotificationCenter = nil;
+ (void) load
{
	if(gNotificationCenter == nil)
	{
		gNotificationCenter = [MPNotificationCenter new];
	}
}
+ (NSNotificationCenter *) defaultCenter
{
	return gNotificationCenter;
}
@end

