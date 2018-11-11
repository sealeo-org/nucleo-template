cmake_minimum_required(VERSION 3.4)

set(ARM_PATH )
set(CMAKE_C_COMPILER    ${ARM_PATH}arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER  ${ARM_PATH}arm-none-eabi-g++)
set(CMAKE_ASM_COMPILER  ${ARM_PATH}arm-none-eabi-as)
set(OBJCOPY             ${ARM_PATH}arm-none-eabi-objcopy)

SET(CMAKE_C_COMPILER_FORCED true)
SET(CMAKE_CXX_COMPILER_FORCED true)

get_filename_component(project_name ${CMAKE_CURRENT_SOURCE_DIR} NAME)
project(${project_name})

# User configuration
set(ELF           ${project_name}.elf)
set(BIN           ${project_name}.bin)

## Nucleo configuration
set(NUCLEO        "L432KC")
set(DISKDIR       "/dev/disk/by-label")
set(LABEL         "NODE_${NUCLEO}")
set(UPLOAD_METHOD "disk") # {disk, jlink}

## Sources
set(UD_SRC        )
set(UD_LIBSRC     )
set(UD_INCLUDES   )
set(UD_LDFLAGS    )
set(UD_LDLIBS     )

## Debugger
set(GDB_PORT      2331)

## Compiler
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

## C++
set(CXX_STANDARD  14)
set(UD_CXX_FLAGS  )
set(UD_CXX_DEFS   )

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

#####################
# MBED configuration
#####################
include(targets.cmake)

file(GLOB_RECURSE src ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)

add_executable(${ELF} 
	${src} 
	${UD_SRC}
)

## Compiler variables
set(MBED_CPU
	-mcpu=cortex-m${CORTEXM} 
	-mthumb 
	-mfpu=fpv4-sp-d16 
	-mfloat-abi=softfp
)

target_compile_options(${ELF} PUBLIC
	-Wall
	-Wextra
	-fdiagnostics-color=always 

	-fmessage-length=0
	-fno-exceptions
	-fno-builtin
	-ffunction-sections 
	-fdata-sections 
	-funsigned-char
	-fno-delete-null-pointer-checks
	-fomit-frame-pointer 
	-fno-rtti

	${MBED_CPU}
	${UD_CXX_FLAGS}

	-include mbed_config.h

)

target_include_directories(${ELF} PUBLIC
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
	${UD_INCLUDES}
)

target_compile_definitions(${ELF} PUBLIC 
	${NUCLEO_FLAGS}
	${UD_CXX_DEFS}
	$<$<CONFIG:Release>:NDEBUG>
	$<$<CONFIG:Debug>:DEBUG>
)


target_link_libraries(${ELF} PUBLIC 
	${MBED_OBJECTS}

	${MBED_CPU} 
	-Wl,--gc-sections 
	-Wl,--wrap,main
	${UD_LDFLAGS}
#	--specs=nosys.specs 

	-T${LINKER_SCRIPT}
	-L${NUCLEO_TARGET}/TOOLCHAIN_GCC_ARM

	-lmbed 
	-Wl,--start-group 
	-lstdc++ 
	-lsupc++ 
	-lm 
	-lc 
	-lgcc 
	-lnosys 
	-lmbed 
	-Wl,--end-group

	${UD_LDLIBS}
)

set(CMAKE_CXX_STANDARD      ${CXX_STANDARD})
set(CMAKE_CXX_FLAGS_DEBUG   "-O0 -ggdb3 -pg")
set(CMAKE_CXX_FLAGS_RELEASE "-Os")

target_link_libraries(${ELF} PUBLIC ${CXX_LIBRARIES})

add_custom_target(generate_bin ALL
	DEPENDS ${ELF}
	COMMAND bash -c "${OBJCOPY} -O binary ${ELF} ${BIN}")

set(DEVICE ${DISKDIR}/${LABEL})
if(EXISTS ${DEVICE})
	add_custom_target(upload
		DEPENDS generate_bin display_size
		COMMAND mount ${DEVICE} /mnt && cp ${BIN} /mnt && sync && umount /mnt)
else()
	add_custom_target(upload
		DEPENDS generate_bin display_size
		COMMAND bash -c "echo !! error: nucleo not found")
endif()
