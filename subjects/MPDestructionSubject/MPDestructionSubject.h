#import <MPCore.h>

/*
	This subject handles object destruction on collision;
	
	This subject recieves message 'objectsCollided' {object1Name, object2Name};
	If one of collided objects have 'destructor' feature and another - 'destructable' feature,
	(And if destructible object responds to selector 'canBeDestructedBy:' with destructor name as param, BOOL as return value,
	it is checked too), it becomes cleaned. Works correctly if both objects have 'destructor' and 'destructable' features.
*/
@interface MPDestructionSubject : NSObject <MPSubject>
{
	id <MPAPI> api;
}
MP_HANDLER_OF_MESSAGE(objectsCollided);
@end


