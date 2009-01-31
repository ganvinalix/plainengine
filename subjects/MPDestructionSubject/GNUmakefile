include $(GNUSTEP_MAKEFILES)/common.make

USE_OBJC_EXCEPTIONS = yes
ADDITIONAL_OBJCFLAGS += -fgnu-runtime -fconstant-string-class=NSConstantString 

###

LIBRARY_NAME = libMPDestructionSubject

libMPDestructionSubject_OBJC_FLAGS = -fPIC
libMPDestructionSubject_LIB_DIRS = -L../../lib/
libMPDestructionSubject_INCLUDE_DIRS = -I../../include/
libMPDestructionSubject_LIBRARIES_DEPEND_UPON = -lMPUtility

libMPDestructionSubject_OBJC_FILES = \
MPDestructionSubject.m \

libMPDestructionSubject_HEADER_FILES = \
MPDestructionSubject.h \ 

include $(GNUSTEP_MAKEFILES)/library.make

