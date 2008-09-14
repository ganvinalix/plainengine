#import <Foundation/Foundation.h>
#import <MPAPI.h>

@protocol MPSubject
- initWithAPI: (id<MPAPI>)anAPI;
- (void) kill;
- (void) update;
@end

