#import <config.h>

#ifdef WIN32
#define MP_EOL @"\r\n"
#else
#define MP_EOL @"\n"
#endif

/** Macros for quick string constants definition */
#define MP_STRING_CONST(name) extern NSString *const name 
#define MP_STRING_CONST_INIT(name, value) NSString *const name = @#value

/** Sleeps for x milliseconds */
//#define MP_SLEEP(x) [NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: (float)(x)/1000]]
#define MP_SLEEP(x) [NSThread sleepForTimeInterval: (float)(x)/1000]

/** Macros for logging (sends message as "info");*/
#define MP_LOG(x) [gLog add: info withFormat: @"%@", x]

/** Begins MPCodeTimer session of section with given name; This macros must be used once per code block*/
#define MP_BEGIN_PROFILE(name) \
	MPCodeTimer *_ct_##name = [MPCodeTimer codeTimerWithSectionName: [NSString stringWithUTF8String: #name]]; \
	[_ct_##name beginSession]

/** Ends MPCodeTimer session of section with given name, created by and only by MP_BEGIN_PROGILE; This macros must be used once per code block*/
#define MP_END_PROFILE(name) [_ct_##name endSession]

/** Prints MPCodeTimer statistics for section with given name to default log */
#define MP_PRINT_STATISTICS(name) MP_LOG([MPCodeTimer printStatisticsByName: @#name]);

/** Macroses for assertions */
#define MP_ASSERT NSAssert

/** Magic macros for compilling in windows*/
#ifdef  MP_USE_EXCEPTIONS
#define THROW(x) @throw x 
#else
#define THROW(x) \
	[gLog add: alert withFormat: @"Program terminated due to exception %@ \n%@", [x name], [x reason]];\
	exit(1);
#endif

/*
#ifdef  MPOBJECT_ENABLESYNCHRONISATION
#define MP_OBJECT MPSynchronisedObject
#else
#define MP_OBJECT MPObject
#endif
*/

/*
/ ** Create object by name and root name * /
#define MP_CREATEOBJECT(name, root) \
	[[MP_OBJECT getObjectByName: root] createSubObjectWithName: name]
*/

/** Create object by name and root name */
#define MP_CREATEOBJECT(system, name, root) \
	[[system getObjectByName: root] createSubObjectWithName: name]
