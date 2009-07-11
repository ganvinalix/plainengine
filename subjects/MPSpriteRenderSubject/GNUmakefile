include $(GNUSTEP_MAKEFILES)/common.make

USE_OBJC_EXCEPTIONS = yes
ADDITIONAL_OBJCFLAGS += -fgnu-runtime -fconstant-string-class=NSConstantString 

###

LIBRARY_NAME = libMPSpriteRenderSubject

libMPSpriteRenderSubject_OBJC_FLAGS = -fPIC
libMPSpriteRenderSubject_LIB_DIRS = -L../../lib/ #`sdl-config --libs`
libMPSpriteRenderSubject_INCLUDE_DIRS = -I../../include/ `sdl-config --cflags`
libMPSpriteRenderSubject_LIBRARIES_DEPEND_UPON = -lMPUtility -lSDL -lGL -lGLU -lIL -lILU -lILUT

libMPSpriteRenderSubject_OBJC_FILES = \
MPSpriteRenderSubject.m \
MPSpriteRenderDelegate.m \
MPRenderable.m \
MPSprite.m \
MPAnimators.m \
MPCamera.m \
MPMouse.m \

libMPSpriteRenderSubject_HEADER_FILES = \
MPSpriteRenderSubject.h \
MPSpriteRenderDelegate.h \
MPSpriteObject.p \
MPRenderable.p \
MPRenderable.h \
MPSprite.h \
MPAnimator.p \
MPCamera.h \
MPMouse.h \

include $(GNUSTEP_MAKEFILES)/library.make

