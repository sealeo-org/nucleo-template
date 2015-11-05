#ifndef QEI_H
#define QEI_H

#include "platform.h"

#if DEVICE_QEI
#include "qei_api.h"

namespace mbed {

class QEI {

public:

    QEI(PinName T1, PinName T2, int offset = 32768) :
        _offset(offset){
        qei_init(&_qei, T1, T2);
    }

    void write(int tick) {
        qei_write(&_qei, tick + _offset);
    }

    void reset() {
        qei_write(&_qei, _offset);
    }

    int read() const {
        return qei_read(&_qei) - _offset;
    }

#ifdef MBED_OPERATORS
    /** A operator shorthand for write()
     */
    QEI& operator= (int tick) {
        write(tick);
        return *this;
    }

    QEI& operator= (QEI& rhs) {
        write(rhs.read());
        return *this;
    }

    /** An operator shorthand for read()
     */
    operator int() const {
        return read();
    }
#endif

protected:
    qei_t _qei;
    int _offset;
};

} // namespace mbed

#endif

#endif
