#import <Foundation/Foundation.h>
#import <MPAPI.p>

@protocol MPSubject <NSObject>
- initWithString: (NSString *)string;

- (void) receiveAPI: (id<MPAPI>)anAPI;
- (void) start;
- (void) stop;
- (void) update;
@end

