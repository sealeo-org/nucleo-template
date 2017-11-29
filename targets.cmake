set(FLASHSIZE 0)
set(RAMSIZE   0)

execute_process(COMMAND bash -c "echo ${NUCLEO}|cut -c2" OUTPUT_VARIABLE NUCLEO_ID)
string(STRIP ${NUCLEO_ID} NUCLEO_ID)

if(${NUCLEO} MATCHES "^F303K8$")
  set(FLASHSIZE 65536)
  set(RAMSIZE   16384)
  set(CORTEXM   4)
  set(LDFILE    STM32F303X8.ld)
endif()

if(${NUCLEO} MATCHES "^F401CD$")
  set(FLASHSIZE 384000)
  set(RAMSIZE   98304)
  set(CORTEXM   4)
  set(LDFILE    STM32F401XD.ld)
endif()

if(${NUCLEO} MATCHES "^F401RE$")
  set(FLASHSIZE 524288)
  set(RAMSIZE   98304)
  set(CORTEXM   4)
  set(LDFILE    STM32F401XE.ld)
endif()

if(${FLASHSIZE} MATCHES "^0$")
  message(FATAL_ERROR "[sealeo/nucleo-template] Invalid target ${NUCLEO}")
endif()

add_custom_target(display_size ALL COMMAND bash -c "${CMAKE_CURRENT_SOURCE_DIR}/size_info ${ELF} ${FLASHSIZE} ${RAMSIZE}")
