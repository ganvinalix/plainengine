#import <Foundation/Foundation.h>

@protocol PEDrawer < NSObject >
- initWithData: (NSData *) aData;

- (void) drawAtX: (double)aX y: (double)aY depth: (double)aDepth;
- (void) drawAtX: (double)aX y: (double)aY depth: (double)aDepth withScaleByX: (double) sX y: (double)sY;
@end

@protocol PEGraphics < NSObject >
// describe params specs here
/*
	unsigned 	width;
	unsigned 	height;
	unsigned 	colorDepth
	BOOL		fullScreen
	
	string		whatPlatform // for initialize abstract factory in PEView
*/
// initialization of drawers factory here
- initWithParams: (NSDictionary *)aParams;
- init;

// factory methods
+ graphicsWithParams: (NSDictionary *)aParams;
+ graphics;

// close graphics
- (void) closeGraphics;

// drawers managment
- (id <PEDrawer>) createDrawer: (NSString *)typeName fromData: (NSData *)aParams;
- (id <PEDrawer>) newDrawer: (NSString *)typeName fromData: (NSData *)aParams;
@end

