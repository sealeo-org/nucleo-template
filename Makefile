# These variables are to be modified so it corresponds to your system
# Possible values for NUCLEO :
# * F303K8
# * F401RE
NUCLEO  = 
DEVICE  = NODE_$(NUCLEO)        # The Nucleo directory name when mounted
DEBUG   = 0                     # 0: release, 1: debug

# if CXXFLAGS is not set in this file, default is:
# -std=gnu++98 -fno-rtti -fno-exceptions
CFLAGS      = -std=gnu99
CXXFLAGS    = -std=c++14

# These variables are to define project's name
PWD         = $(shell pwd)
PROJECT     = $(shell basename $(PWD))

# These variables are to use or deploy libraries, LDFLAGS for -L flags, LDLIBS for -l flags
LDFLAGS     = -Llib 
LDLIBS      = 
# Default value: your project directory's name
LIBNAME     = $(PROJECT)
# List here your sources to add to the library file (e.g.: $(wildcard src/*.cpp) or $(shell find src -name '*.cpp'))
LIBSRC      =
LIBOBJ      = $(addprefix build/,$(LIBSRC:.cpp=.o))

# These variables are not intended to be modified
IMAGE       = nucleo            # The Docker image name (given at build time by -t)
UID         = $(shell id -u)
GID         = $(shell id -g)
MOUNTPOINT  = /firmware
MEDIA       = /$(shell lsblk|grep $(DEVICE)|tr -d ' '|cut -d'/' -f2-)
MEDIAOK     = $(shell [ $(MEDIA) = "/" ] && echo -n "1")
DOCKERMOUNT = -v $(PWD):$(MOUNTPOINT)
NUCLEOARGS  = PROJECT="$(PROJECT)" NUCLEO="$(NUCLEO)"
MAKEARGS    = UID="$(UID)" GID="$(GID)" LDFLAGS="$(LDFLAGS)" LDLIBS="$(LDLIBS)" DEBUG=$(DEBUG) MORE_CFLAGS="$(CFLAGS)" MORE_CXXFLAGS="$(CXXFLAGS)"
DOCKERMAKE  = make -C$(MOUNTPOINT) $(NUCLEOARGS) $(MAKEARGS) -f.mbed.mk
DOCKER      = @docker run --rm $(DOCKERMOUNT) $(IMAGE) $(DOCKERMAKE)
BINARY      = build/$(PROJECT).bin
CP          = cp -p
AR          = @ar rvs

ifeq ($(NUCLEO),)
nucleo_unspecified:
	@echo "Error: you must specify a value for NUCLEO. See Makefile"
all: nucleo_unspecified
upload: nucleo_unspecified
else
all:
	$(DOCKER)
ifneq ($(LIBOBJ),)
	$(AR) build/lib$(LIBNAME).a $(LIBOBJ)
endif

upload: all
ifeq ($(MEDIAOK), 1)
	$(error $(NUCLEO) is not mounted)
else
	$(CP) $(BINARY) $(MEDIA)
endif

%:
	$(DOCKER) $@
endif
