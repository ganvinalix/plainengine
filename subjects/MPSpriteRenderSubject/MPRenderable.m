#import <MPRenderable.h>
#import <MPSprite.h>

@implementation MPRenderable
NSMutableArray *objects = nil;
+ (void) load
{
	objects = [NSMutableArray new];
}

+ addRenderableForNode: (id<MPSpriteObject>)aNode
{
	MPRenderable *drawer = [[MPSprite alloc] initWithNode: aNode];
	[objects addObject: drawer];
	[drawer release];

	return drawer;
}
+ (void) removeRenderable: (id<MPRenderable>)aDrawer
{
	[objects removeObject: aDrawer];
}

+ (void) renderAll
{
	[objects sortUsingSelector: @selector(compare:)];
	NSUInteger i = 0;
	for(; i < [objects count]; ++i)
	{
		[[objects objectAtIndex: i] render];
	}
}

- (NSComparisonResult) compare: (id<MPRenderable>)arg
{
	return NSOrderedSame;
}

- initWithNode: (id<MPSpriteObject>)aNode
{
	return [super init];
}

- (void) bindToNode: (id<MPSpriteObject>) aNode
{

}

- (id<MPSpriteObject>) getNode
{
	return nil;
}

- (void) render
{

}

- (BOOL) isVisible
{
	return NO;
}

- (void) setVisible: (BOOL)vis
{

}

- (BOOL) setTexture: (NSString *)name
{
	return NO;
}

- (unsigned) getTextureId
{
	return 0;
}

- (void) setTextureAnimator: (id<MPAnimator>)anAnim
{

}

@end

