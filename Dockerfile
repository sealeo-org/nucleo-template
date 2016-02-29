FROM debian:8.2
MAINTAINER Alexis Pereda

RUN echo "deb http://http.debian.net/debian jessie-backports main">/etc/apt/sources.list.d/backports.list
RUN apt update && apt install -tjessie-backports -y build-essential software-properties-common ledit libusb-1.0-0-dev pkg-config gcc-arm-none-eabi && rm -rf /var/lib/apt/lists/*

# Build with 'docker build --rm=true -t nucleo .'
