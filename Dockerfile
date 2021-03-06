FROM python:3

###############################################################################
# Install System Packages
###############################################################################

# Install system packages
RUN apt-get update && apt-get install -y \
    git \
    make \
    screen


###############################################################################
# Clone the micropython repository
###############################################################################

WORKDIR /app/
RUN git clone https://github.com/derekenos/micropython --branch=1.13


###############################################################################
# Set up ESP-IDF
###############################################################################

# Set up the toolchain and ESP-IDF
# https://github.com/micropython/micropython/tree/master/ports/esp32#setting-up-the-toolchain-and-esp-idf

# Set up the Espressif IDF (IoT development framework, aka SDK)
WORKDIR /app/esp

# https://www.reddit.com/r/esp32/comments/5f1emg/esp_idf_make_menuconfig_problem/dagqcjf
RUN git clone https://github.com/espressif/esp-idf.git

WORKDIR esp-idf

RUN git checkout `make -f /app/micropython/ports/esp32/Makefile BOARD_DIR=/app/micropython/ports/esp32/boards/GENERIC 2>&1 | grep Supported\ git\ hash | grep -o -P -m1 '\w+$'`

RUN git submodule update --init --recursive

# https://docs.espressif.com/projects/esp-idf/en/latest/get-started/index.html#install-the-required-python-packages
RUN pip install -r requirements.txt

RUN echo export IDF_PATH="/app/esp/esp-idf" >> ~/.bashrc \
    && exec bash

# Set up the Xtensa cross-compiler
RUN apt-get install -y \
    gcc \
    git \
    wget \
    make \
    libncurses-dev \
    flex \
    bison \
    gperf \
    python \
    python-pip \
    python-setuptools \
    python-serial \
    python-cryptography \
    python-future \
    python-pyparsing

WORKDIR /app/esp

RUN wget --quiet https://dl.espressif.com/dl/xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz \
    && tar -xzf xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz \
    && rm xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz

ENV PATH=$PATH:/app/esp/xtensa-esp32-elf/bin

RUN echo export PATH="$PATH:/app/esp/xtensa-esp32-elf/bin" >> ~/.bashrc\
    && exec bash


###############################################################################
# Build Micropython
###############################################################################

# Build the firmare
# https://github.com/micropython/micropython/tree/master/ports/esp32#building-the-firmware
WORKDIR /app/micropython

# Build the cross compiler.
RUN make -C mpy-cross \
    && git submodule update --init --recursive
RUN echo 'function freeze(){ /app/micropython/mpy-cross/mpy-cross $1;  '\
    'chown `stat -c%u $1` ${1%%.*}.mpy; }' >>  ~/.bashrc

# Build the desired ports.
WORKDIR ports

# Unix
WORKDIR unix
RUN make

# ESP32
WORKDIR ../esp32
ENV ESPIDF="/app/esp/esp-idf"
RUN echo export ESPIDF="/app/esp/esp-idf" >> ~/.bashrc \
    && exec bash
RUN make


###############################################################################
# Install Device Management Utilities
###############################################################################

ARG DEVICE_PORT=/dev/ttyUSB0

RUN echo export DEVICE_PORT=$DEVICE_PORT >>  ~/.bashrc

# Install Adafruit ampy utility for interacting with the pyboard filesystem.
RUN pip install adafruit-ampy
RUN echo export AMPY_PORT=$DEVICE_PORT >>  ~/.bashrc


# Install esptool
RUN pip install esptool
RUN echo export ESPTOOL_PORT=$DEVICE_PORT >>  ~/.bashrc
RUN echo export ESPTOOL_BAUD=460800 >>  ~/.bashrc


###############################################################################
# Copy Custom Scripts
###############################################################################

WORKDIR /app

RUN mkdir scripts
COPY scripts scripts


###############################################################################
# Set defaut image command
###############################################################################

CMD ["/bin/bash"]
