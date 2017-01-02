FLASHSIZE   := 0
RAMSIZE     := 0

NUCLEO_ID		:= $(shell echo $(NUCLEO)|cut -c2)

ifeq ($(NUCLEO),F303K8)
FLASHSIZE   := 65536
RAMSIZE     := 16384
CORTEXM			:= 4
LDFILE			:= STM32F303X8.ld
endif

ifeq ($(NUCLEO),F401RE)
FLASHSIZE   := 524288
RAMSIZE     := 98304
CORTEXM			:= 4
LDFILE			:= STM32F401XE.ld
endif

ifeq ($(FLASHSIZE),0)
VALID_TARGET		:= 0
else
  VALID_TARGET	:= 1
endif

SIZE				= arm-none-eabi-size
SIZEFMT			= $(shell $(SIZE) $(ELF)|tail -1|tr -s ' '|cut -d' ' -f2,3,4)
TEXTSIZE		= $(shell echo $(SIZEFMT)|cut -d' ' -f1)
DATASIZE		= $(shell echo $(SIZEFMT)|cut -d' ' -f2)
BSSSIZE			= $(shell echo $(SIZEFMT)|cut -d' ' -f3)
FLASH				= $(shell echo $$(($(TEXTSIZE)+$(DATASIZE))))
RAM					= $(shell echo $$(($(DATASIZE)+$(BSSSIZE))))
