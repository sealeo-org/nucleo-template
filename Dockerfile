FROM nfnty/arch-mini:latest
MAINTAINER Alexis Pereda <alexis@pereda.fr>

RUN echo -e '[archlinuxfr]\n\
SigLevel = Never\n\
Server = http://repo.archlinux.fr/$arch'\
>> /etc/pacman.conf

RUN pacman --noconfirm -Sy archlinux-keyring
RUN pacman --noconfirm -Syu
RUN pacman --noconfirm -S arm-none-eabi-gcc arm-none-eabi-newlib make cmake
RUN pacman --noconfirm -S util-linux binutils wget yaourt awk
RUN pacman --noconfirm -S sudo file fakeroot 

RUN pacman -Scc --noconfirm && \
    sudo ln -sv /usr/bin/core_perl/pod2man /usr/sbin && \
    sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Add user, group sudo; switch to user
RUN groupadd --system sudo && \
    useradd -m --groups sudo user
USER user 

RUN yaourt --noconfirm -S jlink
USER root

ADD tools/gen-jlink /usr/bin/
