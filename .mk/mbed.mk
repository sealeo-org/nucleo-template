include .mk/env.mk
include .mk/commands.mk
include .mk/targets.mk

N_SERIE         = $(shell echo $(NUCLEO)|cut -c1-2)
LDSCRIPT        = STM32$(shell echo $(NUCLEO)|cut -c1-4)X$(shell echo $(NUCLEO)|cut -c6)

TARGET          = TARGET_NUCLEO_$(NUCLEO)
TARGET_STM      = TARGET_STM32$(NUCLEO)
TARGET_STMS     = TARGET_STM32$(N_SERIE)
TARGET_DIR      = mbed/$(TARGET)
TARGET_STMDIR   = $(TARGET_DIR)/TARGET_STM
TARGET_STM32DIR = $(TARGET_STMDIR)/TARGET_STM32$(N_SERIE)
TARGET_SERIE    = $(TARGET_STM32DIR)/$(TARGET)

MEDIA           = /mnt

GCC_BIN         = arm-none-eabi-
SRC             = $(shell find src -name "*.cpp")
OBJECTS         = $(addprefix $(BUILD)/,$(SRC:.cpp=.o))
SYS_OBJECTS     = $(wildcard mbed/$(TARGET)/TOOLCHAIN_GCC_ARM/*.o)
INCLUDE_PATHS   = -Imbed -I$(TARGET_DIR) -I$(TARGET_STMDIR) -I$(TARGET_STM32DIR) -I$(TARGET_SERIE) -Iinc
LIBRARY_PATHS   = -Lmbed/$(TARGET)/TOOLCHAIN_GCC_ARM $(LDFLAGS)
LIBRARIES       = -lmbed $(LDLIBS)
LINKER_SCRIPT   = ./mbed/$(TARGET)/TOOLCHAIN_GCC_ARM/$(LDSCRIPT).ld

BIN = $(BUILD)/$(PROJECT).bin
HEX = $(BIN:.bin=.hex)
ELF = $(BIN:.bin=.elf)
MAP = $(BIN:.bin=.map)
LST = $(BIN:.bin=.lst)
OUTS = $(BIN) $(HEX) $(ELF) $(MAP) $(LST)

CP      = cp
CHOWN   += $(UID):$(GID)
CHOWNR  += $(UID):$(GID)

ifeq ($(HARDFP),1)
	FLOAT_ABI = hard
else
	FLOAT_ABI = softfp
endif

CPU = -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=$(FLOAT_ABI) 
CC_FLAGS = $(CPU) -c -fno-common -fmessage-length=0 -Wall -Wextra -ffunction-sections -fdata-sections -fomit-frame-pointer -MMD -MP
CC_SYMBOLS = -D$(TARGET_STM) -DTARGET_FF_ARDUINO -DTOOLCHAIN_GCC_ARM -DTOOLCHAIN_GCC -DTARGET_FF_MORPHO -DTARGET_CORTEX_M -D__FPU_PRESENT=1 -D__MBED__=1 -D$(TARGET) -DTARGET_M4 -DTARGET_STM -DMBED_BUILD_TIMESTAMP=1449154184.9 -DTARGET_STM32$(N_SERIE) -D__CORTEX_M4 -DARM_MATH_CM4 

LD_FLAGS = $(CPU) -Wl,--gc-sections --specs=nano.specs -u _printf_float -u _scanf_float -Wl,--wrap,main -Wl,-Map=$(MAP),--cref
LD_SYS_LIBS = -lstdc++ -lsupc++ -lc -lgcc -lnosys

ifeq ($(DEBUG), 1)
  CC_FLAGS += -DDEBUG -O0 -g -ggdb
else
  CC_FLAGS += -DNDEBUG -O3
endif

MORE_CFLAGS=-std=gnu99
MORE_CXXFLAGS=-std=gnu++98 -fno-rtti -fno-exceptions

CFLAGS=$(CC_FLAGS) $(MORE_CFLAGS)
CXXFLAGS=$(CC_FLAGS) $(MORE_CXXFLAGS)

.PHONY: all clean lst size own remount upload flash

all: own $(BIN) $(HEX) size
	$(CHOWNR) $(BUILD)

own:
	$(MKDIR) $(BUILDDIR)
	$(CHOWNR) $(BUILDDIR)

upload: mount flash umount
mount:
ifneq ($(MOUNTED),1)
	$(MOUNT) $(DEVICE) $(MEDIA)
endif

umount:
ifneq ($(MOUNTED),1)
	$(UMOUNT) $(MEDIA)
endif

flash:
	$(CP) $(BINARY) $(MEDIA)
	$(SYNC)

clean:
	$(RM) $(OUTS) $(OBJECTS) $(DEPS)

$(BUILD)/%.o: %.S
	$(MKDIR) $(dir $@)
	$(CC) $(CPU) -c -x assembler-with-cpp -o$@ $<
$(BUILD)/%.o: %.c
	$(MKDIR) $(dir $@)
	$(CC) $(CFLAGS) $(CC_SYMBOLS) $(INCLUDE_PATHS) -o$@ $<
$(BUILD)/%.o: %.cpp
	$(MKDIR) $(dir $@)
	$(CXX) $(CXXFLAGS) $(CC_SYMBOLS) $(INCLUDE_PATHS) -o$@ $<

$(ELF): $(OBJECTS) $(SYS_OBJECTS)
	$(LD) $(LD_FLAGS) -T$(LINKER_SCRIPT) $(LIBRARY_PATHS) -o $@ $^ $(LIBRARIES) $(LD_SYS_LIBS) $(LIBRARIES) $(LD_SYS_LIBS)

$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@

$(HEX): $(ELF)
	@$(OBJCOPY) -O ihex $< $@

$(LST): $(ELF)
	@$(OBJDUMP) -Sdh $< > $@

lst: $(LST)

include .mk/size.mk

DEPS = $(OBJECTS:.o=.d) $(SYS_OBJECTS:.o=.d)
-include $(DEPS)
