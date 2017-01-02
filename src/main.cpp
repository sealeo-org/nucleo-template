#include <Serial.h>
#include <DigitalOut.h>
#include <wait_api.h>

int main() {
	using namespace mbed;

	DigitalOut led(LED1);
	Serial usb(USBTX, USBRX);
	for(;;) led = !led, wait(.5f);
}
