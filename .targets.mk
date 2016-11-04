FLASHSIZE   = 0
RAMSIZE     = 0

ifeq ($(NUCLEO),F303K8)
FLASHSIZE   = 65536
RAMSIZE     = 16384
endif

ifeq ($(NUCLEO),F401RE)
FLASHSIZE   = 524288
RAMSIZE     = 98304
endif

ifeq ($(FLASHSIZE),0)
VALID_TARGET=0
else
  VALID_TARGET=1
endif

SIZE=arm-none-eabi-size
SIZEFMT=$(shell $(SIZE) $(ELF)|tail -1|tr -s ' '|cut -d' ' -f2,3,4)
TEXTSIZE=$(shell echo $(SIZEFMT)|cut -d' ' -f1)
DATASIZE=$(shell echo $(SIZEFMT)|cut -d' ' -f2)
BSSSIZE =$(shell echo $(SIZEFMT)|cut -d' ' -f3)
FLASH=$(shell echo $$(($(TEXTSIZE)+$(DATASIZE))))
RAM=$(shell echo $$(($(DATASIZE)+$(BSSSIZE))))

size: $(ELF)
ifneq ($(FLASHSIZE),0)
	@printf '$(RED)Flash: %6d bytes (%2d%%)$(NOCOLOR)\n' $(FLASH) $(shell echo $$((100*$(FLASH)/$(FLASHSIZE))))
	@printf '$(RED)RAM:   %6d bytes (%2d%%)$(NOCOLOR)\n' $(RAM)   $(shell echo $$(((100*$(RAM)/$(RAMSIZE)))))
else
	@printf '$(RED)Error: flash size undefined$(NOCOLOR)\n'
endif
