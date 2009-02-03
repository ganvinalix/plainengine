// Disabling this flag would disable all exception-handling code
#define MP_USE_EXCEPTIONS
// Disable this flag for disabling old GNUstep libraries support; 
//#define MP_OLDGNUSTEPSUPPORT

// Enable this flag in multi-thread applications to activate synchronistion mechanism in MPObject;
#define MPOBJECT_ENABLESYNCHRONISATION

// Enable this flag to activate logging of every object creation, unregistering, etc.
// (useful for debug but strongly decreases perfomance)
//#define MPOBJECT_DETAILLOGGING

// Number of thread updates after which autorelease pool would be cleaned
//#define MPTHREAD_CLEAN_POOL_INTERVAL 25 

#define MPTHREAD_CLEAN_POOL_THRESHOLD 50

// Maximum time (in milliseconds) of waiting for request result
#define MPTHREAD_MAX_WAIT_FOR_REQUEST_TIME 2000

// Maximum time (in milliseconds) of waiting for subject update	when exit
#define MPTHREAD_MAX_WAIT_FOR_UPDATE_TIME 1000

// Enabling this flag will have MPAutoreleasePool to log all objects it contains on release
//#define MPAUTORELEASEPOOL_LOGGING

