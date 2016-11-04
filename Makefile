-include .mbed.mk
# == NUCLEO == #
NUCLEO      = F401RE
TARGET      = NODE_$(NUCLEO)
# ==        == #
# == Inputs == #
UD_SRC      =
UD_LIBSRC   =
UD_TESTSRC  =
UD_LDFLAGS  =
UD_LDLIBS   =
UD_INCLUDES =
# ==        == #
# == Configuration == #
SRCDIR      = src
BUILDDIR    = build
TESTDIR     = tests

DEBUG       = 0
# ==               == #
# == Compiler == #
CXX         = arm-none-eabi-g++
OBJCOPY     = arm-none-eabi-objcopy
OBJDUMP     = arm-none-eabi-objdump
CXXFLAGS    = $(MBED_CXXFLAGS) $(MBED_CXXDEFINES) $(MBED_CPU) -MMD -W -Wall -Wextra -pedantic -ansi -std=c++14
LDFLAGS     = $(MBED_LDFLAGS) $(MBED_CPU) $(_LDFLAGS)
LDLIBS      = $(MBED_LDSYSLIBS) $(_LDLIBS)
INCLUDES    = $(MBED_INCLUDES) $(UD_INCLUDES)
# ==          == #
# == Tests variables == #
TESTFLAGS   = $(CXXFLAGS) -I$(shell pwd)/$(SRCDIR)
TESTLDFLAGS = 
TESTLDLIBS  = 
# ==                == #
# == Sources == #
SRC         = $(wildcard $(SRCDIR)/*.cpp) $(UD_SRC)
LIBSRC      = $(UD_LIBSRC)
TESTSRC     = $(wildcard $(TESTDIR)/*.cpp) $(UD_TESTSRC)
# ==         == #

# == Build directory == #
ifneq ($(DEBUG),1)
MODE        = release
CXXFLAGS   += -DNDEBUG -Os
else
MODE        = debug
CXXFLAGS   += -DDEBUG -O0
endif
BUILD       = $(strip $(BUILDDIR)/$(MODE))
TESTBUILD   = $(strip $(BUILD)/$(TESTDIR))
TESTLDFLAGS+= -L$(BUILD)
# ==                 == #
# == Output files == #
OBJECTS     = $(addprefix $(BUILD)/,$(MBED_OBJECTS)) $(addprefix $(BUILD)/,$(SRC:.cpp=.o))
EXE         = $(BUILD)/$(shell basename $$(pwd))
ELF         = $(EXE).elf
BIN         = $(EXE).bin
HEX         = $(EXE).hex
LST         = $(EXE).lst

LIBOBJS     = $(addprefix $(BUILD)/,$(LIBSRC:.cpp=.o))
LIBOUT      = $(BUILD)/lib$(shell basename $$(pwd)).a

TESTOBJS    = $(addprefix $(BUILD)/,$(TESTSRC:.cpp=.o))
TESTEXE     = $(TESTBUILD)/tests_$(shell basename $$(pwd))

OUTLIST     =
ifneq ($(OBJECTS),)
OUTLIST    += bin hex lst
endif
ifneq ($(LIBOBJS),)
OUTLIST    += lib
endif
ifneq ($(TESTOBJS),)
OUTLIST    += tests
endif
# ==              == #

# == Globals == #
ECHO    = @echo
MKDIR   = @mkdir -p
RM      = @rm -rf
AR      = @ar rvs
CP      = @cp -rf

RED     = \e[1;31m
GREEN   = \e[1;32m
BLUE    = \e[1;34m
YELLOW  = \e[1;33m
NOCOLOR = \e[0m
# ==         == #

# == Rules == #
.PHONY: all exe lib tests run run-test run-tests run-tests-once clean purge clean-tests purge-tests purge-all

all: $(OUTLIST)
exe: $(EXE)
bin: $(BIN)
hex: $(HEX)
lst: $(LST)
lib: $(LIBOUT)
tests: $(TESTEXE)
ifneq ($(LIBOBJS),)
$(TESTEXE): $(LIBOUT)
endif

run: exe
	./$(EXE) $(ARGS)
ifneq ($(TESTOBJS),)
run-tests-once: all
	$(ECHO) $(BLUE)Running all tests$(NOCOLOR)
	@$(TESTEXE) $(TESTOPTS)
run-tests: all
	@tests=$$($(TESTEXE) -t|tail -n+2|head -n+2|tr -d ' '|cut -d'[' -f2|cut -d']' -f1);\
    for test in $$tests; do make -s run-test TEST=$$test; done
run-test: all
	$(ECHO) $(BLUE)Running test: $(TEST)$(NOCOLOR)
	@$(TESTEXE) $(TESTOPTS) "[$(TEST)]"||true
endif
# ==== Cleanup rules ==== #
clean:
	$(RM) $(OBJECTS)
purge:
	$(RM) $(BUILD)
clean-tests:
	$(RM) $(TESTOBJS)
purge-tests:
	$(RM) $(TESTBUILD)
purge-all:
	$(RM) $(BUILDDIR)
# ====               ==== #
# ==== Output generation ==== #
$(EXE): $(OBJECTS)
	$(CXX) -o$@ $^ $(LDFLAGS) $(LDLIBS)
$(ELF): $(LINKER_SCRIPT) $(OBJECTS)
	$(CXX) $(LDFLAGS) -o$@ -T$^ $(LDLIBS)
$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@
$(HEX): $(ELF)
	$(OBJCOPY) -O ihex $< $@
$(LST): $(ELF)
	$(OBJDUMP) -Sdh $< > $@
$(BUILD)/mbed/%.o: mbed/%.o
	$(MKDIR) $(dir $@)
	$(CP) $< $@
$(BUILD)/%.o: %.cpp
	$(MKDIR) $(dir $@)
	$(CXX) $(CXXFLAGS) $(INCLUDES) -o$@ -c $<
-include .targets.mk
# ====                   ==== #
# ==== Output lib generation ==== #
$(LIBOUT): $(LIBOBJS)
	$(AR) $@ $^
# ====                       ==== #
# ==== Tests generation ==== #
ifneq ($(TESTOBJS),)
$(TESTEXE): $(TESTOBJS)
	$(CXX) $(TESTFLAGS) -o$@ $^ $(TESTLDFLAGS) $(TESTLDLIBS)
$(TESTBUILD)/%.o: $(TESTDIR)/%.cpp
	$(MKDIR) $(dir $@)
	$(CXX) $(TESTFLAGS) -o$@ -c $< $(TESTLDFLAGS) $(TESTLDLIBS)
endif
# ====                  ==== #
# ==== Dependencies gen ==== #
DEPS = $(OBJECTS:.o=.d) $(TESTOBJS:.o=.d)
-include $(DEPS)
# ====                  ==== #
# ==      == #
