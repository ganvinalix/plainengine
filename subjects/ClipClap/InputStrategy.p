#import <MPCore.h>

@protocol InputStrategy
- initWithAPI: (id<MPAPI>);

- (void) mouseDown: (NSDictionary *)params;
- (void) mouseUp: (NSDictionary *)params;

- (void) keyDown: (NSDictionary *) params;
@end

