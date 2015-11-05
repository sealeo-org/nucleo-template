Firmware
========

MAINTAINERS
-----------

* Gérald Lelong (ISIBOT - 2013-2015)
* Pierre Guinault (ISIBOT - 2015-2016)
* Alexis Pereda (ISIBOT - 2015-2016)

REQUIREMENTS
-----------

* Compilateur arm gcc (>= 4.8)
  `sudo apt-get install gcc-arm-none-eabi` on ubuntu
  You may need to add a repository with the following command on old ubuntu version : `sudo add-apt-repository ppa:terry.guo/gcc-arm-embedded`

* make
  Chances are you already have it on your computer but otherwise install it with : `sudo apt-get install build-essential` on ubuntu

RECOMMENDED MODULES
-------------------

* openocd

  Its main feature is to allow you to debug your program while running on the Nucleo board

  1. Download sources from [sourceforge](http://sourceforge.net/projects/openocd/files/latest/download?source=files)
  2. Configure the build with `./configure --enable-ftdi --enable-stlink`
  3. Resolve missing dependencies if needed
  4. `make && sudo make install`
  5. Copy *st_nucleo_f401re.cfg* from firmware folder to openocd board directory (*/usr/local/share/openocd/scripts/board*)

* ledit
  `sudo apt-get install ledit` on ubuntu
  Install it if you want to use the *firm* script described in **Communication** section

USAGE WITH DOCKER
-----------------

1. Build your docker : `docker build --rm=true -t firmware .`
2. Run with `docker run --rm -v `pwd`:/firmware firmware make -C firmware bin`
3. Copy `build/nucleo.bin` to Nucleo drive
9. Your code is now running on the board

DEBUGGING
---------

*openocd* allow you to do ICD (In-Circuit Debugging).

If you have it installed you just have to run `arm-none-eabi-gdb ./build/nucleo.elf` from the main folder.
Depending on your *gdb* configuration it may warn you about automatic configuration file loading.
You should allow *gdb* to load the *.gdbinit* file in main folder at startup, so follow the guidelines given by *gdb*.

Main useful commands from gdb shell are :
  * `monitor reset halt` to stop the program execution
  * `monitor reset run` to run the program on the board
  * `flash nucleo` to rebuild and flash the binary
  * `build` to rebuild and flash the binary

When the program is stopped you can input usual *gdb* commands (`break`, `where`, ...).
