# == NUCLEO == #
NUCLEO      := 
DISKDIR			:= /dev/disk/by-label
LABEL				:= NODE_$(NUCLEO)
# ==        == #
# == Configuration == #
UD_SRC      :=
UD_LIBSRC   :=
UD_CXXFLAGS :=
UD_INCLUDES :=
UD_LDFLAGS  :=
UD_LDLIBS   :=

DEBUG       := 0
CPP_VERSION	:= c++11
# ==							 == #
# == Directories == #
SRCDIR      := src
BUILDDIR    := build
# ==               == #
-include .targets.mk
# == MBED ==#
MBED_CPU				:= -mcpu=cortex-m$(CORTEXM) -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=softfp
MBED_CXXFLAGS		:= -fmessage-length=0 -fno-exceptions -fno-builtin -ffunction-sections -fdata-sections -funsigned-char -fomit-frame-pointer -fno-rtti

TARGET_NAME			:= TARGET_NUCLEO_$(NUCLEO)
TARGET_ID				:= TARGET_STM32F$(NUCLEO_ID)

NUCLEO_TARGET		:= mbed/$(TARGET_NAME)
NUCLEO_STM			:= $(NUCLEO_TARGET)/TARGET_STM
NUCLEO_STM_ID		:= $(NUCLEO_STM)/$(TARGET_ID)

MBED_NUCLEO_INC	:= -I$(NUCLEO_TARGET) -I$(NUCLEO_STM) -I$(NUCLEO_STM_ID) -I$(NUCLEO_STM_ID)/$(TARGET_NAME) -I$(NUCLEO_STM_ID)/$(TARGET_NAME)/device -I$(NUCLEO_STM_ID)/device -I$(NUCLEO_TARGET)/TOOLCHAIN_GCC_ARM
MBED_INCLUDES		:= -Imbed -Imbed/drivers -Imbed/hal -Imbed/platform $(MBED_NUCLEO_INC)

MBED_CXXDEFINES := -D__MBED__=1 -D$(TARGET_ID) -DTARGET_LIKE_MBED -D$(TARGET_NAME) -DTARGET_RTOS_M4_M7 -DDEVICE_RTC=1 -DTOOLCHAIN_object -DDEVICE_SERIAL_ASYNCH=1 -DMBED_BUILD_TIMESTAMP=1476920540.02 -D__CMSIS_RTOS -DTOOLCHAIN_GCC -DTARGET_CORTEX_M -DTARGET_LIKE_CORTEX_M$(CORTEXM) -DTARGET_M$(CORTEXM) -DTARGET_UVISOR_UNSUPPORTED -DDEVICE_SERIAL=1 -DDEVICE_INTERRUPTIN=1 -DDEVICE_I2C=1 -DDEVICE_PORTOUT=1 -DDEVICE_I2CSLAVE=1 -D__CORTEX_M$(CORTEXM) -DDEVICE_STDIO_MESSAGES=1 -DTARGET_STM32$(NUCLEO) -DTARGET_FF_MORPHO -D__FPU_PRESENT=1 -DTARGET_FF_ARDUINO -DDEVICE_PORTIN=1 -DTARGET_RELEASE -DTARGET_STM -DDEVICE_SERIAL_FC=1 -DDEVICE_PORTINOUT=1 -D__MBED_CMSIS_RTOS_CM -DDEVICE_SLEEP=1 -DTOOLCHAIN_GCC_ARM -DDEVICE_SPI=1 -DDEVICE_ERROR_RED=1 -DDEVICE_SPISLAVE=1 -DDEVICE_ANALOGIN=1 -DDEVICE_PWMOUT=1 -DARM_MATH_CM4 -include mbed/mbed_config.h

MBED_LDFLAGS		:= -Wl,--gc-sections -Wl,--wrap,main -L$(NUCLEO_TARGET)/TOOLCHAIN_GCC_ARM
MBED_LDSYSLIBS	:= -lstdc++ -lsupc++ -lmbed -lc -lgcc -lnosys

MBED_OBJECTS		:= $(shell find $(NUCLEO_TARGET) -name '*.o')
LINKER_SCRIPT		:= $(NUCLEO_TARGET)/TOOLCHAIN_GCC_ARM/$(LDFILE)
# ==      == #
# == Compiler == #
CXX         := arm-none-eabi-g++
OBJCOPY     := arm-none-eabi-objcopy
OBJDUMP     := arm-none-eabi-objdump
CXXWARNFLAGS:= -Wall -Wextra -pedantic -ansi
CXXFLAGS    := $(MBED_CXXFLAGS) $(MBED_CXXDEFINES) $(MBED_CPU) $(CXXWARNFLAGS) -MMD -std=$(CPP_VERSION) $(UD_CXXFLAGS)
LDFLAGS     := $(MBED_LDFLAGS) $(MBED_CPU) $(_LDFLAGS)
LDLIBS      := $(MBED_LDSYSLIBS) $(_LDLIBS)
INCLUDES    := $(MBED_INCLUDES) $(UD_INCLUDES)
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
  CXXFLAGS		+= -DDEBUG -O0
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
UMOUNT		:= @umount

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

DEVICE		= $(shell readlink -f $(DISKDIR)/$(LABEL))

ifeq ($(DEVICE),)
upload: invalid_device
	readlink -f $(DISKDIR)/$(LABEL)
else
MOUNTED		= $(shell mount|grep -q $(DEVICE) && echo 1 || echo 0)
MOUNTPOINT= $(shell findmnt -cfno target $(DEVICE))

ifeq ($(MOUNTPOINT),)
ifeq ($(shell id -u),0)
upload:
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
