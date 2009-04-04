#import <MPSpriteRenderDelegate.h>
#import <MPRenderable.h>

#define SAFE_RETURN(arg) \
	return arg;

@implementation MPSpriteRenderDelegate
MPSpriteRenderDelegate *root = nil;
+ (void) load
{
	root = [MPSpriteRenderDelegate new];
}

- initWithObject: (id)object
{
	[super init];

	x = y = roll = 0.0;
	sx = sx = 0.1;

	z_order = 0;

	_object = object;
	_lock = [NSLock new];

	children = [NSMutableArray new];

	[self attachTo: root];

	// if is not root
	animator = nil;
	if(object != self)
	{
		drawer = [MPRenderable addRenderableForNode: self];
	}

	[self setVisible: YES];

	return self;
}
- init
{
	return [self initWithObject: self];
}

Class getAnimatorByName(NSString *className)
{
	Class animatorClass = objc_lookUpClass([className UTF8String]);
	if(![animatorClass conformsToProtocol: @protocol(MPAnimator)])
		return nil;
	return animatorClass;
}
#define FOR_PARAM(name) \
		NSString *name = [info objectForKey: @#name]; \
		if(name)\
			if(![name isEqual: @""])
- (void) setFeature: (NSString *)name toValue: (id<MPVariant>)dt userInfo: (NSDictionary *)info
{
	if( [name isEqual: @"renderable"] )
	{
		x = [_object getX];
		y = [_object getY];
		z_order = [_object getZOrder];
		sx = 1;//[_object getXScale];
		sy = 1;//[_object getYScale];
		roll = [_object getRoll];
		[drawer setTextureAnimator: nil];

		if(info)
		{
			FOR_PARAM(parentName)
			{
				id obj = [[_object class] getObjectByName: parentName]; 
				if([obj respondsToSelector: @selector(attachTo:)])
					[self attachTo: obj];
			}
			FOR_PARAM(textureName)
			{
				if(![drawer setTexture: textureName])
				{
					[gLog add: warning withFormat: @"MPSpriteRenderDelegate: Unable to load [%@] texture", textureName];
				}
			}
			FOR_PARAM(scaleX)
			{
				sx = [scaleX doubleValue];
			}
			FOR_PARAM(scaleY)
			{
				sy = [scaleY doubleValue];
			}
			FOR_PARAM(textureAnimator)
			{	
				NSMutableString *animName = [NSMutableString string], *params = [NSMutableString string];
				separateString(textureAnimator, animName, params, @"|");
				NSDictionary *userInfo = parseParamsString(params);

				Class anim = getAnimatorByName(animName);
				if(anim)
					[drawer setTextureAnimator: [[[anim alloc] initWithTime: getMilliseconds() userInfo: userInfo] autorelease]];
			}
		}
	}
	if( [name isEqual: @"animated"] )
	{
		Class anim = getAnimatorByName([dt stringValue]);
		if(anim)
			[self setAnimator: [[[anim alloc] initWithTime: getMilliseconds() userInfo: info] autorelease]];
	}
}
-(void) removeFeature: (NSString *)name
{
	if( ![name isEqual: @"renderable"] ) return;

	[MPRenderable removeRenderable: drawer];
	[self attachTo: nil];
}
+ newDelegateWithObject: (id<MPObject>)object
{
	return [[MPSpriteRenderDelegate alloc] initWithObject: object];
}
- (void) dealloc
{
	[_lock release];
	[children release];
	[super dealloc];
}

- (double) getX
{
	SAFE_RETURN(x);
}
- (double) getY
{
	SAFE_RETURN(y);
}
- (unsigned) getZOrder
{
	SAFE_RETURN(z_order);
}

- (double) getRoll
{
	SAFE_RETURN(roll);
}

- (double) getXScale
{
	SAFE_RETURN(sx);
}
- (double) getYScale
{
	SAFE_RETURN(sy);
}
- (BOOL) isVisible
{
	SAFE_RETURN(visible);
}

- (void) setVisible: (BOOL)vis
{
	[_lock lock];
	visible = vis;
	[drawer setVisible: vis];
	[_lock unlock];
}

- (void) setXY: (double)aX : (double)aY
{
	[_lock lock];

	double chX = 0.0, chY = 0.0;
	NSUInteger i = 0;
	id curr = nil;
	for(; i < [children count]; ++i)
	{
		curr = [children objectAtIndex: i];
		chX = [curr getX];
		chY = [curr getY];
		[curr setXY: (chX-x)+aX : (chY-y)+aY];  
	}

	x = aX;
	y = aY;

	[_lock unlock];
}
- (void) setZOrder: (unsigned)aZo
{
	[_lock lock];
	z_order = aZo;

	/*NSUInteger i = 0;
	for(; i < [children count]; ++i)
	{
		[[children objectAtIndex: i] setZOrder: aZo];  
	}*/

	[_lock unlock];
}
- (void) setRoll: (double)aR
{
	aR /= 3.14;
	aR *= 180;

	[_lock lock];

	NSUInteger i = 0;
	id curr = nil;
	for(; i < [children count]; ++i)
	{
		curr = [children objectAtIndex: i];
		[curr setRoll: aR*3.14/180];  
	}

	roll = aR;

	[_lock unlock];
}

- (void) setScaleXY: (double)aX : (double)aY
{
	[_lock lock];

	double chSX = 0.0, chSY = 0.0;
	NSUInteger i = 0;
	id curr = nil;
	for(; i < [children count]; ++i)
	{
		curr = [children objectAtIndex: i];
		chSX = [curr getXScale];
		chSY = [curr getYScale];
		[curr setScaleXY: (chSX-sx)+aX : (chSY-sy)+aY];  
	}

	sx = aX;
	sy = aY;

	[_lock unlock];
}

- (void) moveByXY: (double)aX : (double)aY
{
	[_object setXY: x+aX : y+aY]; 
}

- (void) attachTo: (id<MPSpriteObject>)node
{
	[_lock lock];

	[parent deattachChild: self];

	parent = node;

	if(parent)
		[parent attachChild: self];

	[_lock unlock];
}
- (void) attachChild: (MPSpriteRenderDelegate *)aChild
{
	// yes, no synch code here beacouse of it method must be called only within 'attachTo', 
	// where such code already exists
	[children addObject: aChild];
}
- (void) deattachChild: (MPSpriteRenderDelegate *)aChild
{
	// yes, no synch code here beacouse of it method must be called only within 'attachTo', 
	// where such code already exists
	[children removeObject: aChild];
}

- (void) setAnimator: (id<MPAnimator>)anAnim
{
	ex = x;
	ey = y;
	esx = sx;
	esy = sy;
	eroll = roll;

	[animator release];
	animator = [anAnim retain];
}
- (void) applyAnimation
{
	if(!animator) return;

	[animator setTime: getMilliseconds() XY: ex : ey scaleXY: esx : esy roll: eroll];  
	[_object setXY: [animator getX] : [animator getY]];
	[_object setScaleXY: [animator getXScale] : [animator getYScale]];
	[_object setRoll: [animator getRoll]];
}
@end

MPSpriteRenderDelegate * GetRootNode()
{
	return root;
}

