include $(GNUSTEP_MAKEFILES)/common.make

USE_OBJC_EXCEPTIONS = yes
ADDITIONAL_OBJCFLAGS += -fgnu-runtime -fconstant-string-class=NSConstantString



LIBRARY_NAME = libMPLuaSubject

libMPLuaSubject_OBJC_FLAGS = -fPIC
libMPLuaSubject_LIB_DIRS = -L../../lib/
libMPLuaSubject_INCLUDE_DIRS = -I../../include/ 
libMPLuaSubject_LIBRARIES_DEPEND_UPON = -lMPUtility -llua5.1

libMPLuaSubject_OBJC_FILES = MPLuaSubject.m\
							 MPLuaExports.m\
							 MPLuaHelpers.m

libMPLuaSubject_HEADER_FILES = MPLuaSubject.h\
							   MPLuaExports.h\
							   MPLuaHelpers.h

include $(GNUSTEP_MAKEFILES)/library.make

