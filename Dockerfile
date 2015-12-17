FROM debian:8.2
MAINTAINER Alexis Pereda

# Install required and recommended packages from repository
RUN echo "deb http://http.debian.net/debian jessie-backports main">/etc/apt/sources.list.d/backports.list
RUN apt update && apt install -tjessie-backports -y \
    build-essential software-properties-common ledit    \
    libusb-1.0-0-dev pkg-config gcc-arm-none-eabi       \
&&  rm -rf /var/lib/apt/lists/*

# Install openocd
WORKDIR /
ADD http://ufpr.dl.sourceforge.net/project/openocd/openocd/0.9.0/openocd-0.9.0.tar.bz2 openocd-0.9.0.tar.bz2
RUN tar jxf openocd-0.9.0.tar.bz2

WORKDIR openocd-0.9.0
RUN ./configure --enable-ftdi --enable-stlink && make && make install

WORKDIR /
RUN rm -rf openocd-0.9.0.tar.bz2 openocd-0.9.0
RUN ls /usr/local/share/openocd/scripts/board
COPY st_nucleo_f401re.cfg /usr/local/share/openocd/scripts/board/
COPY .gdbinit /root/.gdbinit
COPY .openocd.cfg /openocd.cfg

# Build with 'docker build --rm=true -t nucleo .'
