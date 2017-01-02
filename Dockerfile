FROM nfnty/arch-mini:latest
MAINTAINER Alexis Pereda <alexis@pereda.fr>

RUN pacman --noconfirm -Sy archlinux-keyring
RUN pacman --noconfirm -Syu
RUN pacman --noconfirm -S arm-none-eabi-gcc arm-none-eabi-newlib make cmake
RUN pacman --noconfirm -S util-linux

# Build with 'docker build --rm -t nucleo .'
