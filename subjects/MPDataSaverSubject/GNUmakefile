include $(GNUSTEP_MAKEFILES)/common.make

USE_OBJC_EXCEPTIONS = yes
ADDITIONAL_OBJCFLAGS += -fgnu-runtime -fconstant-string-class=NSConstantString 

###

LIBRARY_NAME = libMPDataSaverSubject

libMPDataSaverSubject_OBJC_FLAGS = -fPIC
libMPDataSaverSubject_LIB_DIRS = -L../../lib/
libMPDataSaverSubject_INCLUDE_DIRS = -I../../include/
libMPDataSaverSubject_LIBRARIES_DEPEND_UPON = -lMPUtility

libMPDataSaverSubject_OBJC_FILES = \
MPDataSaverSubject.m \

libMPDataSaverSubject_HEADER_FILES = \
MPDataSaverSubject.h \ 

include $(GNUSTEP_MAKEFILES)/library.make

