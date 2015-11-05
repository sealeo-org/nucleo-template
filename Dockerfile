FROM ubuntu:14.04
MAINTAINER Lelong Gérald

# Install required and recommended packages from repository
RUN apt update
RUN apt install -y build-essential software-properties-common ledit libusb-1.0-0-dev pkg-config

# Install openocd
WORKDIR /
ADD http://ufpr.dl.sourceforge.net/project/openocd/openocd/0.8.0/openocd-0.8.0.tar.bz2 openocd-0.8.0.tar.bz2
RUN tar jxf openocd-0.8.0.tar.bz2

WORKDIR openocd-0.8.0
RUN ./configure --enable-ftdi --enable-stlink && \
    make && \
    make install

WORKDIR /
RUN rm -Rf openocd-0.8.0.tar.bz2 openocd-0.8.0
RUN ls /usr/local/share/openocd/scripts/board
COPY st_nucleo_f401re.cfg /usr/local/share/openocd/scripts/board/

# Install arm compiler from special repository
# (Confirmed bug in official one : https://bugs.launchpad.net/ubuntu/+source/gcc-arm-none-eabi/+bug/1293024)

RUN add-apt-repository -y ppa:terry.guo/gcc-arm-embedded
RUN apt update
RUN apt install -y gcc-arm-none-eabi

# Configure gdb
COPY .gdbinit /root/.gdbinit

# Configure openocd
COPY .openocd.cfg /openocd.cfg

# Build with 'docker build --rm=true -t firmware .'
# Run with 'docker run --rm -v `pwd`:/firmware firmware make -C firmware bin'
# Copy 'build/nucleo.bin' to Nucleo drive

# Run with 'docker run --rm --device=/dev/ttyUSB0 -v `pwd`:/firmware firmware ./fimware/firm' to use 'firm'
# (Change '/dev/ttyUSB0' to match your Nucleo device and check 'README.txt' for details on 'firm')