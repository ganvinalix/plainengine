include $(GNUSTEP_MAKEFILES)/common.make

USE_OBJC_EXCEPTIONS = yes
ADDITIONAL_OBJCFLAGS += -fgnu-runtime -fconstant-string-class=NSConstantString 

###

LIBRARY_NAME = libMPConsoleSubject

libMPConsoleSubject_OBJC_FLAGS = -fPIC
libMPConsoleSubject_LIB_DIRS = -L../../lib/
libMPConsoleSubject_INCLUDE_DIRS = -I../../include/
libMPConsoleSubject_LIBRARIES_DEPEND_UPON = -lMPUtility

libMPConsoleSubject_OBJC_FILES = \
MPConsoleBatchSubject.m \
MPConsoleInputLoggerSubject.m \
MPConsoleInputLoopSubject.m \
MPConsoleInputMessagerSubject.m \
MPConsoleInputObjectManipulatorSubject.m \
MPConsoleInputSubject.m \
MPConsoleBatchSubject.m \
MPConsoleInputDelegateCallerSubject.m \

libMPConsoleSubject_HEADER_FILES = \
MPConsoleBatchSubject.h \
MPConsoleInputLoggerSubject.h \
MPConsoleInputLoopSubject.h \
MPConsoleInputMessagerSubject.h \
MPConsoleInputObjectManipulatorSubject.h \
MPConsoleInputSubject.h \
MPConsoleInputDelegateCallerSubject.h \

include $(GNUSTEP_MAKEFILES)/library.make

