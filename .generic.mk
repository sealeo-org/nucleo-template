##==========================================================================
## Stable Section: usually no need to be changed. But you can add more.
##==========================================================================

SHELL   = /bin/sh
EMPTY   =
SPACE   = $(EMPTY) $(EMPTY)

ifeq ($(PROGRAM),)
  CUR_PATH_NAMES = $(subst /, $(SPACE), $(subst $(SPACE),_,$(CURDIR)))
  PROGRAM = $(word $(words $(CUR_PATH_NAMES)), $(CUR_PATH_NAMES))
  ifeq ($(PROGRAM),)
    PROGRAM = a.out
  endif
endif

ifeq ($(SRCDIRS),)
  SRCDIRS = .
endif

ifneq ($(MAXDEPTH),)
  MAXDEPTH_OPTION = -maxdepth $(MAXDEPTH)
endif

ifneq ($(TESTS_DIR),)
  TESTS_SOURCES_DIRS = $(shell find -L $(wildcard $(TESTS_DIR)) $(MAXDEPTH_OPTION) \
                                      \( ! -regex '.*/\..*' \) -type d) $(TESTS_DIR)
  TESTS_SOURCES = $(foreach d, $(TESTS_SOURCES_DIRS), $(wildcard $(addprefix $(d)/*, $(SRCEXTS))))
  TESTS_OBJS = $(addsuffix .o, $(basename $(TESTS_SOURCES))) $(filter-out %main.o, $(OBJS))
  TESTS_DEPS = $(TESTS_OBJS:.o=.d)
endif

EXPANDED_EXCLUDE_DIRS += $(patsubst %/.,%,$(wildcard $(addsuffix /.,$(EXCLUDE_DIRS)))) $(TESTS_SOURCES_DIRS)

ALL_SOURCES_DIRS = $(filter-out $(patsubst ./%, %, $(EXPANDED_EXCLUDE_DIRS)), $(patsubst ./%, %, \
                                  $(shell find -L $(wildcard $(SOURCES_DIRS)) $(MAXDEPTH_OPTION) \
                                                               \( ! -regex '.*/\..*' \) -type d)))
ALL_INCLUDES_DIRS = $(filter-out $(patsubst ./%, %, $(EXPANDED_EXCLUDE_DIRS)), $(patsubst ./%, %, \
                                   $(shell find -L $(wildcard $(INCLUDES_DIRS)) $(MAXDEPTH_OPTION) \
                                                                 \( ! -regex '.*/\..*' \) -type d)))

SOURCES = $(filter-out $(EXCLUDE_FILES), $(foreach d, $(ALL_SOURCES_DIRS), $(wildcard $(addprefix $(d)/*, $(SRCEXTS)))))
HEADERS = $(filter-out $(EXCLUDE_FILES), $(foreach d, $(ALL_INCLUDES_DIRS), $(wildcard $(addprefix $(d)/*, $(HDREXTS)))))
INCLUDES = $(patsubst %,-I%,$(ALL_INCLUDES_DIRS))
SOURCE_OBJS = $(addsuffix .o, $(basename $(SOURCES)))
OBJS = $(SOURCE_OBJS) $(wildcard $(OBJECT_FILES))
DEPS = gen_deps $(SOURCE_OBJS:.o=.d)

# Define some useful variables.
DEP_OPT = $(shell if `$(CCOMPILER) --version | grep "GCC" >/dev/null`; then echo "-MM -MP"; else echo "-M"; fi )
DEPENDC     = $(CCOMPILER) $(DEP_OPT) $(FLAGS) $(INCLUDES)
DEPENDCPP   = $(CXXCOMPILER) $(DEP_OPT) $(FLAGS) $(CPPFLAGS) $(INCLUDES)
DEPEND.d = $(subst -g,, $(DEPENDC))
COMPILEC    = $(CCOMPILER) $(FLAGS) $(INCLUDES) -c
COMPILECPP  = $(CXXCOMPILER) $(FLAGS) $(CPPFLAGS) $(INCLUDES) -c
LINK = $(CXXCOMPILER) $(FLAGS) $(CPPFLAGS)

ifneq ($(filter $(MAKECMDGOALS), lib),)
COMPILEC    += -fPIC
COMPILECPP  += -fPIC
endif

# Compute progress
ifndef ECHO
T := $(shell $(MAKE) $(MAKECMDGOALS) --no-print-directory \
                    -nrRf $(firstword $(MAKEFILE_LIST)) \
             ECHO="echo COUNTTHIS" | grep -c "COUNTTHIS")
N := x
C = $(words $N)$(eval N := x $N)
ECHO = printf "["; printf "%3.3s" "`expr $C \* 100 / $T`"; echo "%]"
endif

#-------------------------------------
# Rules for generating the executable.
#-------------------------------------

.PHONY: all objs clean distclean help show

# Delete the default suffixes
.SUFFIXES:

all: $(PROGRAM) test
	@$(ECHO) All done

$(PROGRAM): $(DEPS) $(OBJS) $(dir $(PROGRAM))
ifneq ($(OBJS),)
	@$(LINK) $(OBJS) $(LIBS) -o $@
	@$(CHOWN) $@
	@$(ECHO) Linking $@
	@$(SHOWSIZE)
endif

$(dir $(PROGRAM)):
	@mkdir -p $@
	@$(CHOWN) $@

test: FORCE $(TESTS_DIR)/tests
ifneq ($(TESTS_DIR),)
	@$(TESTS_DIR)/tests
endif

$(TESTS_DIR)/tests: $(TESTS_DEPS) $(TESTS_OBJS)
ifneq ($(TESTS_DIR),)
	@$(LINK) $(TESTS_OBJS) $(LIBS) -lgtest -o $@
endif

gen_deps:
	@$(ECHO) Updating dependencies

lib: $(DEPS) $(OBJS)
	$(LINK) -shared -o lib$(PROGRAM).so $(OBJS)
	@$(CHOWN) lib$(PROGRAM).so

#----------------------------------------
# Rules for generating object files (.o).
#----------------------------------------

%.o:%.c
	@$(COMPILEC) $< -o $@
	@$(CHOWN) $@
	@$(ECHO) Compiling $<

%.o:%.cpp
	@$(COMPILECPP) $< -o $@
	@$(CHOWN) $@
	@$(ECHO) Compiling $<

%.o:%.S
	@$(COMPILECPP) $< -o $@
	@$(CHOWN) $@
	@$(ECHO) Compiling $<

#------------------------------------------
# Rules for creating dependency files (.d).
#------------------------------------------

%.d:%.c
	@$(DEPENDC) -MT $(basename $@).o $*.c > $*.d
	@$(CHOWN) $@

%.d:%.cpp
	@$(DEPENDCPP) -MT $(basename $@).o $*.cpp > $*.d
	@$(CHOWN) $@

%.d:%.S
	@$(DEPENDCPP) -MT $(basename $@).o $*.S > $*.d
	@$(CHOWN) $@

#-------------------
# Rules for cleaning
#-------------------

clean:
	@$(RM) $(OBJS) $(PROGRAM) $(PROGRAM:.elf=.bin) $(PROGRAM:.elf=.hex) build/*.a

distclean: clean
	@$(RM) $(DEPS) $(DEPS:%.d=%.d.*)

FORCE:

#---------------------
# Include dependencies
#---------------------

ifndef NODEP
ifneq ($(DEPS),)
ifeq ($(filter $(MAKECMDGOALS), clean distclean help show),)
  -include $(DEPS)
endif
endif
endif

#----------
# Show help
#----------

help:
	@echo 'Usage: make [TARGET]'
	@echo 'TARGETS:'
	@echo '  all       (=make) compile, link and test'
	@echo '  test      compile and run tests'
	@echo '  NODEP=yes make without generating dependencies.'
	@echo '  objs      compile only (no linking).'
	@echo '  clean     clean objects and the executable file.'
	@echo '  distclean clean objects, the executable and dependencies.'
	@echo '  show      show variables (for debug use only).'
	@echo '  help      print this message.'

#-------------------------------------
# Show variables (for debug use only.)
#-------------------------------------

show:
	@echo -e "INCLUDES_DIRS: $(INCLUDES_DIRS)\n"
	@echo -e "INCLUDES_DIRS: $(ALL_INCLUDES_DIRS)\n"
	@echo -e "HEADERS: $(HEADERS)\n"
	@echo -e "SOURCES: $(SOURCES)\n"
	@echo -e "PROGRAM: $(PROGRAM)\n"
	@echo -e "SOURCES_DIRS: $(SOURCES_DIRS)\n"
	@echo -e "SOURCES_DIRS: $(ALL_SOURCES_DIRS)\n"
	@echo -e "EXCLUDE_DIRS: $(EXPANDED_EXCLUDE_DIRS)\n"
	@echo -e "OBJS: $(OBJS)\n"
	@echo -e "DEPS: $(DEPS)\n"
	@echo -e "DEPENDC: $(DEPENDC)\n"
	@echo -e "DEPENDCPP:  $(DEPENDCPP)\n"
	@echo -e "COMPILEC: $(COMPILEC)\n"
	@echo -e "COMPILECPP: $(COMPILECPP)\n"
	@echo -e "LINK: $(LINK)\n"
	@echo -e "INCLUDES: $(INCLUDES)\n"
	@echo -e "TESTS_SOURCES_DIRS: $(TESTS_SOURCES_DIRS)\n"
	@echo -e "TESTS_SOURCES: $(TESTS_SOURCES)\n"
	@echo -e "TESTS_OBJS: $(TESTS_OBJS)\n"
	@echo -e "TESTS_DEPS: $(TESTS_DEPS)\n"
	@echo -e "LIBS: $(LIBS)\n"

##=============================
## End of the Makefile
##=============================
