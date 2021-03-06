FROM phusion/baseimage as cc
RUN apt-get update \
    && apt-get -y --allow-unauthenticated install \
    gcc \
    libcurl4-gnutls-dev \
    tesseract-ocr \
    libtesseract-dev \
    libleptonica-dev \
    autoconf \
    pkg-config \
    wget

ARG VERSION="0.88"
WORKDIR /ccextractor
RUN wget -O ccextractor-${VERSION} https://github.com/CCExtractor/ccextractor/archive/v${VERSION}.tar.gz \
    && tar xvzf ccextractor-${VERSION} \
    && cd ccextractor-${VERSION}/linux \
    && ./autogen.sh \
    && ./configure \
    && make \
    && cp ccextractor /usr/local/bin/ccextractor


FROM cc

# Set correct environment variables
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Configure user nobody to match unRAID's settings
 RUN \
 usermod -u 99 nobody && \
 usermod -g 100 nobody && \
 usermod -d /home nobody && \
 chown -R nobody:users /home

# Disable SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Move Files
COPY root/ /
RUN chmod +x /etc/my_init.d/*.sh

# Install software
RUN apt-get update \
 && apt-get -y --allow-unauthenticated install gddrescue ripit wget eject lame curl git
 
# MakeMKV/FFMPEG setup by github.com/tobbenb
RUN chmod +x /tmp/install/install.sh && sleep 1 && /tmp/install/install.sh && rm -r /tmp/install
