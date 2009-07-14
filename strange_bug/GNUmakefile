include $(GNUSTEP_MAKEFILES)/common.make

USE_OBJC_EXCEPTIONS = yes
ADDITIONAL_OBJCFLAGS += -fgnu-runtime -fconstant-string-class=NSConstantString 

###

LIBRARY_NAME = libMPIrrlichtRenderSubject

libMPIrrlichtRenderSubject_OBJC_FLAGS += -fPIC
libMPIrrlichtRenderSubject_LIB_DIRS += -L../../lib/ -L../../../irrlicht/lib/
libMPIrrlichtRenderSubject_INCLUDE_DIRS += -I../../include/ -I../../../irrlicht/include/
libMPIrrlichtRenderSubject_LIBRARIES_DEPEND_UPON += -lMPUtility -lIrrlicht -lGL -lXxf86vm -lXext -lX11

libMPIrrlichtRenderSubject_OBJCC_FILES = \
MPIrrlichtRenderSubject.mm \
#MPGraphical.mm 

libMPIrrlichtRenderSubject_HEADER_FILES = \
MPIrrlichtRenderSubject.h \
#MPGraphical.h

include $(GNUSTEP_MAKEFILES)/library.make

