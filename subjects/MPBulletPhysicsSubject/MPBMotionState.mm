#import <MPBMotionState.h>
#import <MPBulletPhysicsGlobalParams.h>

MPBMotionState::MPBMotionState(id<MPPhysicalObject> anObj)
{
	obj = anObj;
	trans.setIdentity();
	#define LOAD_VALUE_FROM_OBJECT(obj, sel, var) var = [obj respondsToSelector: @selector(sel)] ? [obj sel] : 0
	double x, y, z, qx, qy, qz, qw, roll;
	LOAD_VALUE_FROM_OBJECT(anObj, getX, x);
	LOAD_VALUE_FROM_OBJECT(anObj, getY, y);
	LOAD_VALUE_FROM_OBJECT(anObj, getZ, z);

	if (!mode2D)
	{
		LOAD_VALUE_FROM_OBJECT(anObj, getRotationQuaternionX, qx);
		LOAD_VALUE_FROM_OBJECT(anObj, getRotationQuaternionY, qy);
		LOAD_VALUE_FROM_OBJECT(anObj, getRotationQuaternionZ, qz);
		LOAD_VALUE_FROM_OBJECT(anObj, getRotationQuaternionW, qw);
		trans.setRotation(btQuaternion(qx, qy, qz, qw));
	}
	else
	{
		LOAD_VALUE_FROM_OBJECT(anObj, getRoll, roll);
		double axis[3];
		axis[disabledAxis] = 1.0f;
		axis[enabledAxis1] = 0;
		axis[enabledAxis2] = 0;

		btQuaternion rot;
		rot.setRotation(btVector3(axis[0], axis[1], axis[2]), roll);
		trans.setRotation(rot);
	}

	trans.setOrigin(btVector3(x,y,z));


}

MPBMotionState::~MPBMotionState()
{

}

void MPBMotionState::getWorldTransform(btTransform &worldTrans) const
{
	worldTrans = trans;
}

void MPBMotionState::setWorldTransform(const btTransform &worldTrans)
{
	trans = worldTrans;
	[obj startInternalChanging];
	if (!mode2D)
	{
		[obj setXYZ: worldTrans.getOrigin().getX()
				   : worldTrans.getOrigin().getY()
				   : worldTrans.getOrigin().getZ()];
		[obj setRotationQuaternionXYZW: worldTrans.getRotation().getX()
									  : worldTrans.getRotation().getY()
									  : worldTrans.getRotation().getZ()
									  : worldTrans.getRotation().getW()];
	}
	else
	{
		double angle, rc;
		switch (disabledAxis)
		{
		case 0:
			[obj setYZ: worldTrans.getOrigin().getY() : worldTrans.getOrigin().getZ()];
			rc = worldTrans.getRotation().getX();
			break;
		case 1:
			[obj setXZ: worldTrans.getOrigin().getX() : worldTrans.getOrigin().getZ()];
			rc = worldTrans.getRotation().getY();
			break;
		case 2:
			[obj setXY: worldTrans.getOrigin().getX() : worldTrans.getOrigin().getY()];
			rc = worldTrans.getRotation().getZ();
			break;
		}
		angle = worldTrans.getRotation().getAngle();
		if (rc<0)
		{
			angle = 2*M_PI-angle;
		}
		[obj setRoll: angle];
	}
	[obj stopInternalChanging];
}

