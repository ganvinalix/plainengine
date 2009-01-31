include $(GNUSTEP_MAKEFILES)/common.make

USE_OBJC_EXCEPTIONS = yes
ADDITIONAL_OBJCFLAGS += -fgnu-runtime -fconstant-string-class=NSConstantString 

###

LIBRARY_NAME = libMPMemorySharingSubject

libMPMemorySharingSubject_OBJC_FLAGS = -fPIC
libMPMemorySharingSubject_LIB_DIRS = -L../../lib/
libMPMemorySharingSubject_INCLUDE_DIRS = -I../../include/
libMPMemorySharingSubject_LIBRARIES_DEPEND_UPON = -lMPUtility

libMPMemorySharingSubject_OBJC_FILES = \
MPMemorySharingSubject.m \

libMPMemorySharingSubject_HEADER_FILES = \
MPMemorySharingSubject.h \ 

include $(GNUSTEP_MAKEFILES)/library.make

