# == NUCLEO == #
NUCLEO      := F401RE
DISKDIR		:= /dev/disk/by-label
LABEL		:= NODE_$(NUCLEO)
UPLOAD		:= jlink# disk or jlink
# ==        == #
# == Configuration == #
UD_SRC      := 	\
								$(shell find include/comp  -name '*.cpp') \
								$(shell find include/hard -name '*.cpp') \
								$(shell find include/tools -name '*.cpp') \
								$(shell find include/rosserial_isibot -name '*.cpp') \
								$(shell find lib/ros_lib_kinetic/ -name '*.cpp')  
								
UD_LIBSRC   := 
UD_CXXFLAGS :=
UD_INCLUDES := -Iinclude/rosserial_isibot -Iinclude/comp -Iinclude/tools -Iinclude/hard -Ilib/ros_lib_kinetic/BufferedSerial/ -Ilib/ros_lib_kinetic/ -Ilib/ros_lib_kinetic/BufferedSerial/Buffer/ -Iinclude/

UD_LDFLAGS  := -Wcpp
UD_LDLIBS   := 

GDB_PORT    := 2331

DEBUG       := 0
CPP_VERSION	:= c++14
# ==							 == #
# == Directories == #
SRCDIR      := src
BUILDDIR    := build
# ==               == #
-include .targets.mk
# == MBED ==#
MBED_CPU			:= -mcpu=cortex-m$(CORTEXM) -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=softfp
MBED_CXXFLAGS		:= '-fno-rtti' '-Wvla' '-c' '-Wall' '-Wextra' '-Wno-unused-parameter' '-Wno-missing-field-initializers' '-fmessage-length=0' '-fno-exceptions' '-fno-builtin' '-ffunction-sections' '-fdata-sections' '-funsigned-char' '-MMD' '-fno-delete-null-pointer-checks' '-fomit-frame-pointer' '-Os' '-DMBED_RTOS_SINGLE_THREAD'

TARGET_NAME			:= TARGET_NUCLEO_$(NUCLEO)
TARGET_ID				:= TARGET_STM32F$(NUCLEO_ID)
TARGET_XID			:= TARGET_STM32$(NUCLEO_XID)
TARGET_STM	  := TARGET_STM32F$(NUCLEO)

NUCLEO_TARGET		:= mbed/$(TARGET_NAME)
NUCLEO_STM			:= $(NUCLEO_TARGET)/TARGET_STM
NUCLEO_STM_ID		:= $(NUCLEO_STM)/$(TARGET_ID)
NUCLEO_STM_XID	:= $(NUCLEO_STM_ID)/$(TARGET_XID)

MBED_NUCLEO_INC	:= -I$(NUCLEO_TARGET) -I$(NUCLEO_STM) -I$(NUCLEO_STM_ID) -I$(NUCLEO_STM_XID) -I$(NUCLEO_STM_XID)/$(TARGET_NAME) -I$(NUCLEO_STM_XID)/device -I$(NUCLEO_STM_XID)/$(TARGET_ID) -I$(NUCLEO_STM_ID)/device -I$(NUCLEO_TARGET)/TOOLCHAIN_GCC_ARM

MBED_INCLUDES		:= -Imbed -Imbed/drivers -Imbed/hal -Imbed/platform $(MBED_NUCLEO_INC)

MBED_CXXDEFINES := $(NUCLEO_FLAGS)

MBED_LDFLAGS		:= -Wl,--gc-sections -Wl,--wrap,main -L$(NUCLEO_TARGET)/TOOLCHAIN_GCC_ARM
MBED_LDSYSLIBS	:= -lstdc++ -lsupc++ -lmbed -lc -lc -lgcc -lnosys

MBED_OBJECTS		:= $(shell find $(NUCLEO_TARGET) -name '*.o')
LINKER_SCRIPT		:= $(NUCLEO_TARGET)/TOOLCHAIN_GCC_ARM/$(LDFILE)
# ==      == #
# == Compiler == #
CXX         := arm-none-eabi-g++
OBJCOPY     := arm-none-eabi-objcopy
OBJDUMP     := arm-none-eabi-objdump
CXXWARNFLAGS:= -Wall -Wextra -pedantic -ansi
CXXFLAGS    := $(MBED_CXXFLAGS) $(MBED_CXXDEFINES) $(MBED_CPU) $(CXXWARNFLAGS) -MMD -std=$(CPP_VERSION) $(UD_CXXFLAGS)
LDFLAGS     := -Llib $(MBED_LDFLAGS) $(MBED_CPU) $(UD_LDFLAGS)
LDLIBS      := $(MBED_LDSYSLIBS) $(UD_LDLIBS)
INCLUDES    := -Iinc $(MBED_INCLUDES) $(UD_INCLUDES)
# ==          == #
# == Sources == #
SRC         := $(shell find $(SRCDIR) -name '*.cpp') $(UD_SRC)
LIBSRC      := $(UD_LIBSRC)
# ==         == #
CXXVER      := $(shell $(CXX) -dumpversion)
CXXMAJOR    := $(shell echo $(CXXVER)|cut -d'.' -f1)
CXXMINOR    := $(shell echo $(CXXVER)|cut -d'.' -f2)
CXXREV      := $(shell echo $(CXXVER)|cut -d'.' -f3)
ifeq ($(CXXMAJOR),$(filter $(CXXMAJOR),5 6 7))
  CXXFLAGS  += -fdiagnostics-color=always
else
  ifeq ($(CXXMAJOR),$(filter $(CXXMAJOR),4))
    ifeq ($(CXXMINOR),$(filter $(CXXMINOR),9))
      CXXFLAGS += -fdiagnostics-color=always
    endif
  endif
endif

# == Build directory == #
ifneq ($(DEBUG),1)
  MODE        := release
  CXXFLAGS		+= -DNDEBUG -Os
else
  MODE        := debug
  CXXFLAGS		+= -DDEBUG -O0 -g
endif
BUILD       := $(strip $(BUILDDIR)/$(NUCLEO)/$(MODE))
# ==                 == #
# == Output files == #
OBJECTS     := $(addprefix $(BUILD)/,$(MBED_OBJECTS)) $(addprefix $(BUILD)/,$(SRC:.cpp=.o))
EXE         := $(BUILD)/$(shell basename $$(pwd))
ELF         := $(EXE).elf
BIN         := $(EXE).bin
HEX         := $(EXE).hex
LST         := $(EXE).lst

LIBOBJS     := $(addprefix $(BUILD)/,$(LIBSRC:.cpp=.o))
LIBOUT      := $(BUILD)/lib$(shell basename $$(pwd)).a

OUTLIST     =
ifneq ($(OBJECTS),)
  OUTLIST    += bin hex lst
endif
ifneq ($(LIBOBJS),)
  OUTLIST    += lib
endif
# ==              == #

# == Globals == #
ECHO			:= @echo -e
MKDIR			:= @mkdir -p
RM				:= @rm -rf
AR				:= @ar rvs
CP				:= @cp -rf
SYNC			:= @sync
MOUNT			:= @mount
UMOUNT		:= @umountGENJLINK  := @gen-jlink
JLINK			:= @JLinkExe -if SWD -speed 4000 -autoconnect 1 -CommanderScript /tmp/script.jlink
JLINK_DBG		:= JLinkGDBServer -if SWD -speed 4000 -endian little

RED				:= \e[1;31m
GREEN			:= \e[1;32m
BLUE			:= \e[1;34m
YELLOW		:= \e[1;33m
NOCOLOR		:= \e[0m
# ==         == #

# == Rules == #
.PHONY: all bin hex lst lib upload clean purge purge-all

ifeq ($(NUCLEO),)
all: nucleo_unspecified
upload: nucleo_unspecified
else
ifneq ($(VALID_TARGET),1)
all: invalid_target
upload: invalid_target
else
all: $(OUTLIST) size
bin: $(BIN)
hex: $(HEX)
lst: $(LST)
lib: $(LIBOUT)

ifeq ($(UPLOAD),disk)
DEVICE		= $(shell readlink -f $(DISKDIR)/$(LABEL))

ifeq ($(DEVICE),)
upload: invalid_device
	readlink -f $(DISKDIR)/$(LABEL)
else
MOUNTED		= $(shell mount|grep -q $(DEVICE) && echo 1 || echo 0)
MOUNTPOINT= $(shell findmnt -cfno target $(DEVICE))

ifeq ($(MOUNTPOINT),)
ifeq ($(shell id -u),0)
upload: all
	$(MOUNT) $(DEVICE) /mnt
	$(CP) $(BIN) /mnt
	$(SYNC)
	$(UMOUNT) /mnt
else
upload:	nucleo_not_mounted
endif	# USER
else
upload: all
	$(CP) $(BIN) $(MOUNTPOINT)
	$(SYNC)
endif	# MOUNTED
endif	# VALID DEVICE
else
upload: all
	$(GENJLINK) $(NUCLEO) $(BIN)
	$(JLINK)

debug:
	@(sleep 2 ; echo -e "\n\n$(GREEN)GDB server address: $$(cat /etc/hosts | grep $$(cat /etc/hostname) | sed -r 's/^\s*(\S+)(\s+.*)?$$/\1/'):$(GDB_PORT)\n$(NOCOLOR)") &
	$(JLINK_DBG) -device STM32$(NUCLEO) -port $(GDB_PORT)
endif	# UPLOAD

endif	# VALID TARGET
endif # NUCLEO

nucleo_unspecified:
	$(ECHO) "$(RED)Error: you must specify a value for NUCLEO. See Makefile$(NOCOLOR)"
invalid_target:
	$(ECHO) "$(RED)Error: invalid target $(NUCLEO)$(NOCOLOR)"
invalid_device:
	$(ECHO) "$(RED)Error: is the nucleo $(NUCLEO) plugged-in?$(NOCOLOR)"
nucleo_not_mounted:
	$(ECHO) "$(RED)Error: $(NUCLEO) not mounted$(NOCOLOR)"
# ==== Cleanup rules ==== #
clean:
	$(RM) $(OBJECTS)
purge:
	$(RM) $(BUILD)
purge-all:
	$(RM) $(BUILDDIR)
	
print-bin:
	$(ECHO) $(ELF)
# ====               ==== #
# ==== Output generation ==== #
$(ELF): $(LINKER_SCRIPT) $(OBJECTS)
	$(ECHO) "$(GREEN)Linking: $@$(NOCOLOR)"
	@$(CXX) $(LDFLAGS) -o$@ -T$^ $(LDLIBS)
$(BIN): $(ELF)
	@$(OBJCOPY) -O binary $< $@
$(HEX): $(ELF)
	@$(OBJCOPY) -O ihex $< $@
$(LST): $(ELF)
	@$(OBJDUMP) -Sdh $< > $@
$(BUILD)/mbed/%.o: mbed/%.o
	$(MKDIR) $(dir $@)
	$(CP) $< $@
$(BUILD)/%.o: %.cpp
	$(ECHO) "$(GREEN)Compiling: $@$(NOCOLOR)"
	$(MKDIR) $(dir $@)
	@$(CXX) $(CXXFLAGS) $(INCLUDES) -o$@ -c $<
size: $(ELF)
ifneq ($(FLASHSIZE),0)
	@printf '$(BLUE)Flash: %6d bytes (%2d%%)$(NOCOLOR)\n' $(FLASH) $(shell echo $$((100*$(FLASH)/$(FLASHSIZE))))
	@printf '$(BLUE)RAM:   %6d bytes (%2d%%)$(NOCOLOR)\n' $(RAM)   $(shell echo $$(((100*$(RAM)/$(RAMSIZE)))))
else
	@printf '$(RED)Error: flash size undefined$(NOCOLOR)\n'
endif
# ====                   ==== #
# ==== Output lib generation ==== #
$(LIBOUT): $(LIBOBJS)
	$(AR) $@ $^
# ====                       ==== #
# ==== Dependencies gen ==== #
DEPS = $(OBJECTS:.o=.d) $(TESTOBJS:.o=.d)
-include $(DEPS)
# ====                  ==== #
# ==      == #
