include $(GNUSTEP_MAKEFILES)/common.make

USE_OBJC_EXCEPTIONS = yes
ADDITIONAL_OBJCFLAGS += -fgnu-runtime -fconstant-string-class=NSConstantString 

###

LIBRARY_NAME = libMPGravityChangerSubject

libMPGravityChangerSubject_OBJC_FLAGS = -fPIC
libMPGravityChangerSubject_LIB_DIRS = -L../../lib/
libMPGravityChangerSubject_INCLUDE_DIRS = -I../../include/
libMPGravityChangerSubject_LIBRARIES_DEPEND_UPON = -lMPUtility

libMPGravityChangerSubject_OBJC_FILES = \
MPGravityChangerSubject.m \

libMPGravityChangerSubject_HEADER_FILES = \
MPGravityChangerSubject.h \ 

include $(GNUSTEP_MAKEFILES)/library.make

