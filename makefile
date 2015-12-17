# These variables are to be modified so it correspond to your system
IMAGE       = nucleo            # The Docker image name (given at build time by -t)
NUCLEO      = NODE_F401RE       # The Nucleo directory name when mounted
DEBUGGER    = gdb               # The debugger to use with make debug
#DEBUGMODE   = 1                # comment this line to enter in release mode

# These variables are to use or deploy libraries
LDFLAGS     = -lm
# Default value: your project directory's name
LIBNAME     = $(shell basename $(shell pwd))
# List here your sources to add to the library file (e.g.: $(wildcard src/*.cpp))
LIBSRC      =
LIBOBJ      = $(addprefix build/,$(LIBSRC:.cpp=.o))

# These variables are not intended to be modified
PWD         = $(shell pwd)
UID         = $(shell id -u)
GID         = $(shell id -g)
MOUNTPOINT  = /firmware
MEDIA       = /$(shell lsblk|grep $(NUCLEO)|tr -d ' '|cut -d'/' -f2-)
MEDIAOK     = $(shell [ $(MEDIA) = "/" ] && echo -n "1")
DOCKERMOUNT = -v $(PWD):$(MOUNTPOINT)
ifneq ($(DEBUGMODE),)
DFLAGS      = -DDEBUG -O0 -ggdb
else
DFLAGS      = -DNDEBUG -Os
endif
MAKEARGS    = UID="$(UID)" GID="$(GID)" LDFLAGS="$(LDFLAGS)" DFLAGS="$(DFLAGS)"
DOCKERMAKE  = make -C$(MOUNTPOINT) $(MAKEARGS) -f.nucleo.mk
DOCKER      = docker run --rm $(DOCKERMOUNT) $(IMAGE) $(DOCKERMAKE)
BINARY      = build/nucleo.bin
ELF         = build/nucleo.elf
CP          = cp -p
AR          = ar rvs

all:
	@$(DOCKER) bin
ifneq ($(LIBOBJ),)
	@$(AR) build/lib$(LIBNAME).a $(LIBOBJ)
endif

upload: all
ifeq ($(MEDIAOK), 1)
	$(error $(NUCLEO) is not mounted)
else
	$(CP) $(BINARY) $(MEDIA)
endif

flash:
	@$(DOCKER) flash

debug:
	@$(DEBUGGER) $(ELF)

clean:
	@$(DOCKER) clean

purge:
	@$(DOCKER) distclean

%:
	@$(DOCKER) $@
