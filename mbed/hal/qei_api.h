#ifndef QEI_API_H
#define QEI_API_H

#include "device.h"

#if DEVICE_QEI

#ifdef __cplusplus
extern "C" {
#endif

typedef struct qei_s qei_t;

void qei_init(qei_t* obj, PinName T1, PinName T2);
void qei_free(qei_t* obj);

void  qei_write(qei_t* obj, unsigned int tick);
unsigned int qei_read(const qei_t* obj);

#ifdef __cplusplus
}
#endif

#endif

#endif
