#include <DigitalOut.h>
#include <wait_api.h>

using mbed::DigitalOut;

int main() {
    DigitalOut led(LED1);
    for(;;) led = !led, wait(.5f);
}
