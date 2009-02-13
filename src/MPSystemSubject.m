#import <MPSystemSubject.h>
#import <core_constants.h>

#import <MPUtility.h>

@implementation MPSystemSubject

-init
{
	return [self initWithSubjectManager: nil];
}

-initWithString: (NSString *)string
{
	return [self init];
}

-initWithSubjectManager: (MPSubjectManager *)subjManager
{
	[super init];
	API = nil;
	subjectManager = subjManager;
	return self;
}

-(void)dealloc
{
	if (API)
	{
		[API release];
	}
	[super dealloc];
}

-(void) receiveAPI: (id<MPAPI>)anAPI
{
	API = [anAPI retain];
}

-(void) start
{

}

-(void) stop
{
	[(id)[API getObjectSystem] cleanup];
}

-(void) update
{

}

MP_HANDLER_OF_MESSAGE(exit)
{
	MP_SLEEP(1); //tambourine to allow other subjects to handle this message
	[subjectManager terminate];
}

MP_HANDLER_OF_MESSAGE(pause)
{
	[subjectManager pause];
}

MP_HANDLER_OF_MESSAGE(resume)
{
	[subjectManager resume];
}

@end
