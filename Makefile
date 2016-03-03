include .mk/env.mk
include .mk/commands.mk

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
BUILDDIR    = build

# These variables are to define project's name
PROJECT     = $(shell basename $(PWD))

# Default value: your project directory's name
LIBNAME     = $(PROJECT)
# List here your sources to add to the library file (e.g.: $(wildcard src/*.cpp) or $(shell find src -name '*.cpp'))
LIBSRC      =

# == Build directory == #
ifneq ($(DEBUG),1)
MODE        = release
else
MODE        = debug
endif
BUILD       = $(strip $(BUILDDIR)/$(NUCLEO)/$(MODE))
# ==                 == #

LIBOBJ      = $(addprefix $(BUILD)/,$(LIBSRC:.cpp=.o))

include .mk/vars.mk
include .mk/targets.mk
.PHONY: all purge purge-all

ifeq ($(NUCLEO),)               # > Check if nucleo is set
all: nucleo_unspecified
upload: nucleo_unspecified
else ifneq ($(VALID_TARGET),1)  # > Check if nucleo is valid
all: invalid_target
upload: invalid_target
else                            # > Nucleo set and valid
all:
	$(DOCKERRUN)
ifneq ($(LIBOBJ),)
	$(AR) $(BUILD)/lib$(LIBNAME).a $(LIBOBJ)
endif

ifneq ($(VALID_DEVICE),1)       # >> Check if device found for upload
upload: invalid_device
else ifeq ($(MOUNTED),1)        # >> Check if device already mounted
upload: all
	$(CP) $(BINARY) $(MEDIA)
	$(SYNC)
else
%:
	$(DOCKERRUN) $@
endif
endif

purge:
	$(RM) $(BUILD)
purge-all:
	$(RM) $(BUILDDIR)

# Error cases
nucleo_unspecified:
	$(ECHO) "Error: you must specify a value for NUCLEO. See Makefile"
invalid_target:
	$(ECHO) "Error: invalid target $(NUCLEO)"
invalid_device:
	$(ECHO) "Error: is the nucleo $(NUCLEO) plugged-in?"
