SIZEFMT=$(shell $(SIZE) $(ELF)|tail -1|tr -s ' '|cut -d' ' -f2,3,4)
TEXTSIZE=$(shell echo $(SIZEFMT)|cut -d' ' -f1)
DATASIZE=$(shell echo $(SIZEFMT)|cut -d' ' -f2)
BSSSIZE =$(shell echo $(SIZEFMT)|cut -d' ' -f3)
FLASH=$(shell echo $$(($(TEXTSIZE)+$(DATASIZE))))
RAM=$(shell echo $$(($(DATASIZE)+$(BSSSIZE))))

size: $(ELF)
ifneq ($(FLASHSIZE),0)
	@printf "\033[1mFlash: %6d bytes (%2d%%)\033[0m\n" $(FLASH) $$((100*$(FLASH)/$(FLASHSIZE)))
	@printf "\033[1mRAM:   %6d bytes (%2d%%)\033[0m\n" $(RAM) $$(((100*$(RAM)/$(RAMSIZE))))
endif
