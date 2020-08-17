FROM python:3

###############################################################################
# Install System Packages
###############################################################################

# Install system packages
RUN apt-get update && apt-get install -y \
    screen


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
