include $(GNUSTEP_MAKEFILES)/common.make

USE_OBJC_EXCEPTIONS = yes
ADDITIONAL_OBJCFLAGS = -fgnu-runtime -fconstant-string-class=NSConstantString 

TOOL_NAME = plainEngine

plainEngine_OBJC_FILES = \
main.m \
MPConfigDictionary.m \
MPFileLogChannel.m \
MPLog.m \
MPNotificationQueue.m \
MPCodeTimer.m \
MPDictionary.m \
MPThread.m \
MPSubjectManager.m \
error_names.m \

plainEngine_C_FILES = \
dictionary.c \

plainEngine_HEADER_FILES = \
common.h \
common_defines.h \
numeric_types.h \
error_names.h \
dictionary.h \
MPLog.h \
MPConfigDictionary.h \
MPNotificationQueue.h \
MPNotifications.h \
MPFileLogChannel.h \
MPFeature.h \
MPObject.h \
MPCodeTimer.h \
MPDictionary.h \

include $(GNUSTEP_MAKEFILES)/tool.make

before-all::
	../sc_gen_src/obj/scgen error_names.txt

