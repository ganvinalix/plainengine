#import <MPSprite.h>
#import <MPCore.h>

#import <GL/gl.h>
#import <GL/glu.h>

#define ILUT_USE_OPENGL

#import <IL/ilut.h>

@implementation MPSprite

id loadTexture(id name)
{
	NSNumber *texID = [NSNumber numberWithUnsignedInt: ilutGLLoadImage((char *)[name UTF8String])];
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, [texID unsignedIntValue]);

	//glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
  	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 

	return texID;
}

MPMapper *textures = nil;

+ (void) load
{
	textures = [[MPMapper alloc] initWithConverter: &loadTexture];
}

- init
{
	return [self initWithNode: nil];
}
- initWithNode: (id<MPSpriteObject>)aNode
{
	[super init];

	node = nil;
	[self bindToNode: aNode];
	visible = YES;
	texName = nil;
	texAnimator = nil;

	return self;
}
- (void) dealloc
{
	[texAnimator release];
	[texName release];
	[super dealloc];
}

- (void) bindToNode: (id<MPSpriteObject>)aNode
{
	node = aNode;
}

- (BOOL) isVisible
{
	return visible;
}

- (void) setVisible: (BOOL)vis
{
	visible = vis;
}

- (BOOL) setTexture: (NSString *)aName
{
	[texName release];
	texName = [aName copy];
	return [[NSFileManager defaultManager] fileExistsAtPath: texName];
}

unsigned prevTex = 0;
- (void) render
{
	if(!visible) return;

	if(!texture)
		if(texName)
			texture = [[textures getObject: texName] unsignedIntValue];

	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();

	[node applyAnimation];

	glTranslated([node getX], [node getY], 0);
	glRotated([node getRoll], 0.0, 0.0, 1.0);
	glScaled([node getXScale], [node getYScale], 1);
	//glScaled(0.1, 0.1, 1);
	
	if(prevTex != texture)
	{
		glEnable(GL_TEXTURE_2D);
		glBindTexture (GL_TEXTURE_2D, texture);
		prevTex = texture;
	}
	glMatrixMode(GL_TEXTURE);
	glLoadIdentity();
	if(texAnimator)
	{
		[texAnimator setTime: getMilliseconds() XY: 0.0 : 0.0 scaleXY: 1.0 : 1.0 roll: 0];  
		glTranslated([texAnimator getX], [texAnimator getY], 0.0);
		glRotated([texAnimator getRoll], 0.0, 0.0, 1.0);
		glScaled([texAnimator getXScale], [texAnimator getYScale], 1.0);
	}
	glMatrixMode(GL_MODELVIEW);

	double one = -1.0;
#ifdef WIN32
	one *= -1.0;
#endif

	glColor3f(1.0f, 1.0f, 1.0f);
	glBegin(GL_TRIANGLE_STRIP);
		glTexCoord2f (0, 0);
		glVertex2d(-1.0, -1.0);

		glTexCoord2f (0, one);
		glVertex2d(-1.0, 1.0);

		glTexCoord2f (one, 0);
		glVertex2d(1.0, -1.0);
		
		glTexCoord2f (one, one);
		glVertex2d(1.0, 1.0);
	glEnd();
	glPopMatrix();
}

- (id<MPSpriteObject>) getNode
{
	return node;
}
- (unsigned) getTextureId
{
	return texture;
}

- (NSComparisonResult) compare: (id<MPRenderable>)arg
{
	if([node getZOrder] < [[arg getNode] getZOrder])
		return NSOrderedAscending;
	if([node getZOrder] > [[arg getNode] getZOrder])
		return NSOrderedDescending;
	if([node getZOrder] == [[arg getNode] getZOrder])
	{
		if(texture < [arg getTextureId])
			return NSOrderedAscending;
		if(texture > [arg getTextureId])
			return NSOrderedDescending;
		if(texture == [arg getTextureId])
			return NSOrderedSame;
	}

	return NSOrderedSame;
}

- (void) setTextureAnimator: (id<MPAnimator>)anAnim
{
	[texAnimator release];
	texAnimator = [anAnim retain];
}
/*- (void) setAnimator: (id<MPAnimator>)anAnim
{
	[animator release];
	animator = [anAnim retain];
}*/

@end

