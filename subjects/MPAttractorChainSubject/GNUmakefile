include $(GNUSTEP_MAKEFILES)/common.make

USE_OBJC_EXCEPTIONS = yes
ADDITIONAL_OBJCFLAGS += -fgnu-runtime -fconstant-string-class=NSConstantString 

###

LIBRARY_NAME = libMPAttractorChainSubject

libMPAttractorChainSubject_OBJC_FLAGS = -fPIC
libMPAttractorChainSubject_LIB_DIRS = -L../../lib/
libMPAttractorChainSubject_INCLUDE_DIRS = -I../../include/
libMPAttractorChainSubject_LIBRARIES_DEPEND_UPON = -lMPUtility

libMPAttractorChainSubject_OBJC_FILES = \
MPAttractorChainSubject.m \
MPACSAttractedDelegate.m \

libMPAttractorChainSubject_HEADER_FILES = \
MPAttractorChainSubject.h \
MPACSAttractedDelegate.h \

include $(GNUSTEP_MAKEFILES)/library.make

