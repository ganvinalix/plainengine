include $(GNUSTEP_MAKEFILES)/common.make

USE_OBJC_EXCEPTIONS = yes
ADDITIONAL_OBJCFLAGS += -fgnu-runtime -fconstant-string-class=NSConstantString 

###

LIBRARY_NAME = libClipClapSubject

libClipClapSubject_OBJC_FLAGS = -fPIC
libClipClapSubject_LIB_DIRS = -L../../lib/
libClipClapSubject_INCLUDE_DIRS = -I../../include/
libClipClapSubject_LIBRARIES_DEPEND_UPON = -lMPUtility

libClipClapSubject_OBJC_FILES = \
ClipClapSubject.m \
ClipClapHelpers.m

libClipClapSubject_HEADER_FILES = \
ClipClapSubject.h \
ClipClapHelpers.h \
InputStrategy.p \

include $(GNUSTEP_MAKEFILES)/library.make

