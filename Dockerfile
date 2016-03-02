FROM debian:8.2
MAINTAINER Alexis Pereda

RUN echo "deb http://http.debian.net/debian jessie-backports main">/etc/apt/sources.list.d/backports.list
RUN apt-get update && apt-get upgrade -y && apt-get install -tjessie-backports -y build-essential gcc-arm-none-eabi && rm -rf /var/lib/apt/lists/*

# Build with 'docker build --rm -t nucleo .'
