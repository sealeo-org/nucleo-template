#include "mbed_assert.h"
#include "qei_api.h"

#if DEVICE_QEI

#include <math.h>
#include "cmsis.h"
#include "pinmap.h"

static const PinMap PinMap_QEI_T1[] = {
    {PA_15, QEI_2, STM_PIN_DATA(STM_MODE_AF_PP, GPIO_PULLUP, GPIO_AF1_TIM2)},
    {PB_6,  QEI_4, STM_PIN_DATA(STM_MODE_AF_PP, GPIO_PULLUP, GPIO_AF2_TIM4)},
    {NC,    NC,    0}
};

static const PinMap PinMap_QEI_T2[] = {
    {PB_3,  QEI_2, STM_PIN_DATA(STM_MODE_AF_PP, GPIO_PULLUP, GPIO_AF1_TIM2)},
    {PB_7,  QEI_4, STM_PIN_DATA(STM_MODE_AF_PP, GPIO_PULLUP, GPIO_AF2_TIM4)},
    {NC,    NC,    0}
};

static TIM_HandleTypeDef QEIHandle;

static void init_qei(qei_t *obj) {
    QEIHandle.Instance = (TIM_TypeDef *)(obj->qei);

    __HAL_TIM_DISABLE(&QEIHandle);

    QEIHandle.Init.Period            = 0xFFFFFFFF;
    QEIHandle.Init.Prescaler         = 0;
    QEIHandle.Init.ClockDivision     = 0;
    QEIHandle.Init.CounterMode       = TIM_COUNTERMODE_UP;
    QEIHandle.Init.RepetitionCounter = 0;

    TIM_Encoder_InitTypeDef QEI_config;
    QEI_config.EncoderMode = TIM_ENCODERMODE_TI12;
    QEI_config.IC1Polarity = TIM_ICPOLARITY_RISING;
    QEI_config.IC2Polarity = TIM_ICPOLARITY_RISING;
    QEI_config.IC1Selection = TIM_ICSELECTION_DIRECTTI;
    QEI_config.IC2Selection = TIM_ICSELECTION_DIRECTTI;

    HAL_TIM_Encoder_Init(&QEIHandle, &QEI_config);

    __HAL_TIM_SetAutoreload(&QEIHandle, 0xffff);
    __HAL_TIM_ENABLE(&QEIHandle);

    HAL_TIM_Encoder_Start(&QEIHandle, 3);
}

void qei_init(qei_t *obj, PinName T1, PinName T2) {

    // Determine the QEI to use
    QEIName qei_t1 = (QEIName)pinmap_peripheral(T1, PinMap_QEI_T1);
    QEIName qei_t2 = (QEIName)pinmap_peripheral(T2, PinMap_QEI_T2);

    obj->qei = (QEIName)pinmap_merge(qei_t1, qei_t2);
    MBED_ASSERT(obj->qei != (QEIName)NC);

    // Configure the QEI pins
    if (obj->qei == QEI_2) {
        __TIM2_CLK_ENABLE();
    }
    if (obj->qei == QEI_4) {
        __TIM4_CLK_ENABLE();
    }

    // Configure the QEI pins
    pinmap_pinout(T1, PinMap_QEI_T1);
    pinmap_pinout(T2, PinMap_QEI_T2);
    pin_mode(T1, PullUp);
    pin_mode(T2, PullUp);

    obj->T1 = T1;
    obj->T2 = T2;

    init_qei(obj);
}

void qei_free(qei_t *obj) {
    // Reset QEI and disable clock
    if (obj->qei == QEI_2) {
        __TIM2_FORCE_RESET();
        __TIM2_RELEASE_RESET();
        __TIM2_CLK_DISABLE();
    }

    if (obj->qei == QEI_4) {
        __TIM4_FORCE_RESET();
        __TIM4_RELEASE_RESET();
        __TIM4_CLK_DISABLE();
    }

    // Configure GPIOs
    pin_function(obj->T1, STM_PIN_DATA(STM_MODE_INPUT, GPIO_NOPULL, 0));
    pin_function(obj->T2, STM_PIN_DATA(STM_MODE_INPUT, GPIO_NOPULL, 0));
}

void  qei_write(qei_t* obj, unsigned int tick)
{
    QEIHandle.Instance = (TIM_TypeDef *)(obj->qei);
    QEIHandle.Instance->CNT = tick;
}

unsigned int qei_read(const qei_t* obj)
{
    QEIHandle.Instance = (TIM_TypeDef *)(obj->qei);
    return QEIHandle.Instance->CNT;
}

#endif
