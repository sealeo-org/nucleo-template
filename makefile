# These variables are to be modified so it correspond to your system
IMAGE       = nucleo            # The Docker image name (given at build time by -t)
NUCLEO      = NODE_F401RE       # The Nucleo directory name when mounted
DEBUGGER    = gdb               # The debugger to use with make debug

# These variables are not intended to be modified
PWD         = $(shell pwd)
MOUNTPOINT  = /firmware
MEDIA       = /$(shell lsblk|grep $(NUCLEO)|tr -d ' '|cut -d'/' -f2-)
MEDIAOK     = $(shell [ $(MEDIA) = "/" ] && echo -n "1")
DOCKER      = docker run --rm -v $(PWD):$(MOUNTPOINT) $(IMAGE) make -C$(MOUNTPOINT) -f.nucleo.mk
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
