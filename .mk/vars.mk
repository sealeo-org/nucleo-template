# These variables are not intended to be modified
DDBLDIR     = /dev/disk/by-label
BINARY      = $(BUILD)/$(PROJECT).bin
IMAGE       = nucleo            # The Docker image name (given at build time by -t)

MOUNTPOINT  = /firmware
DEVICE      ?= $(shell realpath $(DDBLDIR)/$$(file /dev/disk/by-label/*|grep NODE_F303K8|tr -s ' '|cut -d' ' -f5))
MOUNTED     = $(shell mount|grep -q $(TARGET)&&echo -n "1"||echo -n '0')
MEDIA       = $(shell mount|grep $(TARGET)|tr -s ' '|cut -d' ' -f3)
ifneq ($(MOUNTED),1)
MEDIA       = $(strip /media/$(USERNAME)/$(TARGET))
endif

DOCKERMOUNT = -v /media:/media -v $(PWD):$(MOUNTPOINT)
DOCKERARGS  = --rm --privileged $(DOCKERMOUNT)
MBEDMAKEARGS= UID="$(UID)" GID="$(GID)" USERNAME="$(USERNAME)" MOUNTED=$(MOUNTED) BINARY="$(BINARY)"
NUCLEOARGS  = PROJECT="$(PROJECT)" NUCLEO="$(NUCLEO)" DEVICE="$(DEVICE)"
MAKEARGS    = BUILDDIR="$(BUILDDIR)" BUILD="$(BUILD)"
CCOMPARGS   = MORE_CFLAGS="$(CFLAGS)" MORE_CXXFLAGS="$(CXXFLAGS)" LDFLAGS="$(LDFLAGS)" LDLIBS="$(LDLIBS)"
DOCKERMAKE  = make -C$(MOUNTPOINT) $(MBEDMAKEARGS) $(NUCLEOARGS) $(MAKEARGS) $(CCOMPARGS) -f.mk/mbed.mk
DOCKERRUN   = $(strip $(DOCKER) $(DOCKERARGS) $(IMAGE) $(DOCKERMAKE))

ifeq ($(DEVICE),$(DDBLDIR))
VALID_DEVICE=0
else
VALID_DEVICE=1
endif
