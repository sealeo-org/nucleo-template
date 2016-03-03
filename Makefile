# These variables are to be modified so it corresponds to your system
# Possible values for NUCLEO :
# * F303K8
# * F401RE
NUCLEO  = 
TARGET  = NODE_$(NUCLEO)        # The Nucleo directory name when mounted
DEBUG   = 0                     # 0: release, 1: debug

# These variables are to use or deploy libraries, LDFLAGS for -L flags, LDLIBS for -l flags
LDFLAGS     = -Llib 
LDLIBS      = 

# if CXXFLAGS is not set in this file, default is:
# -std=gnu++98 -fno-rtti -fno-exceptions
CFLAGS      = -std=gnu99
CXXFLAGS    = -std=c++14
BUILD       = build

# These variables are to define project's name
PWD         = $(shell pwd)
PROJECT     = $(shell basename $(PWD))

# Default value: your project directory's name
LIBNAME     = $(PROJECT)
# List here your sources to add to the library file (e.g.: $(wildcard src/*.cpp) or $(shell find src -name '*.cpp'))
LIBSRC      =
LIBOBJ      = $(addprefix $(BUILD)/,$(LIBSRC:.cpp=.o))

# These variables are not intended to be modified
BINARY      = $(BUILD)/$(PROJECT).bin
IMAGE       = nucleo            # The Docker image name (given at build time by -t)
UID         = $(shell id -u)
GID         = $(shell id -g)
USERNAME    = $(shell id -nu)
MOUNTPOINT  = /firmware
DEVICE      ?= $(shell realpath /dev/disk/by-label/$$(file /dev/disk/by-label/*|grep NODE_F303K8|tr -s ' '|cut -d' ' -f5))
MOUNTED     = $(shell mount|grep -q $(TARGET)&&echo -n "1"||echo -n '0')
MEDIA       = $(shell mount|grep $(TARGET)|tr -s ' '|cut -d' ' -f3)
ifneq ($(MOUNTED),1)
MEDIA       = $(strip /media/$(USERNAME)/$(TARGET))
endif
DOCKERMOUNT = -v /media:/media -v $(PWD):$(MOUNTPOINT)
DOCKERARGS  = --rm --privileged $(DOCKERMOUNT)
MBEDMAKEARGS= UID="$(UID)" GID="$(GID)" USERNAME="$(USERNAME)" MOUNTED=$(MOUNTED) BINARY="$(BINARY)"
NUCLEOARGS  = PROJECT="$(PROJECT)" NUCLEO="$(NUCLEO)" DEVICE="$(DEVICE)"
MAKEARGS    = BUILD="$(BUILD)" LDFLAGS="$(LDFLAGS)" LDLIBS="$(LDLIBS)" DEBUG=$(DEBUG) MORE_CFLAGS="$(CFLAGS)" MORE_CXXFLAGS="$(CXXFLAGS)"
DOCKERMAKE  = make -C$(MOUNTPOINT) $(MBEDMAKEARGS) $(NUCLEOARGS) $(MAKEARGS) -f.mbed.mk
DOCKER      = $(strip docker run $(DOCKERARGS) $(IMAGE) $(DOCKERMAKE))
CP          = cp -p
AR          = @ar rvs
SYNC        = @sync

.PHONY: all purge

ifeq ($(NUCLEO),)
nucleo_unspecified:
	@echo "Error: you must specify a value for NUCLEO. See Makefile"
all: nucleo_unspecified
upload: nucleo_unspecified
flash: nucleo_unspecified
else
all:
	$(DOCKER)
ifneq ($(LIBOBJ),)
	$(AR) $(BUILD)/lib$(LIBNAME).a $(LIBOBJ)
endif

ifeq ($(MOUNTED),1)
upload: all
	$(CP) $(BINARY) $(MEDIA)
	$(SYNC)
endif

%:
	$(DOCKER) $@
endif

purge:
	rm -rf $(BUILD)
