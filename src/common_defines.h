#define MP_LITERAL_CONST(name) extern NSString *const name 
#define MP_LITERAL_CONST_INIT(name) NSString *const name = @#name

#define MP_SLEEP(x) [NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: (float)(x)/1000]]


#define MP_BEGIN_PROFILE(name) \
	MPCodeTimer *_ct_##name = [MPCodeTimer codeTimerWithSectionName: [NSString stringWithUTF8String: #name]]; \
	[_ct_##name beginSession]

#define MP_END_PROFILE(name) [_ct_##name endSession]

