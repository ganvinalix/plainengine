include $(GNUSTEP_MAKEFILES)/common.make

USE_OBJC_EXCEPTIONS = yes
ADDITIONAL_OBJCFLAGS += -fgnu-runtime -fconstant-string-class=NSConstantString 

###

LIBRARY_NAME = libMPObjectPoser

libMPObjectPoser_OBJC_FLAGS = -fPIC
libMPObjectPoser_LIB_DIRS = -L../../lib/
libMPObjectPoser_INCLUDE_DIRS = -I../../include/
libMPObjectPoser_LIBRARIES_DEPEND_UPON = -lMPUtility

libMPObjectPoser_OBJC_FILES = \
MPObjectPoser.m \

libMPObjectPoser_HEADER_FILES = \
MPObjectPoser.h \ 

include $(GNUSTEP_MAKEFILES)/library.make

