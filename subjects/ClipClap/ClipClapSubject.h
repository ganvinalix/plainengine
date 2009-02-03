#import <MPCore.h>

@interface ClipClapSubject : NSObject <MPSubject>
{
	id<MPAPI> api;
	Class<MPObject> objects;
}
@end


