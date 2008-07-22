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
MPComponent.m \
MPCodeTimer.m \


plainEngine_HEADER_FILES = \
common.h \
MPLog.h \
MPConfigDictionary.h \
MPNotificationQueue.h \
MPNotifications.h \
MPFileLogChannel.h \
MPComponent.h \
MPFeature.h \
MPObject.h \
MPCodeTimer.h \


include $(GNUSTEP_MAKEFILES)/tool.make

