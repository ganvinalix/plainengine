include $(GNUSTEP_MAKEFILES)/common.make

USE_OBJC_EXCEPTIONS = yes
ADDITIONAL_OBJCFLAGS += -fgnu-runtime -fconstant-string-class=NSConstantString 

###

LIBRARY_NAME = libMPMessageAnnouncerSubject

libMPMessageAnnouncerSubject_OBJC_FLAGS = -fPIC
libMPMessageAnnouncerSubject_LIB_DIRS = -L../../lib/
libMPMessageAnnouncerSubject_INCLUDE_DIRS = -I../../include/
libMPMessageAnnouncerSubject_LIBRARIES_DEPEND_UPON = -lMPUtility

libMPMessageAnnouncerSubject_OBJC_FILES = \
MPMessageAnnouncerSubject.m \

libMPMessageAnnouncerSubject_HEADER_FILES = \
MPMessageAnnouncerSubject.h \ 

include $(GNUSTEP_MAKEFILES)/library.make

