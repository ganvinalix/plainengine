include $(GNUSTEP_MAKEFILES)/common.make 
 
USE_OBJC_EXCEPTIONS = yes 
ADDITIONAL_OBJCFLAGS += -fgnu-runtime -fconstant-string-class=NSConstantString  -Wall
 
TOOL_NAME = plainEngine 

plainEngine_TOOL_LIBS += -lMPUtility
plainEngine_LIB_DIRS += -L./obj/
 
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
error_names.m \
core_constants.m \
MPDictionaryPooler.m\
MPLinker.m \
MPResultCradle.m \
MPAssertionHandler.m \

plainEngine_HEADER_FILES = \
common.h \
error_names.h \
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
MPDictionaryPooler.h \
MPLinker.h \
MPResultCradle.h \
MPResultCradle.p \
MPAssertionHandler.h \


LIBRARY_NAME = libMPUtility
libMPUtility_LIBRARIES_DEPEND_UPON += -ldl
libMPUtility_HEADER_FILES = \
common_defines.h \
numeric_types.h \
error_names.h \
dictionary.h \
release_bunch.h \
universal_delegate_headers.h \
MPLog.h \
MPConfigDictionary.h \
MPFileLogChannel.h \
MPCodeTimer.h \
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

libMPUtility_C_FILES = \
dictionary.c \
release_bunch.c \

libMPUtility_OBJC_FILES = \
MPConfigDictionary.m \
MPFileLogChannel.m \
MPLog.m \
MPCodeTimer.m \
MPDictionary.m \
MPVariant.m \
MPUtility.m \
MPPool.m \
MPMapper.m \
MPPair.m \
MPAutoreleasePool.m \
error_names.m \
MPStringToCStringConverter.m \
MPModule.m \
MPRemovalStableList.m \
MPUniversalDelegate.m \
ClassInspection.m \

include $(GNUSTEP_MAKEFILES)/library.make
include $(GNUSTEP_MAKEFILES)/tool.make 
 
before-all:: 
#	./makesclists.sh 

after-all::
	cp ./obj/libMPUtility.so ../lib/
 
