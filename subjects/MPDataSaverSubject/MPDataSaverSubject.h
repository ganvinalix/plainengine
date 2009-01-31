#import <MPCore.h>

/**
  Subject for storing data;
  Init string format: "<filename>"
  Messages:
   1) save - instantly saves data to file;
   2) saveData (category, key, data) - saves 'data' correlating it to 'key' in category 'category'
  Requests:
   1) loadData (category, key) - returns data, relating to 'key' in category 'category'

  */
@interface MPDataSaverSubject : NSObject <MPSubject>
{
	id <MPAPI> api;
	NSString *dataFileName;
	NSMutableDictionary *dataTree;
}
MP_HANDLER_OF_MESSAGE(save);
MP_HANDLER_OF_MESSAGE(saveData);
MP_HANDLER_OF_REQUEST(loadData);
@end


