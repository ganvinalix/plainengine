include $(GNUSTEP_MAKEFILES)/common.make

USE_OBJC_EXCEPTIONS = yes
ADDITIONAL_OBJCFLAGS += -fgnu-runtime -fconstant-string-class=NSConstantString 

###

LIBRARY_NAME = libMPMessageRecoderSubject

libMPMessageRecoderSubject_OBJC_FLAGS = -fPIC
libMPMessageRecoderSubject_LIB_DIRS = -L../../lib/
libMPMessageRecoderSubject_INCLUDE_DIRS = -I../../include/
libMPMessageRecoderSubject_LIBRARIES_DEPEND_UPON = -lMPUtility

libMPMessageRecoderSubject_OBJC_FILES = \
MPMessageRecoderSubject.m \

libMPMessageRecoderSubject_HEADER_FILES = \
MPMessageRecoderSubject.h \ 

include $(GNUSTEP_MAKEFILES)/library.make

