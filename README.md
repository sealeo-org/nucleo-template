Using nucleo-template:
* install Docker
* docker build -t nucleo .
* tools/clone NAME # this will create a project in the parent directory

Should you want to use OpenOCD:
* wget http://ufpr.dl.sourceforge.net/project/openocd/openocd/0.9.0/openocd-0.9.0.tar.bz2 -Oopenocd-0.9.0.tar.bz2
* tar jxf openocd-0.9.0.tar.bz2
* cd openocd-0.9.0
* ./configure --enable-ftdi --enable-stlink && make && sudo make install
* sudo cp tools/st_nucleo_f401re.cfg /usr/local/share/openocd/scripts/board/

OR
* aptitude install openocd

See tools directory
