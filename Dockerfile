# https://docs.docker.com/develop/develop-images/dockerfile_best-practices/

FROM python:3

# Install required system packages
RUN apt-get update && apt-get install -y \
    git \
    make \
    screen

# Clone micropython
WORKDIR /usr/src/app

RUN git clone https://github.com/micropython/micropython.git


# Set up the toolchain and ESP-IDF
# https://github.com/micropython/micropython/tree/master/ports/esp32#setting-up-the-toolchain-and-esp-idf

# Set up the Espressif IDF (IoT development framework, aka SDK)
WORKDIR /usr/src/app/esp

# https://www.reddit.com/r/esp32/comments/5f1emg/esp_idf_make_menuconfig_problem/dagqcjf
RUN git clone --recursive https://github.com/espressif/esp-idf.git

WORKDIR esp-idf

RUN git checkout `make -f /usr/src/app/micropython/ports/esp32/Makefile 2>&1 | grep Supported\ git\ hash | grep -o -P '\w+$'`

RUN git submodule update --init --recursive

# https://docs.espressif.com/projects/esp-idf/en/latest/get-started/index.html#install-the-required-python-packages
RUN pip install -r requirements.txt

RUN echo export IDF_PATH="/usr/src/app/esp/esp-idf" >> ~/.bashrc \
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

WORKDIR /usr/src/app/esp

RUN wget --quiet https://dl.espressif.com/dl/xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz \
    && tar -xzf xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz \
    && rm xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz

ENV PATH=$PATH:/usr/src/app/esp/xtensa-esp32-elf/bin

RUN echo export PATH="$PATH:/usr/src/app/esp/xtensa-esp32-elf/bin" >> ~/.bashrc\
    && exec bash


# Build the firmare
# https://github.com/micropython/micropython/tree/master/ports/esp32#building-the-firmware
WORKDIR /usr/src/app/micropython

# RUN git submodule update --init # commented out 20190218

RUN make -C mpy-cross \
    && git submodule init lib/berkeley-db-1.xx \
    && git submodule update

WORKDIR ports/esp32

ENV ESPIDF="/usr/src/app/esp/esp-idf"

RUN echo export ESPIDF="/usr/src/app/esp/esp-idf" >> ~/.bashrc \
    && exec bash
RUN make

# Install Adafruit ampy utility for interacting with the pyboard filesystem.
RUN pip install adafruit-ampy
RUN echo export AMPY_PORT="/dev/ttyUSB0" >>  ~/.bashrc

WORKDIR /usr/src/app

ENTRYPOINT ["make", "--directory=/usr/src/app/micropython/ports/esp32"]
