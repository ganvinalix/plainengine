#import <PEOpenGLGraphics.h>

/*NSDictionary * createDictionaryWithDefaults(void)
{
	return [NSDictionary dictionaryWithObjectsAndKeys: @"640", @"width", @"480", @"height", @"16", @"1", @"isFullScreen", @"OpenGL", @"whatPlatform", nil];
}*/
//
@implementation PEOpenGLGraphics
// PEGraphics protocol implementation
//=========================================================================================================
// factory methods
+ graphicsWithParams: (NSDictionary *) aParams
{
	return [[[PEOpenGLGraphics alloc] initWithParams: aParams] autorelease];
}
+ graphics
{
	return [[[PEOpenGLGraphics alloc] init] autorelease];
}

// [init] methods
- initWithParams: (NSDictionary *)aParams
{
	return nil;
}
- init
{
	return [self initWithParams: nil];
}

// deinitialization works here
- (void) closeGraphics
{
	//
}
- (void) dealloc
{
	[self closeGraphics];
	[super dealloc];
}
//=========================================================================================================
// drawer managment methods
// creates a drawer without owning
- (id <PEDrawer>) createDrawer: (NSString*)typeName fromData: (NSData *)aParams
{
	return nil;
}
// creates a drawer and a caster of this method beconmes owner of the drawer
- (id <PEDrawer>) newDrawer: (NSString *)typeName fromData: (NSData *)aParams
{
	return nil;
}
@end

