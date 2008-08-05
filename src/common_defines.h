//#define MP_LITERAL_CONST(name) extern NSString *const name 
//#define MP_LITERAL_CONST_INIT(name) NSString *const name = @#name

/** Sleeps for x milliseconds */
#define MP_SLEEP(x) [NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: (float)(x)/1000]]

/** Begins MPCodeTimer session of section with given name; This macros must be used once per code block*/
#define MP_BEGIN_PROFILE(name) \
	MPCodeTimer *_ct_##name = [MPCodeTimer codeTimerWithSectionName: [NSString stringWithUTF8String: #name]]; \
	[_ct_##name beginSession]

/** Ends MPCodeTimer session of section with given name, created by and only by MP_BEGIN_PROGILE; This macros must be used once per code block*/
#define MP_END_PROFILE(name) [_ct_##name endSession]

/** Macroses for assertions */
#define MP_ASSERT NSAssert

