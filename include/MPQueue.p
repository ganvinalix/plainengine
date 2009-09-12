#import <Foundation/Foundation.h>

@protocol MPQueue <NSObject>
	
-(void) push: (id)elem;
-(id) pop;

@end

