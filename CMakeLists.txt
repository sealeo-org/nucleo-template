set(CMAKE_C_COMPILER          /usr/bin/arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER        /usr/bin/arm-none-eabi-g++)
set(CMAKE_ASM_COMPILER        /usr/bin/arm-none-eabi-as)
set(OBJCOPY             			/usr/bin/arm-none-eabi-objcopy)

SET(CMAKE_C_COMPILER_FORCED true)
SET(CMAKE_CXX_COMPILER_FORCED true)

cmake_minimum_required(VERSION 3.4)
get_filename_component(project_name ${CMAKE_CURRENT_SOURCE_DIR} NAME)
project(${project_name})

# User configuration
set(ELF           ${project_name}.elf)
set(BIN           ${project_name}.bin)

## Nucleo configuration
set(NUCLEO        "F401RE")
set(DISKDIR       "/dev/disk/by-label")
set(LABEL         "NODE_${NUCLEO}")
set(UPLOAD_METHOD "disk") # {disk, jlink}

## Sources
set(UD_SRC        "")
set(UD_LIBSRC     "")
set(UD_INCLUDES   "")
set(UD_LDFLAGS    "")
set(UD_LDLIBS     "")

## Debugger
set(GDB_PORT      2331)

## Compiler
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

## C++
set(CXX_STANDARD  14)
set(UD_CXX_FLAGS  "")
set(UD_CXX_DEFS   "")

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

#####################
# MBED configuration
include(targets.cmake)

## Nucleo variables
set(TARGET_NAME   "TARGET_NUCLEO_${NUCLEO}")
set(TARGET_ID     "TARGET_STM32${NUCLEO_FAMILY}${NUCLEO_ID}")

set(NUCLEO_TARGET   "${CMAKE_CURRENT_SOURCE_DIR}/mbed/${TARGET_NAME}")
set(NUCLEO_STM      "${NUCLEO_TARGET}/TARGET_STM")
set(NUCLEO_STM_ID   "${NUCLEO_STM}/${TARGET_ID}")
set(NUCLEO_STM_XID  "${NUCLEO_STM_ID}/TARGET_STM32${NUCLEO_XID}")

set(LINKER_SCRIPT	${NUCLEO_TARGET}/TOOLCHAIN_GCC_ARM/${LDFILE})

## Compiler variables
set(MBED_CPU      "-mcpu=cortex-m${CORTEXM} -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=softfp")
set(MBED_CXXFLAGS "${MBED_CPU} -fmessage-length=0 -fno-exceptions -fno-builtin -ffunction-sections -fdata-sections -funsigned-char -fomit-frame-pointer -fno-rtti")

set(MBED_CXX_DEFS ${NUCLEO_FLAGS})

set(MBED_INCLUDES
	${CMAKE_CURRENT_SOURCE_DIR}/mbed
	${CMAKE_CURRENT_SOURCE_DIR}/mbed/drivers
	${CMAKE_CURRENT_SOURCE_DIR}/mbed/hal
	${CMAKE_CURRENT_SOURCE_DIR}/mbed/platform
	${NUCLEO_TARGET}
	${NUCLEO_STM}
	${NUCLEO_STM_ID}
	${NUCLEO_STM_XID}
	${NUCLEO_STM_XID}/${TARGET_NAME}
	${NUCLEO_STM_XID}/device
	${NUCLEO_STM_XID}/${TARGET_ID}
	${NUCLEO_STM_ID}/device
	${NUCLEO_TARGET}/TOOLCHAIN_GCC_ARM
)

set(MBED_LDFLAGS  "${MBED_CPU} -Wl,--gc-sections -Wl,--wrap,main -L${NUCLEO_TARGET}/TOOLCHAIN_GCC_ARM")
set(MBED_LDSYS    "-lstdc++ -lsupc++ -lc -lmbed -lgcc -lnosys")

file(GLOB_RECURSE MBED_OBJECTS ${NUCLEO_TARGET}/*.o)

# CXX configuration
set(CXX_FLAGS         "-Wall -Wextra -fdiagnostics-color=always ${MBED_CXXFLAGS} ${UD_CXX_FLAGS}")
set(CXX_FLAGS_DEBUG   "-DDEBUG -O0 -ggdb3 -pg")
set(CXX_FLAGS_RELEASE "-DNDEBUG -Os")
set(CXX_DEFINITIONS   "${MBED_CXX_DEFS} ${UD_CXX_DEFS}")

set(CXX_LIBRARIES     ${MBED_LDSYS} ${UD_LDLIBS})

# CMAKE configuration
set(CMAKE_CXX_STANDARD      ${CXX_STANDARD})
set(CMAKE_CXX_FLAGS         "${CMAKE_CXX_FLAGS} ${CXX_FLAGS} ${CXX_DEFINITIONS}")
set(CMAKE_CXX_FLAGS_DEBUG   "${CMAKE_CXX_FLAGS_DEBUG} ${CXX_FLAGS} ${CXX_DEFINITIONS} ${CXX_FLAGS_DEBUG}")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} ${CXX_FLAGS} ${CXX_DEFINITIONS} ${CXX_FLAGS_RELEASE}")

set(CMAKE_EXE_LINKER_FLAGS  "${CMAKE_EXE_LINKER_FLAGS} --specs=nosys.specs ${MBED_LDFLAGS} ${UD_LDFLAGS} -T${LINKER_SCRIPT}")

file(GLOB_RECURSE src ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)

add_executable(${ELF} ${src})
target_include_directories(${ELF} PUBLIC ${MBED_INCLUDES})

target_link_libraries(${ELF} PUBLIC ${MBED_OBJECTS})
target_link_libraries(${ELF} PUBLIC ${CXX_LIBRARIES})

add_custom_target(generate_bin ALL
	DEPENDS ${ELF}
	COMMAND bash -c "${OBJCOPY} -O binary ${ELF} ${BIN}")

set(DEVICE ${DISKDIR}/${LABEL})
if(EXISTS ${DEVICE})
	add_custom_target(upload
		DEPENDS generate_bin
		COMMAND mount ${DEVICE} /mnt && cp ${BIN} /mnt && sync && umount /mnt)
else()
	add_custom_target(upload
		DEPENDS generate_bin display_size
		COMMAND bash -c "echo !! error: nucleo not found")
endif()
