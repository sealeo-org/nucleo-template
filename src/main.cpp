#include <Serial.h>
#include <DigitalOut.h>
#include <wait_api.h>

int main() {
	using namespace mbed;

	DigitalOut led(LED3);
	Serial usb(USBTX, USBRX);
	for(;;) {
		led = !led;
		wait(1.5f);
	}
}
