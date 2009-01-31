include $(GNUSTEP_MAKEFILES)/common.make

USE_OBJC_EXCEPTIONS = yes
ADDITIONAL_OBJCFLAGS += -fgnu-runtime -fconstant-string-class=NSConstantString 

###

LIBRARY_NAME = libMP2DObjectSubject

libMP2DObjectSubject_OBJC_FLAGS = -fPIC
libMP2DObjectSubject_LIB_DIRS = -L../../lib/
libMP2DObjectSubject_INCLUDE_DIRS = -I../../include/
libMP2DObjectSubject_LIBRARIES_DEPEND_UPON = -lMPUtility

libMP2DObjectSubject_OBJC_FILES = \
MP2DObjectSubject.m \
MP2DObjectDelegate.m

libMP2DObjectSubject_HEADER_FILES = \
MP2DObjectSubject.h \
MP2DObjectDelegate.h \
MP2DObject.p \

include $(GNUSTEP_MAKEFILES)/library.make

