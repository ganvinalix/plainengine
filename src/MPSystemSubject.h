#import <common.h>
#import <MPAPI.p>
#import <MPSubject.p>
#import <MPSubjectManager.h>

@interface MPSystemSubject : NSObject <MPSubject>
{
	id<MPAPI> API;
	MPSubjectManager *subjectManager;
}

-init;
-initWithSubjectManager: (MPSubjectManager *)subjManager;

-(void)dealloc;

MP_HANDLER_OF_MESSAGE(exit);
MP_HANDLER_OF_MESSAGE(pause);
MP_HANDLER_OF_MESSAGE(resume);

@end

