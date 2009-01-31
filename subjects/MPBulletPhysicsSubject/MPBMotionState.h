#import <btBulletDynamicsCommon.h>
#import <MPPhysicalObject.h>

class MPBMotionState : public btMotionState
{
private:
	id obj;
	btTransform trans;
public:
	MPBMotionState(id<MPPhysicalObject> anObj);
	virtual ~MPBMotionState();
	virtual void getWorldTransform(btTransform &worldTrans) const;
	virtual void setWorldTransform(const btTransform &worldTrans);
};

