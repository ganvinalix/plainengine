include $(GNUSTEP_MAKEFILES)/common.make

USE_OBJC_EXCEPTIONS = yes
ADDITIONAL_OBJCFLAGS += -fgnu-runtime -fconstant-string-class=NSConstantString 

###

LIBRARY_NAME = libMPMessageCounterSubject

libMPMessageCounterSubject_OBJC_FLAGS = -fPIC
libMPMessageCounterSubject_LIB_DIRS = -L../../lib/
libMPMessageCounterSubject_INCLUDE_DIRS = -I../../include/
libMPMessageCounterSubject_LIBRARIES_DEPEND_UPON = -lMPUtility

libMPMessageCounterSubject_OBJC_FILES = \
MPMessageCounterSubject.m \

libMPMessageCounterSubject_HEADER_FILES = \
MPMessageCounterSubject.h \ 

include $(GNUSTEP_MAKEFILES)/library.make

