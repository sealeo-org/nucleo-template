PROGRAM = build/nucleo.elf

FLAGS = -D__HEAP_SIZE=0x0000 -D__STACK_SIZE=0x0100 -DSTM32F401RE \
        -fno-strict-aliasing -DSTM32F4XX -Wall -fdata-sections -ffunction-sections -O0 -ggdb \
        -DTARGET_NUCLEO_F401RE --specs=nosys.specs -mcpu=cortex-m4 -mlittle-endian \
        -mthumb -mthumb-interwork -DSTM32F401xE -Tsrc/stm32f401re_flash.ld \
        -Wl,--gc-sections,--defsym=__HEAP_SIZE=0x0000,--defsym=__STACK_SIZE=0x0100 -std=c++11

LIBS = -lstdc++ -lm

MAXDEPTH = 5

EXCLUDE_DIRS = mbed/targets/cmsis/TARGET_STM/TARGET_NUCLEO_F401RE/* \
               lib/Emulator lib/Emulator/* tests tests/*

EXCLUDE_FILES = src/periodiccaller.cpp mbed/targets/cmsis/TARGET_STM/TARGET_NUCLEO_F401RE/TOOLCHAIN_ARM_STD/sys.cpp mbed/targets/cmsis/TARGET_STM/TARGET_NUCLEO_F401RE/TOOLCHAIN_ARM_MICRO/sys.cpp

OBJECT_FILES = mbed/TARGET_NUCLEO_F401RE/TOOLCHAIN_GCC_ARM/*.o

COMPILER = arm-none-eabi-gcc

SRCEXTS = .cpp .c .S

HDREXTS = .h

RM = rm -f

CHOWN = chown $(UID):$(GID)

include .generic.mk

ALL_INCLUDES_DIRS += /usr/include/newlib/c++/4.8 /usr/include/newlib/c++/4.8/arm-none-eabi

hex: $(PROGRAM:%.elf=%.hex)

bin: $(PROGRAM:%.elf=%.bin)

%.hex: %.elf
	@arm-none-eabi-objcopy -Oihex $< $@
	@$(CHOWN) $@
	@$(ECHO) Generating $@

%.bin: %.elf
	@arm-none-eabi-objcopy -O binary $< $@
	@$(CHOWN) $@
	@$(ECHO) Generating $@

flash: $(PROGRAM:%.elf=%.hex)
	@$(ECHO) Flashing $<
	@sudo openocd -f .openocd.cfg

%.o:%.cpp
	@$(COMPILE) -std=gnu++0x $< -o $@
	@$(CHOWN) $@
#	@$(ECHO) Compiling $<
