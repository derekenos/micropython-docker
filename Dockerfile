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
# Set up ESP-IDF
###############################################################################

# Set up the toolchain and ESP-IDF
# https://github.com/micropython/micropython/tree/master/ports/esp32#setting-up-esp-idf-and-the-build-environment

# Set up the Espressif IDF (IoT development framework, aka SDK)
WORKDIR /app/esp
RUN git clone -b v5.5.1 --recursive https://github.com/espressif/esp-idf.git
WORKDIR esp-idf
RUN git submodule update --init --recursive
RUN apt install -y libusb-1.0-0-dev
RUN ./install.sh esp32


###############################################################################
# Build Micropython
###############################################################################

WORKDIR /app/
RUN git clone --depth=1 --branch=v1.27.0 https://github.com/derekenos/micropython
WORKDIR micropython
RUN make -C mpy-cross

# Unix
WORKDIR ports/unix
RUN make submodules
RUN make

# ESP32
WORKDIR ../esp32
RUN apt install -y cmake
RUN cd /app/esp/esp-idf && . ./export.sh && cd /app/micropython/ports/esp32 && make submodules && make

# Define freeze shell function
RUN echo 'function freeze(){ /app/micropython/mpy-cross/mpy-cross $1;  '\
    'chown `stat -c%u $1` ${1%%.*}.mpy; }' >>  ~/.bashrc


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
