/* mbed Microcontroller Library
 * Copyright (c) 2017 ARM Limited
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef MBED_MBED_RTX_H
#define MBED_MBED_RTX_H

#ifndef INITIAL_SP

#if (defined(TARGET_STM32F051R8) ||\
     defined(TARGET_STM32F100RB) ||\
     defined(TARGET_STM32L031K6) ||\
     defined(TARGET_STM32L053C8) ||\
     defined(TARGET_STM32L053R8))
#define INITIAL_SP              (0x20002000UL)

#elif (defined(TARGET_STM32F303K8) ||\
       defined(TARGET_STM32F334C8) ||\
       defined(TARGET_STM32F334R8))
#define INITIAL_SP              (0x20003000UL)

#elif (defined(TARGET_STM32F070RB) ||\
       defined(TARGET_STM32F072RB) ||\
       defined(TARGET_STM32F302R8))
#define INITIAL_SP              (0x20004000UL)

#elif (defined(TARGET_STM32F103RB) ||\
       defined(TARGET_STM32F103C8) ||\
       defined(TARGET_STM32L072CZ) ||\
       defined(TARGET_STM32L073RZ))
#define INITIAL_SP              (0x20005000UL)

#elif (defined(TARGET_STM32F091RC) ||\
       defined(TARGET_STM32F410RB) ||\
       defined(TARGET_STM32L151CC) ||\
       defined(TARGET_STM32L151RC) ||\
       defined(TARGET_STM32L152RC))
#define INITIAL_SP              (0x20008000UL)

#elif defined(TARGET_STM32F303VC)
#define INITIAL_SP              (0x2000A000UL)

#elif defined(TARGET_STM32L432KC)
#define INITIAL_SP              (0x20010000UL)

#elif (defined(TARGET_STM32F303RE) ||\
       defined(TARGET_STM32F303ZE) ||\
       defined(TARGET_STM32F401VC))
#define INITIAL_SP              (0x20010000UL)

#elif defined(TARGET_STM32L152RE)
#define INITIAL_SP              (0x20014000UL)

#elif (defined(TARGET_STM32F401RE) ||\
       defined(TARGET_STM32L475VG) ||\
       defined(TARGET_STM32L476RG) ||\
       defined(TARGET_STM32L476JG) ||\
       defined(TARGET_STM32L476VG) ||\
       defined(TARGET_STM32L486RG))
#define INITIAL_SP              (0x20018000UL)

#elif (defined(TARGET_STM32F207ZG) ||\
       defined(TARGET_STM32F405RG) ||\
       defined(TARGET_STM32F407VG) ||\
       defined(TARGET_STM32F411RE) ||\
       defined(TARGET_STM32F446RE) ||\
       defined(TARGET_STM32F446VE) ||\
       defined(TARGET_STM32F446ZE))
#define INITIAL_SP              (0x20020000UL)

#elif (defined(TARGET_STM32F429ZI) ||\
       defined(TARGET_STM32F437VG) ||\
       defined(TARGET_STM32F439ZI))
#define INITIAL_SP              (0x20030000UL)

#elif defined(TARGET_STM32F412ZG)
#define INITIAL_SP              (0x20040000UL)

#elif (defined(TARGET_STM32F413ZH) ||\
       defined(TARGET_STM32F469NI) ||\
       defined(TARGET_STM32F746NG) ||\
       defined(TARGET_STM32F746ZG) ||\
       defined(TARGET_STM32F756ZG))
#define INITIAL_SP              (0x20050000UL)

#elif (defined(TARGET_STM32F767ZI) ||\
       defined(TARGET_STM32F769NI))
#define INITIAL_SP              (0x20080000UL)

#else
#error "INITIAL_SP is not defined for this target in the mbed_rtx.h file"
#endif

#endif // INITIAL_SP

#endif  // MBED_MBED_RTX_H
