#import <MPBulletPhysicsHelpers.h>
#import <fstream>
#import <iostream>

using namespace std;

double getDoubleValueFromDictionary(id dict, NSString *name, double def)
{
	NSString *v = [dict objectForKey: name];
	if (v)
	{
		return [v doubleValue];
	}
	return def;
}

int getIntValueFromDictionary(id dict, NSString *name, int def)
{
	NSString *v = [dict objectForKey: name];
	if (v)
	{
		return [v intValue];
	}
	return def;
}

btCollisionShape *loadMeshFromFile(NSString *fileName)
{
	btTriangleMesh *triMesh = new btTriangleMesh;
	ifstream input([fileName UTF8String]);
	while (!input.eof())
	{
		double x0, y0, z0, x1, y1, z1, x2, y2, z2;
		input >> x0;
		if (input.eof())
		{
			break;
		}
		input >> y0 >> z0 >> x1 >> y1 >> z1 >> x2 >> y2 >> z2;
		/*
		cout << x0 << " " << y0 << " " << z0 << ";"
			 << x1 << " " << y1 << " " << z1 << ";"
			 << x2 << " " << y2 << " " << z2 << "\n";
		*/
		btVector3 v0(x0, y0, z0);
		btVector3 v1(x1, y1, z1);
		btVector3 v2(x2, y2, z2);
		triMesh->addTriangle(v0, v1, v2);
	}

	return new btBvhTriangleMeshShape(triMesh, false);
}

btCollisionShape *getShape(id dict)
{
	NSString *type = [dict objectForKey: @"shapeType"];
	if ([type isEqualToString: @"box"])
	{
		MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(dict, XShape, 1);
		MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(dict, YShape, 1);
		MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(dict, ZShape, 1);
		return new btBoxShape(btVector3(XShape, YShape, ZShape));
	}
	else if ([type isEqualToString: @"cylinder"])
	{
		MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(dict, XShape, 1);
		MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(dict, YShape, 1);
		MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(dict, ZShape, 1);
		return new btCylinderShape(btVector3(XShape, YShape, ZShape));
	}
	else if ([type isEqualToString: @"cone"])
	{
		MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(dict, radius, 1);
		MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(dict, height, 1);
		return new btConeShape(radius, height);
	}
	else if ([type isEqualToString: @"capsule"])
	{
		MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(dict, radius, 1);
		MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(dict, height, 1);
		return new btCapsuleShape(radius, height);
	}
	else if ([type isEqualToString: @"plane"])
	{
		MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(dict, XNormal, 0);
		MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(dict, YNormal, 0);
		MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(dict, ZNormal, 0);
		MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(dict, planeConstant, 0);
		return new btStaticPlaneShape(btVector3(XNormal, YNormal, ZNormal), planeConstant);
	}
	else if ([type isEqualToString: @"mesh"])
	{
		return loadMeshFromFile([dict objectForKey: @"fileName"]);
	}
	else //sphere
	{
		MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(dict, radius, 1);
		return new btSphereShape(radius);
	}
}

@implementation MPUIntWrapper

-init
{
	value=0;
	return [super init];
}

-(NSUInteger) getValue
{
	return value;
}

-(void) setValue: (NSUInteger)val
{
	value = val;
}

-(void) inc
{
	++value;
}

@end

