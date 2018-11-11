#include <AnalogIn.h>
#include <DigitalOut.h>
#include <Serial.h>
#include <mbed_wait_api.h>

int main() {
	mbed::DigitalOut led(LED1);
	mbed::AnalogIn in(A0);
	mbed::Serial usb(USBTX, USBRX);

	for(;;) {
		led = !led;
		usb.printf("Hello world! (%f)\n", in.read());
		wait(0.5f);
	}
}
