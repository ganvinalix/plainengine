#import <Foundation/Foundation.h>
#import <MPAPI.p>

@protocol MPSubject
- (void) receiveAPI: (id<MPAPI>)anAPI;
- (void) kill;
- (void) update;
@end

