include $(GNUSTEP_MAKEFILES)/common.make 
 
USE_OBJC_EXCEPTIONS = yes 
ADDITIONAL_OBJCFLAGS += -fgnu-runtime -fconstant-string-class=NSConstantString -fobjc-exceptions -Wall

debug = no
 
TOOL_NAME = plainEngine 

plainEngine_TOOL_LIBS += -lMPUtility
plainEngine_LIB_DIRS += -L./obj/
plainEngine_INCLUDE_DIRS += -I../include/
 
plainEngine_OBJC_FILES = \
main.m \
MPNotificationQueue.m \
MPThread.m \
MPSubjectManager.m \
MPObject.m \
MPNotifications.m \
MPThreadStrategy.m \
MPForkedThreadStrategy.m \
MPSubroutineThreadStrategy.m \
MPSystemSubject.m \
MPAPI.m \
core_constants.m \
MPLinker.m \
MPResultCradle.m \
MPAssertionHandler.m \

plainEngine_HEADER_FILES = \
common.h \
MPNotificationQueue.h \
MPNotifications.h \
MPObject.h \
MPObject.p \
MPSubjectManager.h \
MPSubject.p \
MPAPI.h \
MPAPI.p \
MPThreadStrategy.h \
MPSubroutineThreadStrategy.h \
MPForkedThreadStrategy.h \
MPSystemSubject.h \
core_constants.h \
MPLinker.h \
MPResultCradle.h \
MPResultCradle.p \
MPAssertionHandler.h \


LIBRARY_NAME = libMPUtility
libMPUtility_INCLUDE_DIRS += -I../include/ 
libMPUtility_LIBRARIES_DEPEND_UPON += -ldl
libMPUtility_HEADER_FILES = \
common_defines.h \
dictionary.h \
release_bunch.h \
universal_delegate_headers.h \
MPLog.h \
MPConfigDictionary.h \
MPFileLogChannel.h \
MPProfiling.h \
MPDictionary.h \
MPDictionary.p \
MPVariant.h \
MPVariant.p \
MPUtility.h \
MPLog.p \
MPPool.h \
MPMapper.h \
MPPair.h \
MPAutoreleasePool.h \
MPStringToCStringConverter.h \
MPModule.h \
MPRemovalStableList.h \
MPUniversalDelegate.h \
ClassInspection.h \
MPConfigFacilities.h \
MPSpinLock.h \
MPSynchronizedQueue.h \
MPNonblockingQueue.h \

libMPUtility_C_FILES = \
dictionary.c \
release_bunch.c \

libMPUtility_OBJC_FILES = \
MPConfigDictionary.m \
MPFileLogChannel.m \
MPLog.m \
MPProfiling.m \
MPDictionary.m \
MPVariant.m \
MPUtility.m \
MPPool.m \
MPMapper.m \
MPPair.m \
MPAutoreleasePool.m \
MPStringToCStringConverter.m \
MPModule.m \
MPRemovalStableList.m \
MPUniversalDelegate.m \
ClassInspection.m \
MPConfigFacilities.m \
MPSpinLock.m \
MPSynchronizedQueue.m \
MPNonblockingQueue.m \


include $(GNUSTEP_MAKEFILES)/library.make
include $(GNUSTEP_MAKEFILES)/tool.make 
 
before-all:: 
#	./makesclists.sh 

after-all::
	cp ./obj/libMPUtility.so ../lib/
 
