include $(GNUSTEP_MAKEFILES)/common.make

USE_OBJC_EXCEPTIONS = yes
ADDITIONAL_OBJCFLAGS += -fgnu-runtime -fconstant-string-class=NSConstantString 

###

LIBRARY_NAME = libMPBulletPhysicsSubject

libMPBulletPhysicsSubject_OBJC_FLAGS = -fPIC
libMPBulletPhysicsSubject_LIB_DIRS = -L../../lib/ -L./bullet/ -L./bullet/BulletCollision/ -L./bullet/BulletDynamics/ -L./bullet/LinearMath/
libMPBulletPhysicsSubject_INCLUDE_DIRS = -I../../include/ -I./bullet/
libMPBulletPhysicsSubject_LIBRARIES_DEPEND_UPON = -lMPUtility -lBulletDynamics -lBulletCollision -lLinearMath

libMPBulletPhysicsSubject_OBJCC_FILES = \
MPBulletPhysicsSubject.mm \
MPPhysicalObject.mm\
MPGhostObject.mm\
MPBMotionState.mm\
MPBulletPhysicsHelpers.mm\
MPBulletPhysicsGlobalParams.mm\
MPAttractorObject.mm

libMPBulletPhysicsSubject_HEADER_FILES = \
MPBulletPhysicsSubject.h \
MPPhysicalObject.h\
MPGhostObject.h\
MPBMotionState.h\
MPBulletPhysicsHelpers.h\
MPBulletPhysicsGlobalParams.h\
MPAttractorObject.h


include $(GNUSTEP_MAKEFILES)/library.make

