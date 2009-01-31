#import <MPCore.h>
#import <btBulletDynamicsCommon.h>

/* Bullet physics subject;
	Works with objects with feature 'physical', 'ghostObject' or 'attractor'
	Physical objects gain delegate MPPhysicalObjectDelegate.
	On adding this feature you must pass userInfo dictionary with param 'shapeType' with one of the following values:
		'box'		- box shape. With this param params 'shapeX', 'shapeY', 'shapeZ' must be passed;
		'cylinder'	- cylinder shape. With this param params 'shapeX', 'shapeY' (central axis), 'shapeZ' must be passed;
		'mesh'		- triangular mesh. With this param param 'fileName' must be passed;
						File must contain coordinates of triangle vectors ('x0 y0 z0 x1 y1 z1 x2 y2 z2' - one triangular);
		'cone'		- cone shape. With this param params 'radius', 'height' must be passed;
		'capsule'	- capsule shape. With this param params 'radius', 'height' must be passed;
		'plane'		- static plane. With this param params 'XNormal', 'YNormal', 'ZNormal', 'planeConstant' must be passed;
		'sphere'	- sphere shape. With this param param 'radius' must be passed;

	Ghost objects gain delegate MPGhostObjectDelegate.

	Attractors are ghost objects than attract physical objects positiond in given raduis near attractor;
		With feature 'attractor' features 'attractingRadius' and 'attractingImpulseCoefficient' must be passed;
		If parameter 'disableCalculateAttractedObjects' is not activated, objects, that are connected to attractor(s),
		gain feature 'attracted' with name of attractor (or names, separated by spaces) as value.
		Before attracting is performed on object, message 'canBeAttractedTo:' with attractor as param is sent to it.
		If 'NO' returned, attracting is not performed

	- Initialization string: consists of following params with syntax (paramname:paramvalue param2name:param2value)
		'minX' (and minY, minZ)				- world X (or Y, Z) minimal constraint;
		'maxX' (and maxY, maxZ)				- world X (or Y, Z) maximal constraint;
		'gravX' (and gravY, gravZ)			- gravity vector coordinates
		'maxObjects'						- maximal objects count
		'velocityCleaningOnManualMove'		- clean velocity of object when method 'setXYZ:::relativePosWithXYZ:::' is called
		'linearVelocitySleepingThreshold'	- threshold of linear (movement) velocity;
													when object linear velocity is less, it stops moving;
		'angularVelocitySleepingThreshold'	- threshold of angular (rotation) velocity;
													when object linear velocity is less, it stops rotating;
		'timeBalance'						- "0" to deactivate, any other integer to activate;
													If active, simulation stops being depended on FPS
		'maxSubSteps'						- unsigned integer value, meaning maximum count of substeps per frame
		'minimalCollisionInterval'			- unsigned integer value; On object collision checks if last collision was more
													than 'minimalCollisionInterval' steps before; If isn't, message
													'objectsCollided' isn't sent
		'disableObjectDeactivation'			- "0" to deactivate, any other integer to activate;
													If activate, objects are always active
		'disableCalculateAttractedObjects'	- "0" to deactivate, any other integer to activate;
													If activate, attracted objects doesn't gain feature 'attracted'


	- Sends messages:
 		'objectsCollided' (params - 'object1Name', 'object2Name')	- on every collision,
									if neither object1 nor object2 have feature 'quietcollisions'
	- Recieves messages:
		'setGravity' (params - 'X', 'Y', 'Z') - coordinates of new gravity vector. Missing params are counted as 0;
		'explosion' (params - 'X', 'Y', 'Z', 'radius', 'impulseCoefficient', 'maximalImpulse') -
			perform explosion at point (X, Y, Z), applying impulse to each object in given radius.
			Impulse is equal to impulseCoefficient/(r^2), where r is distance between explosion eye and object;
			[impulseCoefficient] = [1 kg*(m^3)/s]
			If |impulse| is more than maximalImpulse, |impulse| reduces to it;
		
 */
@interface MPBulletPhysicsSubject : NSObject <MPSubject>
{
	id <MPAPI> api;
	btDefaultCollisionConfiguration* collisionConfiguration;
	btCollisionDispatcher* dispatcher;
	btBroadphaseInterface* overlappingPairCache;
	btSequentialImpulseConstraintSolver* solver;
	btDiscreteDynamicsWorld* dynamicsWorld;
	double lastTime;
	int maxSubSteps;
	BOOL timeBalance;
}
MP_HANDLER_OF_MESSAGE(setGravity); //params - 'X', 'Y', 'Z'
MP_HANDLER_OF_MESSAGE(explosion); //params - 'X', 'Y', 'Z', 'radius', 'impulseCoefficient', 'maximalImpulse'
@end


