include $(GNUSTEP_MAKEFILES)/common.make

USE_OBJC_EXCEPTIONS = yes
ADDITIONAL_OBJCFLAGS += -fgnu-runtime -fconstant-string-class=NSConstantString 

###

LIBRARY_NAME = libMPTimerSubject

libMPTimerSubject_OBJC_FLAGS = -fPIC
libMPTimerSubject_LIB_DIRS = -L../../lib/
libMPTimerSubject_INCLUDE_DIRS = -I../../include/
libMPTimerSubject_LIBRARIES_DEPEND_UPON = -lMPUtility

libMPTimerSubject_OBJC_FILES = \
MPTimerSubject.m \

libMPTimerSubject_HEADER_FILES = \
MPTimerSubject.h \ 

include $(GNUSTEP_MAKEFILES)/library.make

