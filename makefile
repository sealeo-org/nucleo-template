# These variables are to be modified so it correspond to your system
IMAGE       = nucleo            # The Docker image name (given at build time by -t)
NUCLEO      = NODE_F401RE       # The Nucleo directory name when mounted
DEBUGGER    = gdb               # The debugger to use with make debug

# These variables are not intended to be modified
PWD         = $(shell pwd)
UID         = $(shell id -u)
GID         = $(shell id -g)
MOUNTPOINT  = /firmware
MEDIA       = /$(shell lsblk|grep $(NUCLEO)|tr -d ' '|cut -d'/' -f2-)
MEDIAOK     = $(shell [ $(MEDIA) = "/" ] && echo -n "1")
DOCKERMOUNT = -v $(PWD):$(MOUNTPOINT)
DOCKERMAKE  = make -C$(MOUNTPOINT) UID=$(UID) GID=$(GID) VERBOSE=1 -f.nucleo.mk
DOCKER      = docker run --rm $(DOCKERMOUNT) $(IMAGE) $(DOCKERMAKE)
BINARY      = build/nucleo.bin
ELF         = build/nucleo.elf
CP          = cp -p

all:
	@$(DOCKER) bin

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
